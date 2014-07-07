unit Poker.Seats.Seat;

interface

uses
  System.SysUtils, Poker.Cards, Poker.Protobufs.Objects.SeatInfo, Poker.Players.Player;

type
  TSeatInfo = class
  private
    FSeatIndex: Integer;
    FPlayerMongoId: TBytes;
    FPreviousChips: UINT32;
    FChips: UINT32;
    FCardCount: Integer;
    FCards: TCards;
    FDealtCards: Integer;
    FStatus: TPlayerStatus;
    FUpperCaption: String;
    FLowerCaption: String;
    FTimebank: UINT32;
    FCardsVisible: Boolean;
    FCanShow: Boolean;
    FDisconnected: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(const ASeatInfoProtobuf: TPB_SeatInfo);

    procedure ResetDealtCards;
    procedure IncDealtCards;
    procedure FillDealtCards;

    procedure InitToDemoValues(const ASeatIndex: Integer; const AUpperCaption: String; const AChips: UINT32; const ACardCount: Integer; const AMongoId: TBytes);

    property SeatIndex: Integer read FSeatIndex;
    property PlayerMongoId: TBytes read FPlayerMongoId;
    property PreviousChips: UINT32 read FPreviousChips;
    property Chips: UINT32 read FChips;
    property CardCount: Integer read FCardCount;
    property Cards: TCards read FCards;
    property Status: TPlayerStatus read FStatus;
    property UpperCaption: String read FUpperCaption write FUpperCaption;
    property LowerCaption: String read FLowerCaption write FLowerCaption;
    property Timebank: UINT32 read FTimeBank;
    property DealtCards: Integer read FDealtCards;
    property CardsVisible: Boolean read FCardsVisible write FCardsVisible;
    property Disconnected: Boolean read FDisconnected;
    property CanShow: Boolean read FCanShow;
  end;

implementation

{ TSeatInfo }

constructor TSeatInfo.Create;
begin
  FCards := TCards.Create;
end;

destructor TSeatInfo.Destroy;
begin
  FCards.Free;

  inherited;
end;

procedure TSeatInfo.Assign(const ASeatInfoProtobuf: TPB_SeatInfo);
begin
  FSeatIndex := ASeatInfoProtobuf.Seat;
  FPlayerMongoId := ASeatInfoProtobuf.PlayerMongoId;
  FPreviousChips := FChips;
  FChips := ASeatInfoProtobuf.Chips;
  FCardCount := ASeatInfoProtobuf.CardCount;
  FCards.Assign(ASeatInfoProtobuf.Cards);
  FStatus := ASeatInfoProtobuf.Status;
  FTimeBank := ASeatInfoProtobuf.Timebank;
  FCardsVisible := ASeatInfoProtobuf.CardsVisible;
  FDisconnected := ASeatInfoProtobuf.Disconnected;
  FCanShow := ASeatInfoProtobuf.CanShow;
end;

procedure TSeatInfo.InitToDemoValues(const ASeatIndex: Integer; const AUpperCaption: String; const AChips: UINT32; const ACardCount: Integer; const AMongoId: TBytes);
begin
  FSeatIndex := ASeatIndex;
  FPlayerMongoId := Copy(AMongoId, 0, Length(AMongoId));
  FChips := AChips;
  FPreviousChips := AChips;
  FCards.Clear;
  FDealtCards := ACardCount;
  FCardCount := ACardCount;
  FStatus := psInHand;
  FUpperCaption := AUpperCaption;
  FLowerCaption := '';
  FTimebank := 0;
  FCardsVisible := FALSE;
  FCanShow := FALSE;
  FDisconnected := FALSE;
end;

procedure TSeatInfo.IncDealtCards;
begin
  Inc(FDealtCards);
end;

procedure TSeatInfo.ResetDealtCards;
begin
  FDealtCards := 0;
end;

procedure TSeatInfo.FillDealtCards;
begin
  FDealtCards := FCardCount;
end;


end.
