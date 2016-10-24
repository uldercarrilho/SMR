program GroupService;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {frmMain},
  uGroupMembership in 'uGroupMembership.pas',
  uGroupMembershipServer in 'uGroupMembershipServer.pas',
  uGroupMembershipAPI in 'uGroupMembershipAPI.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
