unit ufrmSequencer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer,
  IdSocketHandle, IdThread, IdContext, IdTCPConnection, IdTCPClient, Data.DBXDataSnap, IPPeerClient, Data.DBXCommon,
  Data.DB, Data.SqlExpr, uGMServiceClient, IPPeerServer, Datasnap.DSCommonServer, Datasnap.DSTCPServerTransport,
  Datasnap.DSServer;

type
  TfrmSequencer = class(TForm)
    lblEventsHistory: TLabel;
    grpService: TGroupBox;
    edtServicePort: TEdit;
    lblPort: TLabel;
    rbPrimary: TRadioButton;
    rbBackup: TRadioButton;
    lblMode: TLabel;
    lblStatus: TLabel;
    lblActive: TLabel;
    SQLConnection: TSQLConnection;
    btnActive: TButton;
    grpGroupMembership: TGroupBox;
    edtGroupHostName: TEdit;
    edtGroupPort: TEdit;
    lblGroupHostName: TLabel;
    lblGroupPort: TLabel;
    DSServer: TDSServer;
    DSServerClass: TDSServerClass;
    DSTCPServerTransport: TDSTCPServerTransport;
    mmoPurchaseOrders: TMemo;
    procedure FormDestroy(Sender: TObject);
    procedure btnActiveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DSServerClassGetClass(DSServerClass: TDSServerClass; var PersistentClass: TPersistentClass);
  private
    { Private declarations }
    FId: string;
    FImageIndex: Byte;
    FIP: string;
    FGroupMembership: TGMServiceClient;
    function GetGroupName: string;
    procedure UpdateVisualControls;
    procedure ConnectGroupMembership;
    procedure DisconnectGroupMembership;
    procedure RegisterService;
    procedure UnregisterService;
    procedure StartService;
    procedure StopService;
  public
    { Public declarations }
    procedure NotifyNewOrder(const AOrderInfo: string);
    property Id: string read FId;
    property GroupMembership: TGMServiceClient read FGroupMembership;
  end;

var
  frmSequencer: TfrmSequencer;

implementation

uses
  IdGlobal, uInternetUtils, uSequencer;

{$R *.dfm}

procedure TfrmSequencer.FormCreate(Sender: TObject);
begin
  FId := IntToStr(Random(MaxInt));
  FImageIndex := 4; // TfrmGroupMembership.ImageList
  FIP := GetIPAddressAsString;

  Caption := Format('Sequencer (ID: %s)', [FId]);

  UpdateVisualControls;
end;

procedure TfrmSequencer.FormDestroy(Sender: TObject);
begin
  if SQLConnection.Connected then
    StopService;
end;

procedure TfrmSequencer.DSServerClassGetClass(DSServerClass: TDSServerClass; var PersistentClass: TPersistentClass);
begin
  PersistentClass := TSequencer;
end;

procedure TfrmSequencer.btnActiveClick(Sender: TObject);
begin
  if SQLConnection.Connected then
    StopService
  else
    StartService;

  UpdateVisualControls;
end;

procedure TfrmSequencer.StartService;
begin
  try
    ConnectGroupMembership;
    RegisterService;

    DSTCPServerTransport.Port := StrToInt(edtServicePort.Text);
    DSServer.Start;
  except
    on E: Exception do
    begin
      StopService;
      ShowMessage(E.Message);
    end;
  end;
end;

procedure TfrmSequencer.ConnectGroupMembership;
begin
  SQLConnection.Params.Values['HostName'] := edtGroupHostName.Text;
  SQLConnection.Params.Values['Port'] := edtGroupPort.Text;
  SQLConnection.Connected := True;
end;

procedure TfrmSequencer.RegisterService;
var
  MyAddress: string;
begin
  MyAddress := FIP + ':' + edtServicePort.Text;

  FGroupMembership := TGMServiceClient.Create(SQLConnection.DBXConnection);
  FGroupMembership.Join(FId, MyAddress, FImageIndex, GetGroupName);
end;

function TfrmSequencer.GetGroupName: string;
begin
  if rbPrimary.Checked then
    Result := 'Primary'
  else
    Result := 'Backup';
end;

procedure TfrmSequencer.NotifyNewOrder(const AOrderInfo: string);
begin
  mmoPurchaseOrders.Lines.Append(AOrderInfo);
end;

procedure TfrmSequencer.StopService;
begin
  DSServer.Stop;
  UnregisterService;
  DisconnectGroupMembership;
end;

procedure TfrmSequencer.UnregisterService;
begin
  if Assigned(FGroupMembership) then
    FGroupMembership.Leave(FId, GetGroupName);
end;

procedure TfrmSequencer.DisconnectGroupMembership;
begin
  FreeAndNil(FGroupMembership);
  SQLConnection.Connected := False;
end;

procedure TfrmSequencer.UpdateVisualControls;
const
  STATUS_COLOR: array[Boolean] of TColor = (clRed, clGreen);
  STATUS_CAPTION: array[Boolean] of string = ('Inactive', 'Active');
  BUTTON_CAPTION: array[Boolean] of string = ('Start', 'Stop');
begin
  edtGroupHostName.Enabled := not SQLConnection.Connected;
  edtGroupPort.Enabled := not SQLConnection.Connected;
  edtServicePort.Enabled := not SQLConnection.Connected;
  rbPrimary.Enabled := not SQLConnection.Connected;
  rbBackup.Enabled := not SQLConnection.Connected;
  lblActive.Font.Color := STATUS_COLOR[SQLConnection.Connected];
  lblActive.Caption := STATUS_CAPTION[SQLConnection.Connected];
  btnActive.Caption := BUTTON_CAPTION[SQLConnection.Connected];
end;

end.
