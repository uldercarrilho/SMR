unit uGroupMembershipServer;

interface

uses
  System.Classes, uGroupMembershipAPI, uGroupMembership;

type
  {$METHODINFO ON}
  TGroupMembershipServer = class(TComponent)
  public
    procedure CreateGroup(AName: string; const ALimit: Integer; const AAccess: Byte; const APermissions: string);
    procedure DestroyGroup(const AName: string);

    procedure Join(const AMemberId, AMemberAddress: string; AMemberType: Byte; const AGroupName: string);
  end;
  {$METHODINFO OFF}

var
  GroupMembership: TGroupMembership;

implementation

uses
  System.SyncObjs, System.SysUtils;

var
  CriticalSection: TCriticalSection;

{ TGroupMembershipServer }

procedure TGroupMembershipServer.CreateGroup(AName: string; const ALimit: Integer; const AAccess: Byte;
  const APermissions: string);
begin
  CriticalSection.Enter;
  try
    GroupMembership.CreateGroup(AName, ALimit, TGroupAccess(AAccess), APermissions);
  finally
    CriticalSection.Leave;
  end;
end;

procedure TGroupMembershipServer.DestroyGroup(const AName: string);
begin
  CriticalSection.Enter;
  try
    GroupMembership.DestroyGroup(AName);
  finally
    CriticalSection.Leave;
  end;
end;

procedure TGroupMembershipServer.Join(const AMemberId, AMemberAddress: string; AMemberType: Byte;
  const AGroupName: string);
begin
  CriticalSection.Enter;
  try
    GroupMembership.Join(AMemberId, AMemberAddress, AMemberType, AGroupName);
  finally
    CriticalSection.Leave;
  end;
end;

initialization
  CriticalSection := TCriticalSection.Create;
  GroupMembership := TGroupMembership.Create;

finalization
  FreeAndNil(GroupMembership);
  FreeAndNil(CriticalSection);

end.
