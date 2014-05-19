unit Poker.Common.InstanceController;

interface

type
  TInstanceController = class
  private
    class var
      FMutexName: String;
      FMutexHandle: THandle;

  public
    class function IsAlphaInstance: Boolean;
    class procedure RegisterInstance;
    class procedure UnregisterInstance;

    class property MutexName: String read FMutexName write FMutexName;
  end;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, System.SysUtils, {$ENDIF}
  Winapi.Windows;

class function TInstanceController.IsAlphaInstance: Boolean;
var
  hMutex: THandle;
begin
  hMutex := OpenMutex(SYNCHRONIZE, FALSE, PChar(FMutexName));
  if hMutex <> 0 then
  begin
    CloseHandle(hMutex);
    result := FALSE;
  end
  else
    result := TRUE;

  {$IFDEF DEBUG} DebugLn(Format('IsAlphaInstance: %s', [BoolToStr(result, TRUE)]), ditApplication); {$ENDIF}
end;

class procedure TInstanceController.RegisterInstance;
begin
  FMutexHandle := CreateMutex(nil, FALSE, PChar(FMutexName));
end;

class procedure TInstanceController.UnregisterInstance;
begin
  if FMutexHandle = 0 then
    Exit;

  {$IFDEF DEBUG} DebugLn('Releasing instance mutex', ditApplication); {$ENDIF}
  CloseHandle(FMutexHandle);
  FMutexHandle := 0;
end;

end.

