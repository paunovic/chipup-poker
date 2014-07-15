unit Poker.DirectX.Animations;

interface

uses
   Winapi.Windows, System.Classes, Asphyre.Math, Asphyre.Timing, System.SyncObjs;

type
  TDXAnimations = class(TThread)
  private
    FWaitEvent: TEvent;
    FTiming: TAsphyreTiming;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Signal;

//    procedure Add(const APoints: array of TPoint2; const ASpeed, AStartDelay, AEndDelay: Single);
  end;

implementation

uses
  System.SysUtils;

{ TDXAnimations }


constructor TDXAnimations.Create;
begin
  FWaitEvent := TEvent.Create(nil, FALSE, FALSE, '');
  FTiming := TAsphyreTiming.Create;
end;

destructor TDXAnimations.Destroy;
begin
  FreeAndNil(FTiming);
  FreeAndNil(FWaitEvent);
  inherited;
end;

procedure TDXAnimations.Signal;
begin
  FWaitEvent.SetEvent;
end;

procedure TDXAnimations.Execute;
begin
  while not Terminated do
  begin
    FWaitEvent.WaitFor;
  end;
end;

end.
