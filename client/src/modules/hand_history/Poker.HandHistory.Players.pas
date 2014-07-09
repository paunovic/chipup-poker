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

  TPlayerHandHistories = class(TObjectList<TPlayerHandHistory>)
  private
    procedure NotifyEvent(Sender: TObject; const AValue: TPlayerHandHistory; AAction: TCollectionNotification);
  public
    constructor Create;
    procedure Sort;
    function FindPlayer(const ASeat: Integer; out APlayer: TPlayerHandHistory): Boolean;
  end;

implementation

uses
  Poker.Cards, System.Generics.Defaults;

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
  inherited Create;
  OnNotify := NotifyEvent;
end;

procedure TPlayerHandHistories.NotifyEvent(Sender: TObject; const AValue: TPlayerHandHistory; AAction: TCollectionNotification);
begin
  Sort;
end;

procedure TPlayerHandHistories.Sort;
var
  comparer: IComparer<TPlayerHandHistory>;
begin
  comparer := TComparer<TPlayerHandHistory>.Construct(
    function(const APlayerHandHistory1, APlayerHandHistory2: TPlayerHandHistory): Integer
    begin
      if APlayerHandHistory1.Seat < APlayerHandHistory2.Seat then
        result := -1
      else
        if APlayerHandHistory1.Seat > APlayerHandHistory2.Seat then
          result := 1
        else
          result := 0;
    end
  );

  inherited Sort(comparer);
end;

function TPlayerHandHistories.FindPlayer(const ASeat: Integer; out APlayer: TPlayerHandHistory): Boolean;
var
  phh: TPlayerHandHistory;
begin
  for phh in ToArray do
    if phh.Seat = ASeat then
    begin
      APlayer := phh;
      Exit(TRUE);
    end;
  Exit(FALSE);
end;

end.
