//
// Created by the DataSnap proxy generator.
// 24/10/2016 19:12:51
//

unit uGroupMembershipClient;

interface

uses System.JSON, Data.DBXCommon, Data.DBXClient, Data.DBXDataSnap, Data.DBXJSON, Datasnap.DSProxy, System.Classes, System.SysUtils, Data.DB, Data.SqlExpr, Data.DBXDBReaders, Data.DBXCDSReaders, Data.DBXJSONReflect;

type
  TGroupMembershipClient = class(TDSAdminClient)
  private
    FCreateGroupCommand: TDBXCommand;
    FDestroyGroupCommand: TDBXCommand;
    FJoinCommand: TDBXCommand;
    FLeaveCommand: TDBXCommand;
    FSendMessageCommand: TDBXCommand;
  public
    constructor Create(ADBXConnection: TDBXConnection); overload;
    constructor Create(ADBXConnection: TDBXConnection; AInstanceOwner: Boolean); overload;
    destructor Destroy; override;
    procedure CreateGroup(AName: string; ALimit: Integer; AAccess: Byte; APermissions: string);
    procedure DestroyGroup(AName: string);
    procedure Join(AMemberId: string; AMemberAddress: string; AMemberType: Byte; AGroupName: string);
    procedure Leave(AMemberId: string; AGroupName: string);
    procedure SendMessage(AMemberId: string; AGroupName: string; AMessage: string);
  end;

implementation

procedure TGroupMembershipClient.CreateGroup(AName: string; ALimit: Integer; AAccess: Byte; APermissions: string);
begin
  if FCreateGroupCommand = nil then
  begin
    FCreateGroupCommand := FDBXConnection.CreateCommand;
    FCreateGroupCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FCreateGroupCommand.Text := 'TGroupMembershipServer.CreateGroup';
    FCreateGroupCommand.Prepare;
  end;
  FCreateGroupCommand.Parameters[0].Value.SetWideString(AName);
  FCreateGroupCommand.Parameters[1].Value.SetInt32(ALimit);
  FCreateGroupCommand.Parameters[2].Value.SetUInt8(AAccess);
  FCreateGroupCommand.Parameters[3].Value.SetWideString(APermissions);
  FCreateGroupCommand.ExecuteUpdate;
end;

procedure TGroupMembershipClient.DestroyGroup(AName: string);
begin
  if FDestroyGroupCommand = nil then
  begin
    FDestroyGroupCommand := FDBXConnection.CreateCommand;
    FDestroyGroupCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FDestroyGroupCommand.Text := 'TGroupMembershipServer.DestroyGroup';
    FDestroyGroupCommand.Prepare;
  end;
  FDestroyGroupCommand.Parameters[0].Value.SetWideString(AName);
  FDestroyGroupCommand.ExecuteUpdate;
end;

procedure TGroupMembershipClient.Join(AMemberId: string; AMemberAddress: string; AMemberType: Byte; AGroupName: string);
begin
  if FJoinCommand = nil then
  begin
    FJoinCommand := FDBXConnection.CreateCommand;
    FJoinCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FJoinCommand.Text := 'TGroupMembershipServer.Join';
    FJoinCommand.Prepare;
  end;
  FJoinCommand.Parameters[0].Value.SetWideString(AMemberId);
  FJoinCommand.Parameters[1].Value.SetWideString(AMemberAddress);
  FJoinCommand.Parameters[2].Value.SetUInt8(AMemberType);
  FJoinCommand.Parameters[3].Value.SetWideString(AGroupName);
  FJoinCommand.ExecuteUpdate;
end;

procedure TGroupMembershipClient.Leave(AMemberId: string; AGroupName: string);
begin
  if FLeaveCommand = nil then
  begin
    FLeaveCommand := FDBXConnection.CreateCommand;
    FLeaveCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FLeaveCommand.Text := 'TGroupMembershipServer.Leave';
    FLeaveCommand.Prepare;
  end;
  FLeaveCommand.Parameters[0].Value.SetWideString(AMemberId);
  FLeaveCommand.Parameters[1].Value.SetWideString(AGroupName);
  FLeaveCommand.ExecuteUpdate;
end;

procedure TGroupMembershipClient.SendMessage(AMemberId: string; AGroupName: string; AMessage: string);
begin
  if FSendMessageCommand = nil then
  begin
    FSendMessageCommand := FDBXConnection.CreateCommand;
    FSendMessageCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FSendMessageCommand.Text := 'TGroupMembershipServer.SendMessage';
    FSendMessageCommand.Prepare;
  end;
  FSendMessageCommand.Parameters[0].Value.SetWideString(AMemberId);
  FSendMessageCommand.Parameters[1].Value.SetWideString(AGroupName);
  FSendMessageCommand.Parameters[2].Value.SetWideString(AMessage);
  FSendMessageCommand.ExecuteUpdate;
end;


constructor TGroupMembershipClient.Create(ADBXConnection: TDBXConnection);
begin
  inherited Create(ADBXConnection);
end;


constructor TGroupMembershipClient.Create(ADBXConnection: TDBXConnection; AInstanceOwner: Boolean);
begin
  inherited Create(ADBXConnection, AInstanceOwner);
end;


destructor TGroupMembershipClient.Destroy;
begin
  FCreateGroupCommand.DisposeOf;
  FDestroyGroupCommand.DisposeOf;
  FJoinCommand.DisposeOf;
  FLeaveCommand.DisposeOf;
  FSendMessageCommand.DisposeOf;
  inherited;
end;

end.

