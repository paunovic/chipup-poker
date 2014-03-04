unit uFlopTableAnimationThread;

interface

uses
  System.Classes, GR32;

type
  TFlopTableAnimationThread = class(TThread)
  private
    FStartingPos: TRect;
    FEndPos1    : TRect;
    FEndPos2    : TRect;
    FEndPos3    : TRect;
    FCurPos1    : TRect;
    FCurPos2    : TRect;
    FCurPos3    : TRect;
    FDone       : Boolean;

    FOnAnimation: TNotifyEvent;

    procedure syncAnimation;

  protected
    procedure Execute; override;

  public
    constructor Create(const AStartingPos, AEndPos1, AEndPos2, AEndPos3: TRect);
    destructor Destroy; override;

    procedure SetPositions(const AStartingPos, AEndPos1, AEndPos2, AEndPos3: TRect);

    property CurPos1: TRect read FCurPos1;
    property CurPos2: TRect read FCurPos2;
    property CurPos3: TRect read FCurPos3;
    property Done: Boolean read FDone;
    property OnAnimation: TNotifyEvent read FOnAnimation write FOnAnimation;
  end;

implementation

{ TFlopTableAnimationThread }

constructor TFlopTableAnimationThread.Create(const AStartingPos, AEndPos1, AEndPos2, AEndPos3: TRect);
begin
  SetPositions(AStartingPos, AEndPos1, AEndPos2, AEndPos3);
  FCurPos1 := AStartingPos;
  FCurPos2 := AStartingPos;
  FCurPos3 := AStartingPos;

  inherited Create(TRUE);
  FreeOnTerminate := TRUE;
end;

destructor TFlopTableAnimationThread.Destroy;
begin

  inherited;
end;

procedure TFlopTableAnimationThread.Execute;
begin
  FDone := FALSE;
  while (not Terminated) and
        (not FDone) do
  begin
    if FCurPos1.Left < FEndPos1.Left then
      FCurPos1.Offset(1, 0);
    if FCurPos2.Left < FEndPos2.Left then
      FCurPos2.Offset(4, 0);
    if FCurPos3.Left < FEndPos3.Left then
      FCurPos3.Offset(6, 0);

    if FCurPos1.Left > FEndPos1.Left then
      FCurPos1.Left := FEndPos1.Left;
    if FCurPos2.Left > FEndPos2.Left then
      FCurPos2.Left := FEndPos2.Left;
    if FCurPos3.Left > FEndPos3.Left then
      FCurPos3.Left := FEndPos3.Left;

    FDone := (FCurPos1.Left = FEndPos1.Left) and (FCurPos2.Left = FEndPos2.Left) and (FCurPos3.Left = FEndPos3.Left);

    if Assigned(FOnAnimation) then
      Synchronize(syncAnimation);
  end;
end;

procedure TFlopTableAnimationThread.SetPositions(const AStartingPos, AEndPos1, AEndPos2, AEndPos3: TRect);
begin
  if FEndPos1.Left > FCurPos1.Left then
    FCurPos1.Left := AStartingPos.Left + Round(((FCurPos1.Left - FStartingPos.Left) / (FEndPos1.Left - FStartingPos.Left)) * (AEndPos1.Left - AStartingPos.Left));
  if FEndPos2.Left > FCurPos2.Left then
    FCurPos2.Left := AStartingPos.Left + Round(((FCurPos2.Left - FStartingPos.Left) / (FEndPos2.Left - FStartingPos.Left)) * (AEndPos2.Left - AStartingPos.Left));
  if FEndPos3.Left > FCurPos3.Left then
    FCurPos3.Left := AStartingPos.Left + Round(((FCurPos3.Left - FStartingPos.Left) / (FEndPos3.Left - FStartingPos.Left)) * (AEndPos3.Left - AStartingPos.Left));

  FStartingPos := AStartingPos;
  FEndPos1 := AEndPos1;
  FEndPos2 := AEndPos2;
  FEndPos3 := AEndPos3;
end;

procedure TFlopTableAnimationThread.syncAnimation;
begin
  FOnAnimation(self);
end;

end.
