unit uSimpleDebug;

interface

procedure SimpleDebug(const msg: String);

implementation

var
  capable: Boolean;

function AttachConsole(dwProcessID: Integer): Boolean; stdcall; external 'kernel32.dll';
function FreeConsole(): Boolean; stdcall; external 'kernel32.dll';

procedure SimpleDebug(const msg: String);
begin
  if capable then WriteLn(msg);
end;
initialization
  capable := AttachConsole(-1);

finalization
  if capable then FreeConsole();

end.
