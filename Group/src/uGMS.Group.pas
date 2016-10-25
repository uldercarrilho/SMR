unit uGMS.Group;

interface

uses
  System.Classes, uGMS.Member;

const
  GROUP_UNLIMITED = 0;

type
  TGroupAccess = (gaOpen, gaClosed, gaRestrict);

  TGroup = class
  private
    FName: string;
    FLimit: Integer;
    FPermissions: TStringList;
    FAccess: TGroupAccess;
    FMembers: TStringList;
    function GetMember(Index: Integer): TMember;
    function GetMemberCount: Integer;
  private
    procedure SetLimit(const Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddMember(AMember: TMember);
    procedure RemoveMember(const AIndex: Integer); overload;
    procedure RemoveMember(const AMemberId: string); overload;
    function MemberExists(const AMemberId: string): Boolean;
    function IsFull: Boolean;

    property Name: string read FName write FName;
    property Limit: Integer read FLimit write SetLimit;
    property Access: TGroupAccess read FAccess write FAccess;
    property Permissions: TStringList read FPermissions;

    property Member[Index: Integer]: TMember read GetMember;
    property MemberCount: Integer read GetMemberCount;
  end;

implementation

uses
  System.SysUtils, uGMS.Exceptions;

{ TGroup }

procedure TGroup.AddMember(AMember: TMember);
begin
  if IsFull then
  begin
    AMember.Free;
    raise EGroupLimitExceeded.Create;
  end
  else
    FMembers.AddObject(AMember.Id, AMember);
end;

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

function TGroup.GetMemberCount: Integer;
begin
  Result := FMembers.Count;
end;

function TGroup.IsFull: Boolean;
begin
  Result := (FLimit <> GROUP_UNLIMITED) and (FLimit = FMembers.Count);
end;

function TGroup.MemberExists(const AMemberId: string): Boolean;
begin
  Result := FMembers.IndexOf(AMemberId) <> - 1;
end;

procedure TGroup.RemoveMember(const AMemberId: string);
var
  Index: Integer;
begin
  if FMembers.Find(AMemberId, Index) then
    RemoveMember(Index);
end;

procedure TGroup.SetLimit(const Value: Integer);
begin
  if Value < 0 then
    FLimit := GROUP_UNLIMITED
  else
    FLimit := Value;
end;

procedure TGroup.RemoveMember(const AIndex: Integer);
begin
  FMembers.Objects[AIndex].Free;
  FMembers.Delete(AIndex);
end;

end.
