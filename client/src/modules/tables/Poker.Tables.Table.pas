unit Poker.Tables.Table;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, Poker.Games.Game, Poker.HandHistory.Playback, Poker.Clubs.Club, Vcl.Forms,
  Poker.HandHistory.Items, Poker.Tables.Renderer, Poker.Avatars.Avatar, Poker.Types, Poker.Tables.Status, Poker.Protobufs.Objects.TableStatus,
  Poker.Protobufs.Objects.TableEvent, Poker.Protobufs.Objects.TournamentPlayerTransfer;

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
      FGameId: TMongoId;
      FClubId: TMongoId;
      FClub: TClubInfo;
      FGame: TGameInfo;
      FTournamentId: TMongoId;
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
      FHidden: Boolean;

    procedure WndProc(var AMessage: TMessage);
    procedure ProcessTableEvent(const ATableEvent: TPB_TableEvent);
    procedure SeatClearCaptionTimerCallback;
    procedure ConfigureActions;
    procedure NotifyRendererHandle;
  public
    constructor Create(const AInternalId: Integer);
    destructor Destroy; override;

    function SetupLiveTable(const AGameId: TMongoId; const ASendJoinCommand: Boolean): Boolean;
    function SetupTournamentTable(const AGameId: TMongoId; const ASendJoinCommand: Boolean): Boolean;
    function SetupHandHistoryTable(const AHandHistoryItems: THandHistoryItems; const AHandHistoryItem: THandHistoryItem): Boolean;

    procedure RenderSync;
    procedure LockGameplay(const ASeconds: Single);

    procedure BringToFront;
    procedure SetTableStatus(const ATableStatus: TPB_TableStatus; const AClearAnimations: Boolean);
    procedure PlaySound(const ASound: String; const AIgnoreFocus: Boolean = FALSE);
    procedure Hide;
    procedure Show;

    function UpdateObjects: Boolean;
    function GetTableCaption: String;
    procedure Transfer(const ATournamentPlayerTransfer: TPB_TournamentPlayerTransfer);

    property InternalId: Integer read FInternalId;
    property TableType: TTableType read FTableType;
    property GameId: TMongoId read FGameId;
    property ClubId: TMongoId read FClubId;
    property TournamentId: TMongoId read FTournamentId;
    property Game: TGameInfo read FGame;
    property Club: TClubInfo read FClub;
    property Form: TForm read FForm;
    property Renderer: TTableRenderer read FRenderer;
    property LeaveNotify: Boolean read FLeaveNotify write FLeaveNotify;
    property HandHistoryHandId: UINT read FHandHistoryHandId;
    property HandHistoryPlayback: THandHistoryPlayback read FHandHistoryPlayback;
    property Status: TTableStatus read FStatus;
    property GameplayLocked: Boolean read FGameplayLocked;
    property GameplayLockedEndTime: DWORD read FGameplayLockedEndTime;
    property Hidden: Boolean read FHidden write FHidden;
  end;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, System.TypInfo, {$ENDIF}
  Vcl.Controls, Poker.Forms.Table, Poker.Common.Misc, Poker.Server.Socket, Poker.DirectX.Core, Asphyre.Math, Poker.DataModule,
  Poker.HandHistory.Core, Poker.Players.Player, Poker.Players.PlayerList, Poker.Seats.Seat, Poker.Cards, Poker.Sounds, Poker.Settings,
  System.Classes, Poker.WindowMessages, Poker.Protobufs.Objects.Game, Poker.Protobufs.Objects.SeatInfo,
  Poker.Tournaments, Poker.Tournaments.Info;


{ TTable }

constructor TTable.Create(const AInternalId: Integer);
begin
  {$IFDEF DEBUG} FDebugId := RegisterDebugObject(Format('Table #%d', [AInternalId])); {$ENDIF}
  FFirstStatusSet := FALSE;
  FInternalId := AInternalId;
  FInternalHWND := AllocateHWnd(WndProc);
  FStatus := TTableStatus.Create;
  FClub := TClubInfo.Create;
  FGame := TGameInfo.Create;
end;

destructor TTable.Destroy;
begin
  if FLeaveNotify then
    ServerSocket.LeaveTable(FGameId);

  KillTimer(FInternalHWND, TIMER_ID_RENDER);
  KillTimer(FInternalHWND, TIMER_ID_SEAT_CAPTION_CLEAR);
  KillTimer(FInternalHWND, TIMER_ID_GAMEPLAY_LOCK);
  if Assigned(FRenderer) then
  begin
    FRenderer.Disable;
    FRenderer.SetRenderTarget(0);
  end;
  FreeAndNil(FForm);
  FreeAndNil(FRenderer);
  FreeAndNil(FHandHistoryPlayback);
  FreeAndNil(FStatus);
  FreeAndNil(FGame);
  FreeAndNil(FClub);
  DeallocateHWnd(FInternalHWND);

  {$IFDEF DEBUG} UnregisterDebugObject(FDebugId); {$ENDIF}

  inherited;
end;

function TTable.GetTableCaption: String;
var
  currentgame: String;
  rot_index: Integer;
  hhis: THandHistoryItems;
  hhi: THandHistoryItem;
  tournament: TTournamentInfo;
begin
  result := '';
  case FTableType of
    ttLive: begin
      if FGame.GameType = gtRotationNLHPLO then
      begin
        case FStatus.CurrentGame of
          gtHoldem: currentgame := 'NLH';
          gtOmaha: currentgame := 'PLO';
        end;
        rot_index := FStatus.RotationHand;
        if rot_index = 0 then
          rot_index := 1;
        result := Format('%s (%s/%s %s) (%d/%d %s) - %s', [FGame.Gamename, ChipsToStr(FGame.SmallBlind), ChipsToStr(FGame.BigBlind),
             FGame.AsString(TRUE), (rot_index - 1) mod FGame.Seats + 1, FGame.Seats, currentgame, FClub.Name])
      end
      else
        result := Format('%s (%s/%s %s) - %s', [FGame.Gamename, ChipsToStr(FGame.SmallBlind), ChipsToStr(FGame.BigBlind), FGame.AsString(TRUE), FClub.Name]);
    end;

    ttTournament: begin
      result := 'Tournament';
      if Tournaments.GetAndLock(FTournamentId, tournament) then
      try
        result := Format('Tournament %s, table #%s', [tournament.Name, FGame.Gamename]);
      finally
        Tournaments.Unlock;
      end;
    end;

    ttHandReplay: begin
      HandHistory.Lock;
      try
        if not HandHistory.TryGetValue(FGameId, hhis) then
          Exit;

        if hhis.GetAndLockHand(FHandHistoryHandId, hhi) then
        try
          result := Format('Hand #%d: %s (%s/%s) - %s', [hhi.HandId, TGameInfo.GameTypeToStr(hhi.CurrentGame, hhi.ParentItems.Game.GameLimit, FALSE),
                     ChipsToStr(hhi.ParentItems.Game.SmallBlind), ChipsToStr(hhi.ParentItems.Game.BigBlind), hhi.StartTimeStr]);
        finally
          hhis.Unlock;
        end;
      finally
        HandHistory.Unlock;
      end;
    end;
  end;
end;

procedure TTable.Hide;
begin
  if Assigned(FForm) then
    FForm.Close;
  FHidden := TRUE;
end;

function TTable.UpdateObjects;
var
  club: TClubInfo;
  game: TGameInfo;
  pbgame: TPB_Game;
  tournament: TTournamentInfo;
begin
  case FTableType of
    ttLive: begin
      result := FALSE;
      if dmMain.SelfInfo.Clubs.GetAndLockByGame(FGameId, club, game) then
      try
        FClub.Assign(club);
        FClubId := FClub.MongoId;
        FGame.Assign(game);
        result := TRUE;
      finally
        dmMain.SelfInfo.Clubs.Unlock;
      end;
    end;

    ttHandReplay: result := TRUE;

    ttTournament: begin
      result := FALSE;
      if Tournaments.GetAndLockByGame(FGameId, tournament, pbgame) then
      try
        FTournamentId := tournament.MongoId;
        FGame.Assign(pbgame);
        result := TRUE;
      finally
        Tournaments.Unlock;
      end;

    end;
  else
    result := FALSE;
  end;
end;

function TTable.SetupLiveTable(const AGameId: TMongoId; const ASendJoinCommand: Boolean): Boolean;
var
  form: TfrmTable;
begin
  FTableType := ttLive;
  FGameId := AGameId;
  if not UpdateObjects then
    Exit(FALSE);
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
  Exit(TRUE);
end;

function TTable.SetupTournamentTable(const AGameId: TMongoId; const ASendJoinCommand: Boolean): Boolean;
var
  form: TfrmTable;
begin
  FTableType := ttTournament;
  FGameId := AGameId;
  if not UpdateObjects then
    Exit(FALSE);
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
  Exit(TRUE);
end;

procedure TTable.Show;
begin
  if Assigned(FForm) then
    BringToFront;
  FHidden := FALSE;
end;

procedure TTable.Transfer(const ATournamentPlayerTransfer: TPB_TournamentPlayerTransfer);
begin
  FGameId := ATournamentPlayerTransfer.GameDestination;
  UpdateObjects;
end;

function TTable.SetupHandHistoryTable(const AHandHistoryItems: THandHistoryItems; const AHandHistoryItem: THandHistoryItem): Boolean;
var
  form: TfrmTable;
begin
  FTableType := ttHandReplay;
  FGameId := AHandHistoryItems.FGameId;
  FClubId := AHandHistoryItems.FParentId;
  FTournamentId := AHandHistoryItems.FParentId;
  FClub.Assign(AHandHistoryItems.Club);
  FGame.Assign(AHandHistoryItems.Game);
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
  query_users: TArray<TMongoId>;
  empty_avatar_id: TBytes;
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
  FRenderer.Disable;

  if AClearAnimations then
    FRenderer.ClearAnimations;

  FStatus.Assign(ATableStatus);

  if not FFirstStatusSet then
  begin
    for C1 := 0 to FStatus.Seats.Count - 1 do
      FStatus.Seats[C1].DealtCards := FStatus.Seats[C1].CardCount;

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
    SetLength(empty_avatar_id, 0);
    for C1 := 0 to Length(query_users) - 1 do
      Players.AddPlayer(query_users[C1], 'Retrieving...', '', empty_avatar_id);
    ServerSocket.GetUserInfos(query_users);
  end;

  // update self info
  dmMain.UpdateSelfInfoInPlayers;

  ConfigureActions;

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
      csdbg := csdbg + ' - ' + playerdbg.Displayname;
    tb := seatdbg.Timebank;
  end;

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
        events := events + Format('FOLD [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Displayname, ChipsToStr(FStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)])
      else
        events := events + Format('FOLD [#%d]', [pbevent.Seat]);
      teSit: events := events + Format('SIT [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Displayname, ChipsToStr(FStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)]);
      teStandUp: events := events + Format('STAND UP [#%d]', [pbevent.Seat]);
      teWinning: events := events + 'WINNING';
      teDealing: events := events + 'DEALING';
      teCheck: events := events + Format('CHECK [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Displayname, ChipsToStr(FStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)]);
      teCall: events := events + Format('CALL [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Displayname, ChipsToStr(FStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)]);
      teRaise: events := events + Format('RAISE [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Displayname, ChipsToStr(FStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)]);
      teAllIn: events := events + Format('ALL-IN [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Displayname, ChipsToStr(FStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)]);
      teFlop: events := events + Format('FLOP [%s]', [FStatus.FlopCards.AsString]);
      teTurn: events := events + Format('TURN [%s]', [FStatus.TurnCard.AsString]);
      teRiver: events := events + Format('RIVER [%s]', [FStatus.RiverCard.AsString]);
      tePostRiver: events := events + 'POST RIVER';
      tePreWin: events := events + 'PRE WIN';
      teExistingCards: events := events + Format('EXISTING CARDS [%s]', [TCards.BytesToString(pbevent.Cards)]);
      teDisconnect: events := events + Format('DISCONNECTED [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Displayname, ChipsToStr(FStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)]);
    else
      events := events + Format('UNHANDLED EVENT RECEIVED: %s', [GetEnumName(TypeInfo(TTableEventType), Integer(pbevent.Event))]);
    end;
  end;

  DebugLn(FDebugId, tstatusdbg, ditApplication, events);
  {$ENDIF}

  NotifyRendererHandle;
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
//      if FStatus.GetSeatInfo(ATableEvent.Seat, seat) then
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

procedure TTable.PlaySound(const ASound: String; const AIgnoreFocus: Boolean = FALSE);
begin
  if ((AIgnoreFocus) or (GetForegroundWindow = FRenderer.RenderHandle)) and
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

procedure TTable.NotifyRendererHandle;
begin
  if FRenderer.RenderHandle > 0 then
    PostMessage(FRenderer.RenderHandle, WM_TABLESTATUS_REFRESH, 0, 0);
end;

procedure TTable.ConfigureActions;
var
  seat: TSeatInfo;
  fgwnd: HWND;
begin
  FStatus.ResetRaiseValue := not FStatus.ActionRaise;
  FStatus.ActionStandUp := FALSE;
  FStatus.ActionFold := FALSE;
  FStatus.ActionCall := FALSE;
  FStatus.ActionCheck := FALSE;
  FStatus.ActionRaise := FALSE;
  FStatus.ActionBet := FALSE;
  FStatus.ActionPlayNow := FALSE;
  FStatus.ActionSitOut := FALSE;
  FStatus.ActionFoldToAny := FALSE;
  FStatus.ActionSitOutNextBB := FALSE;
  FStatus.ActionShowCards := FALSE;

  if (not (FTableType in [ttLive, ttTournament])) or
     (not FStatus.GetSeatInfo(FStatus.SelfSeatIndex, seat)) then
    Exit;

  FStatus.ActionStandUp := FTableType = ttLive;

  FStatus.FocusWindow := FALSE;

  if seat.AutoPlay then
  begin
    FStatus.ActionPlayNow := TRUE;
    FStatus.ActionFoldToAny := FALSE;
    FStatus.ActionSitOut := FALSE;
    FStatus.ActionSitOutNextBB := FALSE;
  end
  else
    if FGame.State <> gsClosed then
      case seat.Status of
        psOutOfPlay: begin
          FStatus.ActionPlayNow := TRUE;
          FStatus.ActionFoldToAny := FALSE;
          FStatus.ActionSitOut := FALSE;
          FStatus.ActionSitOutNextBB := FALSE;
        end;

        psOutOfHand: begin
          FStatus.ActionFoldToAny := FALSE;
          FStatus.ActionSitOut := TRUE;
          FStatus.ActionSitOutNextBB := TRUE;
        end;

        psInHand, psAllIn: begin
          FStatus.ActionSitOut := TRUE;
          FStatus.ActionSitOutNextBB := TRUE;
          if (seat.Status = psInHand) and
             (FStatus.State in [tsPreFlop, tsFlop, tsTurn, tsRiver]) then
            FStatus.ActionFoldToAny := TRUE;

          if (FStatus.CurrentSeat = FStatus.SelfSeatIndex) and
             (not FStatus.Locked) and
             (not FGameplayLocked) then
            case FStatus.State of
              tsIdle: begin
                FStatus.ActionFoldToAny := FALSE;
              end;

              tsPreFlop, tsFlop, tsTurn, tsRiver: begin
                FStatus.ActionFold := TRUE;

                fgwnd := GetForegroundWindow;
                if (IsWindowVisible(fgwnd)) and (not IsIconic(fgwnd)) and (IsZoomed(fgwnd)) then // make sure to not focus if some fullscreen window is active
                  FStatus.FocusWindow := TRUE;

                // check if our current bet is smaller than minimumbet (call/raise situation)
                if FStatus.GetBet(seat.SeatIndex) < FStatus.MinimumBet then
                begin
                  if seat.Chips <= FStatus.MinimumBet then
                    FStatus.CallCaption := 'CALL (ALL-IN)'
                  else
                    FStatus.CallCaption := Format('CALL (%s)', [ChipsToStr(FStatus.MinimumBet{ - FStatus.GetBet(seat_info.SeatIndex)})]);
                  FStatus.ActionCall := TRUE;

                  // if we can call, there is a possibility that we can raise too - we check if we can raise here
                  if (seat.Chips > FStatus.MinimumBet) and
                     (FStatus.MinimumBet < FStatus.MinimumRaise) then
                    FStatus.ActionRaise := TRUE;
                end
                else // if our current bet isnt smaller than minimum bet, that means its check/raise situation
                begin
                  FStatus.ActionCheck := TRUE;
                  FStatus.ActionBet := TRUE;
                end;
              end;

              tsWinning, tsWinning2: begin
                FStatus.ActionFoldToAny := FALSE;
              end;
            end;
        end;

        psFolded: begin
          FStatus.ActionFoldToAny := FALSE;
          FStatus.ActionSitOut := TRUE;
          FStatus.ActionSitOutNextBB := TRUE;
        end;
      end;

  // check if SHOW CARDS button is enabled
  FStatus.ActionShowCards := (FStatus.State in [tsWinning, tsWinning2]) and
                             (seat.CanShow) and
                             (not seat.CardsVisible) and
                             (seat.Status in [psFolded, psAllIn, psInHand]) and
                             (not seat.AutoPlay);
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
        ConfigureActions;
        FRenderer.Disable;
        NotifyRendererHandle;
      end;
    end;

  end;
end;

end.
