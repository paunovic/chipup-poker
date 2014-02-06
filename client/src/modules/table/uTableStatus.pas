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
    FState         : TTableState;
    FDealer        : Integer;
    FCurrentSeat   : Integer;
    FSeatInfos     : TSeatInfos;
    FBets          : TArray<Integer>;
    FFlopCards     : String;
    FTurnCard      : String;
    FRiverCard     : String;
    FSmallBlindSeat: Integer;
    FBigBlindSeat  : Integer;

    function GetHighestBet: Integer;

  public
    constructor Create;
    destructor Destroy; override;

    function GetNextSeatIndex(const ACurrentSeatIndex: Integer; const AOnlyInHand: Boolean): Integer;
    function GetBet(const ASeatIndex: Integer): Integer;
    function IsSeatTaken(const ASeatIndex: Integer): Boolean;
    function GetSeatInfo(const ASeatIndex: Integer; var ASeatInfo: TSeatInfo): Boolean;
    procedure Assign(const ATableStatusProtobuf: TPB_TableStatus);

    property State: TTableState read FState;
    property Dealer: Integer read FDealer;
    property CurrentSeat: Integer read FCurrentSeat;
    property Seats: TSeatInfos read FSeatInfos;
    property Bets: TArray<Integer> read FBets;
    property HighestBet: Integer read GetHighestBet;
    property FlopCards: String read FFlopCards;
    property TurnCard: String read FTurnCard;
    property RiverCard: String read FRiverCard;
    property SmallBlindSeat: Integer read FSmallBlindSeat;
    property BigBlindSeat: Integer read FBigBlindSeat;
  end;

implementation

uses
  uCommon;

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
  FDealer := -1;
  FCurrentSeat := -1;
  FSeatInfos := TSeatInfos.Create;
end;

destructor TTableStatus.Destroy;
begin
  FSeatInfos.Free;

  inherited;
end;

function TTableStatus.GetNextSeatIndex(const ACurrentSeatIndex: Integer; const AOnlyInHand: Boolean): Integer;
var
  C1   : Integer;
  seat : TSeatInfo;
  index: Integer;
begin
  if not Assigned(FSeatInfos) then
    Exit(-1);

  index := -1;
  for C1 := 0 to FSeatInfos.Count - 1 do
    if FSeatInfos[C1].SeatIndex = ACurrentSeatIndex then
    begin
      if C1 = FSeatInfos.Count - 1 then
        index := FSeatInfos[0].SeatIndex
      else
        index := FSeatInfos[C1 + 1].SeatIndex;
      Break;
    end;

  if (index = -1) or
     (not AOnlyInHand) then
    Exit(index);

  if GetSeatInfo(index, seat) then
  begin
    while seat.Status <> psInHand do
    begin
      index := GetNextSeatIndex(index, AOnlyInHand);
      if (not GetSeatInfo(index, seat)) or
         (index = ACurrentSeatIndex) then
        Exit(-1);
    end;
    Exit(seat.SeatIndex);
  end
  else
    Exit(-1);
end;

function TTableStatus.GetHighestBet: Integer;
var
  C1: Integer;
begin
  result := 0;
  for C1 := Low(FBets) to High(FBets) do
    if FBets[C1] > result then
      result := FBets[C1];
end;

function TTableStatus.GetBet(const ASeatIndex: Integer): Integer;
begin
  if (ASeatIndex < Low(FBets)) or
     (ASeatIndex > High(FBets)) then
    Exit(0)
  else
    Exit(FBets[ASeatIndex]);
end;

function TTableStatus.GetSeatInfo(const ASeatIndex: Integer; var ASeatInfo: TSeatInfo): Boolean;
var
  C1: Integer;
begin
  for C1 := 0 to FSeatInfos.Count - 1 do
    if FSeatInfos[C1].SeatIndex = ASeatIndex then
    begin
      ASeatInfo := FSeatInfos[C1];
      Exit(TRUE);
    end;

  Exit(FALSE);
end;

function TTableStatus.IsSeatTaken(const ASeatIndex: Integer): Boolean;
var
  C1: Integer;
begin
  if not Assigned(FSeatInfos) then
    Exit(FALSE);

  for C1 := 0 to FSeatInfos.Count - 1 do
    if FSeatInfos[C1].SeatIndex = ASeatIndex then
      Exit(TRUE);
  Exit(FALSE);
end;

procedure TTableStatus.Assign(const ATableStatusProtobuf: TPB_TableStatus);
var
  C1   : Integer;
  seat : TSeatInfo;
begin
  FState := ATableStatusProtobuf.State;
  FDealer := ATableStatusProtobuf.Dealer;
  FCurrentSeat := ATableStatusProtobuf.CurrentSeat;
  FFlopCards := ATableStatusProtobuf.Flop;
  FTurnCard := ATableStatusProtobuf.Turn;
  FRiverCard := ATableStatusProtobuf.River;

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

  case FState of
    tsIdle: begin
      FSmallBlindSeat := -1;
      FBigBlindSeat := -1;
    end;
    tsPreFlop: begin
      FSmallBlindSeat := GetNextSeatIndex(FDealer, TRUE);
      FBigBlindSeat := GetNextSeatIndex(FSmallBlindSeat, TRUE);
    end;
  end;

  FBets := ATableStatusProtobuf.Bets;
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
