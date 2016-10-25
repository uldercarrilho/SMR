//
// Created by the DataSnap proxy generator.
// 25/10/2016 17:51:12
//

unit uSequencerClient;

interface

uses System.JSON, Data.DBXCommon, Data.DBXClient, Data.DBXDataSnap, Data.DBXJSON, Datasnap.DSProxy, System.Classes, System.SysUtils, Data.DB, Data.SqlExpr, Data.DBXDBReaders, Data.DBXCDSReaders, Data.DBXJSONReflect;

type
  TSequencerClient = class(TDSAdminClient)
  private
    FPurchaseOrderCommand: TDBXCommand;
    FProcessMessageCommand: TDBXCommand;
  public
    constructor Create(ADBXConnection: TDBXConnection); overload;
    constructor Create(ADBXConnection: TDBXConnection; AInstanceOwner: Boolean); overload;
    destructor Destroy; override;
    function PurchaseOrder(AClientId: string; AOrderId: string): Integer;
    function ProcessMessage(AMessage: string): string;
  end;

implementation

function TSequencerClient.PurchaseOrder(AClientId: string; AOrderId: string): Integer;
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
  Result := FPurchaseOrderCommand.Parameters[2].Value.GetInt32;
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

