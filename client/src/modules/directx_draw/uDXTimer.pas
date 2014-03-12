unit uDXTimer;

interface

uses
  AsphyreTimer, AsphyreImages, uDXAnimation, Vectors2;

type
  TDXTimer = class
  private
    FAnimations: TDXAnimations;

    procedure TimerEvent(Sender: TObject);
    procedure ProcessEvent(Sender: TObject);

  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
    destructor Destroy; override;

    procedure AddAnimation(const AHandle: THandle; const AID: Integer; const ACallback: TDXAnimationCallback; const AStartPoint, AEndPoint: TPoint2; const ASpeed, AStartDelay: Single);
    procedure RemoveAnimations(const AHandle: THandle);
    function Find(const AHandle: THandle; const AID: Integer; out AAnimation: TDXAnimation): Boolean;
  end;

var
  DXTimer: TDXTimer;

implementation

uses
  Winapi.Windows, System.SysUtils, System.Generics.Collections;


class procedure TDXTimer.Initialize;
begin
  DXTimer := TDXTimer.Create;
end;

class procedure TDXTimer.Deinitialize;
begin
  FreeAndNil(DXTimer);
end;


constructor TDXTimer.Create;
begin
  FAnimations := TDXAnimations.Create;

  Timer.OnTimer := TimerEvent;
  Timer.OnProcess := ProcessEvent;
  Timer.Speed := 60;
end;

destructor TDXTimer.Destroy;
begin
  FAnimations.Free;

  inherited;
end;

procedure TDXTimer.AddAnimation(const AHandle: THandle; const AID: Integer; const ACallback: TDXAnimationCallback; const AStartPoint, AEndPoint: TPoint2; const ASpeed, AStartDelay: Single);
var
  animation: TDXAnimation;
begin
  if Find(AHandle, AID, animation) then
    FAnimations.Remove(animation);
  animation := TDXAnimation.Create(AHandle, AID, ACallback, AStartPoint, AEndPoint, ASpeed, AStartDelay);
  FAnimations.Add(animation);

  Timer.Enabled := TRUE;
end;

procedure TDXTimer.RemoveAnimations(const AHandle: THandle);
var
  C1: Integer;
begin
  C1 := 0;
  while C1 < FAnimations.Count do
    if FAnimations[C1].Handle = AHandle then
      FAnimations.Delete(C1)
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


procedure TDXTimer.TimerEvent(Sender: TObject);
begin
  Timer.Process;

  if FAnimations.Count = 0 then
    Timer.Enabled := FALSE;
end;

procedure TDXTimer.ProcessEvent(Sender: TObject);
var
  C1       : Integer;
  currtime : DWORD;
  callbacks: TList<TDXAnimationCallback>;
begin
  currtime := GetTickCount;

  callbacks := TList<TDXAnimationCallback>.Create;
  try
    C1 := 0;
    while C1 < FAnimations.Count do
    begin
      FAnimations[C1].Animate(currtime);

      if callbacks.IndexOf(FAnimations[C1].Callback) = -1 then
        callbacks.Add(FAnimations[C1].Callback);

      if FAnimations[C1].Status = asDone then
        FAnimations.Delete(C1)
      else
        Inc(C1);
    end;

    for C1 := 0 to callbacks.Count - 1 do
      callbacks[C1](nil);
  finally
    callbacks.Free;
  end;
end;



end.
