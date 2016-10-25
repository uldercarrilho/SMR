unit ufrmClient;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Data.DBXDataSnap, IPPeerClient, Data.DBXCommon,
  Data.DB, Data.SqlExpr, uGMServiceClient, uSequencerClient;

type
  TfrmClient = class(TForm)
    rgClientType: TRadioGroup;
    grpGroupMembership: TGroupBox;
    lblGroupHostName: TLabel;
    lblGroupPort: TLabel;
    edtGroupHostName: TEdit;
    edtGroupPort: TEdit;
    lblPurchaseOrder: TLabel;
    btnBuy: TButton;
    mmoPurchaseOrder: TMemo;
    SQLConnGroupMembership: TSQLConnection;
    SQLConnSequencer: TSQLConnection;
    procedure FormCreate(Sender: TObject);
    procedure btnBuyClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FId: string;
    FLocalSequence: Integer;
    FServerSequence: Integer;
    FGroupMembership: TGMServiceClient;

    FSequencer: TSequencerClient;
    FSequencerHostName: string;
    FSequencerPort: Word;

    procedure ConnectToGroupMembership;
    procedure DisconnectFromGroupMembership;
    procedure ConnectToSequencer;
    procedure DisconnectFromSequencer;
    procedure PurchaseOrder;
    procedure SaveOrder;

    procedure TryBuy;
    function TryConnectToGroupMembership: Boolean;
    function GetNewSequencer: Boolean;
    function TryConnectToSequencer: Boolean;
    function TryPurchaseOrder: Boolean;
  public
    { Public declarations }
  end;

var
  frmClient: TfrmClient;

implementation

uses
  IdGlobal, uExceptions;

{$R *.dfm}

procedure TfrmClient.FormCreate(Sender: TObject);
begin
  FId := IntToStr(Random(MaxInt));
  Caption := Format('Client (ID: %s)', [FId]);

  FLocalSequence := 0;
  FServerSequence := 0;
  FGroupMembership := nil;

  FSequencer := nil;
  FSequencerHostName := '';
  FSequencerPort := 0;
end;

procedure TfrmClient.FormDestroy(Sender: TObject);
begin
  DisconnectFromGroupMembership;
end;

procedure TfrmClient.btnBuyClick(Sender: TObject);
begin
  Cursor := crHourGlass;
  try
    TryBuy;
  finally
    Cursor := crDefault;
  end;
end;

procedure TfrmClient.TryBuy;
var
  RetryGroupMembership: Boolean;
  RetrySequencer: Boolean;
begin
  RetryGroupMembership := False;
  repeat
    if not TryConnectToGroupMembership then
      raise EConnGroupMembership.Create;

    try
      RetrySequencer := False;
      repeat
        if not GetNewSequencer then
          raise EConnSequencer.Create;

        if TryConnectToSequencer and TryPurchaseOrder then
        begin
          SaveOrder;
          DisconnectFromSequencer;
        end
        else
          RetrySequencer := True;
      until not RetrySequencer;
    except
      on E: EConnSequencer do
        raise E;
    else
      RetryGroupMembership := True;
    end;
  until not RetryGroupMembership;
end;

function TfrmClient.TryConnectToGroupMembership: Boolean;
begin
  try
    if not SQLConnGroupMembership.Connected then
      ConnectToGroupMembership;

    Result := True;
  except
    Result := False;
  end;
end;

procedure TfrmClient.ConnectToGroupMembership;
begin
  SQLConnGroupMembership.Params.Values['HostName'] := edtGroupHostName.Text;
  SQLConnGroupMembership.Params.Values['Port'] := edtGroupPort.Text;
  SQLConnGroupMembership.Connected := True;

  FGroupMembership := TGMServiceClient.Create(SQLConnGroupMembership.DBXConnection);
  FGroupMembership.Join(FId, '', rgClientType.ItemIndex, 'Clients');
end;

function TfrmClient.GetNewSequencer: Boolean;
var
  Address: string;
begin
  Address := FGroupMembership.GetMembersAddress('Primary');
  Address := Fetch(Address, '|'); // only first address
  FSequencerHostName := Fetch(Address, ':');
  FSequencerPort := StrToIntDef(Address, 0);

  Result := (FSequencerHostName <> '');
end;

function TfrmClient.TryConnectToSequencer: Boolean;
begin
  try
    if not SQLConnSequencer.Connected then
      ConnectToSequencer;

    Result := True;
  except
    Result := False;
  end;
end;

procedure TfrmClient.ConnectToSequencer;
begin
  SQLConnSequencer.Params.Values['HostName'] := FSequencerHostName;
  SQLConnSequencer.Params.Values['Port'] := IntToStr(FSequencerPort);
  SQLConnSequencer.Connected := True;

  FSequencer := TSequencerClient.Create(SQLConnSequencer.DBXConnection);
end;

function TfrmClient.TryPurchaseOrder: Boolean;
begin
  try
    PurchaseOrder;
    Result := True;
  except
    on E: Exception do
    begin
      ShowMessage(E.Message);  // 'TDBXError'
      Result := False;
    end;
  end;
end;

procedure TfrmClient.PurchaseOrder;
begin
  FServerSequence := FSequencer.PurchaseOrder(FId, IntToStr(FLocalSequence + 1));
  Inc(FLocalSequence);
end;

procedure TfrmClient.SaveOrder;
var
  Time: string;
  OrderInfo: string;
begin
  Time := FormatDateTime('hh:nn:ss.zzz', Now);
  OrderInfo := Format('%s | LocalSequence=%d | ServerSequence=%d', [Time, FLocalSequence, FServerSequence]);
  mmoPurchaseOrder.Lines.Add(OrderInfo);
end;

procedure TfrmClient.DisconnectFromSequencer;
begin
  SQLConnSequencer.Connected := False;
  FreeAndNil(FSequencer);
end;

procedure TfrmClient.DisconnectFromGroupMembership;
begin
  SQLConnGroupMembership.Connected := False;
  FreeAndNil(FGroupMembership);
end;

end.
