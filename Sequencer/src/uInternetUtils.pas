unit uInternetUtils;

interface

function GetIPAddress: Integer;
function GetIPAddressAsString: String;

implementation

uses
  Winapi.WinSock, System.SysUtils;

function GetIPAddress: Integer;
var
  Buffer: array[0..255] of AnsiChar;
  RemoteHost: PHostEnt;
begin
  GetHostName(@Buffer, 255);
  RemoteHost := GetHostByName(Buffer);
  if RemoteHost = nil then
    Result := htonl($07000001) { 127.0.0.1 }
  else
    Result := longint(pointer(RemoteHost^.h_addr_list^)^);

  Result := ntohl(Result);
end;

function GetIPAddressAsString: String;
var
  tempAddress: Integer;
  Buffer: array[0..3] of Byte absolute tempAddress;
begin
  tempAddress := GetIPAddress;
  Result := Format('%d.%d.%d.%d', [Buffer[3], Buffer[2], Buffer[1], Buffer[0]]);
end;

end.
