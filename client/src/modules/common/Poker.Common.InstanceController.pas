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
  Winapi.Windows;

class function TInstanceController.AcquireInstance(const AMutexName: String): Boolean;
var
  hMutex: THandle;
begin
  result := FALSE;
  hMutex := CreateMutex(nil, FALSE, PChar(AMutexName));
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

