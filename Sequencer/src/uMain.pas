unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer,
  IdSocketHandle, IdThread, IdContext, IdTCPConnection, IdTCPClient, Data.DBXDataSnap, IPPeerClient, Data.DBXCommon,
  Data.DB, Data.SqlExpr, uGroupMembershipClient;

type
  TfrmMain = class(TForm)
    lstEvents: TListBox;
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
    procedure FormDestroy(Sender: TObject);
    procedure btnActiveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FId: string;
    FKind: Byte;
    FIP: string;
    FGroupMembership: TGroupMembershipClient;
    function GetGroupName: string;
    procedure UpdateVisualControls;
    procedure ConnectGroupMembership;
    procedure RegisterService;
    procedure UnregisterService;
    procedure StartService;
    procedure StopService;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  IdGlobal, uInternetUtils;

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FId := IntToStr(Random(MaxInt));
  FKind := 0; // TODO : map to GroupService
  FIP := GetIPAddressAsString;

  UpdateVisualControls;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  StopService;
end;

function TfrmMain.GetGroupName: string;
begin
  if rbPrimary.Checked then
    Result := 'Primary'
  else
    Result := 'Backup';
end;

procedure TfrmMain.btnActiveClick(Sender: TObject);
begin
  if SQLConnection.Connected then
    StopService
  else
    StartService;

  UpdateVisualControls;
end;

procedure TfrmMain.StartService;
begin
  try
    ConnectGroupMembership;
    RegisterService;
  except
    on E: Exception do
    begin
      StopService;
      ShowMessage(E.Message);
    end;
  end;
end;

procedure TfrmMain.ConnectGroupMembership;
begin
  SQLConnection.Params.Values['HostName'] := edtGroupHostName.Text;
  SQLConnection.Params.Values['Port'] := edtGroupPort.Text;
  SQLConnection.Connected := True;
end;

procedure TfrmMain.RegisterService;
var
  MyAddress: string;
begin
  MyAddress := FIP + ':' + edtServicePort.Text;

  FGroupMembership := TGroupMembershipClient.Create(SQLConnection.DBXConnection);
  FGroupMembership.Join(FId, MyAddress, 0, GetGroupName);
end;

procedure TfrmMain.StopService;
begin
  UnregisterService;
  FreeAndNil(FGroupMembership);
  SQLConnection.Connected := False;
end;

procedure TfrmMain.UnregisterService;
begin
  if Assigned(FGroupMembership) then
    FGroupMembership.Leave(FId, GetGroupName);
end;

procedure TfrmMain.UpdateVisualControls;
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
