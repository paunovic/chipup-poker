unit uTableStatus;

interface

uses
  uPB_TableStatus, uPB_SeatInfo, System.SysUtils, System.Generics.Collections;

type
  TSeatInfo = class
  private
    FSeatIndex: Integer;
    FPlayerMongoId: TBytes;
    FChips: Integer;
    FCardCount: Integer;
    FCards: String;
    FStatus: TPlayerStatus;
  public
    procedure Assign(const ASeatInfoProtobuf: TPB_SeatInfo);

    property SeatIndex: Integer read FSeatIndex;
    property PlayerMongoId: TBytes read FPlayerMongoId;
    property Chips: Integer read FChips;
    property CardCount: Integer read FCardCount;
    property Cards: String read FCards;
    property Status: TPlayerStatus read FStatus;
  end;

  TSeatInfos = TObjectList<TSeatInfo>;

  TTableStatus = class
  private
    FState      : String;
    FDealer     : Integer;
    FCurrentSeat: Integer;
    FSeatInfos  : TSeatInfos;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(const ATableStatusProtobuf: TPB_TableStatus);

    property State: String read FState;
    property Dealer: Integer read FDealer;
    property CurrentSeat: Integer read FCurrentSeat;
    property Seats: TSeatInfos read FSeatInfos;
  end;

implementation

{ TSeatInfo }

procedure TSeatInfo.Assign(const ASeatInfoProtobuf: TPB_SeatInfo);
begin
  FSeatIndex := ASeatInfoProtobuf.Seat;
  FPlayerMongoId := ASeatInfoProtobuf.PlayerMongoId;
  FChips := ASeatInfoProtobuf.Chips;
  FCardCount := ASeatInfoProtobuf.CardCount;
  FCards := ASeatInfoProtobuf.Cards;
  FStatus := ASeatInfoProtobuf.Status;
end;

{ TTableStatus }

constructor TTableStatus.Create;
begin
  FSeatInfos := TSeatInfos.Create;
end;

destructor TTableStatus.Destroy;
begin
  FSeatInfos.Free;

  inherited;
end;

procedure TTableStatus.Assign(const ATableStatusProtobuf: TPB_TableStatus);
var
  C1  : Integer;
  seat: TSeatInfo;
begin
  FState := ATableStatusProtobuf.State;
  FDealer := ATableStatusProtobuf.Dealer;
  FCurrentSeat := ATableStatusProtobuf.CurrentSeat;

  FSeatInfos.Clear;
  if Assigned(ATableStatusProtobuf.Seats) then
    for C1 := 0 to ATableStatusProtobuf.Seats.Count - 1 do
    begin
      seat := TSeatInfo.Create;
      seat.Assign(ATableStatusProtobuf.Seats[C1]);
      FSeatInfos.Add(seat);
    end;
end;

end.
