unit uSequencer;

interface

uses
  System.Classes;

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

implementation

uses
  System.SyncObjs, System.SysUtils, uGMServiceClient, IdGlobal, ufrmSequencer;

const
  CMD_UPDATE_SEQUENCE = 'UPDATE_SEQUENCE';
  CMD_UPDATE_SEQUENCE_RESPONSE = 'OK';
  CMD_CHECK_STATUS = 'CHECK_STATUS';
  CMD_CHECK_STATUS_RESPONSE = 'ACTIVE';

var
  CriticalSection: TCriticalSection;
  SequenceOrder: Integer = 0;

{ TSequenceServer }

function TSequencer.ProcessMessage(AMessage: string): string;
var
  Command: string;
begin
  Command := Fetch(AMessage, '|');

  if Command = CMD_UPDATE_SEQUENCE then
  begin
    SequenceOrder := StrToInt(AMessage);
    Result := CMD_UPDATE_SEQUENCE_RESPONSE;
  end
  else
  if Command = CMD_CHECK_STATUS then
    Result := CMD_CHECK_STATUS_RESPONSE;
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
