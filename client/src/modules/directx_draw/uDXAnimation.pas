unit uDXAnimation;

interface

uses
  Winapi.Windows, System.Generics.Collections, Vectors2;

type
  TDXAnimation = class;

  TDXAnimationStatus = (asIdle, asAnimating, asDone);

  TDXAnimationCallback = procedure(const AAnimation: TDXAnimation) of object;

  TDXAnimation = class
  private
    FHandle    : THandle;
    FID        : Integer;
    FCallback  : TDXAnimationCallback;
    FStartPoint: TPoint2;
    FEndPoint  : TPoint2;
    FCurrPoint : TPoint2;
    FStartDelay: Single;
    FSpeed     : Single;
    FStartTime : DWORD;
    FEndTime   : DWORD;
    FStatus    : TDXAnimationStatus;
    FProgress  : Single;

  public
    constructor Create(const AHandle: THandle; const AID: Integer; const ACallback: TDXAnimationCallback; const AStartPoint, AEndPoint: TPoint2; const ASpeed, AStartDelay: Single);
    destructor Destroy; override;

    procedure Animate(const ACurrentTime: DWORD);

    property ID: Integer read FID;
    property Handle: THandle read FHandle;
    property Callback: TDXAnimationCallback read FCallback;
    property StartPoint: TPoint2 read FStartPoint;
    property EndPoint: TPoint2 read FEndPoint;
    property CurrPoint: TPoint2 read FCurrPoint;
    property Speed: Single read FSpeed;
    property Status: TDXAnimationStatus read FStatus;
    property Progress: Single read FProgress;
  end;

  TDXAnimations = TObjectList<TDXAnimation>;

implementation



constructor TDXAnimation.Create(const AHandle: THandle; const AID: Integer; const ACallback: TDXAnimationCallback; const AStartPoint, AEndPoint: TPoint2; const ASpeed, AStartDelay: Single);
begin
  FStartTime := 0;
  FEndTime := 0;
  FProgress := 0;

  FHandle := AHandle;
  FID := AID;
  FCallback := ACallback;
  FStartPoint := AStartPoint;
  FEndPoint := AEndPoint;
  FCurrPoint := FStartPoint;
  FSpeed := ASpeed;
  FStartDelay := AStartDelay;
  FStatus := asIdle;
end;

destructor TDXAnimation.Destroy;
begin

  inherited;
end;

procedure TDXAnimation.Animate(const ACurrentTime: DWORD);
var
  ani_start_time: DWORD;
begin
  if FStartTime = 0 then
  begin
    FStartTime := GetTickCount;
    FEndTime := Round(FStartTime + FStartDelay * 1000 + FSpeed * 1000);
  end;

  ani_start_time := Round(FStartTime + FStartDelay * 1000);
  if ACurrentTime < ani_start_time then
    Exit;

  if FStatus = asIdle then
    FStatus := asAnimating;

  if FStatus = asAnimating then
  begin
    FProgress := (ACurrentTime - ani_start_time) / (FEndTime - ani_start_time);

    FCurrPoint.x := FStartPoint.x + (FEndPoint.x - FStartPoint.x) * FProgress;
    FCurrPoint.y := FStartPoint.y + (FEndPoint.y - FStartPoint.y) * FProgress;

    if FProgress >= 1 then
    begin
      FCurrPoint := FEndPoint;
      FProgress := 1;
      FStatus := asDone;
    end;
  end;

  if Assigned(FCallback) then
    FCallback(self);
end;

end.
