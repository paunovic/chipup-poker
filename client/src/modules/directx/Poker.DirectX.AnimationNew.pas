unit Poker.DirectX.AnimationNew;

interface

uses
  Asphyre.Math, System.Generics.Collections;

type
  TDXAnimationStatus = (asStarting, asAnimating, asFinished);
  TDXAnimationNew = class
  private
    FPoints: TList<TPoint2>;
    FStartTime: Double;
    FEndTime: Double;
    FTimePerPoint: Double;
    FCurrentPoint: Integer;
    FCurrentPercPos: TPoint2;
    FCurrentRealPos: TPoint2;
    FStatus: TDXAnimationStatus;
    FEnabled: Boolean;

    procedure UpdateRealPos(const ADXAreaSize: TPoint2px);
  public
    constructor Create(const ADXAreaSize: TPoint2px; const APoints: array of TPoint2; const AStartAt, AEndAt: Double);
    destructor Destroy; override;

    procedure Update(const ATime: Double; const ADXAreaSize: TPoint2px);

    property Status: TDXAnimationStatus read FStatus;
    property Enabled: Boolean read FEnabled write FEnabled;
    property CurrentPos: TPoint2 read FCurrentRealPos;
  end;

implementation

{ TDXAnimationNew }

constructor TDXAnimationNew.Create(const ADXAreaSize: TPoint2px; const APoints: array of TPoint2; const AStartAt, AEndAt: Double);
var
  point: TPoint2;
begin
  FEnabled := TRUE;
  FStatus := asStarting;
  FStartTime := AStartAt;
  FEndTime := AEndAt;
  FPoints := TList<TPoint2>.Create;
  for point in APoints do
    FPoints.Add(Point2(point.x / ADXAreaSize.x, point.y / ADXAreaSize.y));
  FTimePerPoint := (FEndTime - FStartTime) / FPoints.Count;
  FCurrentPercPos := FPoints[0];
  FCurrentPoint := 0;
  UpdateRealPos(ADXAreaSize);
end;

destructor TDXAnimationNew.Destroy;
begin
  FPoints.Free;
  inherited;
end;

procedure TDXAnimationNew.Update(const ATime: Double; const ADXAreaSize: TPoint2px);
var
  xp, yp, ptime: Double;
begin
  if ATime < FStartTime then
  begin
    FStatus := asStarting;
    Exit;
  end;

  if FStatus = asFinished then
    Exit;

  xp := FPoints[FCurrentPoint + 1].x - FPoints[FCurrentPoint].x;
  yp := FPoints[FCurrentPoint + 1].y - FPoints[FCurrentPoint].y;
  ptime := ATime - FStartTime - FCurrentPoint * FTimePerPoint;

  if ptime > FTimePerPoint then
  begin
    if FCurrentPoint = FPoints.Count - 1 then
      FStatus := asFinished
    else
      Inc(FCurrentPoint);
    FCurrentPercPos := FPoints[FCurrentPoint];
    UpdateRealPos(ADXAreaSize);
  end
  else
  begin
    FStatus := asAnimating;
    if FEnabled then
    begin
      FCurrentPercPos.x := FPoints[FCurrentPoint].x + xp / ptime;
      FCurrentPercPos.y := FPoints[FCurrentPoint].y + yp / ptime;
      UpdateRealPos(ADXAreaSize);
    end;
  end;
end;

procedure TDXAnimationNew.UpdateRealPos(const ADXAreaSize: TPoint2px);
begin
  FCurrentRealPos.x := FCurrentPercPos.x * ADXAreaSize.x;
  FCurrentRealPos.y := FCurrentPercPos.y * ADXAreaSize.y;
end;

end.
