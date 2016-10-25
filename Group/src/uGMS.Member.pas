unit uGMS.Member;

interface

type
  TMember = class
  private
    FId: string;
    FImageIndex: Word;
    FHostName: string;
    FPort: Word;
  private
    function GetAddress: string;
    procedure SetAddress(const Value: string);
  public
    property Id: string read FId write FId;
    property ImageIndex: Word read FImageIndex write FImageIndex;
    property Address: string read GetAddress write SetAddress;
    property HostName: string read FHostName write FHostName;
    property Port: Word read FPort write FPort;
  end;

implementation

uses
  System.SysUtils, IdGlobal;

{ TMember }

function TMember.GetAddress: string;
begin
  Result := FHostName + ':' + IntToStr(FPort);
end;

procedure TMember.SetAddress(const Value: string);
var
  Address: string;
begin
  Address := Value;
  FHostName := Fetch(Address, ':');
  FPort := StrToIntDef(Address, 0);
end;

end.
