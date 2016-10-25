unit uGMS.Manager;

interface

uses
  System.Classes, uGMS.Group, uGMS.Member;

type
  TManager = class
  private
    FGroups: TStringList;
    function GetGroup(Name: string): TGroup;
    function Send(const AHostName: string; const APort: Word; const AMessage: string): string;
    function CheckStatus(AMember: TMember): Boolean;
    procedure DestroyGroups;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateGroup(AName: string; const ALimit: Integer = GROUP_UNLIMITED;
      const AAccess: TGroupAccess = gaOpen; const APermissions: string = ''): TGroup;
    procedure DestroyGroup(const AName: string);

    procedure Join(const AMemberId, AMemberAddress: string; AMemberType: Byte; const AGroupName: string);
    procedure Leave(const AMemberId, AGroupName: string);
    procedure RemoveMembersInactive;
    function SendMessage(const ASenderId, AGroupName, AMessage: string): string;

    property Group[Name: string]: TGroup read GetGroup;
  end;

implementation

uses
  System.SysUtils, IdGlobal, Winapi.Windows, Data.SqlExpr, uGMS.Exceptions, uSequencerClient;

{ TGroupMembership }

constructor TManager.Create;
begin
  FGroups := TStringList.Create;
  FGroups.Sorted := True;
  FGroups.Duplicates := dupError;
end;

destructor TManager.Destroy;
begin
  DestroyGroups;
  FreeAndNil(FGroups);
  inherited;
end;

procedure TManager.DestroyGroups;
var
  i: Integer;
begin
  for i := FGroups.Count - 1 downto 0 do
  begin
    FGroups.Objects[i].Free;
    FGroups.Delete(i);
  end;
end;

function TManager.CreateGroup(AName: string; const ALimit: Integer; const AAccess: TGroupAccess;
  const APermissions: string): TGroup;
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

  FGroups.AddObject(AName, NewGroup);
  Result := NewGroup;
end;

procedure TManager.DestroyGroup(const AName: string);
var
  Index: Integer;
begin
  if FGroups.Find(AName, Index) then
  begin
    FGroups.Objects[Index].Free;
    FGroups.Delete(Index);
  end;
end;

procedure TManager.Join(const AMemberId, AMemberAddress: string; AMemberType: Byte; const AGroupName: string);
var
  Index: Integer;
  Group: TGroup;
  Member: TMember;
begin
  if not FGroups.Find(AGroupName, Index) then
    raise EGroupNotExists.Create;

  Group := TGroup(FGroups.Objects[Index]);

  // check if member belongs to group
  if Group.MemberExists(AMemberId) then
    Exit;

  Member := TMember.Create;
  Member.Id := AMemberId;
  Member.Kind := AMemberType;
  Member.Address := AMemberAddress;

  Group.AddMember(Member);
end;

procedure TManager.Leave(const AMemberId, AGroupName: string);
var
  Index: Integer;
begin
  if not FGroups.Find(AGroupName, Index) then
    raise EGroupNotExists.Create;

  TGroup(FGroups.Objects[Index]).RemoveMember(AMemberId);
end;

procedure TManager.RemoveMembersInactive;
var
  IdxGroup, IdxMember: Integer;
  Group: TGroup;
begin
  for IdxGroup := FGroups.Count - 1 downto 0 do
  begin
    Group := TGroup(FGroups.Objects[IdxGroup]);
    for IdxMember := Group.MemberCount - 1 downto 0 do
    begin
      if not CheckStatus(Group.Member[IdxMember]) then
        Group.RemoveMember(IdxMember);
    end;
  end;
end;

function TManager.CheckStatus(AMember: TMember): Boolean;
var
  Response: string;
begin
  try
    Response := Send(AMember.HostName, AMember.Port, CMD_CHECK_STATUS);
    Result := (Response = CMD_CHECK_STATUS_RESPONSE);
  except
    Result := False;
  end;
end;

function TManager.Send(const AHostName: string; const APort: Word; const AMessage: string): string;
var
  SQLConnection: TSQLConnection;
  Sequencer: TSequencerClient;
begin
  SQLConnection := TSQLConnection.Create(nil);
  try
    SQLConnection.DriverName := 'DataSnap';
    SQLConnection.LoginPrompt := False;
    SQLConnection.Params.Values['HostName'] := AHostName;
    SQLConnection.Params.Values['Port'] := IntToStr(APort);
    SQLConnection.Params.Values['ConnectTimeout'] := '3000';
    SQLConnection.Connected := True;

    // TODO : remove dependecy with Sequencer
    Sequencer := TSequencerClient.Create(SQLConnection.DBXConnection);
    try
      Result := Sequencer.ProcessMessage(AMessage);
    finally
      FreeAndNil(Sequencer);
    end;
  finally
    FreeAndNil(SQLConnection);
  end;
end;

function TManager.SendMessage(const ASenderId, AGroupName, AMessage: string): string;
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
      if FGroups.Find(Permission, Index) then
      begin
        GroupPermission := TGroup(FGroups.Objects[Index]);
        Result := GroupPermission.MemberExists(ASenderId);
        if Result then
          Break;
      end;
    end;
  end;

begin
  if not FGroups.Find(AGroupName, Index) then
    raise EGroupNotExists.Create;

  GroupDest := TGroup(FGroups.Objects[Index]);

  if GroupDest.MemberCount = 0 then
    Exit;

  case GroupDest.Access of
    gaOpen: MemberHasPermission := True;
    gaClosed: MemberHasPermission := GroupDest.MemberExists(ASenderId);
    gaRestrict: MemberHasPermission := CheckPermissions;
  else
    MemberHasPermission := False;
  end;
  if not MemberHasPermission then
    raise EMemberPermission.Create;

  // broadcast message to members group
  for i := 0 to GroupDest.MemberCount - 1 do
  begin
    MemberDest := TMember(GroupDest.Member[i]);
    Send(MemberDest.HostName, MemberDest.Port, AMessage);
  end;
  Result := 'OK';
end;

function TManager.GetGroup(Name: string): TGroup;
var
  Index: Integer;
begin
  if FGroups.Find(Name, Index) then
    Result := TGroup(FGroups.Objects[Index])
  else
    raise EGroupNotExists.Create;
end;

end.
