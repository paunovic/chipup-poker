unit Poker.Tournaments;

interface

uses
  Poker.Protobufs.Objects.TournamentList, Poker.Common.SafeMutex, System.Generics.Collections, Poker.Types, Poker.Tournaments.Info,
  Poker.Protobufs.Objects.TournamentInfo, Poker.Games.Game, Poker.Protobufs.Objects.Game;

type
  TTournamentList = class(TObjectDictionary<TMongoId, TTournamentInfo>)
  private
    FLock: TSafeMutex;
  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
    destructor Destroy; override;

    function GetAndLock(const AId: TMongoId; out ATournament: TTournamentInfo): Boolean;
    function GetAndLockByGame(const AId: TMongoId; out ATournament: TTournamentInfo; out AGame: TPB_Game): Boolean;
    function AdjustRegisteredPlayersCount(const AId: TMongoId; const AAdjustment: Integer): Boolean;

    procedure Assign(const ATournamentList: TList<TPB_TournamentInfo>); overload;
    procedure Assign(const ATournamentList: TPB_TournamentList); overload;
    procedure Add(const ATournamentInfo: TPB_TournamentInfo);
    procedure Clear;

    procedure Lock;
    procedure Unlock;
  end;

var
  Tournaments: TTournamentList;

implementation

uses
  System.SysUtils, Poker.Games.GameList, Winapi.Windows;

{ TTournamentList }

class procedure TTournamentList.Initialize;
begin
  Tournaments := TTournamentList.Create;
end;

class procedure TTournamentList.Deinitialize;
begin
  FreeAndNil(Tournaments);
end;

constructor TTournamentList.Create;
begin
  FLock := TSafeMutex.Create;
  inherited Create([doOwnsValues]);
end;

destructor TTournamentList.Destroy;
begin
  FLock.Free;
  inherited;
end;

procedure TTournamentList.Lock;
begin
  FLock.Acquire;
end;

procedure TTournamentList.Unlock;
begin
  if not FLock.Release then
    OutputDebugString('!');
end;

procedure TTournamentList.Clear;
begin
  FLock.Acquire;
  try
    inherited Clear;
  finally
    FLock.Release;
  end;
end;

function TTournamentList.AdjustRegisteredPlayersCount(const AId: TMongoId; const AAdjustment: Integer): Boolean;
var
  tournament: TTournamentInfo;
  reg_players: Integer;
begin
  result := FALSE;
  if GetAndLock(AId, tournament) then
  try
    reg_players := tournament.RegisteredPlayers;
    Inc(reg_players, AAdjustment);
    if reg_players < 0 then
      reg_players := 0;
    tournament.RegisteredPlayers := reg_players;
    result := TRUE;
  finally
    Unlock;
  end;
end;

procedure TTournamentList.Assign(const ATournamentList: TPB_TournamentList);
begin
  Assign(ATournamentList.Items);
end;

procedure TTournamentList.Assign(const ATournamentList: TList<TPB_TournamentInfo>);
var
  pbtournament: TPB_TournamentInfo;
  tournament: TTournamentInfo;
  C1: Integer;
  games: TObjectList<TPB_Game>;
  mongoid: TMongoId;
  to_remove: TList<TMongoId>;
begin
  FLock.Acquire;
  try
    games := TObjectList<TPB_Game>.Create;
    try
      for tournament in Values do
        for C1 := 0 to tournament.Games.Count - 1 do
          games.Add(TPB_Game.Create(tournament.Games[C1]));

      to_remove := TList<TMongoId>.Create;
      try
        for tournament in Values do
          to_remove.Add(tournament.MongoId);

        for pbtournament in ATournamentList do
          if TryGetValue(pbtournament.MongoId, tournament) then
          begin
            if pbtournament.has_Name then
              tournament.Name := pbtournament.Name;
            if pbtournament.has_Description then
              tournament.Description := pbtournament.Description;
            if pbtournament.has_Gametype then
              tournament.Gametype := pbtournament.Gametype;
            if pbtournament.has_Limit then
              tournament.Limit := pbtournament.Limit;
            if pbtournament.has_SeatsPerTable then
              tournament.SeatsPerTable := pbtournament.SeatsPerTable;
            if pbtournament.has_Minplayers then
              tournament.Minplayers := pbtournament.Minplayers;
            if pbtournament.has_Maxplayers then
              tournament.Maxplayers := pbtournament.Maxplayers;
            if pbtournament.has_Startingchips then
              tournament.Startingchips := pbtournament.Startingchips;
            if pbtournament.has_Timeperlevel then
              tournament.Timeperlevel := pbtournament.Timeperlevel;
            if pbtournament.has_RegisteredPlayers then
              tournament.RegisteredPlayers := pbtournament.RegisteredPlayers;
            if pbtournament.has_StartTime then
              tournament.StartTime := pbtournament.StartTime;
            if pbtournament.has_State then
              tournament.State := pbtournament.State;
            to_remove.Remove(tournament.MongoId)
          end
          else
            Add(pbtournament);

        for mongoid in to_remove do
          Remove(mongoid);
      finally
        to_remove.Free;
      end;

      for C1 := 0 to games.Count - 1 do
        if TryGetValue(games[C1].Tournament, tournament) then
          tournament.AddGame(games[C1])
    finally
      games.Free;
    end;
  finally
    FLock.Release;
  end;
end;

procedure TTournamentList.Add(const ATournamentInfo: TPB_TournamentInfo);
begin
  FLock.Acquire;
  try
    if ContainsKey(ATournamentInfo.MongoId) then
      inherited Remove(ATournamentInfo.MongoId);
    inherited Add(ATournamentInfo.MongoId, TTournamentInfo.Create(ATournamentInfo));
  finally
    FLock.Release;
  end;
end;

function TTournamentList.GetAndLock(const AId: TMongoId; out ATournament: TTournamentInfo): Boolean;
begin
  FLock.Acquire;
  if TryGetValue(AId, ATournament) then
    result := TRUE
  else
  begin
    FLock.Release;
    result := FALSE;
  end;
end;

function TTournamentList.GetAndLockByGame(const AId: TMongoId; out ATournament: TTournamentInfo; out AGame: TPB_Game): Boolean;
var
  tournament: TTournamentInfo;
  game: TPB_Game;
begin
  FLock.Acquire;
  for tournament in Values do
    for game in tournament.Games do
      if game.MongoId = AId then
      begin
        ATournament := tournament;
        AGame := game;
        Exit(TRUE);
      end;
  FLock.Release;
  Exit(FALSE);
end;

end.
