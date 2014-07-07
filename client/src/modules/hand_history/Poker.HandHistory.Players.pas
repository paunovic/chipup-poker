unit Poker.HandHistory.Players;

interface

uses
  System.SysUtils, System.Generics.Collections, Poker.Protobufs.Objects.PlayerHandHistory, Poker.Protobufs.Objects.SeatInfo;

type
  TPlayerHandHistory = class
  private
    FMongoId: TBytes;
    FSeat: Integer;
    FCards: TBytes;
    FCardsStr: String;
    FChips: UINT32;
    FNick: String;
    FMucked: Boolean;
    FStatus: TPlayerStatus;
  public
    constructor Create(const AProtobuf: TPB_PlayerHandHistory);

    property MongoId: TBytes read FMongoId;
    property Seat: Integer read FSeat;
    property Cards: TBytes read FCards;
    property CardsStr: String read FCardsStr;
    property Chips: UINT32 read FChips;
    property Nick: String read FNick;
    property Mucked: Boolean read FMucked;
    property Status: TPlayerStatus read FStatus;
  end;

  TPlayerHandHistories = class(TObjectDictionary<Integer, TPlayerHandHistory>)
  public
    constructor Create;
  end;

implementation

uses
  Poker.Cards;

{ TPlayerHandHistory }

constructor TPlayerHandHistory.Create(const AProtobuf: TPB_PlayerHandHistory);
begin
  FMongoId := AProtobuf.MongoId;
  FSeat := AProtobuf.Seat;
  FCards := AProtobuf.Cards;
  FCardsStr := TCards.BytesToString(FCards);
  FChips := AProtobuf.Chips;
  FNick := AProtobuf.Nick;
  FMucked := AProtobuf.Muck;
  FStatus := AProtobuf.Status;
end;

{ TPlayerHandHistories }

constructor TPlayerHandHistories.Create;
begin
  inherited Create([doOwnsValues]);
end;

end.
