unit Poker.Objects.TableStatus;

interface

uses
  Winapi.Windows, System.Generics.Collections, Poker.Protobufs.Objects.TableStatus, Poker.Cards, Poker.Protobufs.Objects.Game,
  Poker.Objects.PotInfo, Poker.Objects.SeatInfo, Poker.Objects.GameInfo;

type
  TTableStatus = class
  private
    FState: TTableState;
    FDealer: Integer;
    FCurrentSeat: Integer;
    FSeatInfos: TSeatInfos;
    FBets: TList<UINT32>;
    FPreviousBets: TList<UINT32>;
    FFlopCards: TCards;
    FTurnCard: TCard;
    FRiverCard: TCard;
    FSmallBlindSeat: Integer;
    FBigBlindSeat: Integer;
    FRakePercent: UINT32;
    FLocked: Boolean;
    FLockTimerEnabled: Boolean;
    FMinimumBet: UINT32;
    FHandId: UINT32;
    FMaximumRaise: UINT32;
    FPreviousPots: TPotInfos;
    FPots: TPotInfos;
    FTime: UINT64;
    FRotationHand: UINT32;
    FCurrentGame: TGameType;
    FCurrentLimit: TGameLimit;
    FMinimumRaise: UINT32;
    FClosingTime: DWORD;
    FTimebarEndtime: DWORD;
    FCurrentPlaytime: Int64;

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

    FActionCallCaption: String;
    FActionRaiseCaption: String;

//    FEvents        : TTableEvents;

    procedure PadList(const AList: TList<UINT32>; const ACount: Integer);

  public
    constructor Create;
    destructor Destroy; override;

    function GetBet(const ASeatIndex: Integer): UINT32;
    function IsSeatTaken(const ASeatIndex: Integer): Boolean;
    function GetSeatInfo(const ASeatIndex: Integer; var ASeatInfo: TSeatInfo): Boolean;
    procedure Assign(const ATableStatusProtobuf: TPB_TableStatus);
    procedure InitToDemoValues;

    procedure UpdateClosingTime(const AGame: TGameInfo);
    procedure UpdateCurrentPlaytime;
    procedure NewHandCleanup;

    property State: TTableState read FState;
    property Dealer: Integer read FDealer;
    property CurrentSeat: Integer read FCurrentSeat;
    property Seats: TSeatInfos read FSeatInfos;
    property Bets: TList<UINT32> read FBets write FBets;
    property PreviousBets: TList<UINT32> read FPreviousBets;
    property MinimumBet: UINT32 read FMinimumBet;
    property FlopCards: TCards read FFlopCards;
    property TurnCard: TCard read FTurnCard;
    property RiverCard: TCard read FRiverCard;
    property SmallBlindSeat: Integer read FSmallBlindSeat;
    property BigBlindSeat: Integer read FBigBlindSeat;
    property Locked: Boolean read FLocked;
    property HandId: UINT32 read FHandId;
    property Pots: TPotInfos read FPots write FPots;
    property PreviousPots: TPotInfos read FPreviousPots;
    property MaximumRaise: UINT32 read FMaximumRaise;
    property Time: UINT64 read FTime;
    property RotationHand: UINT32 read FRotationHand;
    property CurrentGame: TGameType read FCurrentGame;
    property CurrentLimit: TGameLimit read FCurrentLimit;
    property MinimumRaise: UINT32 read FMinimumRaise;
    property LockTimerEnabled: Boolean read FLockTimerEnabled write FLockTimerEnabled;
    property ClosingTime: DWORD read FClosingTime;
    property TimebarEndtime: DWORD read FTimebarEndtime;
    property CurrentPlaytime: Int64 read FCurrentPlaytime;
    property RakePercent: UINT32 read FRakePercent;

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

    property ActionCallCaption: String read FActionCallcaption write FActionCallCaption;
    property ActionRaiseCaption: String read FActionRaiseCaption write FActionRaiseCaption;

//    property Events: TTableEvents read FEvents;
  end;

implementation

uses
  System.SysUtils, Poker.Server.Socket.Commands, Poker.DataModule;

{ TTableStatus }

constructor TTableStatus.Create;
begin
  FDealer := -1;
  FCurrentSeat := -1;
  FSeatInfos := TSeatInfos.Create;

  FBets := TList<UINT32>.Create;
  FPreviousBets := TList<UINT32>.Create;

  FPreviousPots := TPotInfos.Create;
  FPots := TPotInfos.Create;
  FFlopCards := TCards.Create;
  FTurnCard := TCard.Create;
  FRiverCard := TCard.Create;
//  FEvents := TTableEvents.Create;
end;

destructor TTableStatus.Destroy;
begin
  FBets.Free;
  FPreviousBets.Free;
//  FEvents.Free;
  FFlopCards.Free;
  FTurnCard.Free;
  FRiverCard.Free;
  FPots.Free;
  FPreviousPots.Free;
  FSeatInfos.Free;

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

procedure TTableStatus.NewHandCleanup;
begin
  FFlopCards.Clear;
  FTurnCard.Clear;
  FRiverCard.Clear;
  FPreviousPots.Clear;
  FPreviousBets.Clear;
end;

procedure TTableStatus.PadList(const AList: TList<UINT32>; const ACount: Integer);
begin
  while AList.Count < ACount do
    AList.Add(0);
end;

procedure TTableStatus.Assign(const ATableStatusProtobuf: TPB_TableStatus);
var
  C1, C2: Integer;
  seat: TSeatInfo;
  delete: Boolean;
  oldstate: TTableState;
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

  // assign certain values only if new table state is < tsWinning or previous table state is < tsWinning
  // this fixes animation bugs if some event occurs during tsWinning
  if (oldstate < tsWinning) or
     (FState < tsWinning) then
  begin
    FPreviousPots.Assign(FPots, FRakePercent);
    FPots.Assign(ATableStatusProtobuf.Pots, FRakePercent);
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
      FFlopCards.Clear;
      FTurnCard.Clear;
      FRiverCard.Clear;
    end;
  end;

  if FSeatInfos.Count > 0 then
  begin
    while FPreviousPots.Count < FSeatInfos.Last.SeatIndex do
      FPreviousPots.Add(TPotInfo.Create);

    while FPots.Count < FSeatInfos.Last.SeatIndex do
      FPots.Add(TPotInfo.Create);

    PadList(FPreviousBets, FSeatInfos.Last.SeatIndex + 1);
    PadList(FBets, FSeatInfos.Last.SeatIndex + 1);
  end;

//  FEvents.Assign(ATableStatusProtobuf.Events);
end;

procedure TTableStatus.UpdateClosingTime(const AGame: TGameInfo);
var
  gtc: DWORD;
  ct: DWORD;
begin
  if AGame.State = gsClosing then
  begin
    gtc := GetTickCount;
    ct := AGame.ClosingTime - ServerSocket.TimeOffset;
    if (AGame.ClosingTime = 0) or
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
  FCurrentPlaytime := Int64(FTimebarEndtime) - Int64(GetTickCount);
end;

procedure TTableStatus.InitToDemoValues;
var
  seatinfo: TSeatInfo;
  bytes: TBytes;
begin
  FState := tsPreFlop;
  FDealer := 2;
  FCurrentSeat := 5;

  SetLength(bytes, 0);
  FSeatInfos.Clear;
  seatinfo := TSeatInfo.Create;
  seatinfo.InitToDemoValues(2, 'reiser', 100000, 2, bytes);
  FSeatInfos.Add(seatinfo);

  seatinfo := TSeatInfo.Create;
  seatinfo.InitToDemoValues(3, '', 88400, 2, dmMain.SelfInfo.Id);
  FSeatInfos.Add(seatinfo);

  seatinfo := TSeatInfo.Create;
  seatinfo.InitToDemoValues(4, 'paunovic', 88400, 2, bytes);
  FSeatInfos.Add(seatinfo);

  seatinfo := TSeatInfo.Create;
  seatinfo.InitToDemoValues(5, 'marko', 111400, 2, bytes);
  FSeatInfos.Add(seatinfo);

  FBets.Clear;
  FBets.Add(0); FBets.Add(0); FBets.Add(3573); FBets.Add(7317); FBets.Add(18458);
  FPreviousBets.Clear;
  FPreviousBets.AddRange(FBets);
  FFlopCards.Clear;
  FTurnCard.Clear;
  FRiverCard.Clear;
  FSmallBlindSeat := 3;
  FBigBlindSeat := 4;
  FRakePercent := 5;
  FLocked := FALSE;
  FLockTimerEnabled := FALSE;
  FMinimumBet := 0;
  FHandId := 0;
  FMaximumRaise := 0;
  FPots.Clear;
  FPreviousPots.Clear;
  FTime := 0;
  FRotationHand := 0;
  FCurrentGame := gtHoldem;
  FCurrentLimit := glNoLimit;
  FMinimumRaise := 0;
  FClosingTime := 0;
  FTimebarEndtime := 0;
  FCurrentPlaytime := 0;
end;




end.
