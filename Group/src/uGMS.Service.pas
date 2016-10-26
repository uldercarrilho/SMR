unit uGMS.Service;

interface

uses
  System.Classes, System.SyncObjs, uGMS.Manager;

type
  {$METHODINFO ON}
  TGMService = class(TComponent)
  public
    procedure Join(const AMemberId, AMemberAddress: string; AMemberImageIndex: Byte; const AGroupName: string);
    procedure Leave(const AMemberId, AGroupName: string);
    function SendMessage(const ASenderId, AGroupName, AMessage: string): string;

    function GetMembersAddress(const AGroupName: string): string;
  end;
  {$METHODINFO OFF}

var
  GMSManager: TManager;
  CSGMSManager: TCriticalSection;

implementation

uses
  System.SysUtils, uGMS.Group;

{ TGroupMembershipServer }

function TGMService.GetMembersAddress(const AGroupName: string): string;
var
  Group: TGroup;
  i: Integer;
begin
  Result := '';
  CSGMSManager.Enter;
  try
    Group := GMSManager.Group[AGroupName];
    for i := 0 to Group.MemberCount - 1 do
      Result := Result + Group.Member[i].Address + '|';
  finally
    CSGMSManager.Leave;
  end;
end;

procedure TGMService.Join(const AMemberId, AMemberAddress: string; AMemberImageIndex: Byte;
  const AGroupName: string);
begin
  CSGMSManager.Enter;
  try
    GMSManager.Join(AMemberId, AMemberAddress, AMemberImageIndex, AGroupName);
  finally
    CSGMSManager.Leave;
  end;
end;

procedure TGMService.Leave(const AMemberId, AGroupName: string);
begin
  CSGMSManager.Enter;
  try
    GMSManager.Leave(AMemberId, AGroupName);
  finally
    CSGMSManager.Leave;
  end;
end;

function TGMService.SendMessage(const ASenderId, AGroupName, AMessage: string): string;
begin
  CSGMSManager.Enter;
  try
    Result := GMSManager.SendMessage(ASenderId, AGroupName, AMessage);
  finally
    CSGMSManager.Leave;
  end;
end;

initialization
  CSGMSManager := TCriticalSection.Create;
  GMSManager := TManager.Create;

finalization
  FreeAndNil(GMSManager);
  FreeAndNil(CSGMSManager);

end.
