program Sequencer;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {frmMain},
  uInternetUtils in 'uInternetUtils.pas',
  uGroupMembershipClient in 'uGroupMembershipClient.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
