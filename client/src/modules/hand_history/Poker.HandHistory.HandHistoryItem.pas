unit Poker.HandHistory.HandHistoryItem;

interface

uses
  Winapi.Windows, System.SysUtils, Poker.Protobufs.Objects.HandHistory, System.Generics.Collections, System.Classes, System.SyncObjs,
  Poker.HandHistory.Players, Poker.HandHistory.Moves, Poker.Objects.GameInfo, Poker.Objects.ClubInfo, Poker.Protobufs.Objects.Game;

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
    FMongoId: TBytes;
    FHandId: UINT32;
    FRake: UINT32;
    FPlayers: TPlayerHandHistories;
    FCards: TBytes;
    FTableCardsStr: String;
    FStartTime: TDateTime;
    FStartTimeStr: String;
    FEndTime: TDateTime;
    FBalanceChanges: TArray<Integer>;
    FMoves: THandHistoryMoves;
    FLines: TStringList;
    FRVLines: TStringList;
    FDealerIndex: Integer;
    FCurrentGame: TGameType;

    procedure MakeText(const ALines: TStrings; const ATags: TRichViewTags);
    procedure MakeLines;

  public
    constructor Create(const AParent: THandHistoryItems; const AHandHistory: TPB_HandHistory);
    destructor Destroy; override;

    procedure Assign(const AHandHistory: TPB_HandHistory);

    property MongoId: TBytes read FMongoId;
    property HandId: UINT32 read FHandId;
    property CurrentGame: TGameType read FCurrentGame;
    property StartTimeStr: String read FStartTimeStr;
    property ParentItems: THandHistoryItems read FParentItems;

    property Lines: TStringList read FLines;
    property RVLines: TStringList read FRVLines;
  end;

  THandHistoryItems = class(TObjectList<THandHistoryItem>)
  var
    FGameId: TBytes;
    FClubId: TBytes;
    FGame: TGameInfo;
    FClub: TClubInfo;
    FLock: TCriticalSection;
  public
    constructor Create(const AClubId, AGameId: TBytes);
    destructor Destroy; override;

    procedure AddHand(const AHandHistory: TPB_HandHistory);
    function FindHand(const AHandId: UINT; out AHandHistoryItem: THandHistoryItem): Boolean;
    function LastHandId: UINT;

    property Club: TClubInfo read FClub;
    property Game: TGameInfo read FGame;
  end;

implementation

uses
  Poker.DataModule, Poker.Protobufs.Objects.PlayerHandHistory, Poker.Protobufs.Objects.TableEvent, Poker.Protobufs.Objects.MoveRow,
  Poker.Cards, Poker.Common.Misc, Poker.Table.Status, Poker.HandStrengthCalculator, System.DateUtils, Poker.Settings;

{ THandHistoryItem }

constructor THandHistoryItem.Create(const AParent: THandHistoryItems; const AHandHistory: TPB_HandHistory);
begin
  FParentItems := AParent;
  FPlayers := TPlayerHandHistories.Create;
  FMoves := THandHistoryMoves.Create;
  FLines := TStringList.Create;
  FRVLines := TStringList.Create;
  Assign(AHandHistory);
end;

destructor THandHistoryItem.Destroy;
begin
  FLines.Free;
  FRVLines.Free;
  FMoves.Free;
  FPlayers.Free;
  inherited;
end;

procedure THandHistoryItem.Assign(const AHandHistory: TPB_HandHistory);
var
  phh: TPB_PlayerHandHistory;
  mhh: TPB_MoveRow;
begin
  FMongoId := AHandHistory.MongoId;
  FHandId := AHandHistory.Seq;
  FRake := AHandHistory.Totalrake;
  SetLength(FCards, Length(AHandHistory.Cards));
  Move(AHandHistory.Cards[0], FCards[0], Length(AHandHistory.Cards) * SizeOf(Byte));
  FTableCardsStr := TCards.BytesToString(FCards);
  FEndTime := TTimeZone.Local.ToLocalTime(UnixToDateTime(AHandHistory.Endtime));
  FBalanceChanges := AHandHistory.BalanceChanges;
  FDealerIndex := AHandHistory.Dealer;
  FCurrentGame := AHandHistory.CurrentGame;
  FStartTime := TTimeZone.Local.ToLocalTime(MongoIdToDateTime(FMongoId));
  FStartTimeStr := FormatDateTime('yyyy/mm/dd hh:nn:ss', FStartTime);

  FPlayers.Clear;
  for phh in AHandHistory.Players do
    FPlayers.Add(TPlayerHandHistory.Create(phh));

  FMoves.Clear;
  for mhh in AHandHistory.Moves do
    FMoves.Add(THandHistoryMove.Create(mhh));

  MakeLines;
end;

procedure THandHistoryItem.MakeLines;
begin
  MakeText(FLines, PLAIN_TAGS);
  MakeText(FRVLines, RV_TAGS);
end;

procedure THandHistoryItem.MakeText(const ALines: TStrings; const ATags: TRichViewTags);
var
  C1: Integer;
  player: TPlayerHandHistory;
  move: THandHistoryMove;
  player_nick: String;
  pot: TPotInfo;
  total_pot: UINT32;
  total_rake: UINT32;
  player_line: String;
  hand_strength: String;
  seat_winnings: TArray<UINT32>;
  line: String;
begin
  ALines.Clear;

  // basic info
  ALines.Add(Format('%sHand %s#%d%s: %s%s (%s/%s)%s - %s%s', [
      ATags.HeaderNormal, ATags.HandId, FHandId, ATags.HeaderNormal, ATags.GameType, TGameInfo.GameTypeToStr(FCurrentGame, FParentItems.Game.Limit, FALSE),
      ChipsToStr(FParentItems.Game.SmallBlind), ChipsToStr(FParentItems.Game.BigBlind), ATags.HeaderNormal, ATags.GameTime, FStartTimeStr
  ]));

  ALines.Add(Format('%sTable ''%s%s%s'' (%s%d-max%s) - %s%s', [
      ATags.HeaderNormal, ATags.TableName, FParentItems.Game.Name, ATags.HeaderNormal, ATags.TableMaxSeats, FParentItems.Game.Seats, ATags.HeaderNormal,
      ATags.ClubName, FParentItems.Club.Name
  ]));

  ALines.Add('');

  // seats info
  // we increment seats by one here, so they dont start from zero!
  for C1 := 0 to FPlayers.Count - 1 do
  begin
    line := '%sSeat %s%d%s: %s%s%s (%s%s%s chips';
    if FPlayers[C1].Seat = FDealerIndex then
      line := line + ', dealer';
    line := line + ')';

    ALines.Add(Format(line, [
        ATags.NormalText, ATags.SeatIndex, FPlayers[C1].Seat + 1, ATags.NormalText, ATags.PlayerNick, FPlayers[C1].Nick,
        ATags.NormalText, ATags.Chips, ChipsToStr(FPlayers[C1].Chips), ATags.NormalText
    ]));
  end;

  // moves
  for move in FMoves do
  begin
    player_nick := 'Unknown';
    if FPlayers.FindPlayer(move.Seat, player) then
      player_nick := player.Nick;

    if move.ContainsEvent(teSB) then
      ALines.Add(Format('%s%s%s posts small blind (%s%s%s)', [ATags.PlayerNick, player_nick, ATags.NormalText, ATags.Chips, ChipsToStr(move.Bet), ATags.NormalText]));

    if move.ContainsEvent(teBB) then
      ALines.Add(Format('%s%s%s posts big blind (%s%s%s)', [ATags.PlayerNick, player_nick, ATags.NormalText, ATags.Chips, ChipsToStr(move.Bet), ATags.NormalText]));

    if move.ContainsEvent(teDealing) then
    begin
      ALines.Add('');
      ALines.Add(Format('%s*** HOLE CARDS ***', [ATags.TableEvent]));
      ALines.Add('');
    end;

    if move.ContainsEvent(teCheck) then
      ALines.Add(Format('%s%s%s checks', [ATags.PlayerNick, player_nick, ATags.NormalText, player_nick]));

    if move.ContainsEvent(teCall) then
      ALines.Add(Format('%s%s%s calls %s%s', [ATags.PlayerNick, player_nick, ATags.NormalText, ATags.Chips, ChipsToStr(move.Bet)]));

    if move.ContainsEvent(teRaise) then // handler for BET here too! FIXME
    begin
      ALines.Add(Format('%s%s%s raises %s%s', [ATags.PlayerNick, player_nick, ATags.NormalText, ATags.Chips, ChipsToStr(move.Bet)]));
    end;

    if move.ContainsEvent(teFlop) then
    begin
      ALines.Add('');
      ALines.Add(Format('%s*** FLOP *** [%s%s%s]', [ATags.TableEvent, ATags.Cards, TCards.BytesToString(FCards, ' ', 3), ATags.TableEvent]));
      ALines.Add('');
    end;

    if move.ContainsEvent(teTurn) then
    begin
      ALines.Add('');
      ALines.Add(Format('%s*** TURN *** [%s%s%s]', [ATags.TableEvent, ATags.Cards, TCard.ByteToString(FCards[3]), ATags.TableEvent]));
      ALines.Add('');
    end;

    if move.ContainsEvent(teRiver) then
    begin
      ALines.Add('');
      ALines.Add(Format('%s*** RIVER *** [%s%s%s]', [ATags.TableEvent, ATags.Cards, TCard.ByteToString(FCards[4]), ATags.TableEvent]));
      ALines.Add('');
    end;

    if move.ContainsEvent(teFold) then
      ALines.Add(Format('%s%s%s folds', [ATags.PlayerNick, player_nick, ATags.NormalText]));

    if move.ContainsEvent(teWinning) then
    begin
      // showdown
      ALines.Add('');
      ALines.Add(Format('%s*** SHOW DOWN ***', [ATags.TableEvent]));
      ALines.Add('');

      for C1 := 0 to FPlayers.Count - 1 do
      begin
        if FPlayers[C1].Mucked then
          ALines.Add(Format('%s%s%s mucks hand', [ATags.PlayerNick, FPlayers[C1].Nick, ATags.NormalText]))
        else
        begin
          hand_strength := THandStrengthCalculator.GetHandStrength(FPlayers[C1].CardsStr, FTableCardsStr, FCurrentGame, FALSE);
          ALines.Add(Format('%s%s%s shows [%s%s%s] (%s%s%s)', [
              ATags.PlayerNick, FPlayers[C1].Nick, ATags.NormalText, ATags.Cards, TCards.BytesToString(FPlayers[C1].Cards, ' '),
              ATags.NormalText, ATags.HandStrength, hand_strength, ATags.NormalText
          ]));
        end;
      end;

      // summary
      ALines.Add('');
      ALines.Add(Format('%s*** SUMMARY ***', [ATags.TableEvent]));
      ALines.Add('');

      // show total pot and rake
      total_pot := 0;
      total_rake := 0;
      for pot in move.WinnerPots do
      begin
        Inc(total_pot, pot.Value);
        Inc(total_rake, pot.Rake);
      end;
      ALines.Add(Format('%sTotal pot: %s%s%s | Rake: %s%s%s', [
         ATags.NormalText, ATags.Chips, ChipsToStr(total_pot - total_rake), ATags.NormalText, ATags.Chips, ChipsToStr(total_rake),
         ATags.NormalText
      ]));
      ALines.Add(Format('%sTable cards [%s%s%s]', [ATags.NormalText, ATags.Cards, TCards.BytesToString(FCards, ' '), ATags.NormalText]));

      // calculate each player winning amount
      SetLength(seat_winnings, FParentItems.Game.Seats);
      FillChar(seat_winnings[0], Length(seat_winnings) * SizeOf(UINT32), 0);
      for pot in move.WinnerPots do
        for C1 := 0 to pot.WinnerData.Count - 1 do
          Inc(seat_winnings[pot.WinnerData[C1].Seat], (pot.Value - pot.Rake) div UINT32(pot.WinnerData.Count));

      // show summary
      for C1 := 0 to FPlayers.Count - 1 do
      begin
        player := FPlayers[C1];
        player_line := Format('%sSeat %s%d%s: %s%s%s ', [
            ATags.NormalText, ATags.SeatIndex, player.Seat, ATags.NormalText, ATags.PlayerNick, player.Nick, ATags.NormalText
        ]);

        hand_strength := '';
        if Length(player.Cards) > 0 then
        begin
          hand_strength := THandStrengthCalculator.GetHandStrength(player.CardsStr, FTableCardsStr, FCurrentGame, FALSE);
          player_line := player_line + Format('[%s%s%s] ', [ATags.Cards, TCards.BytesToString(player.Cards, ' '), ATags.NormalText]);
        end;

        if player.Mucked then
          player_line := player_line + 'mucked ';

        if seat_winnings[player.Seat] > 0 then
        begin
          if player.Mucked then
            player_line := player_line + 'and ';

          player_line := player_line + Format('won %s%s%s', [ATags.Chips, ChipsToStr(seat_winnings[player.Seat]), ATags.NormalText]);

          if hand_strength <> '' then
            player_line := player_line + Format(' with %s%s', [ATags.HandStrength, hand_strength]);
        end;

        player_line := TrimRight(player_line);

        ALines.Add(player_line);
      end;
    end;
  end;
end;

{ THandHistoryItems }

constructor THandHistoryItems.Create(const AClubId, AGameId: TBytes);
var
  club: TClubInfo;
  game: TGameInfo;
begin
  FLock := TCriticalSection.Create;

  FClubId := AClubId;
  FGameId := AGameId;
  FClub := TClubInfo.Create;
  FGame := TGameInfo.Create;

  // try to copy Club and Game from internal lists (if found)
  if dmMain.SelfInfo.Clubs.FindClub(AClubId, club) then
  begin
    FClub.Assign(club);
    if club.Games.FindGame(AGameId, game) then
      FGame.Assign(game);
  end;

  // check if objects are found, and if not, try to copy them from server proto
  // fixme
  if not Assigned(club) then
  begin

  end;

  if not Assigned(game) then
  begin

  end;

  inherited Create;
end;

destructor THandHistoryItems.Destroy;
begin
  FGame.Free;
  FClub.Free;

  FLock.Free;

  inherited;
end;

procedure THandHistoryItems.AddHand(const AHandHistory: TPB_HandHistory);
var
  hhi: THandHistoryItem;
begin
  FLock.Enter;
  try
    for hhi in ToArray do
      if hhi.HandId = AHandHistory.Seq then
      begin
        hhi.Assign(AHandHistory);
        Exit;
      end;

    while Count >= Settings.Hardcoded.HAND_HISTORY_HAND_LIMIT_PER_TABLE do
      Delete(0);

    Add(THandHistoryItem.Create(self, AHandHistory));
  finally
    FLock.Leave;
  end;
end;

function THandHistoryItems.FindHand(const AHandId: UINT; out AHandHistoryItem: THandHistoryItem): Boolean;
var
  hhi: THandHistoryItem;
begin
  FLock.Enter;
  try
    for hhi in ToArray do
      if hhi.HandId = AHandId then
      begin
        AHandHistoryItem := hhi;
        Exit(TRUE);
      end;
    Exit(FALSE);
  finally
    FLock.Leave;
  end;
end;

function THandHistoryItems.LastHandId: UINT;
begin
  FLock.Enter;
  try
    if Count = 0 then
      Exit(0)
    else
      result := Last.HandId;
  finally
    FLock.Leave;
  end;
end;

end.
