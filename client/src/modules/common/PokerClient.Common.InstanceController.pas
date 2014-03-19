unit PokerClient.Common.InstanceController;

interface

type
  TInstanceController = class
  private
    class var
      FMutexName  : String;
      FMutexHandle: THandle;

  public
    class function IsAlphaInstance: Boolean;
    class procedure RegisterInstance;
    class procedure UnregisterInstance;

    class property MutexName: String read FMutexName write FMutexName;
  end;

implementation

uses
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
end;

class procedure TInstanceController.RegisterInstance;
begin
  FMutexHandle := CreateMutex(nil, FALSE, PChar(FMutexName));
end;

class procedure TInstanceController.UnregisterInstance;
begin
  ReleaseMutex(FMutexHandle);
end;

end.

