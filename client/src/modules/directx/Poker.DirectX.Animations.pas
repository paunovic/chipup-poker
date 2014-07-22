unit Poker.DirectX.Animations;

interface

uses
   Winapi.Windows, System.Generics.Collections, System.Classes, Asphyre.Math, Asphyre.Timing, System.SyncObjs, Poker.DirectX.AnimationNew;

const
  ANITAG_CARD_INDEX   = 1;
  ANITAG_WIN_MESSAGE  = 2;
  ANITAG_CHIPS_AMOUNT = 3;
  ANITAG_SEAT_INDEX   = 4;
  ANITAG_POT_INDEX    = 5;

type
  TDXAnimations = class(TThread)
  private
    FWaitEvent: TEvent;
    FTiming: TAsphyreTiming;
    FAnimations: TObjectList<TDXAnimationNew>;
    FLock: TCriticalSection;
    FFPS: Integer;
    FEnabled: Boolean;
    FDXAreaSize: TPoint2px;
    FUpdateInterval: Integer;

    procedure SetFPS(const AValue: Integer);
    procedure UpdateAnimations;
    function GetCount: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Signal;

    procedure Clear;

    property FPS: Integer read FFPS write SetFPS;
    property Enabled: Boolean read FEnabled write FEnabled;
    property DXAreaSize: TPoint2px read FDXAreaSize write FDXAreaSize;
    property Count: Integer read GetCount;

    procedure Add(const APoints: array of TPoint2; const ASpeed, AStartDelay, AEndDelay: Single);
  end;

implementation

{ TDXAnimations }

constructor TDXAnimations.Create;
begin
  inherited Create(TRUE);

  FFPS := 30;
  FLock := TCriticalSection.Create;
  FEnabled := TRUE;
  FWaitEvent := TEvent.Create(nil, FALSE, FALSE, '');
  FTiming := TAsphyreTiming.Create;
  FAnimations := TObjectList<TDXAnimationNew>.Create;
end;

destructor TDXAnimations.Destroy;
begin
  FLock.Enter;
  try
    FAnimations.Free;
    FTiming.Free;
    FWaitEvent.Free;
  finally
    FLock.Leave;
  end;

  FLock.Free;
  inherited;
end;

procedure TDXAnimations.Signal;
begin
  FWaitEvent.SetEvent;
end;

procedure TDXAnimations.SetFPS(const AValue: Integer);
begin
  FFPS := AValue;
  FUpdateInterval := 1000 div FFPS;
end;

procedure TDXAnimations.Add(const APoints: array of TPoint2; const ASpeed, AStartDelay, AEndDelay: Single);
var
  animation: TDXAnimationNew;
  time: Double;
begin
  time := FTiming.GetTimeValue;
  animation := TDXAnimationNew.Create(FDXAreaSize, APoints, time + AStartDelay, time + AStartDelay + ASpeed);
  FLock.Enter;
  try
    FAnimations.Add(animation);
  finally
    FLock.Leave;
  end;
  FWaitEvent.SetEvent;
end;

function TDXAnimations.GetCount: Integer;
begin
  FLock.Enter;
  try
    result := FAnimations.Count;
  finally
    FLock.Leave;
  end;
end;

procedure TDXAnimations.UpdateAnimations;
var
  time: Double;
  animation: TDXAnimationNew;
begin
  time := FTiming.GetTimeValue;
  FLock.Enter;
  try
    for animation in FAnimations do
      animation.Update(time, FDXAreaSize);
  finally
    FLock.Leave;
  end;
end;

procedure TDXAnimations.Clear;
begin
  FLock.Enter;
  try
    FAnimations.Clear;
  finally
    FLock.Leave;
  end;
end;

procedure TDXAnimations.Execute;
begin
  while not Terminated do
  begin
    if Count = 0 then
      FWaitEvent.WaitFor
    else
      FWaitEvent.WaitFor(FUpdateInterval);

    UpdateAnimations;
  end;
end;


end.
