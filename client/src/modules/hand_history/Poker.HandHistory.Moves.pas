unit Poker.HandHistory.Moves;

interface

uses
  System.Generics.Collections, Poker.Protobufs.Objects.MoveRow, Poker.Protobufs.Objects.TableEvent;

type
  THandHistoryMove = class
  private
    FEvents: TArray<TTableEventType>;
    FSeat: Integer;
    FBet: UINT32;
  public
    constructor Create(const AProtobuf: TPB_MoveRow);

    function ContainsEvent(const AEvent: TTableEventType): Boolean;

    property Events: TArray<TTableEventType> read FEvents;
    property Seat: Integer read FSeat;
    property Bet: UINT32 read FBet;
  end;

  THandHistoryMoves = TObjectList<THandHistoryMove>;

implementation

{ THandHistoryMove }

constructor THandHistoryMove.Create(const AProtobuf: TPB_MoveRow);
begin
  FEvents := AProtobuf.Code;
  FSeat := AProtobuf.Seat;
  FBet := AProtobuf.Bet;
end;

function THandHistoryMove.ContainsEvent(const AEvent: TTableEventType): Boolean;
var
  event: TTableEventType;
begin
  for event in FEvents do
    if event = AEvent then
      Exit(TRUE);
  Exit(FALSE);
end;


end.
