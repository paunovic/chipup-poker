unit PokerClient.DirectX.Timer;

interface

uses
  Winapi.Windows, System.Classes, PokerClient.DirectX.Animation, Vectors2, AsphyreTiming;

type
  TDXTimer = class(TThread)
  private
    FAnimations   : TDXAnimations;
    FSignalEvent  : THandle;
    FMsg_Animation: UINT;
    FTiming       : TAsphyreTiming;
    FLastUpdate   : Double;
    FLockCount    : Integer;

    procedure Process;

  protected
    procedure Execute; override;

  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
    destructor Destroy; override;

    procedure Signal;
    procedure Shutdown;

    procedure AddAnimation(const AHandle: THandle; const AID: Integer; const AStartPoint, AEndPoint: TPoint2; const ASpeed, AStartDelay: Single);
    procedure RemoveAnimations(const AHandle: THandle);
    function Find(const AHandle: THandle; const AID: Integer; out AAnimation: TDXAnimation): Boolean;

    property AnimationMessage: UINT read FMsg_Animation;
  end;

var
  DXTimer: TDXTimer;

implementation

uses
  System.SysUtils, System.Generics.Collections;


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
  FSignalEvent := CreateEvent(nil, FALSE, FALSE, nil);
  FTiming := TAsphyreTiming.Create;
  FMsg_Animation := RegisterWindowMessage('DXTANMSG');
  FAnimations := TDXAnimations.Create;

  inherited Create(TRUE);
end;

destructor TDXTimer.Destroy;
begin
  FAnimations.Free;
  FTiming.Free;
  CloseHandle(FSignalEvent);

  inherited;
end;

procedure TDXTimer.AddAnimation(const AHandle: THandle; const AID: Integer; const AStartPoint, AEndPoint: TPoint2; const ASpeed, AStartDelay: Single);
var
  animation: TDXAnimation;
begin
  if Find(AHandle, AID, animation) then
    animation.SetParams(AHandle, AID, FMsg_Animation, FTiming.GetTimeValue, AStartPoint, AEndPoint, ASpeed, AStartDelay)
  else
  begin
    animation := TDXAnimation.Create(AHandle, AID, FMsg_Animation, FTiming.GetTimeValue, AStartPoint, AEndPoint, ASpeed, AStartDelay);
    FAnimations.Add(animation);
  end;

  Signal;
end;

procedure TDXTimer.RemoveAnimations(const AHandle: THandle);
var
  C1: Integer;
begin
  C1 := 0;
  while C1 < FAnimations.Count do
    if FAnimations[C1].Handle = AHandle then
    begin
      if FLockCount = 0 then
        FAnimations.Delete(C1)
      else
      begin
        FAnimations[C1].Removed := TRUE;
        Inc(C1);
      end;
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
  Signal;
  WaitFor;
end;

procedure TDXTimer.Signal;
begin
  SetEvent(FSignalEvent);
end;

procedure TDXTimer.Process;
const
  UPDATE_FPS      = 60;
  UPDATE_INTERVAL = 1000 / UPDATE_FPS;
var
  C1            : Integer;
  callbacks     : TList<THandle>;
  callbacks_must: TList<THandle>;
begin
  callbacks := TList<THandle>.Create;
  try
    callbacks_must := TList<THandle>.Create;
    try
      Inc(FLockCount);
      try
        C1 := 0;
        while C1 < FAnimations.Count do
        begin
          FAnimations[C1].Animate(FTiming.GetTimeValue);

          if FAnimations[C1].Status = asDone then
          begin
            callbacks.Remove(FAnimations[C1].Handle);
            if callbacks_must.IndexOf(FAnimations[C1].Handle) = -1 then
              callbacks_must.Add(FAnimations[C1].Handle);
            FAnimations.Delete(C1)
          end
          else
          begin
            if (callbacks_must.IndexOf(FAnimations[C1].Handle) = -1) and
               (callbacks.IndexOf(FAnimations[C1].Handle) = -1) then
              callbacks.Add(FAnimations[C1].Handle);
            Inc(C1);
          end;
        end;
      finally
        Dec(FLockCount);
      end;

      for C1 := 0 to callbacks_must.Count - 1 do
        PostMessage(callbacks_must[C1], FMsg_Animation, 0, 0);
      if FTiming.GetTimeValue - FLastUpdate > UPDATE_INTERVAL then
      begin
        for C1 := 0 to callbacks.Count - 1 do
          PostMessage(callbacks[C1], FMsg_Animation, 0, 0);
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
      ResetEvent(FSignalEvent);
      WaitForSingleObject(FSignalEvent, INFINITE);
    end;
  end;
end;



end.
