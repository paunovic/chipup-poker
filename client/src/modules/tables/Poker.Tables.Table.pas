unit Poker.Tables.Table;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, Poker.Games.Game, Poker.HandHistory.Playback, Poker.Clubs.Club, Vcl.Forms,
  Poker.HandHistory.Items, Poker.Tables.Renderer, Poker.Avatars.Avatar, Poker.Types, Poker.Tables.Status,
  Poker.Protobufs.Objects.TableStatus, Poker.Protobufs.Objects.TableEvent;

type
  TTable = class
  private
    const
      TIMER_ID_RENDER = 1;
      TIMER_ID_SEAT_CAPTION_CLEAR = 2;
      TIMER_ID_GAMEPLAY_LOCK = 3;

    var
      {$IFDEF DEBUG} FDebugId: Integer; {$ENDIF}
      FInternalId: Integer;
      FInternalHWND: HWND;
      FTableType: TTableType;
      FGameId: TBytes;
      FClubId: TBytes;
      FForm: TForm;
      FRenderer: TTableRenderer;
      FLeaveNotify: Boolean;
      FStatus: TTableStatus;
      FFirstStatusSet: Boolean;
      FHandHistoryHandId: UINT;
      FHandHistoryPlayback: THandHistoryPlayback;
      FSeatClearCaptionIndex: Integer;
      FGameplayLocked: Boolean;
      FGameplayLockedEndTime: DWORD;

    procedure WndProc(var AMessage: TMessage);
    procedure ProcessTableEvent(const ATableEvent: TPB_TableEvent);
    procedure SeatClearCaptionTimerCallback;
  public
    constructor Create(const AInternalId: Integer);
    destructor Destroy; override;

    function SetupLiveTable(const AGameId: TBytes; const ASendJoinCommand: Boolean): Boolean;
    function SetupHandHistoryTable(const AHandHistoryItems: THandHistoryItems; const AHandHistoryItem: THandHistoryItem): Boolean;

    procedure RenderSync;
    procedure LockGameplay(const ASeconds: Single);

    function GetObjectCopy(out AGame: TGameInfo): Boolean; overload;
    function GetObjectCopy(out AClub: TClubInfo; out AGame: TGameInfo): Boolean; overload;

    procedure BringToFront;
    procedure SetTableStatus(const ATableStatus: TPB_TableStatus; const AClearAnimations: Boolean);
    procedure PlaySound(const ASound: String);

    function GetHandHistoryItem(out AHandHistoryItem: THandHistoryItem): Boolean;

    property InternalId: Integer read FInternalId;
    property TableType: TTableType read FTableType;
    property GameId: TBytes read FGameId;
    property ClubId: TBytes read FClubId;
    property Form: TForm read FForm;
    property Renderer: TTableRenderer read FRenderer;
    property LeaveNotify: Boolean read FLeaveNotify write FLeaveNotify;
    property HandHistoryHandId: UINT read FHandHistoryHandId;
    property HandHistoryPlayback: THandHistoryPlayback read FHandHistoryPlayback;
    property Status: TTableStatus read FStatus;
    property GameplayLocked: Boolean read FGameplayLocked;
    property GameplayLockedEndTime: DWORD read FGameplayLockedEndTime;
  end;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, System.TypInfo, {$ENDIF}
  Vcl.Controls, Poker.Forms.Table, Poker.Common.Misc, Poker.Server.Socket.Commands, Poker.DirectX.Core, Vectors2px, Poker.DataModule,
  Poker.HandHistory.Core, Poker.Players.Player, Poker.Players.PlayerList, Poker.Seats.Seat, Poker.Cards, Poker.Sounds, Poker.Settings,
  System.Classes, Poker.WindowMessages;


{ TTable }

constructor TTable.Create(const AInternalId: Integer);
begin
  {$IFDEF DEBUG} FDebugId := RegisterDebugObject(Format('Table #%d', [AInternalId])); {$ENDIF}
  FFirstStatusSet := FALSE;
  FInternalId := AInternalId;
  FInternalHWND := AllocateHWnd(WndProc);
  FStatus := TTableStatus.Create;
end;

destructor TTable.Destroy;
begin
  if FLeaveNotify then
    ServerSocket.LeaveTable(FGameId);

  KillTimer(FInternalHWND, TIMER_ID_RENDER);
  KillTimer(FInternalHWND, TIMER_ID_SEAT_CAPTION_CLEAR);
  KillTimer(FInternalHWND, TIMER_ID_GAMEPLAY_LOCK);
  FRenderer.SetRenderTarget(0);
  FreeAndNil(FForm);
  FreeAndNil(FRenderer);
  FreeAndNil(FHandHistoryPlayback);
  FreeAndNil(FStatus);
  DeallocateHWnd(FInternalHWND);

  {$IFDEF DEBUG} UnregisterDebugObject(FDebugId); {$ENDIF}

  inherited;
end;

function TTable.GetObjectCopy(out AGame: TGameInfo): Boolean;
var
  club: TClubInfo;
  game: TGameInfo;
begin
  if dmMain.SelfInfo.Clubs.FindGame(FGameId, club, game) then
  begin
    AGame := TGameInfo.Create;
    AGame.Assign(game);
    result := TRUE;
  end
  else
    result := FALSE;
end;

function TTable.GetHandHistoryItem(out AHandHistoryItem: THandHistoryItem): Boolean;
var
  hhis: THandHistoryItems;
begin
  result := (FTableType = ttHandPlayback) and
            (HandHistory.TryGetValue(FGameId, hhis)) and
            (hhis.FindHand(FHandHistoryHandId, AHandHistoryItem));
end;

function TTable.GetObjectCopy(out AClub: TClubInfo; out AGame: TGameInfo): Boolean;
var
  club: TClubInfo;
  game: TGameInfo;
begin
  if dmMain.SelfInfo.Clubs.FindGame(FGameId, club, game) then
  begin
    AClub := TClubInfo.Create;
    AClub.Assign(club);
    AGame := TGameInfo.Create;
    AGame.Assign(game);
    result := TRUE;
  end
  else
    result := FALSE;
end;

function TTable.SetupLiveTable(const AGameId: TBytes; const ASendJoinCommand: Boolean): Boolean;
var
  form: TfrmTable;
  game: TGameInfo;
  club: TClubInfo;
begin
  FTableType := ttLiveGame;
  FGameId := AGameId;
  if not dmMain.SelfInfo.Clubs.FindGame(FGameId, club, game) then
    Exit(FALSE);
  FClubId := club.MongoId;
  FRenderer := TTableRenderer.Create(FInternalId, FInternalHWND, FTableType);
  if not FRenderer.AcquireSwapChainElement then
  begin
    FreeAndNil(FRenderer);
    Exit(FALSE);
  end;
  form := TfrmTable.Create(FInternalId);
  FRenderer.SetRenderTarget(form.Handle);
  SetTimer(FInternalHWND, TIMER_ID_RENDER, 250, nil);
  FForm := form;
  FLeaveNotify := TRUE;
  if ASendJoinCommand then
    ServerSocket.JoinTable(AGameId);
  FRenderer.UpdateDXAreaSize;
  FRenderer.Enable;
  Exit(TRUE);
end;

function TTable.SetupHandHistoryTable(const AHandHistoryItems: THandHistoryItems; const AHandHistoryItem: THandHistoryItem): Boolean;
var
  form: TfrmTable;
begin
  FTableType := ttHandPlayback;
  FGameId := AHandHistoryItems.FGameId;
  FHandHistoryHandId := AHandHistoryItem.HandId;
  FHandHistoryPlayback := THandHistoryPlayback.Create(AHandHistoryItems, AHandHistoryItem);
  FRenderer := TTableRenderer.Create(FInternalId, FInternalHWND, FTableType);
  if not FRenderer.AcquireSwapChainElement then
  begin
    FreeAndNil(FRenderer);
    Exit(FALSE);
  end;
  form := TfrmTable.Create(FInternalId);
  FRenderer.SetRenderTarget(form.Handle);
  SetTimer(FInternalHWND, TIMER_ID_RENDER, 250, nil);
  SetTableStatus(FHandHistoryPlayback.CurrentState, TRUE);
  FForm := form;
  FLeaveNotify := FALSE;
  FRenderer.UpdateDXAreaSize;
  FRenderer.Enable;
  Exit(TRUE);
end;

procedure TTable.BringToFront;
begin
  if IsIconic(FForm.Handle) then
    ShowWindow(FForm.Handle, SW_RESTORE);
  FForm.Show;
end;

procedure TTable.RenderSync;
begin
  TSyncRenderer.Render(FRenderer);
end;

procedure TTable.SeatClearCaptionTimerCallback;
var
  seat: TSeatInfo;
begin
  if FStatus.GetSeatInfo(FSeatClearCaptionIndex, seat) then
    seat.LowerCaption := '';
  FSeatClearCaptionIndex := -1;
  KillTimer(FInternalHWND, TIMER_ID_SEAT_CAPTION_CLEAR);
  FRenderer.Render;
end;

procedure TTable.SetTableStatus(const ATableStatus: TPB_TableStatus; const AClearAnimations: Boolean);
var
  C1: Integer;
  player: TPlayerInfo;
  query_users: TArray<TBytes>;
  empty_array: TBytes;
  seat: TSeatInfo;
  winning: Boolean;
  {$IFDEF DEBUG}
  pbevent: TPB_TableEvent;
  events: String;
  tmp: String;
  tb: UINT32;
  tstatusdbg: String;
  csdbg: String;
  seatdbg: TSeatInfo;
  playerdbg: TPlayerInfo;
  {$ENDIF}
begin
  if AClearAnimations then
    FRenderer.ClearAnimations;

  FStatus.Assign(ATableStatus);

  if not FFirstStatusSet then
  begin
    for C1 := 0 to FStatus.Seats.Count - 1 do
      FStatus.Seats[C1].FillDealtCards;

    if FStatus.State in [tsFlop, tsTurn, tsRiver, tsWinning, tsWinning2] then
      FRenderer.FlopAnimated := TRUE;
    if FStatus.State in [tsTurn, tsRiver, tsWinning, tsWinning2] then
      FRenderer.TurnAnimated := TRUE;
    if FStatus.State in [tsRiver, tsWinning, tsWinning2] then
      FRenderer.RiverAnimated := TRUE;

    FFirstStatusSet := TRUE;
  end;

  // reset animation delays
  FRenderer.WinningFlopAniDelay := 0;
  FRenderer.WinningTurnAniDelay := 0;
  FRenderer.WinningRiverAniDelay := 0;
  FRenderer.WinningAniDelay := 0;

  // check if its winning phase
  winning := FALSE;
  for C1 := 0 to ATableStatus.Events.Count - 1 do
    if ATableStatus.Events[C1].Event = teWinning then
    begin
      winning := TRUE;
      Break;
    end;

  // ...and if it is, make animation delays
  // this is required if everyone goes all in pre-flop for example, so it shows cards one by one (flop > turn > river), with proper delays
  if winning then
    for C1 := 0 to ATableStatus.Events.Count - 1 do
      case ATableStatus.Events[C1].Event of
        teFlop: FRenderer.WinningFlopAniDelay := 0.2;
        teTurn: FRenderer.WinningTurnAniDelay := FRenderer.WinningFlopAniDelay + 1;
        teRiver: FRenderer.WinningRiverAniDelay := FRenderer.WinningFlopAniDelay + FRenderer.WinningTurnAniDelay + 1;
        teWinning: FRenderer.WinningAniDelay := FRenderer.WinningFlopAniDelay + FRenderer.WinningTurnAniDelay + FRenderer.WinningRiverAniDelay + 0.2;
      end;

  // process table events
  for C1 := 0 to FStatus.Events.Count - 1 do
    ProcessTableEvent(FStatus.Events[C1]);

  // get user infos that we dont have
  SetLength(query_users, 0);
  for seat in FStatus.Seats do
    if not Players.TryGetValue(seat.PlayerMongoId, player) then
    begin
      SetLength(query_users, Length(query_users) + 1);
      query_users[Length(query_users) - 1] := seat.PlayerMongoId;
    end;

  if Length(query_users) > 0 then
  begin
    SetLength(empty_array, 0);
    for C1 := 0 to Length(query_users) - 1 do
      Players.AddPlayer(query_users[C1], 'Retrieving...', '', 0, empty_array);
    ServerSocket.GetUserInfos(query_users);
  end;

  // update self info
  dmMain.SelfInfo.Balance := ATableStatus.TotalBalance;
  dmMain.UpdateSelfInfoInPlayers;

  // notify render handle that table status is updated
  if FRenderer.RenderHandle > 0 then
    PostMessage(FRenderer.RenderHandle, WM_TABLESTATUS_REFRESH, 0, 0);

  {$IFDEF DEBUG}
  tmp := GetEnumName(TypeInfo(TTableState), Integer(FStatus.State));
  if ATableStatus.Locked then
    tmp := tmp + ', LOCKED';
  seatdbg := nil;
  playerdbg := nil;
  tb := 0;
  csdbg := IntToStr(FStatus.CurrentSeat);
  if FStatus.GetSeatInfo(FStatus.CurrentSeat, seatdbg) then
  begin
    if Players.TryGetValue(seatdbg.PlayerMongoId, playerdbg) then
      csdbg := csdbg + ' - ' + playerdbg.Nick;
    tb := seatdbg.Timebank;
  end;

  FStatus.UpdateCurrentPlaytime;
  tstatusdbg := Format('[#%d] %s, D: %d, E: %d | #%s, %.2fs/%.2fs',
    [ATableStatus.Seq, tmp, FStatus.Dealer, ATableStatus.Events.Count, csdbg, FStatus.CurrentPlaytime / 1000, tb / 1000]);

  events := '';
  for C1 := 0 to ATableStatus.Events.Count - 1 do
  begin
    pbevent := ATableStatus.Events[C1];
    if events <> '' then
      events := events + #10;

    seatdbg := nil;
    playerdbg := nil;
    if FStatus.GetSeatInfo(pbevent.Seat, seatdbg) then
      Players.TryGetValue(seatdbg.PlayerMongoId, playerdbg);

    case pbevent.Event of
      teFold: if Assigned(seatdbg) then
        events := events + Format('FOLD [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(FStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)])
      else
        events := events + Format('FOLD [#%d]', [pbevent.Seat]);
      teSit: events := events + Format('SIT [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(FStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)]);
      teStandUp: events := events + Format('STAND UP [#%d]', [pbevent.Seat]);
      teWinning: events := events + 'WINNING';
      teDealing: events := events + 'DEALING';
      teCheck: events := events + Format('CHECK [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(FStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)]);
      teCall: events := events + Format('CALL [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(FStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)]);
      teRaise: events := events + Format('RAISE [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(FStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)]);
      teAllIn: events := events + Format('ALL-IN [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(FStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)]);
      teFlop: events := events + Format('FLOP [%s]', [FStatus.FlopCards.AsString]);
      teTurn: events := events + Format('TURN [%s]', [FStatus.TurnCard.AsString]);
      teRiver: events := events + Format('RIVER [%s]', [FStatus.RiverCard.AsString]);
      tePostRiver: events := events + 'POST RIVER';
      tePreWin: events := events + 'PRE WIN';
      teExistingCards: events := events + Format('EXISTING CARDS [%s]', [TCards.BytesToString(pbevent.Cards)]);
      teDisconnect: events := events + Format('DISCONNECTED [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(FStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)]);
    else
      events := events + Format('UNHANDLED EVENT RECEIVED: %s', [GetEnumName(TypeInfo(TTableEventType), Integer(pbevent.Event))]);
    end;
  end;

  DebugLn(FDebugId, tstatusdbg, ditApplication, events);
  {$ENDIF}
end;

procedure TTable.ProcessTableEvent(const ATableEvent: TPB_TableEvent);
var
  seat_caption: String;
  seat: TSeatInfo;
  flop: TBytes;
begin
  seat_caption := '';
  case ATableEvent.Event of
    teExistingCards: begin
      if Length(ATableEvent.Cards) >= 3 then
      begin
        flop := Copy(ATableEvent.Cards, 0, 3);
        FStatus.FlopCards.Assign(flop);
      end;
      if Length(ATableEvent.Cards) >= 4 then
        FStatus.TurnCard.Assign(ATableEvent.Cards[3]);
      if Length(ATableEvent.Cards) >= 5 then
        FStatus.RiverCard.Assign(ATableEvent.Cards[4]);
    end;

    teFold: begin
      seat_caption := 'FOLD';
    end;

    teSit: begin
    end;

    teStandUp: begin
      if FRenderer.PotWinAnimations.Count = 0 then
        FRenderer.AnimateBets(FStatus.PreviousBets, ATableEvent.Seat);
    end;

    tePostRiver: begin
      FStatus.PreviousBets.Clear;
      FStatus.PreviousBets.AddRange(ATableEvent.Bets);
    end;

    teWinning: begin
      LockGameplay(2 + ATableEvent.Pots.Count * 0.5);
      FStatus.Pots.Assign(ATableEvent.Pots);
      if FRenderer.AnimateBets(FStatus.PreviousBets) then
        PlaySound(Sounds.SOUND_MOVE_CHIPS);
      FRenderer.AnimateWinnerPots(ATableEvent.Pots);
    end;

    teDealing: begin
      LockGameplay(0.1 + Settings.Hardcoded.ANIMATION_METRICS.DEALING_INITIAL_DELAY + FRenderer.DealAnimations.Count * Settings.Hardcoded.ANIMATION_METRICS.DEALING_CARD_DELAY);
      FRenderer.ClearAnimations;
      FRenderer.ChipStackMaker.Clear;
      FStatus.NewHandCleanup;
      FRenderer.AnimateBlinds;
      FRenderer.AnimateDealingCards;
    end;

    teCheck: begin
      seat_caption := 'CHECK';
      PlaySound(Sounds.SOUND_CHECK);
    end;

    teCall: begin
      seat_caption := 'CALL';
      PlaySound(Sounds.SOUND_PUTCHIPS_SMALL);
    end;

    teRaise: begin
      seat_caption := 'RAISE';
      PlaySound(Sounds.SOUND_PUTCHIPS_SMALL);
    end;

    teAllIn: begin
      seat_caption := 'ALL-IN';
    end;

    teFlop: begin
      LockGameplay(1.5 + FRenderer.WinningFlopAniDelay);
      FStatus.FlopCards.Assign(ATableEvent.Cards);
      if FRenderer.AnimateBets(ATableEvent.Bets) then
        PlaySound(Sounds.SOUND_MOVE_CHIPS);
    end;

    teTurn: begin
      LockGameplay(1.5 + FRenderer.WinningTurnAniDelay);
      FStatus.TurnCard.Assign(ATableEvent.Cards);
      if FRenderer.AnimateBets(ATableEvent.Bets) then
        PlaySound(Sounds.SOUND_MOVE_CHIPS);
    end;

    teRiver: begin
      LockGameplay(1.5 + FRenderer.WinningRiverAniDelay);
      FStatus.RiverCard.Assign(ATableEvent.Cards);
      if FRenderer.AnimateBets(ATableEvent.Bets) then
        PlaySound(Sounds.SOUND_MOVE_CHIPS);
    end;

    teDisconnect: begin
//      if table.Status.GetSeatInfo(ATableEvent.Seat, seat) then
//        seat_caption := 'DISCONNECTED';
    end;
  end;

  if seat_caption <> '' then
  begin
    FStatus.Seats.ClearCaptions;
    if FStatus.GetSeatInfo(ATableEvent.Seat, seat) then
    begin
      seat.LowerCaption := seat_caption;
      if FSeatClearCaptionIndex > -1 then
        SeatClearCaptionTimerCallback;
      FSeatClearCaptionIndex := seat.SeatIndex;
      SetTimer(FInternalHWND, TIMER_ID_SEAT_CAPTION_CLEAR, 1800, nil);
    end;
  end;
end;

procedure TTable.PlaySound(const ASound: String);
begin
  if (GetForegroundWindow = FRenderer.RenderHandle) and
     (Settings.Sounds) then
    Sounds.Play(ASound);
end;

procedure TTable.LockGameplay(const ASeconds: Single);
var
  milliseconds: DWORD;
begin
  milliseconds := Round(ASeconds * 1000);
  FGameplayLocked := TRUE;
  FGameplayLockedEndTime := GetTickCount + milliseconds;
  SetTimer(FInternalHWND, TIMER_ID_GAMEPLAY_LOCK, milliseconds, nil);
end;

procedure TTable.WndProc(var AMessage: TMessage);
begin
  inherited;

  case AMessage.Msg of
    WM_DIRECTX_ANIMATION: FRenderer.AnimationCallback(pointer(AMessage.WParam));

    WM_TIMER: case AMessage.WParam of
      TIMER_ID_SEAT_CAPTION_CLEAR: SeatClearCaptionTimerCallback;
      TIMER_ID_RENDER: FRenderer.Render;
      TIMER_ID_GAMEPLAY_LOCK: begin
        KillTimer(FInternalHWND, TIMER_ID_GAMEPLAY_LOCK);
        FGameplayLocked := FALSE;
        FGameplayLockedEndTime := 0;
        FRenderer.Render;
      end;
    end;

  end;
end;




end.
