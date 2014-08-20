unit Poker.Common.SafeMutex;

interface

uses
  System.SyncObjs;

type
  TSafeMutex = class(TMutex)
  private
  public
    function Acquire: Boolean; reintroduce;
    function Release: Boolean; reintroduce;
  end;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  System.SysUtils, Winapi.Windows;

{ TSafeCriticalSection }

function TSafeMutex.Acquire: Boolean;
var
  res: TWaitResult;
begin
  res := WaitFor(INFINITE);
  result := res <> wrError;
  {$IFDEF DEBUG}
  if not result then
    DebugLn(0, Format('Error while attempting to acquire mutex object [err: %d; handle: %d]', [Integer(res), Handle]), ditException);
  {$ENDIF}
end;

function TSafeMutex.Release: Boolean;
begin
  result := ReleaseMutex(FHandle);
  {$IFDEF DEBUG}
  if not result then
    DebugLn(0, Format('Error while attempting to release mutex object [handle: %d]', [Handle]), ditException);
  {$ENDIF}
end;

end.
