unit Poker.Common.InstanceController;

interface

type
  TInstanceController = class
  private
    class var
      FMutexHandle: THandle;

  public
    class function AcquireInstance(const AMutexName: String): Boolean;
    class procedure ReleaseInstance;
  end;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  System.SysUtils, Winapi.Windows;


class function TInstanceController.AcquireInstance(const AMutexName: String): Boolean;
var
  hMutex: THandle;
begin
  result := FALSE;
  hMutex := CreateMutex(nil, FALSE, PChar(AMutexName));
  if hMutex <> 0 then
  begin
    if GetLastError = ERROR_ALREADY_EXISTS then
      result := FALSE
    else
    begin
      FMutexHandle := hMutex;
      result := TRUE;
      {$IFDEF DEBUG} DebugLn('Instance mutex acquired', ditApplication); {$ENDIF}
    end;
  end
  else
  begin
    {$IFDEF DEBUG} DebugLn(Format('Failed to acquire instance mutex [%d]', [GetLastError]), ditApplication); {$ENDIF}
  end;
end;

class procedure TInstanceController.ReleaseInstance;
begin
  if FMutexHandle > 0 then
  begin
    CloseHandle(FMutexHandle);
    FMutexHandle := 0;
  end;

  {$IFDEF DEBUG} DebugLn('Instance mutex released', ditApplication); {$ENDIF}
end;

end.

