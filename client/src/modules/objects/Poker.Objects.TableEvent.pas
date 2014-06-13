unit Poker.Objects.TableEvent;

interface

uses
  System.Generics.Collections, System.SysUtils, Poker.Protobufs.Objects.TableEvent, Poker.Objects.PotInfo;

type
  TTableEvent = class
  private
    FEvent: TTableEventType;
    FSeat: Integer;
    FPots: TPotInfos;
    FBets: TList<UINT32>;
    FCards: TBytes;
  public
    constructor Create(const APBTableEvent: TPB_TableEvent);
    destructor Destroy; override;

    procedure Assign(const APBTableEvent: TPB_TableEvent);

    property Event: TTableEventType read FEvent;
    property Seat: Integer read FSeat;
    property Pots: TPotInfos read FPots;
    property Bets: TList<UINT32> read FBets;
    property Cards: TBytes read FCards;
  end;

  TTableEvents = class(TObjectList<TTableEvent>)
  public
    procedure Assign(const AEvents: TObjectList<TPB_TableEvent>);
  end;

implementation

{ TTableEvent }

constructor TTableEvent.Create(const APBTableEvent: TPB_TableEvent);
begin
  FBets := TList<UINT32>.Create;
  FPots := TPotInfos.Create;
  Assign(APBTableEvent);
end;

destructor TTableEvent.Destroy;
begin
  FPots.Free;
  FBets.Free;
  inherited;
end;

procedure TTableEvent.Assign(const APBTableEvent: TPB_TableEvent);
begin
  FEvent := APBTableEvent.Event;
  FSeat := APBTableEvent.Seat;
  FBets.Clear;
  FBets.AddRange(APBTableEvent.Bets);
  FPots.Assign(APBTableEvent.Pots);
  FCards := APBTableEvent.Cards;
end;


{ TTableEvents }

procedure TTableEvents.Assign(const AEvents: TObjectList<TPB_TableEvent>);
var
  C1: Integer;
begin
  Clear;
  if not Assigned(AEvents) then
    Exit;

  for C1 := 0 to AEvents.Count - 1 do
    Add(TTableEvent.Create(AEvents[C1]));
end;

end.
