unit uGroupMembership;

interface

uses
  System.Classes, System.Generics.Collections, System.SysUtils, uGroupMembershipAPI;

type
  TGroup = class;
  TMember = class;

  TGroupMembership = class
  private
    FGroups: TStringList;
    procedure Send(const AHostName: string; const APort: Word; const AMessage: string);
    function GetGroup(Name: string): TGroup;
  public
    constructor Create;
    destructor Destroy; override;

    procedure CreateGroup(AName: string; const ALimit: Integer = GROUP_UNLIMITED;
      const AAccess: TGroupAccess = gaOpen; const APermissions: string = '');
    procedure DestroyGroup(const AName: string);

    procedure Join(AMemberId, AMemberAddress: string; AMemberType: Byte; const AGroupName: string);
    procedure Leave(const AMemberId, AGroupName: string);
    procedure SendMessage(const AMemberId, AGroupName, AMessage: string);

    property Group[Name: string]: TGroup read GetGroup;
  end;

  TMember = class
  private
    FId: string;
    FKind: Word;
    FHostName: string;
    FPort: Word;
  public
    property Id: string read FId write FId;
    property Kind: Word read FKind write FKind;
    property HostName: string read FHostName write FHostName;
    property Port: Word read FPort write FPort;
  end;

  TGroup = class
  private
    FName: string;
    FLimit: Integer;
    FPermissions: TStringList;
    FAccess: TGroupAccess;
    FMembers: TStringList;
    function GetMember(Index: Integer): TMember;
  public
    constructor Create;
    destructor Destroy; override;
    property Name: string read FName write FName;
    property Limit: Integer read FLimit write FLimit;
    property Access: TGroupAccess read FAccess write FAccess;
    property Permissions: TStringList read FPermissions;

    property Members: TStringList read FMembers;
    property Member[Index: Integer]: TMember read GetMember;
  end;

  EGroupUndefined = class(Exception)
  public
    constructor Create;
  end;

  EGroupDuplicated = class(Exception)
  public
    constructor Create;
  end;

  EGroupNotExists = class(Exception)
  public
    constructor Create;
  end;

  EGroupLimitExceeded = class(Exception)
  public
    constructor Create;
  end;

  EMemberPermission = class(Exception)
  public
    constructor Create;
  end;

implementation

uses
  Winapi.Windows, IdGlobal;

{ TGroupMembership }

constructor TGroupMembership.Create;
begin
  FGroups := TStringList.Create;
  FGroups.Sorted := True;
  FGroups.Duplicates := dupError;
end;

procedure TGroupMembership.CreateGroup(AName: string; const ALimit: Integer; const AAccess: TGroupAccess;
  const APermissions: string);
var
  NewGroup: TGroup;
begin
  AName := Trim(AName);
  if AName = '' then
    raise EGroupUndefined.Create;

  if FGroups.IndexOf(AName) <> -1 then
    raise EGroupDuplicated.Create;

  NewGroup := TGroup.Create;
  NewGroup.Name := AName;
  NewGroup.Limit := ALimit;
  NewGroup.Access := AAccess;
  if AAccess = gaRestrict then
    NewGroup.Permissions.CommaText := APermissions;

  FGroups.AddObject(AName, NewGroup)
end;

destructor TGroupMembership.Destroy;
begin
  FreeAndNil(FGroups);
  inherited;
end;

procedure TGroupMembership.DestroyGroup(const AName: string);
var
  Index: Integer;
begin
  if FGroups.Find(AName, Index) then
  begin
    FGroups.Objects[Index].Free;
    FGroups.Delete(Index);
  end;
end;

function TGroupMembership.GetGroup(Name: string): TGroup;
var
  Index: Integer;
begin
  if FGroups.Find(Name, Index) then
    Result := TGroup(FGroups.Objects[Index])
  else
    raise EGroupNotExists.Create;
end;

procedure TGroupMembership.Join(AMemberId, AMemberAddress: string; AMemberType: Byte; const AGroupName: string);
var
  Index: Integer;
  Group: TGroup;
  Member: TMember;
begin
  if not FGroups.Find(AGroupName, Index) then
    raise EGroupNotExists.Create;

  Group := TGroup(FGroups.Objects[Index]);

  // check if member belongs to group
  if Group.Members.IndexOf(AMemberId) <> -1 then
    Exit;

  // check limits of group
  if (Group.Limit <> GROUP_UNLIMITED) and (Group.Limit = Group.Members.Count) then
    raise EGroupLimitExceeded.Create;

  Member := TMember.Create;
  Member.Id := AMemberId;
  Member.Kind := AMemberType;
  Member.HostName := Fetch(AMemberAddress, ':');
  Member.Port := StrToInt(AMemberAddress);

  Group.Members.AddObject(AMemberId, Member);
end;

procedure TGroupMembership.Leave(const AMemberId, AGroupName: string);
var
  IndexGroup: Integer;
  IndexMember: Integer;
  Group: TGroup;
begin
  if not FGroups.Find(AGroupName, IndexGroup) then
    raise EGroupNotExists.Create;

  Group := TGroup(FGroups.Objects[IndexGroup]);

  if Group.Members.Find(AMemberId, IndexMember) then
  begin
    Group.Members.Objects[IndexMember].Free;
    Group.Members.Delete(IndexMember);
  end;
end;

procedure TGroupMembership.Send(const AHostName: string; const APort: Word; const AMessage: string);
var
  Msg: string;
begin
  Msg := Format('%s:%d %s', [AHostName, APort, AMessage]);
  OutputDebugString(PChar(Msg));
end;

procedure TGroupMembership.SendMessage(const AMemberId, AGroupName, AMessage: string);
var
  Index: Integer;
  GroupDest: TGroup;
  MemberHasPermission: Boolean;
  MemberDest: TMember;
  i: Integer;

  function CheckPermissions: Boolean;
  var
    Permission: string;
    GroupPermission: TGroup;
  begin
    Result := False;

    // for each permission, check if member belongs to least one of them
    for Permission in GroupDest.Permissions do
    begin
      if FGroups.Find(AGroupName, Index) then
      begin
        GroupPermission := TGroup(FGroups.Objects[Index]);
        Result := (GroupPermission.Members.IndexOf(AMemberId) <> -1);
        if Result then
          Break;
      end;
    end;
  end;

begin
  if not FGroups.Find(AGroupName, Index) then
    raise EGroupNotExists.Create;

  GroupDest := TGroup(FGroups.Objects[Index]);

  case GroupDest.Access of
    gaOpen: MemberHasPermission := True;
    gaClosed: MemberHasPermission := (GroupDest.Members.IndexOf(AMemberId) <> -1);
    gaRestrict: MemberHasPermission := CheckPermissions;
  else
    MemberHasPermission := False;
  end;
  if not MemberHasPermission then
    raise EMemberPermission.Create;

  // broadcast message to members group
  for i := 0 to GroupDest.Members.Count - 1 do
  begin
    MemberDest := TMember(GroupDest.Members.Objects[i]);
    Send(MemberDest.HostName, MemberDest.Port, AMessage);
  end;
end;

{ TGroup }

constructor TGroup.Create;
begin
  FMembers := TStringList.Create;
  FMembers.Sorted := True;
  FMembers.Duplicates := dupError;

  FPermissions := TStringList.Create;
  FPermissions.Sorted := True;
  FPermissions.Duplicates := dupIgnore;
end;

destructor TGroup.Destroy;
begin
  FreeAndNil(FMembers);
  FreeAndNil(FPermissions);
  inherited;
end;

function TGroup.GetMember(Index: Integer): TMember;
begin
  Result := TMember(FMembers.Objects[Index])
end;

{ EGroupUndefined }

constructor EGroupUndefined.Create;
begin
  inherited Create('Group name must be defined.');
end;

{ EGroupDuplicated }

constructor EGroupDuplicated.Create;
begin
  inherited Create('Group name already exists.');
end;

{ EGroupNotExists }

constructor EGroupNotExists.Create;
begin
  inherited Create('Group does not exists.');
end;

{ EGroupLimitExceeded }

constructor EGroupLimitExceeded.Create;
begin
  inherited Create('Group limit exceeded.');
end;

{ EMemberPermission }

constructor EMemberPermission.Create;
begin
  inherited Create('Member does not have permission to send message to this group.');
end;

end.
