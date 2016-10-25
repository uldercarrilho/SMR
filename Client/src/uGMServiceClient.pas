//
// Created by the DataSnap proxy generator.
// 25/10/2016 15:30:07
//

unit uGMServiceClient;

interface

uses System.JSON, Data.DBXCommon, Data.DBXClient, Data.DBXDataSnap, Data.DBXJSON, Datasnap.DSProxy, System.Classes, System.SysUtils, Data.DB, Data.SqlExpr, Data.DBXDBReaders, Data.DBXCDSReaders, Data.DBXJSONReflect;

type
  TGMServiceClient = class(TDSAdminClient)
  private
    FJoinCommand: TDBXCommand;
    FLeaveCommand: TDBXCommand;
    FSendMessageCommand: TDBXCommand;
    FGetMembersAddressCommand: TDBXCommand;
  public
    constructor Create(ADBXConnection: TDBXConnection); overload;
    constructor Create(ADBXConnection: TDBXConnection; AInstanceOwner: Boolean); overload;
    destructor Destroy; override;
    procedure Join(AMemberId: string; AMemberAddress: string; AMemberType: Byte; AGroupName: string);
    procedure Leave(AMemberId: string; AGroupName: string);
    function SendMessage(ASenderId: string; AGroupName: string; AMessage: string): string;
    function GetMembersAddress(AGroupName: string): string;
  end;

implementation

procedure TGMServiceClient.Join(AMemberId: string; AMemberAddress: string; AMemberType: Byte; AGroupName: string);
begin
  if FJoinCommand = nil then
  begin
    FJoinCommand := FDBXConnection.CreateCommand;
    FJoinCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FJoinCommand.Text := 'TGMService.Join';
    FJoinCommand.Prepare;
  end;
  FJoinCommand.Parameters[0].Value.SetWideString(AMemberId);
  FJoinCommand.Parameters[1].Value.SetWideString(AMemberAddress);
  FJoinCommand.Parameters[2].Value.SetUInt8(AMemberType);
  FJoinCommand.Parameters[3].Value.SetWideString(AGroupName);
  FJoinCommand.ExecuteUpdate;
end;

procedure TGMServiceClient.Leave(AMemberId: string; AGroupName: string);
begin
  if FLeaveCommand = nil then
  begin
    FLeaveCommand := FDBXConnection.CreateCommand;
    FLeaveCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FLeaveCommand.Text := 'TGMService.Leave';
    FLeaveCommand.Prepare;
  end;
  FLeaveCommand.Parameters[0].Value.SetWideString(AMemberId);
  FLeaveCommand.Parameters[1].Value.SetWideString(AGroupName);
  FLeaveCommand.ExecuteUpdate;
end;

function TGMServiceClient.SendMessage(ASenderId: string; AGroupName: string; AMessage: string): string;
begin
  if FSendMessageCommand = nil then
  begin
    FSendMessageCommand := FDBXConnection.CreateCommand;
    FSendMessageCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FSendMessageCommand.Text := 'TGMService.SendMessage';
    FSendMessageCommand.Prepare;
  end;
  FSendMessageCommand.Parameters[0].Value.SetWideString(ASenderId);
  FSendMessageCommand.Parameters[1].Value.SetWideString(AGroupName);
  FSendMessageCommand.Parameters[2].Value.SetWideString(AMessage);
  FSendMessageCommand.ExecuteUpdate;
  Result := FSendMessageCommand.Parameters[3].Value.GetWideString;
end;

function TGMServiceClient.GetMembersAddress(AGroupName: string): string;
begin
  if FGetMembersAddressCommand = nil then
  begin
    FGetMembersAddressCommand := FDBXConnection.CreateCommand;
    FGetMembersAddressCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FGetMembersAddressCommand.Text := 'TGMService.GetMembersAddress';
    FGetMembersAddressCommand.Prepare;
  end;
  FGetMembersAddressCommand.Parameters[0].Value.SetWideString(AGroupName);
  FGetMembersAddressCommand.ExecuteUpdate;
  Result := FGetMembersAddressCommand.Parameters[1].Value.GetWideString;
end;


constructor TGMServiceClient.Create(ADBXConnection: TDBXConnection);
begin
  inherited Create(ADBXConnection);
end;


constructor TGMServiceClient.Create(ADBXConnection: TDBXConnection; AInstanceOwner: Boolean);
begin
  inherited Create(ADBXConnection, AInstanceOwner);
end;


destructor TGMServiceClient.Destroy;
begin
  FJoinCommand.DisposeOf;
  FLeaveCommand.DisposeOf;
  FSendMessageCommand.DisposeOf;
  FGetMembersAddressCommand.DisposeOf;
  inherited;
end;

end.

