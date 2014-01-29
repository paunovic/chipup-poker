unit uTableStatus;

interface

uses
  uPB_TableStatus, uPB_SeatInfo, System.SysUtils, System.Generics.Collections, System.Generics.Defaults;

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

  TSeatInfos = class(TObjectList<TSeatInfo>)
    procedure Sort; reintroduce;
  end;

  TTableStatus = class
  private
    FState      : String;
    FDealer     : Integer;
    FCurrentSeat: Integer;
    FSeatInfos  : TSeatInfos;

    function GetBigBlindSeat: Integer;
    function GetSmallBlindSeat: Integer;

  public
    constructor Create;
    destructor Destroy; override;

    function GetNextSeatIndex(const ACurrentSeatIndex: Integer): Integer;
    procedure Assign(const ATableStatusProtobuf: TPB_TableStatus);

    property State: String read FState;
    property Dealer: Integer read FDealer;
    property SmallBlindSeat: Integer read GetSmallBlindSeat;
    property BigBlindSeat: Integer read GetBigBlindSeat;
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

function TTableStatus.GetNextSeatIndex(const ACurrentSeatIndex: Integer): Integer;
var
  C1: Integer;
begin
  if not Assigned(FSeatInfos) then
    Exit(-1);

  result := -1;
  for C1 := 0 to FSeatInfos.Count - 1 do
    if FSeatInfos[C1].SeatIndex = ACurrentSeatIndex then
    begin
      if C1 = FSeatInfos.Count - 1 then
        result := FSeatInfos[0].SeatIndex
      else
        result := FSeatInfos[C1 + 1].SeatIndex;
      Break;
    end;
end;

function TTableStatus.GetBigBlindSeat: Integer;
begin
  result := GetNextSeatIndex(GetSmallBlindSeat);
end;

function TTableStatus.GetSmallBlindSeat: Integer;
begin
  result := GetNextSeatIndex(FDealer);
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
  begin
    for C1 := 0 to ATableStatusProtobuf.Seats.Count - 1 do
    begin
      seat := TSeatInfo.Create;
      seat.Assign(ATableStatusProtobuf.Seats[C1]);
      FSeatInfos.Add(seat);
    end;
    FSeatInfos.Sort;
  end;
end;

{ TSeatInfos }

procedure TSeatInfos.Sort;
var
  comparer  : IComparer<TSeatInfo>;
  comparison: TComparison<TSeatInfo>;
begin
  comparison := function(const ASeatInfo1, ASeatInfo2: TSeatInfo): Integer
  begin
    if ASeatInfo1.SeatIndex < ASeatInfo2.SeatIndex then
      result := -1
    else
      if ASeatInfo1.SeatIndex > ASeatInfo2.SeatIndex then
        result := 1
      else
        result := 0;
  end;

  comparer := TComparer<TSeatInfo>.Construct(comparison);
  inherited Sort(comparer);
end;

end.
