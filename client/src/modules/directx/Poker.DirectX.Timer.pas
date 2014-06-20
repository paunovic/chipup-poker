unit Poker.DirectX.Timer;

interface

uses
  Winapi.Windows, System.Classes, Poker.DirectX.Animation, Vectors2, AsphyreTiming, System.SyncObjs;

type
  TDXTimer = class(TThread)
  private
    FAnimations: TDXAnimations;
    FSignalEvent: TEvent;
    FTiming: TAsphyreTiming;
    FLastUpdate: Double;
    FNextId: Integer;
    FLocK: TCriticalSection;

    procedure Process;
    procedure Shutdown;
    procedure SetAnimationsEnabled(const AValue: Boolean);
    function GetAnimationsEnabled: Boolean;

  protected
    procedure Execute; override;

  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
    destructor Destroy; override;

    function AddAnimation(const AHandle: THandle; const AStartPoint, AEndPoint: TPoint2; const ASpeed, AStartDelay, AEndDelay: Single; const ACanvasSize: TPoint2): TDXAnimation;
    procedure RemoveAnimations(const AHandle: THandle);
    function Find(const AHandle: THandle; const AID: Integer; out AAnimation: TDXAnimation): Boolean;

    property AnimationsEnabled: Boolean read GetAnimationsEnabled write SetAnimationsEnabled;
  end;

var
  DXTimer: TDXTimer;

implementation

uses
  System.SysUtils, System.Generics.Collections, Poker.WindowMessages, Poker.Settings;


class procedure TDXTimer.Initialize;
begin
  DXTimer := TDXTimer.Create;
  DXTimer.Start;
end;

class procedure TDXTimer.Deinitialize;
begin
  DXTimer.Shutdown;
  FreeAndNil(DXTimer);
end;


constructor TDXTimer.Create;
begin
  FNextId := 0;
  FLock := TCriticalSection.Create;
  FSignalEvent := TEvent.Create(nil, FALSE, FALSE, '');
  FTiming := TAsphyreTiming.Create;
  FAnimations := TDXAnimations.Create;
  FAnimations.AnimationsEnabled := FALSE;

  inherited Create(TRUE);
end;

destructor TDXTimer.Destroy;
begin
  FAnimations.Free;
  FTiming.Free;
  FreeAndNil(FSignalEvent);
  FreeAndNil(FLock);

  inherited;
end;

function TDXTimer.AddAnimation(const AHandle: THandle; const AStartPoint, AEndPoint: TPoint2; const ASpeed, AStartDelay, AEndDelay: Single; const ACanvasSize: TPoint2): TDXAnimation;
var
  animation: TDXAnimation;
begin
  animation := TDXAnimation.Create(AHandle, FNextId, FTiming.GetTimeValue, AStartPoint, AEndPoint, ASpeed, AStartDelay, AEndDelay, ACanvasSize);
  animation.AnimationEnabled := FAnimations.AnimationsEnabled;
  Inc(FNextId);
  FAnimations.Add(animation);
  result := animation;
  FSignalEvent.SetEvent;
end;

procedure TDXTimer.RemoveAnimations(const AHandle: THandle);
var
  C1: Integer;
begin
  C1 := 0;
  while C1 < FAnimations.Count do
    if FAnimations[C1].Handle = AHandle then
    begin
      FAnimations[C1].Removed := TRUE;
      Inc(C1);
    end
    else
      Inc(C1);
end;

function TDXTimer.Find(const AHandle: THandle; const AID: Integer; out AAnimation: TDXAnimation): Boolean;
var
  animation: TDXAnimation;
begin
  for animation in FAnimations do
    if (animation.Handle = AHandle) and
       (animation.ID = AID) then
    begin
      AAnimation := animation;
      Exit(TRUE);
    end;
  Exit(FALSE);
end;

procedure TDXTimer.Shutdown;
begin
  Terminate;
  FSignalEvent.SetEvent;
  WaitFor;
end;

procedure TDXTimer.SetAnimationsEnabled(const AValue: Boolean);
begin
  FAnimations.AnimationsEnabled := AValue;
end;

function TDXTimer.GetAnimationsEnabled: Boolean;
begin
  result := FAnimations.AnimationsEnabled;
end;


procedure TDXTimer.Process;
const
  UPDATE_FPS      = 60;
  UPDATE_INTERVAL = 1000 / UPDATE_FPS;
var
  C1: Integer;
  callbacks: TList<THandle>;
  callbacks_must: TList<THandle>;
begin
  callbacks := TList<THandle>.Create;
  try
    callbacks_must := TList<THandle>.Create;
    try
      FLock.Enter;
      try
        C1 := 0;
        while (Assigned(FAnimations)) and (C1 < FAnimations.Count) do
        begin
          if FAnimations[C1].Removed then
          begin
            FAnimations.Delete(C1);
            Continue;
          end;

          FAnimations[C1].Animate(FTiming.GetTimeValue);

          if FAnimations[C1].Status = asDone then
          begin
            callbacks.Remove(FAnimations[C1].Handle);
            if callbacks_must.IndexOf(FAnimations[C1].Handle) = -1 then
              callbacks_must.Add(FAnimations[C1].Handle);
            FAnimations.Delete(C1);
            Continue;
          end;

          if (callbacks_must.IndexOf(FAnimations[C1].Handle) = -1) and
             (callbacks.IndexOf(FAnimations[C1].Handle) = -1) then
            callbacks.Add(FAnimations[C1].Handle);
          Inc(C1);
        end;
      finally
        FLock.Leave;
      end;

      for C1 := 0 to callbacks_must.Count - 1 do
        PostMessage(callbacks_must[C1], WM_DIRECTX_ANIMATION, 0, 0);

      if FTiming.GetTimeValue - FLastUpdate > UPDATE_INTERVAL then
      begin
        for C1 := 0 to callbacks.Count - 1 do
          PostMessage(callbacks[C1], WM_DIRECTX_ANIMATION, 0, 0);
        FLastUpdate := FTiming.GetTimeValue;
      end;
    finally
      callbacks_must.Free;
    end;
  finally
    callbacks.Free;
  end;
end;

procedure TDXTimer.Execute;
begin
  while not Terminated do
  begin
    Process;
    if FAnimations.Count = 0 then
    begin
      FNextId := 0;
      FSignalEvent.WaitFor;
    end
    else
      Sleep(1);
  end;
end;



end.
