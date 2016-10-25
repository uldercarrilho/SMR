program Client;

uses
  Vcl.Forms,
  ufrmClient in 'ufrmClient.pas' {frmClient},
  uGMServiceClient in 'uGMServiceClient.pas',
  uSequencerClient in 'uSequencerClient.pas',
  uExceptions in 'uExceptions.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmClient, frmClient);
  Application.Run;
end.
