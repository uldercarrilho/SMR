unit uGMS.Exceptions;

interface

uses
  System.SysUtils;

type
  EGroupUndefined = class(Exception)
  public
    constructor Create;
  end;

  EGroupDuplicated = class(Exception)
  public
    constructor Create;
  end;

  EGroupNotExists = class(Exception)
  public
    constructor Create;
  end;

  EGroupLimitExceeded = class(Exception)
  public
    constructor Create;
  end;

  EMemberPermission = class(Exception)
  public
    constructor Create;
  end;

implementation

{ EGroupUndefined }

constructor EGroupUndefined.Create;
begin
  inherited Create('Group name must be defined.');
end;

{ EGroupDuplicated }

constructor EGroupDuplicated.Create;
begin
  inherited Create('Group name already exists.');
end;

{ EGroupNotExists }

constructor EGroupNotExists.Create;
begin
  inherited Create('Group does not exists.');
end;

{ EGroupLimitExceeded }

constructor EGroupLimitExceeded.Create;
begin
  inherited Create('Group limit exceeded.');
end;

{ EMemberPermission }

constructor EMemberPermission.Create;
begin
  inherited Create('Member does not have permission to send message to this group.');
end;

end.
