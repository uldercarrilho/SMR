program Sequencer;

uses
  Vcl.Forms,
  ufrmSequencer in 'ufrmSequencer.pas' {frmSequencer},
  uInternetUtils in 'uInternetUtils.pas',
  uGMServiceClient in 'uGMServiceClient.pas',
  uSequencer in 'uSequencer.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmSequencer, frmSequencer);
  Application.Run;
end.
