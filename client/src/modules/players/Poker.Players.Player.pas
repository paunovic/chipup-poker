unit Poker.Players.Player;

interface

uses
  System.Generics.Collections, System.SysUtils, Poker.Clubs.ClubList,
  Poker.Protobufs.Objects.LoginReply, Poker.Types, Poker.Protobufs.Objects.User,
  Poker.Protobufs.Objects.PlayerClubStatus, Poker.Protobufs.Objects.Club;

type
  TPlayerInfo = class(TPB_User)
  private
    FPassword: String;
    FClubs: TClubList;
//    FPendingClubs: TClubList;
    FRegisteredTournaments: TList<TMongoId>;
    FTableStatuses: TObjectDictionary<TMongoId, TPB_PlayerClubStatus>;

    procedure ProcessClubsObject(const AClubs: TList<TPB_Club>);
//    procedure ProcessPendingClubsObject(const AClubs: TList<TPB_Club>);

  public
    constructor Create;
    destructor Destroy; override;

    procedure Flush;

    procedure LoadFromLoginReply(const ALoginReply: TPB_LoginReply);

    property Password: String read FPassword write FPassword;
    property Clubs: TClubList read FClubs;
//    property PendingClubs: TClubList read FPendingClubs;
    property RegisteredTournaments: TList<TMongoId> read FRegisteredTournaments;
    property TableStatuses: TObjectDictionary<TMongoId, TPB_PlayerClubStatus> read FTableStatuses;
  end;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Poker.Tables.TableList, Poker.Protobufs.Objects.Game,
  Poker.Common.Misc, Poker.Clubs.Club, Poker.Tables.Table, Poker.Games.Game,
  Poker.Tournaments, Poker.Tournaments.Info;

{ TPlayerInfo }

constructor TPlayerInfo.Create;
begin
  inherited Create(TRUE);

  FClubs := TClubList.Create;
//  FPendingClubs := TClubList.Create;
  FRegisteredTournaments := TList<TMongoId>.Create;
  FTableStatuses := TObjectDictionary<TMongoId, TPB_PlayerClubStatus>.Create([doOwnsValues]);
end;

destructor TPlayerInfo.Destroy;
begin
  FTableStatuses.Free;
  FRegisteredTournaments.Free;
//  FPendingClubs.Free;
  FClubs.Free;

  inherited;
end;

procedure TPlayerInfo.Flush;
begin
  Clear;
  FClubs.Clear;
//  FPendingClubs.Clear;
  FPassword := '';
  FRegisteredTournaments.Clear;
  FTableStatuses.Clear;
end;

procedure TPlayerInfo.ProcessClubsObject(const AClubs: TList<TPB_Club>);
var
  to_remove: TList<TMongoId>;
  club: TClubInfo;
  pbclub: TPB_Club;
  found: Boolean;
  mongoid: TMongoId;
begin
  to_remove := TList<TMongoId>.Create;
  try
    FClubs.Lock;
    try
      for club in Clubs.Values do
      begin
        found := FALSE;
        for pbclub in AClubs do
          if pbclub.MongoId = club.MongoId then
          begin
            club.Assign(pbclub);
            found := TRUE;
            Break;
          end;

        if not found then
          to_remove.Add(club.Mongoid);
      end;
    finally
      FClubs.Unlock;
    end;

    for mongoid in to_remove do
    begin
      FClubs.Lock;
      try
        if FClubs.ContainsKey(mongoid) then
        begin
          Tables.CloseTablesForClub(mongoid);
          FClubs.Remove(mongoid);
        end;
      finally
        FClubs.Unlock;
      end;
    end;

    for pbclub in AClubs do
    begin
      FClubs.Lock;
      try
        if not FClubs.ContainsKey(pbclub.MongoId) then
          FClubs.AddClub(pbclub);
      finally
        FClubs.Unlock;
      end;
    end;
  finally
    to_remove.Free;
  end;
end;
{
procedure TPlayerInfo.ProcessPendingClubsObject(const AClubs: TList<TPB_Club>);
var
  to_remove: TList<TMongoId>;
  club: TClubInfo;
  pbclub: TPB_Club;
  found: Boolean;
  mongoid: TMongoId;
begin
  to_remove := TList<TMongoId>.Create;
  try
    FPendingClubs.Lock;
    try
      for club in FPendingClubs.Values do
      begin
        found := FALSE;
        for pbclub in AClubs do
          if pbclub.MongoId = club.MongoId then
          begin
            club.Assign(pbclub);
            found := TRUE;
            Break;
          end;

        if not found then
          to_remove.Add(club.Mongoid);
      end;
    finally
      FPendingClubs.Unlock;
    end;

    for mongoid in to_remove do
    begin
      FPendingClubs.Lock;
      try
        if FPendingClubs.ContainsKey(mongoid) then
          FClubs.Remove(mongoid);
      finally
        FPendingClubs.Unlock;
      end;
    end;

    for pbclub in AClubs do
    begin
      FPendingClubs.Lock;
      try
        if not FPendingClubs.ContainsKey(pbclub.MongoId) then
          FPendingClubs.AddClub(pbclub);
      finally
        FPendingClubs.Unlock;
      end;
    end;
  finally
    to_remove.Free;
  end;
end;
 }
procedure TPlayerInfo.LoadFromLoginReply(const ALoginReply: TPB_LoginReply);
var
  pcs: TPB_PlayerClubStatus;
  pbgame: TPB_Game;
  tables_close: TObjectList<TTable>;
  game: TGameInfo;
  table: TTable;
  found: Boolean;
  tournament: TTournamentInfo;
  club: TClubInfo;
begin
  Clear;
  MergeFrom(ALoginReply.Self);

  ProcessClubsObject(ALoginReply.Clubs);
//  ProcessPendingClubsObject(ALoginReply.PendingClubs);

  for pbgame in ALoginReply.Games do
  begin
    if FClubs.GetAndLock(pbgame.ClubMongoid, club) then
    try
      club.Games.AddGame(pbgame);
    finally
      FClubs.Unlock;
    end;

    if Tournaments.GetAndLock(pbgame.Tournament, tournament) then
    try
      tournament.AddGame(pbgame);
    finally
      Tournaments.Unlock;
    end;
  end;

  tables_close := TObjectList<TTable>.Create(FALSE);
  try
    Tables.Lock;
    try
      for table in Tables.Values do
      begin
        found := FALSE;
        if FClubs.GetAndLockByGame(table.GameId, club, game) then
        begin
          found := TRUE;
          FClubs.Unlock;
        end
        else
          if Tournaments.GetAndLockByGame(table.GameId, tournament, pbgame) then
          begin
            found := TRUE;
            Tournaments.Unlock;
          end;

        if not found then
          tables_close.Add(table)
      end;
    finally
      Tables.Unlock;
    end;

    for table in tables_close do
      Tables.Remove(table.InternalId);
  finally
    tables_close.Free;
  end;

  FTableStatuses.Clear;
  for pcs in ALoginReply.PlayerClubStatuses do
    FTableStatuses.AddOrSetValue(pcs.Tableid, TPB_PlayerClubStatus.Create(pcs, TRUE));
end;

end.
