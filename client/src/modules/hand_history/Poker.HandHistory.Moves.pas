unit Poker.HandHistory.Moves;

interface

uses
  System.Generics.Collections, Poker.Protobufs.Objects.MoveRow, Poker.Protobufs.Objects.TableEvent, Poker.Objects.PotInfo;

type
  THandHistoryMove = class
  private
    FEvents: TArray<TTableEventType>;
    FSeat: Integer;
    FBet: UINT32;
    FWinnerPots: TPotInfos;
  public
    constructor Create(const AProtobuf: TPB_MoveRow);
    destructor Destroy; override;

    function ContainsEvent(const AEvent: TTableEventType): Boolean;

    property Events: TArray<TTableEventType> read FEvents;
    property Seat: Integer read FSeat;
    property Bet: UINT32 read FBet;
    property WinnerPots: TPotInfos read FWinnerPots;
  end;

  THandHistoryMoves = TObjectList<THandHistoryMove>;

implementation

{ THandHistoryMove }

constructor THandHistoryMove.Create(const AProtobuf: TPB_MoveRow);
begin
  FEvents := AProtobuf.Code;
  FSeat := AProtobuf.Seat;
  FBet := AProtobuf.Bet;
  FWinnerPots := TPotInfos.Create;
  FWinnerPots.Assign(AProtobuf.Potdata);
end;

destructor THandHistoryMove.Destroy;
begin
  FWinnerPots.Free;
  inherited;
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
