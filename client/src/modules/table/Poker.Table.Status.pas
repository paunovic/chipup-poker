unit Poker.Table.Status;

interface

uses
  System.Generics.Collections, Poker.Protobufs.Objects.TableStatus, Poker.Cards, Poker.Protobufs.Objects.Game, Poker.Objects.PotInfo, Poker.Objects.SeatInfo;

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
//    FEvents        : TTableEvents;

  public
    constructor Create;
    destructor Destroy; override;

    function GetBet(const ASeatIndex: Integer): UINT32;
    function IsSeatTaken(const ASeatIndex: Integer): Boolean;
    function GetSeatInfo(const ASeatIndex: Integer; var ASeatInfo: TSeatInfo): Boolean;
    procedure Assign(const ATableStatusProtobuf: TPB_TableStatus); overload;

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
//    property Events: TTableEvents read FEvents;
  end;

implementation



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
  FPreviousBets.Clear;
  FPreviousBets.AddRange(FBets);
  FBets.Clear;
  FBets.AddRange(ATableStatusProtobuf.Bets);
  FLocked := ATableStatusProtobuf.Locked;
  FMaximumRaise := ATableStatusProtobuf.MaximumRaise;
  FRakePercent := ATableStatusProtobuf.RakePercent;
  FPreviousPots.Assign(FPots, FRakePercent);
  FPots.Assign(ATableStatusProtobuf.Pots, FRakePercent);
  FCurrentGame := ATableStatusProtobuf.CurrentGame;
  FRotationHand := ATableStatusProtobuf.Rotation;
  FCurrentLimit := ATableStatusProtobuf.GameLimit;
  FMinimumRaise := ATableStatusProtobuf.MinimumRaise;

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

//  FEvents.Assign(ATableStatusProtobuf.Events);
end;




end.
