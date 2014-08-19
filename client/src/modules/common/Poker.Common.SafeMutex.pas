unit Poker.Common.SafeMutex;

interface

uses
  System.SyncObjs;

type
  TSafeMutex = class(TMutex)
  private
  public
    function Release: Boolean; reintroduce;
  end;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  System.SysUtils, Winapi.Windows;

{ TSafeCriticalSection }

function TSafeMutex.Release: Boolean;
begin
  result := ReleaseMutex(FHandle);
  {$IFDEF DEBUG}
  if not result then
    DebugLn(0, Format('Attempted to release unacquired mutex object [%d]', [Handle]), ditException);
  {$ENDIF}
end;

end.
