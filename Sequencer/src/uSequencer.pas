unit uSequencer;

interface

uses
  System.Classes;

const
  CMD_UPDATE_SEQUENCE = 'UPDATE_SEQUENCE';
  CMD_SUCCESS_RESPONSE = 'OK';
  CMD_CHECK_STATUS = 'CHECK_STATUS';
  CMD_CHECK_STATUS_RESPONSE = 'ACTIVE';
  CMD_UPDATE_MODE_TO_PRIMARY = 'UPDATE_MODE_TO_PRIMARY';
  CMD_GET_SEQUENCE = 'GET_SEQUENCE';

type
  {$METHODINFO ON}
  TSequencer = class(TPersistent)
  private
    procedure SaveOrder(const AOrderInfo: string);
  public
    function PurchaseOrder(const AClientId, AOrderId: string): Integer;
    function ProcessMessage(AMessage: string): string;
  end;
  {$METHODINFO OFF}

var
  SequenceOrder: Integer = 0;

implementation

uses
  System.SyncObjs, System.SysUtils, uGMServiceClient, IdGlobal, ufrmSequencer;

var
  CriticalSection: TCriticalSection;

{ TSequenceServer }

function TSequencer.ProcessMessage(AMessage: string): string;
var
  Command: string;
begin
  Command := Fetch(AMessage, '|');

  if Command = CMD_UPDATE_SEQUENCE then
  begin
    SequenceOrder := StrToInt(AMessage);
    Result := CMD_SUCCESS_RESPONSE;
  end
  else
  if Command = CMD_UPDATE_MODE_TO_PRIMARY then
  begin
    frmSequencer.rbPrimary.Checked := True;
    Result := '';
  end
  else
  if Command = CMD_CHECK_STATUS then
    Result := CMD_CHECK_STATUS_RESPONSE
  else
  if Command = CMD_GET_SEQUENCE then
    Result := IntToStr(SequenceOrder);
end;

function TSequencer.PurchaseOrder(const AClientId, AOrderId: string): Integer;
var
  Msg: string;
  Time: string;
  OrderInfo: string;
  NewSequence: Integer;
begin
  CriticalSection.Enter;
  try
    NewSequence := SequenceOrder + 1;

    // update sequence on backups
    Msg := CMD_UPDATE_SEQUENCE + '|' + IntToStr(NewSequence);
    frmSequencer.GroupMembership.SendMessage(frmSequencer.Id, 'Backup', Msg);

    SequenceOrder := NewSequence;

    // create purchase order
    Time := FormatDateTime('hh:nn:ss.zzz', Now);
    OrderInfo := Format('%s | Sequence=%d | ClientId=%s | OrderId=%s', [Time, NewSequence, AClientId, AOrderId]);

    SaveOrder(OrderInfo);
    frmSequencer.NotifyNewOrder(OrderInfo);

    Result := SequenceOrder;
  finally
    CriticalSection.Leave;
  end;
end;

procedure TSequencer.SaveOrder(const AOrderInfo: string);
const
  FILENAME = 'PurchaseOrders.txt';
var
  FileOrder: TextFile;
begin
  AssignFile(FileOrder, FILENAME);

  if FileExists(FILENAME) then
    Append(FileOrder)
  else
    Rewrite(FileOrder);

  Writeln(FileOrder, AOrderInfo);
  CloseFile(FileOrder);
end;

initialization
  CriticalSection := TCriticalSection.Create;

finalization
  FreeAndNil(CriticalSection);

end.
