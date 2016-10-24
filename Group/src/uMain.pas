unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, uGroupMembership, IdBaseComponent, IdComponent, IdCustomTCPServer,
  IdTCPServer, IdContext, IPPeerServer, Datasnap.DSCommonServer, Datasnap.DSTCPServerTransport, Datasnap.DSServer,
  System.ImageList, Vcl.ImgList, Vcl.ComCtrls, Vcl.ExtCtrls;

type
  TfrmMain = class(TForm)
    grpServiceConfig: TGroupBox;
    edtPort: TEdit;
    lblPort: TLabel;
    lblStatus: TLabel;
    lblActive: TLabel;
    btnActive: TButton;
    DSServer: TDSServer;
    DSServerClass: TDSServerClass;
    DSTCPServerTransport: TDSTCPServerTransport;
    lvClients: TListView;
    lblClients: TLabel;
    ImageList: TImageList;
    lvPrimary: TListView;
    lvBackup: TListView;
    lblPrimary: TLabel;
    lblBackup: TLabel;
    tmrStatus: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure btnActiveClick(Sender: TObject);
    procedure DSServerClassGetClass(DSServerClass: TDSServerClass; var PersistentClass: TPersistentClass);
    procedure tmrStatusTimer(Sender: TObject);
  private
    { Private declarations }
    procedure RefreshMembers;
    procedure UpdateVisualControls;
    procedure StartService;
    procedure StopService;
    procedure CreateGroups;
    procedure DestroyGroups;
    procedure UpdateMembers(AListView: TListView; const AGroupName: string);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  uGroupMembershipAPI, uGroupMembershipServer;

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  UpdateVisualControls;
end;

procedure TfrmMain.RefreshMembers;
begin
  // verifica se os membros estão ativos
end;

procedure TfrmMain.btnActiveClick(Sender: TObject);
begin
  if DSServer.Started then
    StopService
  else
    StartService;

  UpdateVisualControls;
end;

procedure TfrmMain.StartService;
begin
  CreateGroups;

  DSTCPServerTransport.Port := StrToInt(edtPort.Text);
  DSServer.Start;
end;

procedure TfrmMain.CreateGroups;
begin
  GroupMembership.CreateGroup('Clients');
  GroupMembership.CreateGroup('Primary', 1, gaRestrict, 'Clients');
  GroupMembership.CreateGroup('Backup', GROUP_UNLIMITED, gaRestrict, 'Primary');
end;

procedure TfrmMain.StopService;
begin
  DSServer.Stop;

  DestroyGroups;
end;

procedure TfrmMain.DestroyGroups;
begin
  GroupMembership.DestroyGroup('Clients');
  GroupMembership.DestroyGroup('Primary');
  GroupMembership.DestroyGroup('Backup');
end;

procedure TfrmMain.DSServerClassGetClass(DSServerClass: TDSServerClass; var PersistentClass: TPersistentClass);
begin
  PersistentClass := TGroupMembershipServer;
end;

procedure TfrmMain.UpdateVisualControls;
const
  STATUS_COLOR: array[Boolean] of TColor = (clRed, clGreen);
  STATUS_CAPTION: array[Boolean] of string = ('Inactive', 'Active');
  BUTTON_CAPTION: array[Boolean] of string = ('Start', 'Stop');
begin
  edtPort.Enabled := not DSServer.Started;
  lblActive.Font.Color := STATUS_COLOR[DSServer.Started];
  lblActive.Caption := STATUS_CAPTION[DSServer.Started];
  btnActive.Caption := BUTTON_CAPTION[DSServer.Started];
  tmrStatus.Enabled := DSServer.Started;
end;

procedure TfrmMain.tmrStatusTimer(Sender: TObject);
begin
  RefreshMembers;
  UpdateMembers(lvClients, 'Clients');
  UpdateMembers(lvPrimary, 'Primary');
  UpdateMembers(lvBackup, 'Backup');
end;

procedure TfrmMain.UpdateMembers(AListView: TListView; const AGroupName: string);
var
  i: Integer;
  Member: TMember;
  Item: TListItem;
  Group: TGroup;
begin
  AListView.Items.Clear;
  Group := GroupMembership.Group[AGroupName];
  for i := 0 to Group.Members.Count - 1 do
  begin
    Member := Group.Member[i];

    Item := AListView.Items.Add;
    Item.Caption := Member.Id;
    Item.ImageIndex := Member.Kind;
  end;
end;

end.
