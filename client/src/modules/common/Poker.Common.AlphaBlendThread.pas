unit Poker.Common.AlphaBlendThread;

interface

uses
  System.Classes;

type
  TAlphaBlendThread = class(TThread)
  private
    FCurrentValue: Integer;
    FFrom: Integer;
    FTo: Integer;
    FTimeInterval: Single;
    FDelay: Single;
    FOnNotify: TNotifyEvent;
    FDone: Boolean;

    procedure syncNotify;

  protected
    procedure Execute; override;
  public
    constructor Create(const AFrom, ATo: Integer; const ADelay, ATimeInterval: Single; const AOnNotify: TNotifyEvent);

    property CurrentValue: Integer read FCurrentValue;
    property Done: Boolean read FDone;
  end;

implementation

uses
  Winapi.Windows;

{ TAlphaBlendThread }

constructor TAlphaBlendThread.Create(const AFrom, ATo: Integer; const ADelay, ATimeInterval: Single; const AOnNotify: TNotifyEvent);
begin
  FreeOnTerminate := TRUE;
  FDone := FALSE;
  FFrom := AFrom;
  FTo := ATo;
  FTimeInterval := ATimeInterval;
  FDelay := ADelay;
  FOnNotify := AOnNotify;
  FCurrentValue := AFrom;

  inherited Create(FALSE);
end;

procedure TAlphaBlendThread.Execute;
var
  start_time, total_time: DWORD;
  gtc, elapsed_time: DWORD;
begin
  total_time := Round(FTimeInterval * 1000);
  start_time := GetTickCount + Round(FDelay * 1000);
  while (not Terminated) and
        (not FDone) do
  begin
    gtc := GetTickCount;
    if gtc < start_time then
    begin
      Sleep(1);
      Continue;
    end;

    elapsed_time := GetTickCount - start_time;

    if elapsed_time > total_time then
      FCurrentValue := FTo
    else
      FCurrentValue := Round(FFrom + (elapsed_time / total_time) * (FTo - FFrom));

    FDone := FCurrentValue = FTo;

    if Assigned(FOnNotify) then
      Synchronize(syncNotify);

    if not FDone then
      Sleep(1);
  end;
end;

procedure TAlphaBlendThread.syncNotify;
begin
  FOnNotify(self);
end;

end.
