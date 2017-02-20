unit Poker.HandHistory.Items;

interface

uses
  Winapi.Windows, System.SysUtils, System.Generics.Collections, System.Classes,
  Poker.Common.SafeMutex, Poker.Protobufs.Objects.HandHistory, Poker.HandHistory.Players,
  Poker.Protobufs.Objects.HandHistoryMove, Poker.Games.Game, Poker.Clubs.Club,
  Poker.Protobufs.Objects.Game, Poker.Types, Poker.Tournaments, Poker.Tournaments.Info;

type
  THandHistoryItems = class;

  THandHistoryItem = class
  public
    type
      TRichViewTags = record
        HeaderNormal: String;
        HandId: String;
        GameType: String;
        GameTime: String;
        TableName: String;
        TableMaxSeats: String;
        ClubName: String;
        NormalText: String;
        SeatIndex: String;
        PlayerNick: String;
        Chips: String;
        TableEvent: String;
        Cards: String;
        HandStrength: String;
      end;

    const
      RV_TAGS: TRichViewTags = (
        HeaderNormal: '\i\cCCCCCC';
        HandId: '\i\b\cFFFFFF';
        GameType: '\i\b\cFFC000';
        GameTime: '\i\b\cFFFF99';
        TableName: '\i\b\cFFFF99';
        TableMaxSeats: '\i\cFFFFFF';
        ClubName: '\i\cFFFFFF';
        NormalText: '\cCCCCCC';
        SeatIndex: '\cFFFFFF';
        PlayerNick: '\cFFFFFF';
        Chips: '\cFFC000';
        TableEvent: '\b\cCEE3F2';
        Cards: '\b\cFFFF00';
        HandStrength: '\cFFFFFF';
      );

      PLAIN_TAGS: TRichViewTags = (
        HeaderNormal: '';
        HandId: '';
        GameType: '';
        GameTime: '';
        TableName: '';
        TableMaxSeats: '';
        ClubName: '';
        NormalText: '';
        SeatIndex: '';
        PlayerNick: '';
        Chips: '';
        TableEvent: '';
        Cards: '';
        HandStrength: '';
      );

  private
    FParentItems: THandHistoryItems;
    FMongoId: TMongoId;
    FHandId: UINT32;
    FRake: Integer;
    FTotalRake: UINT32;
    FPlayers: TPlayerHandHistories;
    FCards: TList<TBytes>;
    FStartTime: TDateTime;
    FStartTimeStr: String;
    FEndTime: TDateTime;
    FBalanceChanges: TList<Integer>;
    FMoves: TPB_HandHistoryMoveList;
//    FLines: TStringList;
    FRVLines: TStringList;
    FDealerIndex: Integer;
    FCurrentGame: TGameType;

    procedure MakeText(const ALines: TStrings; const ATags: TRichViewTags);
  public
    constructor Create(const AParent: THandHistoryItems; const AHandHistory: TPB_HandHistory);
    destructor Destroy; override;

    procedure Assign(const AHandHistory: TPB_HandHistory);
    procedure MakeLines;

    property ParentItems: THandHistoryItems read FParentItems;
    property MongoId: TMongoId read FMongoId;
    property HandId: UINT32 read FHandId;
    property Rake: Integer read FRake;
    property TotalRake: UINT32 read FTotalRake;
    property Players: TPlayerHandHistories read FPlayers;
    property Cards: TList<TBytes> read FCards;
    property StartTime: TDateTime read FStartTime;
    property StartTimeStr: String read FStartTimeStr;
    property EndTime: TDateTime read FEndTime;
    property BalanceChanges: TList<Integer> read FBalanceChanges;
    property Moves: TPB_HandHistoryMoveList read FMoves;
    property DealerIndex: Integer read FDealerIndex;
    property CurrentGame: TGameType read FCurrentGame;

    property RVLines: TStringList read FRVLines;
  end;

  THandHistoryItems = class(TObjectList<THandHistoryItem>)
  var
    FGameId: TMongoId;
    FParentId: TMongoId;
    FGame: TGameInfo;
    FClub: TClubInfo;
    FTournament: TTournamentInfo;
    FLock: TSafeMutex;
  public
    constructor Create(const AParentId, AGameId: TMongoId);
    destructor Destroy; override;

    procedure AddHand(const AHandHistory: TPB_HandHistory);
    function LastHandId: UINT;
    function GetAndLockHand(const AHandId: UINT; out AHandHistoryItem: THandHistoryItem): Boolean;

    procedure Unlock;

    property GameId: TMongoId read FGameId;
    property Club: TClubInfo read FClub;
    property Game: TGameInfo read FGame;
    property Tournament: TTournamentInfo read FTournament;
  end;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Poker.DataModule, Poker.Protobufs.Objects.PlayerHandHistory, Poker.Protobufs.Objects.TableEvent, Poker.Cards, Poker.Common.Misc,
  Poker.HandStrengthCalculator, System.DateUtils, Poker.Settings, Poker.Protobufs.Objects.SeatInfo, Poker.Protobufs.Objects.TableStatus,
  Poker.Protobufs.Objects.Pot, Poker.Helpers.HandHistoryMove, Poker.SoftExceptions;

{ THandHistoryItem }

constructor THandHistoryItem.Create(const AParent: THandHistoryItems; const AHandHistory: TPB_HandHistory);
begin
  FParentItems := AParent;
  FPlayers := TPlayerHandHistories.Create;
  FMoves := TPB_HandHistoryMoveList.Create;
//  FLines := TStringList.Create;
  FRVLines := TStringList.Create;
  FBalanceChanges := TList<Integer>.Create;
  FCards := TList<TBytes>.Create;
  Assign(AHandHistory);
end;

destructor THandHistoryItem.Destroy;
begin
  FBalanceChanges.Free;
//  FLines.Free;
  FRVLines.Free;
  FMoves.Free;
  FPlayers.Free;
  FCards.Free;
  inherited;
end;

procedure THandHistoryItem.Assign(const AHandHistory: TPB_HandHistory);
begin
  FMongoId := AHandHistory.MongoId;
  FHandId := AHandHistory.Seq;
  FRake := AHandHistory.Rake;
  FTotalRake := AHandHistory.Totalrake;
  FCards.Clear;
  FCards.AddRange(AHandHistory.Cards);
  FEndTime := TTimeZone.Local.ToLocalTime(UnixToDateTime(AHandHistory.Endtime));
  FBalanceChanges.Clear;
  FBalanceChanges.AddRange(AHandHistory.BalanceChanges);
  FDealerIndex := AHandHistory.Dealer;
  FCurrentGame := AHandHistory.CurrentGame;
  FStartTime := TTimeZone.Local.ToLocalTime(FMongoId.ToDateTime);
  FStartTimeStr := FormatDateTime('yyyy/mm/dd hh:nn:ss', FStartTime);
  FPlayers.Assign(AHandHistory.Players);
  FMoves.Assign(AHandHistory.Moves);
end;

procedure THandHistoryItem.MakeLines;
begin
//  MakeText(FLines, PLAIN_TAGS);
  MakeText(FRVLines, RV_TAGS);
end;

procedure THandHistoryItem.MakeText(const ALines: TStrings; const ATags: TRichViewTags);
var
  player: TPB_PlayerHandHistory;
  move: TPB_HandHistoryMove;
  player_nick: String;
  pot: TPB_Pot;
  total_pot: UINT32;
  total_rake: UINT32;
  player_line: String;
  seat_winnings: TArray<UINT32>;
  fold_on: TArray<TTableState>;
  line: String;
  tablestate: TTableState;
  C1, C2: Integer;
  action: String;
  last_bet: UINT32;
  parent_name: String;
  tmp: String;
  index: Integer;
  cards_set: TBytes;
  hand_strength: String;
  gamename: String;
begin
  ALines.Clear;

  tablestate := tsPreFlop;

  // basic info
  if FParentItems.Game.GameType = gtRotationNLHPLO then
  begin
    case FCurrentGame of
      gtHoldem: gamename := GameTypeToStr(FCurrentGame, glNoLimit, FALSE);
      gtOmaha: gamename := GameTypeToStr(FCurrentGame, glPotLimit, FALSE);
    end;
  end
  else
    gamename := FParentItems.Game.GameName;

  ALines.Add(Format('%sHand %s#%d%s: %s%s (%s/%s)%s - %s%s', [
      ATags.HeaderNormal, ATags.HandId, FHandId, ATags.HeaderNormal,
      ATags.GameType, gamename, ChipsToStr(FParentItems.Game.SmallBlind),
      ChipsToStr(FParentItems.Game.BigBlind), ATags.HeaderNormal,
      ATags.GameTime, FStartTimeStr
  ]));

  if Assigned(FParentItems.Tournament) then
    parent_name := FParentItems.Tournament.Name
  else
    parent_name := FParentItems.Club.Name;

  ALines.Add(Format('%sTable ''%s%s%s'' (%s%d-max%s) - %s%s', [
      ATags.HeaderNormal, ATags.TableName, gamename,
      ATags.HeaderNormal, ATags.TableMaxSeats, FParentItems.Game.Seats,
      ATags.HeaderNormal, ATags.ClubName, parent_name
  ]));

  ALines.Add('');

  // seats info
  for player in FPlayers do
  begin
    line := '%sSeat %s%d%s: %s%s%s (%s%s%s chips';
    if player.Seat = FDealerIndex then
      line := line + ', dealer';
    if player.Status = psOutOfPlay then
      line := line + ', sitting out';
    if player.Status = psOutOfHand then
      line := line + ', out of hand';
    line := line + ')';

    ALines.Add(Format(line, [
        ATags.NormalText, ATags.SeatIndex, player.Seat + 1, ATags.NormalText, ATags.PlayerNick, player.Nick,
        ATags.NormalText, ATags.Chips, ChipsToStr(player.Chips), ATags.NormalText
    ]));
  end;

  SetLength(fold_on, FParentItems.Game.Seats);

  last_bet := 0;
  // moves
  for move in FMoves do
  begin
    player_nick := 'Unknown player';
    if FPlayers.FindPlayer(move.Seat, player) then
      player_nick := player.Nick;

    if move.ContainsEvent(teSB) then
    begin
      ALines.Add(Format('%s%s%s posts small blind (%s%s%s)', [ATags.PlayerNick, player_nick, ATags.NormalText, ATags.Chips, ChipsToStr(move.Bet), ATags.NormalText]));
      last_bet := move.Bet;
    end;

    if move.ContainsEvent(teBB) then
    begin
      ALines.Add(Format('%s%s%s posts big blind (%s%s%s)', [ATags.PlayerNick, player_nick, ATags.NormalText, ATags.Chips, ChipsToStr(move.Bet), ATags.NormalText]));
      last_bet := move.Bet;
    end;

    if move.ContainsEvent(teDealing) then
    begin
      tablestate := tsPreFlop;
      ALines.Add('');
      ALines.Add(Format('%s*** HOLE CARDS ***', [ATags.TableEvent]));
      ALines.Add('');
    end;

    if move.ContainsEvent(teCheck) then
      ALines.Add(Format('%s%s%s checks', [ATags.PlayerNick, player_nick, ATags.NormalText]));

    if move.ContainsEvent(teCall) then
    begin
      ALines.Add(Format('%s%s%s calls %s%s', [ATags.PlayerNick, player_nick, ATags.NormalText, ATags.Chips, ChipsToStr(move.Bet)]));
      last_bet := move.Bet;
    end;

    if move.ContainsEvent(teRaise) then
    begin
      if last_bet = 0 then
        action := 'bets'
      else
        action := 'raises to';

      ALines.Add(Format('%s%s%s %s %s%s', [ATags.PlayerNick, player_nick, ATags.NormalText, action, ATags.Chips, ChipsToStr(move.Bet)]));
      last_bet := move.Bet;
    end;

    if move.ContainsEvent(teAllIn) then
    begin
      if move.Bet > last_bet then
        action := 'raises to'
      else
        action := 'calls';

      ALines.Add(Format('%s%s%s %s %s%s%s and is all-in', [ATags.PlayerNick, player_nick, ATags.NormalText, action, ATags.Chips, ChipsToStr(move.Bet), ATags.NormalText]));
    end;

    if move.ContainsEvent(teFlop) then
    begin
      last_bet := 0;
      tablestate := tsFlop;
      ALines.Add('');
      tmp := Format('%s*** FLOP *** [', [ATags.TableEvent]);
      for C1 := 0 to FCards.Count - 1 do
        if Length(FCards[C1]) >= 3 then
          tmp := tmp + ATags.Cards + TCards.BytesToString(FCards[C1], ' ', 3) +
               ATags.NormalText + ' | ';
      if tmp[Length(tmp)] = ' ' then
        Delete(tmp, Length(tmp) - 2, 3);
      tmp := tmp + ATags.TableEvent + ']';
      ALines.Add(tmp);
    end;

    if move.ContainsEvent(teTurn) then
    begin
      last_bet := 0;
      tablestate := tsTurn;
      ALines.Add('');

      tmp := Format('%s*** TURN *** [', [ATags.TableEvent]);
      for C1 := 0 to FCards.Count - 1 do
      begin
        if Length(FCards[C1]) > 3 then
          index := 3
        else
          if Length(FCards[C1]) = 2 then
            index := 0
          else
            index := -1;
        if index <> -1 then
          tmp := tmp + ATags.Cards + TCard.ByteToString(FCards[C1][index]) + ATags.NormalText + ' | ';
      end;
      if tmp[Length(tmp)] = ' ' then
        Delete(tmp, Length(tmp) - 2, 3);
      tmp := tmp + ATags.TableEvent + ']';
      ALines.Add(tmp);
      ALines.Add('');
    end;

    if move.ContainsEvent(teRiver) then
    begin
      last_bet := 0;
      tablestate := tsRiver;

      tmp := Format('%s*** RIVER *** [', [ATags.TableEvent]);
      for C1 := 0 to FCards.Count - 1 do
      begin
        if Length(FCards[C1]) > 4 then
          index := 4
        else
          if Length(FCards[C1]) = 2 then
            index := 1
          else
            if Length(FCards[C1]) = 1 then
              index := 0
            else
              index := -1;
        if index <> -1 then
          tmp := tmp + ATags.Cards + TCard.ByteToString(FCards[C1][index]) + ATags.NormalText + ' | ';
      end;
      if tmp[Length(tmp)] = ' ' then
        Delete(tmp, Length(tmp) - 2, 3);
      tmp := tmp + ATags.TableEvent + ']';
      ALines.Add(tmp);
      ALines.Add('');
    end;

    if move.ContainsEvent(teFold) then
    begin
      ALines.Add(Format('%s%s%s folds', [ATags.PlayerNick, player_nick, ATags.NormalText]));
      fold_on[move.Seat] := tablestate;
    end;

    if move.ContainsEvent(teWinning) then
    begin
      tablestate := tsWinning;

      // showdown
      ALines.Add('');
      ALines.Add(Format('%s*** SHOW DOWN ***', [ATags.TableEvent]));
      ALines.Add('');

      for player in FPlayers do
      begin
        if fold_on[player.Seat] > tsIdle then
          Continue;

        if player.Muck then
          ALines.Add(Format('%s%s%s mucks hand', [ATags.PlayerNick, player.Nick, ATags.NormalText]))
        else
          if player.Status in [psInHand, psFolded, psAllIn] then
          begin
            tmp := Format('%s%s%s shows [%s%s%s] (%s', [
                ATags.PlayerNick, player.Nick, ATags.NormalText, ATags.Cards, TCards.BytesToString(player.Cards, ' '),
                ATags.NormalText, ATags.HandStrength]);

            SetLength(cards_set, 0);
            for C1 := 0 to FCards.Count - 1 do
            begin
              if Length(cards_set) = 0 then
                cards_set := Copy(FCards[C1], 0, Length(FCards[C1]));

              for C2 := High(FCards[C1]) downto Low(FCards[C1]) do
                cards_set[C2] := FCards[C1][C2];

              hand_strength := THandStrengthCalculator.GetHandStrength(TCards.BytesToString(player.Cards),
                  TCards.BytesToString(cards_set), FCurrentGame, FALSE);
              tmp := tmp + hand_strength;
              if C1 < FCards.Count - 1 then
                tmp := tmp + ATags.NormalText + ' | ' + ATags.HandStrength;
            end;

            tmp := tmp + ATags.NormalText + ')';
            ALines.Add(tmp);
          end;
      end;

      // summary
      ALines.Add('');
      ALines.Add(Format('%s*** SUMMARY ***', [ATags.TableEvent]));
      ALines.Add('');

      // show total pot and rake
      total_pot := 0;
      total_rake := 0;
      for pot in move.WinnerPotData do
      begin
        Inc(total_pot, pot.Value);
        Inc(total_rake, pot.Rake);
      end;
      ALines.Add(Format('%sTotal pot: %s%s%s | Rake: %s%s%s', [ATags.NormalText, ATags.Chips, ChipsToStr(total_pot - total_rake),
         ATags.NormalText, ATags.Chips, ChipsToStr(total_rake), ATags.NormalText]));

      if FCards.Count > 0 then
      begin
        tmp := Format('%sTable cards [%s', [ATags.NormalText, ATags.Cards]);
        for C1 := 0 to FCards.Count - 1 do
        begin
          tmp := tmp + TCards.BytesToString(FCards[C1], ' ');
          if C1 < FCards.Count - 1 then
            tmp := tmp + ATags.NormalText + ' | ' + ATags.Cards;
        end;
        tmp := tmp + ATags.NormalText + ']';
        ALines.Add(tmp);
      end;

      // calculate each player winning amount
      SetLength(seat_winnings, FParentItems.Game.Seats);
      FillChar(seat_winnings[0], Length(seat_winnings) * SizeOf(UINT32), 0);
      for pot in move.WinnerPotData do
        for C1 := 0 to pot.WinnerData.Count - 1 do
          Inc(seat_winnings[pot.WinnerData[C1].Seat], (pot.Value - pot.Rake) div UINT32(pot.WinnerData.Count));

      // show summary
      for player in FPlayers do
      begin
        player_line := Format('%sSeat %s%d%s: %s%s%s ', [
            ATags.NormalText, ATags.SeatIndex, player.Seat, ATags.NormalText, ATags.PlayerNick, player.Nick, ATags.NormalText
        ]);

        if Length(player.Cards) > 0 then
          player_line := player_line + Format('[%s%s%s] ', [ATags.Cards, TCards.BytesToString(player.Cards, ' '), ATags.NormalText]);

        if player.Status = psOutOfPlay then
          player_line := player_line + 'is sitting out '
        else
          if player.Status = psOutOfHand then
            player_line := player_line + 'is out of hand '
          else
            if fold_on[player.Seat] > tsIdle then
            begin
              case fold_on[player.Seat] of
                tsPreFlop: player_line := player_line + 'folded pre-flop ';
                tsFlop: player_line := player_line + 'folded on flop ';
                tsTurn: player_line := player_line + 'folded on turn ';
                tsRiver: player_line := player_line + 'folded on river ';
              end;
            end
            else
              if player.Muck then
                player_line := player_line + 'mucked ';

        if seat_winnings[player.Seat] > 0 then
        begin
          if player.Muck then
            player_line := player_line + 'and ';

          player_line := player_line + Format('won %s%s%s', [ATags.Chips, ChipsToStr(seat_winnings[player.Seat]), ATags.NormalText]);

          if hand_strength <> '' then // FIXME / CHECKME!
            player_line := player_line + Format(' with %s%s', [ATags.HandStrength, hand_strength]);
        end;

        player_line := TrimRight(player_line);

        ALines.Add(player_line);
      end;
    end;
  end;
end;

{ THandHistoryItems }

constructor THandHistoryItems.Create(const AParentId, AGameId: TMongoId);
var
  club: TClubInfo;
  game: TGameInfo;
  pbgame: TPB_Game;
  tournament: TTournamentInfo;
begin
  inherited Create(TRUE);

  FLock := TSafeMutex.Create;

  FParentId := AParentId;
  FGameId := AGameId;
  FClub := TClubInfo.Create;
  FGame := TGameInfo.Create;
  FTournament := nil;

  // try to copy Club and Game from internal lists (if found)
  if dmMain.SelfInfo.Clubs.GetAndLock(FParentId, club) then
  try
    FClub.Assign(club, FALSE);
    if club.Games.TryGetValue(AGameId, game) then
      FGame.Assign(game);
  finally
    dmMain.SelfInfo.Clubs.Unlock;
  end;

  if not Assigned(club) then
  begin
    if Tournaments.GetAndLockByGame(FGameId, tournament, pbgame) then
    try
      FTournament := TTournamentInfo.Create(tournament);
      FGame.Assign(pbgame);
    finally
      Tournaments.Unlock;
    end;
  end;

  // fixme
  if FGame.MongoId.IsEmpty then
  begin
    SoftException('HandHistory: Game.MongoId is empty');
  end;
end;

destructor THandHistoryItems.Destroy;
begin
  FGame.Free;
  FClub.Free;
  FreeAndNil(FTournament);

  FLock.Free;

  inherited;
end;

function THandHistoryItems.GetAndLockHand(const AHandId: UINT; out AHandHistoryItem: THandHistoryItem): Boolean;
var
  hhi: THandHistoryItem;
begin
  result := FALSE;
  FLock.Acquire;
  for hhi in ToArray do
    if hhi.HandId = AHandId then
    begin
      AHandHistoryItem := hhi;
      Exit(TRUE);
    end
    else
      if hhi.HandId > AHandId then
        Break;
  FLock.Release;
end;

procedure THandHistoryItems.AddHand(const AHandHistory: TPB_HandHistory);
var
  hhi: THandHistoryItem;
begin
  if GetAndLockHand(AHandHistory.Seq, hhi) then
  begin
    hhi.Assign(AHandHistory);
    Unlock;
  end
  else
  begin
    FLock.Acquire;
    try
      while Count >= Settings.Hardcoded.TABLE_HAND_HISTORY_LIMIT do
        inherited Remove(Last);
      inherited Add(THandHistoryItem.Create(self, AHandHistory));
    finally
      FLock.Release;
    end;
  end;
end;

function THandHistoryItems.LastHandId: UINT;
begin
  FLock.Acquire;
  try
    if Count = 0 then
      Exit(0)
    else
      result := Last.HandId;
  finally
    FLock.Release;
  end;
end;

procedure THandHistoryItems.Unlock;
begin
  FLock.Release;
end;

end.
