unit Poker.DirectX.Animation;

interface

uses
  Winapi.Windows, System.Generics.Collections, Vectors2;

const
  ANITAG_CARD_INDEX = 'card_index';
  ANITAG_SOUND = 'sound';
  ANITAG_WINMSG = 'winmsg';
  ANITAG_BLIND = 'blind';
  ANITAG_CHIPS = 'chips';
  ANITAG_SEAT = 'seat';
  ANITAG_POT_INDEX = 'pot_index';

type
  TDXAnimation = class;

  TDXAnimationStatus = (asIdle, asAnimating, asDone);

  TDXAnimation = class
  private
    FStartTime: Double;
    FAniStartTime: Double;
    FAniEndTime: Double;
    FEndTime: Double;
    FHandle: THandle;
    FId: Integer;
    FStartPoint: TPoint2;
    FEndPoint: TPoint2;
    FCurrPoint: TPoint2;
    FStartDelay: Single;
    FSpeed: Single;
    FStatus: TDXAnimationStatus;
    FProgress: Single;
    FRemoved: Boolean;
    FTags: TDictionary<String, Variant>;
    FAnimationEnabled: Boolean;

  public
    constructor Create(const AHandle: THandle; const AID: Integer; const AStartTime: Double; const AStartPoint, AEndPoint: TPoint2; const ASpeed, AStartDelay, AEndDelay: Single; const ACanvasSize: TPoint2);
    destructor Destroy; override;

    procedure Animate(const ACurrentTime: Double);

    function GetCurrPoint(const ACanvasSize: TPoint2): TPoint2;

    property AnimationEnabled: Boolean read FAnimationEnabled write FAnimationEnabled;

    property Id: Integer read FId;
    property Handle: THandle read FHandle;
    property StartPoint: TPoint2 read FStartPoint;
    property EndPoint: TPoint2 read FEndPoint;
    property Speed: Single read FSpeed;
    property Status: TDXAnimationStatus read FStatus;
    property Progress: Single read FProgress;
    property Removed: Boolean read FRemoved write FRemoved;
    property Tags: TDictionary<String, Variant> read FTags;
  end;

  TDXAnimations = class(TObjectList<TDXAnimation>)
  private
    FAnimationsEnabled: Boolean;
    procedure SetAnimationsEnabled(const AValue: Boolean);
  public
    property AnimationsEnabled: Boolean read FAnimationsEnabled write SetAnimationsEnabled;
  end;

implementation

uses
  Poker.WindowMessages;


constructor TDXAnimation.Create(const AHandle: THandle; const AID: Integer; const AStartTime: Double; const AStartPoint, AEndPoint: TPoint2; const ASpeed, AStartDelay, AEndDelay: Single; const ACanvasSize: TPoint2);
begin
  FTags := TDictionary<String, Variant>.Create;
  FStartTime := AStartTime;
  FAniStartTime := AStartTime + AStartDelay * 1000;
  FAniEndTime := FAniStartTime + ASpeed * 1000;
  FEndTime := FAniEndTime + AEndDelay * 1000;
  FHandle := AHandle;
  FID := AID;
  FStartPoint.x := AStartPoint.x / ACanvasSize.x;
  FStartPoint.y := AStartPoint.y / ACanvasSize.y;
  FEndPoint.x := AEndPoint.x / ACanvasSize.x;
  FEndPoint.y := AEndPoint.y / ACanvasSize.y;
  FCurrPoint := FStartPoint;
  FSpeed := ASpeed;
  FStartDelay := AStartDelay;
  FStatus := asIdle;
  FProgress := 0;
end;

destructor TDXAnimation.Destroy;
begin
  FTags.Free;
  inherited;
end;

function TDXAnimation.GetCurrPoint(const ACanvasSize: TPoint2): TPoint2;
begin
  if AnimationEnabled then
    Exit(Point2(FCurrPoint.x * ACanvasSize.x, FCurrPoint.y * ACanvasSize.y))
  else
    if FStatus <> asDone then
      Exit(Point2(FStartPoint.x * ACanvasSize.x, FStartPoint.y * ACanvasSize.y))
    else
      Exit(Point2(FEndPoint.x * ACanvasSize.x, FEndPoint.y * ACanvasSize.y));
end;

procedure TDXAnimation.Animate(const ACurrentTime: Double);
begin
  if ACurrentTime < FAniStartTime then
    Exit;

  if FStatus = asIdle then
    FStatus := asAnimating;

  if FStatus = asAnimating then
  begin
    if FAniEndTime - FAniStartTime > 0 then
    begin
      FProgress := (ACurrentTime - FAniStartTime) / (FAniEndTime - FAniStartTime);
      if FProgress < 0 then
        FProgress := 0;
    end
    else
      FProgress := 1;

    FCurrPoint.x := FStartPoint.x + (FEndPoint.x - FStartPoint.x) * FProgress;
    FCurrPoint.y := FStartPoint.y + (FEndPoint.y - FStartPoint.y) * FProgress;

    if FProgress >= 1 then
    begin
      FCurrPoint := FEndPoint;
      FProgress := 1;

      if (FEndTime <= FAniEndTime) or
         ((ACurrentTime - FAniEndTime) / (FEndTime - FAniEndTime) >= 1) then
        FStatus := asDone;
    end;
  end;

  SendMessage(FHandle, WM_DIRECTX_ANIMATION, WPARAM(NativeUInt(self)), 0);
end;

procedure TDXAnimations.SetAnimationsEnabled(const AValue: Boolean);
var
  animation: TDXAnimation;
begin
  FAnimationsEnabled := AValue;
  for animation in ToArray do
    animation.AnimationEnabled := FAnimationsEnabled;
end;


end.
