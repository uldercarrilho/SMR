unit uExceptions;

interface

uses
  System.SysUtils;

type
  EConnectionError = class(Exception)
  public
    constructor Create(const AServerName: string);
  end;

  EConnGroupMembership = class(EConnectionError)
  public
    constructor Create;
  end;

  EConnSequencer = class(EConnectionError)
  public
    constructor Create;
  end;

implementation

{ EConnectionError }

constructor EConnectionError.Create(const AServerName: string);
begin
  inherited CreateFmt('Could not connect to %s.', [AServerName]);
end;

{ EConnGroupMembership }

constructor EConnGroupMembership.Create;
begin
  inherited Create('Group Membership');
end;

{ EConnSequencer }

constructor EConnSequencer.Create;
begin
  inherited Create('Sequencer');
end;

end.
