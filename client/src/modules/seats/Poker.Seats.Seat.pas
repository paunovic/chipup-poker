unit Poker.Seats.Seat;

interface

uses
  System.SysUtils, Poker.Cards, Poker.Protobufs.Objects.SeatInfo, Poker.Players.Player;

type
  TSeatInfo = class(TPB_SeatInfo)
  private
    FPreviousChips: UINT32;
    FCards: TCards;
    FDealtCards: Integer;
    FUpperCaption: String;
    FLowerCaption: String;
    FLastDisconnectedBlink: TDateTime;
    FShowDisconnectedLabel: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(const ASeatInfoProtobuf: TPB_SeatInfo); overload;
    procedure Assign(const ASeatInfo: TSeatInfo); overload;

    property Cards: TCards read FCards;
    property PreviousChips: UINT32 read FPreviousChips;
    property DealtCards: Integer read FDealtCards write FDealtCards;
    property UpperCaption: String read FUpperCaption write FUpperCaption;
    property LowerCaption: String read FLowerCaption write FLowerCaption;
    property LastDisconnectedBlink: TDateTime read FLastDisconnectedBlink write FLastDisconnectedBlink;
    property ShowDisconnectedLabel: Boolean read FShowDisconnectedLabel write FShowDisconnectedLabel;
  end;

implementation

{ TSeatInfo }


constructor TSeatInfo.Create;
begin
  inherited Create(TRUE);
  FCards := TCards.Create;
end;

destructor TSeatInfo.Destroy;
begin
  FCards.Free;
  inherited;
end;

procedure TSeatInfo.Assign(const ASeatInfoProtobuf: TPB_SeatInfo);
begin
  SeatIndex := ASeatInfoProtobuf.SeatIndex;
  PlayerMongoId := ASeatInfoProtobuf.PlayerMongoId;
  FPreviousChips := Chips;
  Chips := ASeatInfoProtobuf.Chips;
  CardCount := ASeatInfoProtobuf.CardCount;
  Cards.Assign(ASeatInfoProtobuf.Cards);
  Status := ASeatInfoProtobuf.Status;
  TimeBank := ASeatInfoProtobuf.Timebank;
  CardsVisible := ASeatInfoProtobuf.CardsVisible;
  Disconnected := ASeatInfoProtobuf.Disconnected;
  if not Disconnected then
    FShowDisconnectedLabel := FALSE;
  CanShow := ASeatInfoProtobuf.CanShow;
  AutoPlay := ASeatInfoProtobuf.Autoplay;
end;

procedure TSeatInfo.Assign(const ASeatInfo: TSeatInfo);
var
  C1: Integer;
begin
  SeatIndex := ASeatInfo.SeatIndex;
  PlayerMongoId := ASeatInfo.PlayerMongoId;
  FPreviousChips := ASeatInfo.PreviousChips;
  Chips := ASeatInfo.Chips;
  CardCount := ASeatInfo.CardCount;
  Cards.Clear;
  for C1 := 0 to ASeatInfo.FCards.Count - 1 do
    Cards.Add(TCard.Create(ASeatInfo.FCards[C1].Value, ASeatInfo.FCards[C1].Suit));
  Status := ASeatInfo.Status;
  TimeBank := ASeatInfo.Timebank;
  CardsVisible := ASeatInfo.CardsVisible;
  Disconnected := ASeatInfo.Disconnected;
  CanShow := ASeatInfo.CanShow;
  FDealtCards := ASeatInfo.DealtCards;
  AutoPlay := ASeatInfo.Autoplay;
  FUpperCaption := ASeatInfo.UpperCaption;
  FLowerCaption := ASeatInfo.LowerCaption;
  FLastDisconnectedBlink := ASeatInfo.LastDisconnectedBlink;
  FShowDisconnectedLabel := ASeatInfo.ShowDisconnectedLabel;
end;

end.
