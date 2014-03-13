unit uDXAnimation;

interface

uses
  Winapi.Windows, System.Generics.Collections, Vectors2;

type
  TDXAnimation = class;

  TDXAnimationStatus = (asIdle, asAnimating, asDone);

  TDXAnimation = class
  private
    FStartTime   : Double;
    FAniStartTime: Double;
    FEndTime     : Double;
    FHandle      : THandle;
    FID          : Integer;
    FStartPoint  : TPoint2;
    FEndPoint    : TPoint2;
    FCurrPoint   : TPoint2;
    FStartDelay  : Single;
    FSpeed       : Single;
    FStatus      : TDXAnimationStatus;
    FAnimationMsg: UINT;
    FProgress    : Single;
    FRemoved     : Boolean;

  public
    constructor Create(const AHandle: THandle; const AID: Integer; const AAnimationMsg: UINT; const AStartTime: Double; const AStartPoint, AEndPoint: TPoint2; const ASpeed, AStartDelay: Single);
    destructor Destroy; override;

    procedure SetParams(const AHandle: THandle; const AID: Integer; const AAnimationMsg: UINT; const AStartTime: Double; const AStartPoint, AEndPoint: TPoint2; const ASpeed, AStartDelay: Single);

    procedure Animate(const ACurrentTime: Double);

    property ID: Integer read FID;
    property Handle: THandle read FHandle;
    property StartPoint: TPoint2 read FStartPoint;
    property EndPoint: TPoint2 read FEndPoint;
    property CurrPoint: TPoint2 read FCurrPoint;
    property Speed: Single read FSpeed;
    property Status: TDXAnimationStatus read FStatus;
    property Progress: Single read FProgress;
    property Removed: Boolean read FRemoved write FRemoved;
  end;

  TDXAnimations = TObjectList<TDXAnimation>;

implementation


constructor TDXAnimation.Create(const AHandle: THandle; const AID: Integer; const AAnimationMsg: UINT; const AStartTime: Double; const AStartPoint, AEndPoint: TPoint2; const ASpeed, AStartDelay: Single);
begin
  FStartTime := AStartTime;
  FAniStartTime := AStartTime + AStartDelay * 1000;
  FEndTime := FAniStartTime + ASpeed * 1000;
  FHandle := AHandle;
  FAnimationMsg := AAnimationMsg;
  FID := AID;
  FStartPoint := AStartPoint;
  FEndPoint := AEndPoint;
  FCurrPoint := FStartPoint;
  FSpeed := ASpeed;
  FStartDelay := AStartDelay;
  FStatus := asIdle;
  FProgress := 0;
end;

destructor TDXAnimation.Destroy;
begin

  inherited;
end;

procedure TDXAnimation.SetParams(const AHandle: THandle; const AID: Integer; const AAnimationMsg: UINT; const AStartTime: Double; const AStartPoint, AEndPoint: TPoint2; const ASpeed, AStartDelay: Single);
begin
  FStartTime := AStartTime;
  FAniStartTime := AStartTime + AStartDelay * 1000;
  FEndTime := FAniStartTime + ASpeed * 1000;
  FHandle := AHandle;
  FAnimationMsg := AAnimationMsg;
  FID := AID;
  FStartPoint := AStartPoint;
  FEndPoint := AEndPoint;
  FCurrPoint := FStartPoint;
  FSpeed := ASpeed;
  FStartDelay := AStartDelay;
  FStatus := asIdle;
  FProgress := 0;
end;

procedure TDXAnimation.Animate(const ACurrentTime: Double);
begin
  if ACurrentTime < FAniStartTime then
    Exit;

  if FStatus = asIdle then
    FStatus := asAnimating;

  if FStatus = asAnimating then
  begin
    if FEndTime - FAniStartTime > 0 then
    begin
      FProgress := (ACurrentTime - FAniStartTime) / (FEndTime - FAniStartTime);
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
      FStatus := asDone;
    end;
  end;

  SendMessage(FHandle, FAnimationMsg, WPARAM(NativeUInt(self)), 0);
end;


end.
