unit Poker.Players.Player;

interface

uses
  System.Generics.Collections, System.SysUtils, Poker.Clubs.ClubList, Poker.Protobufs.Objects.StatusReply,
  Poker.Protobufs.Objects.User;

type
  TPlayerInfo = class
  private
    FId: TBytes;
    FNick: String;
    FEMail: String;
    FPassword: String;
    FBalance: UINT32;
    FAuthed: Boolean;
    FAvatarId: TBytes;
    FClubs: TClubList;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Flush;

    procedure LoadFromStatusProtobuf(const AStatusReply: TPB_StatusReply);

    property Id: TBytes read FId write FId;
    property Nick: String read FNick write FNick;
    property Password: String read FPassword write FPassword;
    property EMail: String read FEMail write FEMail;
    property Balance: UINT32 read FBalance write FBalance;
    property Authed: Boolean read FAuthed write FAuthed;
    property AvatarId: TBytes read FAvatarId write FAvatarId;
    property Clubs: TClubList read FClubs;
  end;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Poker.Tables.TableList, Poker.Protobufs.Objects.Club, Poker.Protobufs.Objects.Game, Poker.Common.Misc, Poker.Clubs.Club,
  Poker.Tables.Table, Poker.Games.Game;

{ TPlayerInfo }

constructor TPlayerInfo.Create;
begin
  FClubs := TClubList.Create;
end;

destructor TPlayerInfo.Destroy;
begin
  FClubs.Free;

  inherited;
end;

procedure TPlayerInfo.Flush;
begin
  SetLength(FId, 0);
  FNick := '';
  FEMail := '';
  FPassword := '';
  FBalance := 0;
  FAuthed := FALSE;
  SetLength(FAvatarId, 0);
  FClubs.Clear;
end;

procedure TPlayerInfo.LoadFromStatusProtobuf(const AStatusReply: TPB_StatusReply);
var
  club: TClubInfo;
  pbclub: TPB_Club;
  pbgame: TPB_Game;
  tables_ids: TList<TBytes>;
  tables_close: TObjectList<TTable>;
  game: TGameInfo;
  table: TTable;
begin
  FId := AStatusReply.Self.MongoId;
  FEMail := AStatusReply.Self.EMail;
  FNick := AStatusReply.Self.DisplayName;
  FAuthed := AStatusReply.Self.Authed;
  FAvatarId := AStatusReply.Self.Avatar;
  FBalance := AStatusReply.Self.Chips;

  tables_ids := TList<TBytes>.Create;
  try
    FClubs.Clear;
    for pbclub in AStatusReply.Clubs do
      FClubs.AddClub(pbclub);

    for pbgame in AStatusReply.Games do
      if FClubs.FindClubBySeq(pbgame.Clubseq, club) then
        club.Games.AddGame(pbgame);

    tables_close := TObjectList<TTable>.Create(FALSE);
    try
      Tables.Lock;
      try
        for table in Tables.Values do
          if not FClubs.FindGame(table.GameId, club, game) then
            tables_close.Add(table);
      finally
        Tables.Unlock;
      end;

      for table in tables_close do
        Tables.Remove(table.InternalId);
    finally
      tables_close.Free;
    end;
  finally
    tables_ids.Free;
  end;
end;

end.
