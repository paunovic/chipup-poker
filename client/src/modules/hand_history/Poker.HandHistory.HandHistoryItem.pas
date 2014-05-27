unit Poker.HandHistory.HandHistoryItem;

interface

uses
  System.SysUtils, Poker.Protobufs.Objects.HandHistory, System.Generics.Collections, System.Classes, Poker.HandHistory.Players,
  Poker.HandHistory.Moves;

type
  THandHistoryItem = class
  private
    FClubId: TBytes;
    FGameId: TBytes;
    FMongoId: TBytes;
    FHandId: UINT32;
    FRake: UINT32;
    FPlayers: TPlayerHandHistories;
    FTableCards: TBytes;
    FEndTime: UINT32;
    FBalanceChanges: TArray<Integer>;
    FMoves: THandHistoryMoves;
    FLines: TStringList;

    procedure MakeLines;

  public
    constructor Create(const AClubId, AGameId: TBytes; const AHandHistory: TPB_HandHistory);
    destructor Destroy; override;

    procedure Assign(const AClubId, AGameId: TBytes; const AHandHistory: TPB_HandHistory);

    property MongoId: TBytes read FMongoId;
    property ClubId: TBytes read FClubId;
    property GameId: TBytes read FGameId;
    property HandId: UINT32 read FHandId;

    property Lines: TStringList read FLines;
  end;

  THandHistoryItems = TObjectList<THandHistoryItem>;

implementation

uses
  Poker.DataModule, Poker.Objects.GameInfo, Poker.Objects.ClubInfo, Poker.Protobufs.Objects.PlayerHandHistory,
  Poker.Protobufs.Objects.TableEvent, Poker.Protobufs.Objects.MoveRow;

{ THandHistoryItem }

constructor THandHistoryItem.Create(const AClubId, AGameId: TBytes; const AHandHistory: TPB_HandHistory);
begin
  FPlayers := TPlayerHandHistories.Create;
  FMoves := THandHistoryMoves.Create;
  FLines := TStringList.Create;
  Assign(AClubId, AGameId, AHandHistory);
end;

destructor THandHistoryItem.Destroy;
begin
  FLines.Free;
  FMoves.Free;
  FPlayers.Free;
  inherited;
end;

procedure THandHistoryItem.Assign(const AClubId, AGameId: TBytes; const AHandHistory: TPB_HandHistory);
var
  phh: TPB_PlayerHandHistory;
  mhh: TPB_MoveRow;
begin
  FClubId := AClubId;
  FGameId := AGameId;
  FMongoId := AHandHistory.MongoId;
  FHandId := AHandHistory.Seq;
  FRake := AHandHistory.Totalrake;
  FTableCards := AHandHistory.Tablecards;
  FEndTime := AHandHistory.Endtime;
  FBalanceChanges := AHandHistory.BalanceChanges;

  FPlayers.Clear;
  for phh in AHandHistory.Players do
    FPlayers.Add(TPlayerHandHistory.Create(phh));

  FMoves.Clear;
  for mhh in AHandHistory.Moves do
    FMoves.Add(THandHistoryMove.Create(mhh));

  MakeLines;
end;

procedure THandHistoryItem.MakeLines;
var
  club: TClubInfo;
  game: TGameInfo;
  C1: Integer;
  player: TPlayerHandHistory;
  move: THandHistoryMove;
  player_nick: String;
begin
  FLines.Clear;

  dmMain.SelfInfo.Clubs.FindClub(FClubId, club);
  club.Games.FindGame(FGameId, game);

  // basic info
  FLines.Add(Format('Hand #%d: %s (%.2f/%.2f)', [FHandId, game.GameTypeStrFull, game.SmallBlind / 100, game.BigBlind / 100]));
  FLines.Add(Format('Table %s %d-max', [game.Name, game.Seats]));

  // seats info
  for C1 := 0 to FPlayers.Count - 1 do
    FLines.Add(Format('Seat %d: %s (%.2f chips)', [FPlayers[C1].Seat, FPlayers[C1].Nick, FPlayers[C1].Chips / 100]));

  // sb info
  for move in FMoves do
    if move.ContainsEvent(teSB) then
    begin
      player_nick := 'Unknown';
      if FPlayers.FindPlayer(move.Seat, player) then
        player_nick := player.Nick;
      FLines.Add(Format('%s posts small blind (%.2f)', [player_nick, move.Bet / 100]));
    end;

  // bb info
  for move in FMoves do
    if move.ContainsEvent(teBB) then
    begin
      player_nick := 'Unknown';
      if FPlayers.FindPlayer(move.Seat, player) then
        player_nick := player.Nick;
      FLines.Add(Format('%s posts big blind (%.2f)', [player_nick, move.Bet / 100]));
    end;



end;

end.
