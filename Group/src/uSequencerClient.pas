//
// Created by the DataSnap proxy generator.
// 25/10/2016 13:54:24
// 

unit uSequencerClient;

interface

uses
  System.JSON, Data.DBXCommon, Data.DBXClient, Data.DBXDataSnap, Data.DBXJSON, Datasnap.DSProxy, System.Classes,
  System.SysUtils, Data.DB, Data.SqlExpr, Data.DBXDBReaders, Data.DBXCDSReaders, Data.DBXJSONReflect;

const
  CMD_UPDATE_SEQUENCE = 'UPDATE_SEQUENCE';
  CMD_SUCCESS_RESPONSE = 'OK';
  CMD_CHECK_STATUS = 'CHECK_STATUS';
  CMD_CHECK_STATUS_RESPONSE = 'ACTIVE';
  CMD_UPDATE_MODE_TO_PRIMARY = 'UPDATE_MODE_TO_PRIMARY';

type
  TSequencerClient = class(TDSAdminClient)
  private
    FPurchaseOrderCommand: TDBXCommand;
    FProcessMessageCommand: TDBXCommand;
  public
    constructor Create(ADBXConnection: TDBXConnection); overload;
    constructor Create(ADBXConnection: TDBXConnection; AInstanceOwner: Boolean); overload;
    destructor Destroy; override;
    function PurchaseOrder(AClientId: string; AOrderId: string): string;
    function ProcessMessage(AMessage: string): string;
  end;

implementation

function TSequencerClient.PurchaseOrder(AClientId: string; AOrderId: string): string;
begin
  if FPurchaseOrderCommand = nil then
  begin
    FPurchaseOrderCommand := FDBXConnection.CreateCommand;
    FPurchaseOrderCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FPurchaseOrderCommand.Text := 'TSequencer.PurchaseOrder';
    FPurchaseOrderCommand.Prepare;
  end;
  FPurchaseOrderCommand.Parameters[0].Value.SetWideString(AClientId);
  FPurchaseOrderCommand.Parameters[1].Value.SetWideString(AOrderId);
  FPurchaseOrderCommand.ExecuteUpdate;
  Result := FPurchaseOrderCommand.Parameters[2].Value.GetWideString;
end;

function TSequencerClient.ProcessMessage(AMessage: string): string;
begin
  if FProcessMessageCommand = nil then
  begin
    FProcessMessageCommand := FDBXConnection.CreateCommand;
    FProcessMessageCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FProcessMessageCommand.Text := 'TSequencer.ProcessMessage';
    FProcessMessageCommand.Prepare;
  end;
  FProcessMessageCommand.Parameters[0].Value.SetWideString(AMessage);
  FProcessMessageCommand.ExecuteUpdate;
  Result := FProcessMessageCommand.Parameters[1].Value.GetWideString;
end;


constructor TSequencerClient.Create(ADBXConnection: TDBXConnection);
begin
  inherited Create(ADBXConnection);
end;


constructor TSequencerClient.Create(ADBXConnection: TDBXConnection; AInstanceOwner: Boolean);
begin
  inherited Create(ADBXConnection, AInstanceOwner);
end;


destructor TSequencerClient.Destroy;
begin
  FPurchaseOrderCommand.DisposeOf;
  FProcessMessageCommand.DisposeOf;
  inherited;
end;

end.
