unit Poker.Common.InstanceController;

interface

type
  TInstanceController = class
  private
    class var
      FMutexName: String;
      FMutexHandle: THandle;

  public
    class function AcquireInstance: Boolean;
    class procedure ReleaseInstance;

    class property MutexName: String read FMutexName write FMutexName;
  end;

implementation

uses
  Winapi.Windows;

class function TInstanceController.AcquireInstance: Boolean;
var
  hMutex: THandle;
begin
  result := FALSE;
  hMutex := CreateMutex(nil, FALSE, PChar(FMutexName));
  if hMutex <> 0 then
    if GetLastError = ERROR_ALREADY_EXISTS then
      result := FALSE
    else
    begin
      FMutexHandle := hMutex;
      result := TRUE;
    end;
end;

class procedure TInstanceController.ReleaseInstance;
begin
  if FMutexHandle = 0 then
    Exit;

  CloseHandle(FMutexHandle);
  FMutexHandle := 0;
end;

end.

