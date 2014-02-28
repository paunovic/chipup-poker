unit uTableStatus;

interface

uses
  System.SyncObjs,
  uPB_TableStatus, uPB_SeatInfo, uPB_TableEvent, System.SysUtils, System.Generics.Collections, System.Generics.Defaults, uCards;

type
  TSeatInfo = class
  private
    FSeatIndex: Integer;
    FPlayerMongoId: TBytes;
    FChips: Integer;
    FCardCount: Integer;
    FCards: TCards;
    FStatus: TPlayerStatus;
    FCaption: String;

    function GetStatusStr: String;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(const ASeatInfoProtobuf: TPB_SeatInfo);

    property SeatIndex: Integer read FSeatIndex;
    property PlayerMongoId: TBytes read FPlayerMongoId;
    property Chips: Integer read FChips;
    property CardCount: Integer read FCardCount;
    property Cards: TCards read FCards;
    property Status: TPlayerStatus read FStatus;
    property StatusAsStr: String read GetStatusStr;
    property Caption: String read FCaption write FCaption;
  end;

  TSeatInfos = class(TObjectList<TSeatInfo>)
  private
    FLock: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ClearCaptions;

    procedure Lock;
    procedure Unlock;
    procedure Sort; reintroduce;
  end;

  TTableStatus = class
  private
    FState         : TTableState;
    FDealer        : Integer;
    FCurrentSeat   : Integer;
    FSeatInfos     : TSeatInfos;
    FBets          : TArray<Integer>;
    FFlopCards     : TCards;
    FTurnCard      : TCard;
    FRiverCard     : TCard;
    FSmallBlindSeat: Integer;
    FBigBlindSeat  : Integer;
    FLocked        : Boolean;
    FHighestBet    : Integer;
    FHandId        : UINT32;
    FBetLimit      : UINT32;
    FPots          : TArray<Integer>;

  public
    constructor Create;
    destructor Destroy; override;

    function GetBet(const ASeatIndex: Integer): Integer;
    function IsSeatTaken(const ASeatIndex: Integer): Boolean;
    function GetSeatInfo(const ASeatIndex: Integer; var ASeatInfo: TSeatInfo): Boolean;
    procedure Assign(const ATableStatusProtobuf: TPB_TableStatus); overload;
    procedure Assign(const ATableStatusProtobuf: TPB_TableEvent); overload;

    property State: TTableState read FState;
    property Dealer: Integer read FDealer;
    property CurrentSeat: Integer read FCurrentSeat;
    property Seats: TSeatInfos read FSeatInfos;
    property Bets: TArray<Integer> read FBets;
    property HighestBet: Integer read FHighestBet;
    property FlopCards: TCards read FFlopCards;
    property TurnCard: TCard read FTurnCard;
    property RiverCard: TCard read FRiverCard;
    property SmallBlindSeat: Integer read FSmallBlindSeat;
    property BigBlindSeat: Integer read FBigBlindSeat;
    property Locked: Boolean read FLocked;
    property HandId: UINT32 read FHandId;
    property Pots: TArray<Integer> read FPots;
    property BetLimit: UINT32 read FBetLimit;
  end;

implementation

uses
  uCommon;

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
  FChips := ASeatInfoProtobuf.Chips;
  FCardCount := ASeatInfoProtobuf.CardCount;
  FCards.Assign(ASeatInfoProtobuf.Cards);
  FStatus := ASeatInfoProtobuf.Status;
end;


function TSeatInfo.GetStatusStr: String;
begin
  case FStatus of
    psOutOfPlay: result := 'OutOfPlay';
    psOutOfHand: result := 'OutOfHand';
    psInHand: result := 'InHand';
    psFolded: result := 'Folded';
    psAllIn: result := 'AllIn';
    psStandingUp: result := 'StandingUp';
  end;
end;

{ TTableStatus }

constructor TTableStatus.Create;
begin
  FDealer := -1;
  FCurrentSeat := -1;
  FSeatInfos := TSeatInfos.Create;

  FFlopCards := TCards.Create;
  FTurnCard := TCard.Create;
  FRiverCard := TCard.Create;
end;

destructor TTableStatus.Destroy;
begin
  FSeatInfos.Free;

  FFlopCards.Free;
  FTurnCard.Free;
  FRiverCard.Free;

  inherited;
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
  C1, C2: Integer;
  seat  : TSeatInfo;
  delete: Boolean;
begin
  FState := ATableStatusProtobuf.State;
  FDealer := ATableStatusProtobuf.Dealer;
  FSmallBlindSeat := ATableStatusProtobuf.SmallBlind;
  FBigBlindSeat := ATableStatusProtobuf.BigBlind;
  FCurrentSeat := ATableStatusProtobuf.CurrentSeat;
  FHighestBet := ATableStatusProtobuf.MinimumBet;
  FHandId := ATableStatusProtobuf.Handid;
  if State <> tsWinning then
  begin
    FFlopCards.Assign(ATableStatusProtobuf.Flop);
    FTurnCard.Assign(ATableStatusProtobuf.Turn);
    FRiverCard.Assign(ATableStatusProtobuf.River);
  end;

  if Assigned(ATableStatusProtobuf.Seats) then
  begin
    C1 := 0;
    FSeatInfos.Lock;
    try
      while C1 < FSeatInfos.Count do
      begin
        delete := TRUE;
        for C2 := 0 to ATableStatusProtobuf.Seats.Count - 1 do
          if ATableStatusProtobuf.Seats[C2].Seat = FSeatInfos[C1].SeatIndex then
          begin
            delete := FALSE;
            Break;
          end;

        if delete then
          FSeatInfos.Delete(C1)
        else
          Inc(C1);
      end;

      for C1 := 0 to ATableStatusProtobuf.Seats.Count - 1 do
      begin
        seat := nil;
        for C2 := 0 to FSeatInfos.Count - 1 do
          if FSeatInfos[C2].SeatIndex = ATableStatusProtobuf.Seats[C1].Seat then
          begin
            seat := FSeatInfos[C2];
            Break;
          end;
        if not Assigned(seat) then
        begin
          seat := TSeatInfo.Create;
          FSeatInfos.Add(seat);
        end;
        seat.Assign(ATableStatusProtobuf.Seats[C1]);
      end;

      FSeatInfos.Sort;
    finally
      FSeatInfos.Unlock;
    end;
  end
  else
    FSeatInfos.Clear;

  case FState of
    tsIdle: begin
      FSmallBlindSeat := -1;
      FBigBlindSeat := -1;
    end;
  end;

  FBets := ATableStatusProtobuf.Bets;
  FLocked := ATableStatusProtobuf.Locked;
  FBetLimit := ATableStatusProtobuf.BetLimit;
  FPots := ATableStatusProtobuf.Pots;
end;

procedure TTableStatus.Assign(const ATableStatusProtobuf: TPB_TableEvent);
begin
  case ATableStatusProtobuf.Event of
    teFold: ;
    teSit: ;
    teStandUp: ;
    teWinning: ;
    teDealing: ;
    teCheck: ;
    teCall: ;
    teRaise: ;
    teAllIn: ;
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

procedure TSeatInfos.ClearCaptions;
var
  C1: Integer;
begin
  for C1 := Low(ToArray) to High(ToArray) do
    ToArray[C1].Caption := '';
end;

constructor TSeatInfos.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
end;

destructor TSeatInfos.Destroy;
begin
  FLock.Free;
  inherited;
end;

procedure TSeatInfos.Lock;
begin
  FLock.Acquire;
end;

procedure TSeatInfos.Unlock;
begin
  FLock.Release;
end;

end.
