unit Poker.HandHistory.Moves;

interface

uses
  System.Generics.Collections, Poker.Protobufs.Objects.MoveRow, Poker.Protobufs.Objects.TableEvent, Poker.Objects.PotInfo;

type
  THandHistoryMove = class
  private
    FEvents: TList<TTableEventType>;
    FSeat: Integer;
    FBet: UINT32;
    FWinnerPots: TPotInfos;
    FPots: TPotInfos;
  public
    constructor Create(const AProtobuf: TPB_MoveRow);
    destructor Destroy; override;

    function ContainsEvent(const AEvent: TTableEventType): Boolean;

    property Events: TList<TTableEventType> read FEvents;
    property Seat: Integer read FSeat;
    property Bet: UINT32 read FBet;
    property WinnerPots: TPotInfos read FWinnerPots;
    property Pots: TPotInfos read FPots;
  end;

  THandHistoryMoves = TObjectList<THandHistoryMove>;

implementation

{ THandHistoryMove }

constructor THandHistoryMove.Create(const AProtobuf: TPB_MoveRow);
begin
  FEvents := TList<TTableEventType>.Create;
  FEvents.AddRange(AProtobuf.Code);
  FSeat := AProtobuf.Seat;
  FBet := AProtobuf.Bet;
  FWinnerPots := TPotInfos.Create;
  FWinnerPots.Assign(AProtobuf.Potdata);
  FPots := TPotInfos.Create;
  FPots.Assign(AProtobuf.Pots, 0);
end;

destructor THandHistoryMove.Destroy;
begin
  FEvents.Free;
  FPots.Free;
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
