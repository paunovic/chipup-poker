unit Poker.HandHistory.Players;

interface

uses
  System.SysUtils, System.Generics.Collections, Poker.Protobufs.Objects.PlayerHandHistory;

type
  TPlayerHandHistory = class
  private
    FMongoId: TBytes;
    FSeat: Integer;
    FCards: TBytes;
    FChips: UINT32;
    FNick: String;
  public
    constructor Create(const AProtobuf: TPB_PlayerHandHistory);
    destructor Destroy; override;

    property MongoId: TBytes read FMongoId;
    property Seat: Integer read FSeat;
    property Cards: TBytes read FCards;
    property Chips: UINT32 read FChips;
    property Nick: String read FNick;
  end;

  TPlayerHandHistories = class(TObjectList<TPlayerHandHistory>)
  public
    function FindPlayer(const ASeatIndex: Integer; var APlayer: TPlayerHandHistory): Boolean;
  end;

implementation

{ TPlayerHandHistory }

constructor TPlayerHandHistory.Create(const AProtobuf: TPB_PlayerHandHistory);
begin
  FMongoId := AProtobuf.MongoId;
  FSeat := AProtobuf.Seat;
  FCards := AProtobuf.Cards;
  FChips := AProtobuf.Chips;
  FNick := AProtobuf.Nick;
end;

destructor TPlayerHandHistory.Destroy;
begin

  inherited;
end;

{ TPlayerHandHistories }

function TPlayerHandHistories.FindPlayer(const ASeatIndex: Integer; var APlayer: TPlayerHandHistory): Boolean;
var
  C1: Integer;
begin
  for C1 := 0 to Length(ToArray) - 1 do
    if ToArray[C1].Seat = ASeatIndex then
    begin
      APlayer := ToArray[C1];
      Exit(TRUE);
    end;
  Exit(FALSE);
end;

end.
