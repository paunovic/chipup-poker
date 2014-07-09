unit Poker.HandHistory.Moves;

interface

uses
  System.Generics.Collections, Poker.Protobufs.Objects.MoveRow, Poker.Protobufs.Objects.TableEvent, Poker.Pots.PotList;

type
  THandHistoryMove = class
  private
    FEvents: TList<TTableEventType>;
    FSeat: Integer;
    FBet: UINT32;
    FWinnerPots: TPotList;
    FPots: TPotList;
  public
    constructor Create(const AProtobuf: TPB_MoveRow);
    destructor Destroy; override;

    function ContainsEvent(const AEvent: TTableEventType): Boolean;

    property Events: TList<TTableEventType> read FEvents;
    property Seat: Integer read FSeat;
    property Bet: UINT32 read FBet;
    property WinnerPots: TPotList read FWinnerPots;
    property Pots: TPotList read FPots;
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
  FWinnerPots := TPotList.Create;
  FWinnerPots.Assign(AProtobuf.WinnerPotData);
  FPots := TPotList.Create;
  FPots.Assign(AProtobuf.Pots);
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
