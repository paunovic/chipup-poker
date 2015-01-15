unit Poker.Tables.Status;

interface

uses
  Winapi.Windows, System.Generics.Collections, Poker.Protobufs.Objects.TableStatus, Poker.Cards, Poker.Protobufs.Objects.Game,
  Poker.Seats.SeatList, Poker.Games.Game, Poker.Seats.Seat, Poker.Protobufs.Objects.TableEvent, Poker.Protobufs.Objects.Pot,
  Poker.Protobufs.Objects.TableMessage;

type
  TTableStatus = class
  private
    FState: TTableState;
    FDealer: Integer;
    FCurrentSeat: Integer;
    FSeats: TSeatList;
    FBets: TList<UINT32>;
    FPreviousBets: TList<UINT32>;
    FFlopCards: TObjectList<TCards>;
    FTurnCard: TObjectList<TCard>;
    FRiverCard: TObjectList<TCard>;
    FSmallBlindSeat: Integer;
    FBigBlindSeat: Integer;
    FRakePercent: UINT32;
    FLocked: Boolean;
    FMinimumBet: UINT32;
    FHandId: UINT32;
    FMaximumRaise: UINT32;
    FPreviousPots: TPB_PotList;
    FPots: TPB_PotList;
    FTime: UINT64;
    FRotationHand: UINT32;
    FCurrentGame: TGameType;
    FCurrentLimit: TGameLimit;
    FMinimumRaise: UINT32;
    FClosingTime: DWORD;
    FTimebarEndtime: DWORD;
    FCurrentPlaytime: Int64;
    FSelfSeatIndex: Integer;
    FMessages: TObjectList<TPB_TableMessage>;

    FActionStandUp: Boolean;
    FActionFold: Boolean;
    FActionCall: Boolean;
    FActionCheck: Boolean;
    FActionRaise: Boolean;
    FActionBet: Boolean;
    FActionPlayNow: Boolean;
    FActionSitOut: Boolean;
    FActionFoldToAny: Boolean;
    FActionSitOutNextBB: Boolean;
    FActionShowCards: Boolean;
    FActionShowStats: Boolean;
    FEvents: TPB_TableEventList;

    FAutoCheckVisible: Boolean;
    FAutoCheckFoldVisible: Boolean;
    FAutoFoldVisible: Boolean;
    FAutoCallVisible: Boolean;
    FAutoCallAnyVisible: Boolean;

    FCallCaption: String;
    FAutoCallCaption: String;
    FResetRaiseValue: Boolean;
    FFocusWindow: Boolean;
    FTotalRake: UINT32;
    FAutoCallAmount: UINT32;
  public
    constructor Create;
    destructor Destroy; override;

    function GetBet(const ASeatIndex: Integer): UINT32;
    function IsSeatTaken(const ASeatIndex: Integer): Boolean;
    function GetSeatInfo(const ASeatIndex: Integer; var ASeatInfo: TSeatInfo): Boolean;
    procedure Assign(const ATableStatusProtobuf: TPB_TableStatus);

    procedure UpdateClosingTime(const AGame: TGameInfo);
    procedure UpdateCurrentPlaytime;
    procedure NewHandCleanup;
    function GetCallAmount(out AState: TTableState): UINT32;

    property State: TTableState read FState;
    property Dealer: Integer read FDealer;
    property CurrentSeat: Integer read FCurrentSeat;
    property Seats: TSeatList read FSeats;
    property Bets: TList<UINT32> read FBets write FBets;
    property PreviousBets: TList<UINT32> read FPreviousBets;
    property MinimumBet: UINT32 read FMinimumBet;
    property FlopCards: TObjectList<TCards> read FFlopCards;
    property TurnCard: TObjectList<TCard> read FTurnCard;
    property RiverCard: TObjectList<TCard> read FRiverCard;
    property SmallBlindSeat: Integer read FSmallBlindSeat;
    property BigBlindSeat: Integer read FBigBlindSeat;
    property Locked: Boolean read FLocked;
    property HandId: UINT32 read FHandId;
    property Pots: TPB_PotList read FPots write FPots;
    property PreviousPots: TPB_PotList read FPreviousPots;
    property MaximumRaise: UINT32 read FMaximumRaise;
    property Time: UINT64 read FTime;
    property RotationHand: UINT32 read FRotationHand;
    property CurrentGame: TGameType read FCurrentGame;
    property CurrentLimit: TGameLimit read FCurrentLimit;
    property MinimumRaise: UINT32 read FMinimumRaise;
    property ClosingTime: DWORD read FClosingTime;
    property TimebarEndtime: DWORD read FTimebarEndtime;
    property CurrentPlaytime: Int64 read FCurrentPlaytime;
    property RakePercent: UINT32 read FRakePercent;
    property SelfSeatIndex: Integer read FSelfSeatIndex;
    property TotalRake: UINT32 read FTotalRake;

    function IsSitting: Boolean;

    property ActionStandUp: Boolean read FActionStandUp write FActionStandUp;
    property ActionFold: Boolean read FActionFold write FActionFold;
    property ActionCall: Boolean read FActionCall write FActionCall;
    property ActionCheck: Boolean read FActionCheck write FActionCheck;
    property ActionRaise: Boolean read FActionRaise write FActionRaise;
    property ActionBet: Boolean read FActionBet write FActionBet;
    property ActionPlayNow: Boolean read FActionPlayNow write FActionPlayNow;
    property ActionSitOut: Boolean read FActionSitOut write FActionSitOut;
    property ActionFoldToAny: Boolean read FActionFoldToAny write FActionFoldToAny;
    property ActionSitOutNextBB: Boolean read FActionSitOutNextBB write FActionSitOutNextBB;
    property ActionShowCards: Boolean read FActionShowCards write FActionShowCards;
    property ActionShowStats: Boolean read FActionShowStats write FActionShowStats;
    property Messages: TObjectList<TPB_TableMessage> read FMessages;

    property AutoCheckVisible: Boolean read FAutoCheckVisible write FAutoCheckVisible;
    property AutoFoldVisible: Boolean read FAutoFoldVisible write FAutoFoldVisible;
    property AutoCheckFoldVisible: Boolean read FAutoCheckFoldVisible write FAutoCheckFoldVisible;
    property AutoCallVisible: Boolean read FAutoCallVisible write FAutoCallVisible;
    property AutoCallAmount: UINT32 read FAutoCallAmount write FAutoCallAmount;
    property AutoCallCaption: String read FAutoCallCaption write FAutoCallCaption;
    property AutoCallAnyVisible: Boolean read FAutoCallAnyVisible write FAutoCallAnyVisible;

    property CallCaption: String read FCallCaption write FCallCaption;
    property ResetRaiseValue: Boolean read FResetRaiseValue write FResetRaiseValue;
    property FocusWindow: Boolean read FFocusWindow write FFocusWindow;

    property Events: TPB_TableEventList read FEvents;
  end;

implementation

uses
  System.SysUtils, Poker.Server.Socket, Poker.DataModule, Poker.Common.Misc, Poker.Types;

{ TTableStatus }

constructor TTableStatus.Create;
begin
  FDealer := -1;
  FCurrentSeat := -1;
  FSelfSeatIndex := -1;
  FSeats := TSeatList.Create;

  FBets := TList<UINT32>.Create;
  FPreviousBets := TList<UINT32>.Create;

  FPreviousPots := TPB_PotList.Create;
  FPots := TPB_PotList.Create;
  FEvents := TPB_TableEventList.Create;
  FMessages := TObjectList<TPB_TableMessage>.Create;

  FFlopCards := TObjectList<TCards>.Create;
  FTurnCard := TObjectList<TCard>.Create;
  FRiverCard := TObjectList<TCard>.Create;
end;

destructor TTableStatus.Destroy;
begin
  FMessages.Free;
  FBets.Free;
  FPreviousBets.Free;
  FEvents.Free;
  FFlopCards.Free;
  FTurnCard.Free;
  FRiverCard.Free;
  FPots.Free;
  FPreviousPots.Free;
  FSeats.Free;

  inherited;
end;

function TTableStatus.GetBet(const ASeatIndex: Integer): UINT32;
begin
  if (ASeatIndex < 0) or
     (ASeatIndex > FBets.Count - 1) then
    Exit(0)
  else
    Exit(FBets[ASeatIndex]);
end;

function TTableStatus.GetSeatInfo(const ASeatIndex: Integer; var ASeatInfo: TSeatInfo): Boolean;
var
  C1: Integer;
begin
  for C1 := 0 to FSeats.Count - 1 do
    if FSeats[C1].SeatIndex = ASeatIndex then
    begin
      ASeatInfo := FSeats[C1];
      Exit(TRUE);
    end;

  Exit(FALSE);
end;

function TTableStatus.IsSeatTaken(const ASeatIndex: Integer): Boolean;
var
  C1: Integer;
begin
  if not Assigned(FSeats) then
    Exit(FALSE);

  for C1 := 0 to FSeats.Count - 1 do
    if FSeats[C1].SeatIndex = ASeatIndex then
      Exit(TRUE);
  Exit(FALSE);
end;

function TTableStatus.IsSitting: Boolean;
begin
  result := FSelfSeatIndex <> -1;
end;

procedure TTableStatus.NewHandCleanup;
begin
  FFlopCards.Clear;
  FTurnCard.Clear;
  FRiverCard.Clear;
  FPreviousPots.Clear;
  FPreviousBets.Clear;
end;

procedure TTableStatus.Assign(const ATableStatusProtobuf: TPB_TableStatus);
var
  C1, C2: Integer;
  seat: TSeatInfo;
  delete: Boolean;
  oldstate: TTableState;
  seat_index: Integer;
  pot: TPB_Pot;
  table_message: TPB_TableMessage;
begin
  oldstate := FState;
  FState := ATableStatusProtobuf.State;
  FDealer := ATableStatusProtobuf.Dealer;
  FSmallBlindSeat := ATableStatusProtobuf.SmallBlind;
  FBigBlindSeat := ATableStatusProtobuf.BigBlind;
  FCurrentSeat := ATableStatusProtobuf.CurrentSeat;
  FMinimumBet := ATableStatusProtobuf.MinimumBet;
  FHandId := ATableStatusProtobuf.Handid;
  FTime := ATableStatusProtobuf.Time;
  FLocked := ATableStatusProtobuf.Locked;
  FMaximumRaise := ATableStatusProtobuf.MaximumRaise;
  FRakePercent := ATableStatusProtobuf.RakePercent;
  FCurrentGame := ATableStatusProtobuf.CurrentGame;
  FRotationHand := ATableStatusProtobuf.Rotation;
  FCurrentLimit := ATableStatusProtobuf.GameLimit;
  FMinimumRaise := ATableStatusProtobuf.MinimumRaise;
  FMessages.Clear;
  for table_message in ATableStatusProtobuf.TableMessage do
    FMessages.Add(TPB_TableMessage.Create(table_message));

  // assign certain values only if new table state is < tsWinning or previous table state is < tsWinning
  // this fixes animation bugs if some event occurs during tsWinning
  if (oldstate < tsWinning) or
     (FState < tsWinning) then
  begin
    FPreviousPots.Assign(FPots);
    FPots.Assign(ATableStatusProtobuf.Pots);
    FPreviousBets.Clear;
    FPreviousBets.AddRange(FBets);
    FBets.Clear;
    FBets.AddRange(ATableStatusProtobuf.Bets);
  end;

  if FTime > 0 then
    FTimebarEndtime := FTime - ServerSocket.TimeOffset
  else
    FTimebarEndtime := 0;

  if Assigned(ATableStatusProtobuf.Seats) then
  begin
    C1 := 0;
    while C1 < FSeats.Count do
    begin
      delete := TRUE;
      for C2 := 0 to ATableStatusProtobuf.Seats.Count - 1 do
        if ATableStatusProtobuf.Seats[C2].SeatIndex = FSeats[C1].SeatIndex then
        begin
          delete := FALSE;
          Break;
        end;

      if delete then
        FSeats.Delete(C1)
      else
        Inc(C1);
    end;

    for C1 := 0 to ATableStatusProtobuf.Seats.Count - 1 do
    begin
      seat := nil;
      for C2 := 0 to FSeats.Count - 1 do
        if FSeats[C2].SeatIndex = ATableStatusProtobuf.Seats[C1].SeatIndex then
        begin
          seat := FSeats[C2];
          Break;
        end;

      if not Assigned(seat) then
      begin
        seat := TSeatInfo.Create;
        seat.Assign(ATableStatusProtobuf.Seats[C1]);
        FSeats.Add(seat);
      end
      else
        seat.Assign(ATableStatusProtobuf.Seats[C1]);
    end;

    FSeats.Sort;
  end
  else
    FSeats.Clear;

  // iterate through table status seats and find our seat index
  seat_index := -1;
  for C1 := 0 to FSeats.Count - 1 do
    if FSeats[C1].PlayerMongoId = dmMain.SelfInfo.MongoId then
    begin
      seat_index := FSeats[C1].SeatIndex;
      Break;
    end;
  FSelfSeatIndex := seat_index;

  case FState of
    tsIdle: begin
      FSmallBlindSeat := -1;
      FBigBlindSeat := -1;
      FFlopCards.Clear;
      FTurnCard.Clear;
      FRiverCard.Clear;
    end;
  end;

  if FSeats.Count > 0 then
  begin
    while FPreviousPots.Count < FSeats.Last.SeatIndex do
      FPreviousPots.Add(TPB_Pot.Create);

    while FPots.Count < FSeats.Last.SeatIndex do
      FPots.Add(TPB_Pot.Create);
  end;

  FTotalRake := 0;
  if FState >= tsWinning then
  begin
    for pot in FPreviousPots do
      Inc(FTotalRake, pot.Rake);
  end
  else
    for pot in FPots do
      Inc(FTotalRake, pot.Rake);

  FEvents.Assign(ATableStatusProtobuf.Events);

  UpdateCurrentPlaytime;
end;

procedure TTableStatus.UpdateClosingTime(const AGame: TGameInfo);
var
  gtc: DWORD;
  ct: DWORD;
begin
  if AGame.State = gsClosing then
  begin
    gtc := GetTickCount;
    ct := AGame.Closetime - ServerSocket.TimeOffset;
    if (AGame.Closetime = 0) or
       (gtc > ct) then
      FClosingTime := 0
    else
      FClosingTime := ct - gtc;
  end
  else
    FClosingTime := 0;
end;

procedure TTableStatus.UpdateCurrentPlaytime;
begin
  if FTimebarEndtime = 0 then
    FCurrentPlaytime := 0
  else
    FCurrentPlaytime := Int64(FTimebarEndtime) - Int64(GetTickCount);
end;

function TTableStatus.GetCallAmount(out AState: TTableState): UINT32;
var
  seat_bet: UINT32;
  call_amount: UINT32;
  seat_info: TSeatInfo;
begin
  AState := tsIdle;
  Assert(GetSeatInfo(SelfSeatIndex, seat_info));
  AState := State;
  seat_bet := GetBet(seat_info.SeatIndex);
  if seat_bet + seat_info.Chips < MinimumBet then
    call_amount := seat_bet + seat_info.Chips
  else
    call_amount := MinimumBet;
  result := call_amount;
end;


end.
