program GroupMembershipService;

uses
  Vcl.Forms,
  ufrmGroupMembership in 'ufrmGroupMembership.pas' {frmGroupMembership},
  uGMS.Service in 'uGMS.Service.pas',
  uGMS.Manager in 'uGMS.Manager.pas',
  uGMS.Group in 'uGMS.Group.pas',
  uGMS.Member in 'uGMS.Member.pas',
  uGMS.Exceptions in 'uGMS.Exceptions.pas',
  uSequencerClient in 'uSequencerClient.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmGroupMembership, frmGroupMembership);
  Application.Run;
end.
