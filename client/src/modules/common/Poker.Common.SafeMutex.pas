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
  System.SysUtils, Winapi.Windows, Poker.SoftExceptions;

{ TSafeCriticalSection }

function TSafeMutex.Acquire: Boolean;
var
  res: TWaitResult;
begin
  res := WaitFor(INFINITE);
  result := res <> wrError;
  if not result then
    SoftException(Format('Error while attempting to acquire mutex object [err: %d; handle: %d]', [Integer(res), Handle]));
end;

function TSafeMutex.Release: Boolean;
begin
  result := ReleaseMutex(FHandle);
  if not result then
    SoftException(Format('Error while attempting to release mutex object [handle: %d]', [Handle]));
end;

end.
