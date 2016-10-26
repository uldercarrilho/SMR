unit ufrmGroupMembership;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdBaseComponent, IdComponent, IdCustomTCPServer,
  IdTCPServer, IdContext, IPPeerServer, Datasnap.DSCommonServer, Datasnap.DSTCPServerTransport, Datasnap.DSServer,
  System.ImageList, Vcl.ImgList, Vcl.ComCtrls, Vcl.ExtCtrls, uGMS.Group, Data.DBXDataSnap, IPPeerClient, Data.DBXCommon,
  Data.DB, Data.SqlExpr;

type
  TfrmGroupMembership = class(TForm)
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
    FGroupBackup: TGroup;
    FGroupPrimary: TGroup;
    FGroupClients: TGroup;
    procedure ClearListViews;
    procedure RefreshMembers;
    procedure ChooseNewPrimary;
    procedure UpdateVisualControls;
    procedure StartService;
    procedure StopService;
    procedure CreateGroups;
    procedure DestroyGroups;
    procedure UpdateListView(AListView: TListView; const AGroup: TGroup);
  public
    { Public declarations }
  end;

var
  frmGroupMembership: TfrmGroupMembership;

implementation

uses
  System.SyncObjs, uGMS.Member, uGMS.Service, uSequencerClient;

{$R *.dfm}

procedure TfrmGroupMembership.FormCreate(Sender: TObject);
begin
  UpdateVisualControls;
end;

procedure TfrmGroupMembership.btnActiveClick(Sender: TObject);
begin
  if DSServer.Started then
    StopService
  else
    StartService;

  UpdateVisualControls;
end;

procedure TfrmGroupMembership.StartService;
begin
  CreateGroups;
  DSTCPServerTransport.Port := StrToInt(edtPort.Text);
  DSServer.Start;
end;

procedure TfrmGroupMembership.CreateGroups;
begin
  FGroupClients := GMSManager.CreateGroup('Clients');
  FGroupPrimary := GMSManager.CreateGroup('Primary', 1, gaRestrict, 'Clients,Backup');
  FGroupBackup := GMSManager.CreateGroup('Backup', GROUP_UNLIMITED, gaRestrict, 'Primary');
end;

procedure TfrmGroupMembership.StopService;
begin
  DSServer.Stop;
  DestroyGroups;
  ClearListViews;
end;

procedure TfrmGroupMembership.DestroyGroups;
begin
  FGroupClients := nil;
  FGroupPrimary := nil;
  FGroupBackup := nil;

  GMSManager.DestroyGroup('Clients');
  GMSManager.DestroyGroup('Primary');
  GMSManager.DestroyGroup('Backup');
end;

procedure TfrmGroupMembership.ClearListViews;
begin
  lvClients.Items.Clear;
  lvPrimary.Items.Clear;
  lvBackup.Items.Clear;
end;

procedure TfrmGroupMembership.DSServerClassGetClass(DSServerClass: TDSServerClass; var PersistentClass: TPersistentClass);
begin
  PersistentClass := TGMService;
end;

procedure TfrmGroupMembership.UpdateVisualControls;
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

procedure TfrmGroupMembership.tmrStatusTimer(Sender: TObject);
begin
  RefreshMembers;
  ClearListViews;
  UpdateListView(lvClients, FGroupClients);
  UpdateListView(lvPrimary, FGroupPrimary);
  UpdateListView(lvBackup, FGroupBackup);
end;

procedure TfrmGroupMembership.RefreshMembers;
begin
  CSGMSManager.Enter;
  try
    GMSManager.RemoveMembersInactive;
    if FGroupPrimary.MemberCount = 0 then
      ChooseNewPrimary;
  finally
    CSGMSManager.Leave;
  end;
end;

procedure TfrmGroupMembership.ChooseNewPrimary;
var
  Member: TMember;
begin
  if FGroupBackup.MemberCount = 0 then
    Exit;

  Member := FGroupBackup.Member[0];
  GMSManager.Join(Member.Id, Member.Address, Member.ImageIndex, 'Primary');
  GMSManager.SendMessage(Member.Id, 'Primary', CMD_UPDATE_MODE_TO_PRIMARY);
  GMSManager.Leave(Member.Id, 'Backup');
end;

procedure TfrmGroupMembership.UpdateListView(AListView: TListView; const AGroup: TGroup);
var
  i: Integer;
  Member: TMember;
  Item: TListItem;
begin
  for i := 0 to AGroup.MemberCount - 1 do
  begin
    Member := AGroup.Member[i];

    Item := AListView.Items.Add;
    Item.Caption := Member.Id;
    Item.ImageIndex := Member.ImageIndex;
  end;
end;

end.
