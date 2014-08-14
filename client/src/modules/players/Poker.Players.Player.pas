unit Poker.Players.Player;

interface

uses
  System.Generics.Collections, System.SysUtils, Poker.Clubs.ClubList, Poker.Protobufs.Objects.LoginReply, Poker.Types,
  Poker.Protobufs.Objects.User;

type
  TPlayerInfo = class(TPB_User)
  private
    FPassword: String;
    FClubs: TClubList;
    FRegisteredTournaments: TList<TMongoId>;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Flush;

    procedure LoadFromLoginReply(const ALoginReply: TPB_LoginReply);

    property Password: String read FPassword write FPassword;
    property Clubs: TClubList read FClubs;
    property RegisteredTournaments: TList<TMongoId> read FRegisteredTournaments;
  end;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Poker.Tables.TableList, Poker.Protobufs.Objects.Club, Poker.Protobufs.Objects.Game, Poker.Common.Misc, Poker.Clubs.Club,
  Poker.Tables.Table, Poker.Games.Game, Poker.Tournaments, Poker.Tournaments.Info;

{ TPlayerInfo }

constructor TPlayerInfo.Create;
begin
  inherited Create(TRUE);

  FClubs := TClubList.Create;
  FRegisteredTournaments := TList<TMongoId>.Create;
end;

destructor TPlayerInfo.Destroy;
begin
  FRegisteredTournaments.Free;
  FClubs.Free;

  inherited;
end;

procedure TPlayerInfo.Flush;
begin
  Clear;
  FClubs.Clear;
  FPassword := '';
  FRegisteredTournaments.Clear;
end;

procedure TPlayerInfo.LoadFromLoginReply(const ALoginReply: TPB_LoginReply);
var
  club: TClubInfo;
  pbclub: TPB_Club;
  pbgame: TPB_Game;
  tables_close: TObjectList<TTable>;
  game: TGameInfo;
  table: TTable;
  found: Boolean;
  to_remove: TList<TMongoId>;
  mongoid: TMongoId;
  tournament: TTournamentInfo;
begin
  Clear;
  MergeFrom(ALoginReply.Self);

  to_remove := TList<TMongoId>.Create;
  try
    FClubs.Lock;
    try
      for club in FClubs.Values do
      begin
        found := FALSE;
        for pbclub in AloginReply.Clubs do
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

    for pbclub in AloginReply.Clubs do
    begin
      FClubs.Lock;
      try
        if not FClubs.ContainsKey(pbclub.MongoId) then
          FClubs.AddClub(pbclub);
      finally
        FClubs.Unlock;
      end;
    end;

    for pbgame in AloginReply.Games do
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
          if not FClubs.GetAndLockByGame(table.GameId, club, game) then
            tables_close.Add(table)
          else
            FClubs.Unlock;
      finally
        Tables.Unlock;
      end;

      for table in tables_close do
        Tables.Remove(table.InternalId);
    finally
      tables_close.Free;
    end;
  finally
    to_remove.Free;
  end;
end;

end.
