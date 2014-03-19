unit PokerClient.Table.Status;

interface

uses
  PokerClient.Protobufs.Objects.TableStatus, PokerClient.Protobufs.Objects.SeatInfo, PokerClient.Protobufs.Objects.TableEvent,
  System.SysUtils, System.Generics.Collections, System.Generics.Defaults, PokerClient.Cards, PokerClient.Protobufs.Objects.Pot;

type
  TSeatInfo = class
  private
    FSeatIndex: Integer;
    FPlayerMongoId: TBytes;
    FChips: Integer;
    FCardCount: Integer;
    FCards: TCards;
    FDealtCards: Integer;
    FStatus: TPlayerStatus;
    FCaption: String;
    FTimebank: UINT32;

    function GetStatusStr: String;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(const ASeatInfoProtobuf: TPB_SeatInfo);

    procedure ResetDealtCards;
    procedure IncDealtCards;
    procedure FillDealtCards;

    property SeatIndex: Integer read FSeatIndex;
    property PlayerMongoId: TBytes read FPlayerMongoId;
    property Chips: Integer read FChips;
    property CardCount: Integer read FCardCount;
    property Cards: TCards read FCards;
    property Status: TPlayerStatus read FStatus;
    property StatusAsStr: String read GetStatusStr;
    property Caption: String read FCaption write FCaption;
    property Timebank: UINT32 read FTimeBank;
    property DealtCards: Integer read FDealtCards;
  end;

  TSeatInfos = class(TObjectList<TSeatInfo>)
  private
  public
    procedure ClearCaptions;

    procedure Sort; reintroduce;
  end;

  TPotInfo = class
  private
    FValue: UINT32;
    FMembers: TArray<UINT32>;
    FAnimating: Boolean;
  public
    procedure Assign(const APotProtobuf: TPB_Pot); overload;
    procedure Assign(const APot: TPotInfo); overload;

    property Value: UINT32 read FValue;
    property Members: TArray<UINT32> read FMembers;
    property Animating: Boolean read FAnimating write FAnimating;
  end;

  TPotInfos = class(TObjectList<TPotInfo>)
  private
  public
    procedure Assign(const APots: TObjectList<TPB_Pot>); overload;
    procedure Assign(const APots: TPotInfos); overload;
  end;

  TTableStatus = class
  private
    FState         : TTableState;
    FDealer        : Integer;
    FCurrentSeat   : Integer;
    FSeatInfos     : TSeatInfos;
    FBets          : TArray<UINT32>;
    FFlopCards     : TCards;
    FTurnCard      : TCard;
    FRiverCard     : TCard;
    FSmallBlindSeat: Integer;
    FBigBlindSeat  : Integer;
    FLocked        : Boolean;
    FMinimumBet    : Integer;
    FHandId        : UINT32;
    FMaximumBet    : UINT32;
    FPreviousPots  : TPotInfos;
    FPots          : TPotInfos;
    FTime          : UINT64;

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
    property Bets: TArray<UINT32> read FBets;
    property MinimumBet: Integer read FMinimumBet;
    property FlopCards: TCards read FFlopCards;
    property TurnCard: TCard read FTurnCard;
    property RiverCard: TCard read FRiverCard;
    property SmallBlindSeat: Integer read FSmallBlindSeat;
    property BigBlindSeat: Integer read FBigBlindSeat;
    property Locked: Boolean read FLocked;
    property HandId: UINT32 read FHandId;
    property Pots: TPotInfos read FPots;
    property PreviousPots: TPotInfos read FPreviousPots;
    property MaximumBet: UINT32 read FMaximumBet;
    property Time: UINT64 read FTime;
  end;

implementation

uses
  PokerClient.Common.Misc;

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
  FTimeBank := ASeatInfoProtobuf.Timebank;
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


{ TTableStatus }

constructor TTableStatus.Create;
begin
  FDealer := -1;
  FCurrentSeat := -1;
  FSeatInfos := TSeatInfos.Create;

  FPreviousPots := TPotInfos.Create;
  FPots := TPotInfos.Create;
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
  FPots.Free;
  FPreviousPots.Free;

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
  FMinimumBet := ATableStatusProtobuf.MinimumBet;
  FHandId := ATableStatusProtobuf.Handid;
  FTime := ATableStatusProtobuf.Time;
  FBets := ATableStatusProtobuf.Bets;
  FLocked := ATableStatusProtobuf.Locked;
  FMaximumBet := ATableStatusProtobuf.MaximumLimit;
  FPreviousPots.Assign(FPots);
  FPots.Assign(ATableStatusProtobuf.Pots);

  if State <> tsWinning then
  begin
    FFlopCards.Assign(ATableStatusProtobuf.Flop);
    FTurnCard.Assign(ATableStatusProtobuf.Turn);
    FRiverCard.Assign(ATableStatusProtobuf.River);
  end;

  if Assigned(ATableStatusProtobuf.Seats) then
  begin
    C1 := 0;
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
  end
  else
    FSeatInfos.Clear;

  case FState of
    tsIdle: begin
      FSmallBlindSeat := -1;
      FBigBlindSeat := -1;
    end;
  end;
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

{ TPotInfo }

procedure TPotInfo.Assign(const APotProtobuf: TPB_Pot);
begin
  FValue := APotProtobuf.Value;
  FMembers := APotProtobuf.Members;
end;


procedure TPotInfo.Assign(const APot: TPotInfo);
begin
  FValue := APot.Value;
  FMembers := APot.Members;
end;

{ TPotInfos }

procedure TPotInfos.Assign(const APots: TObjectList<TPB_Pot>);
var
  pot: TPotInfo;
  C1 : Integer;
begin
  Clear;

  for C1 := 0 to APots.Count - 1 do
  begin
    pot := TPotInfo.Create;
    pot.Assign(APots[C1]);
    Add(pot);
  end;
end;

procedure TPotInfos.Assign(const APots: TPotInfos);
var
  pot: TPotInfo;
  C1 : Integer;
begin
  Clear;

  for C1 := 0 to APots.Count - 1 do
  begin
    pot := TPotInfo.Create;
    pot.Assign(APots[C1]);
    Add(pot);
  end;
end;

end.
