unit Poker.Objects.Players.Player;

interface

uses
  System.Generics.Collections, System.SysUtils, Poker.Objects.Clubs.ClubList, Poker.Protobufs.Objects.StatusReply,
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
  Poker.Table.Tables, Poker.Protobufs.Objects.Club, Poker.Protobufs.Objects.Game, Poker.Common.Misc, Poker.Objects.Clubs.Club;

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
  FClubs.Clear;
end;

procedure TPlayerInfo.LoadFromStatusProtobuf(const AStatusReply: TPB_StatusReply);
var
  club: TClubInfo;
  pbgame: TPB_Game;
  C1: Integer;
  tables_ids: TList<TBytes>;
  tables_close: TObjectList<TTable>;
begin
  FId := AStatusReply.Self.MongoId;
  FEMail := AStatusReply.Self.EMail;
  FNick := AStatusReply.Self.DisplayName;
  FAuthed := AStatusReply.Self.Authed;
  FAvatarId := AStatusReply.Self.Avatar;
  FBalance := AStatusReply.Self.Chips;

  tables_ids := TList<TBytes>.Create;
  try
    for C1 := 0 to Tables.Count - 1 do
      tables_ids.Add(Tables.Items[C1].Game.MongoId);

    FClubs.Clear;
    for C1 := 0 to AStatusReply.Clubs.Count - 1 do
      FClubs.AddClub(AStatusReply.Clubs[C1]);

    for pbgame in AStatusReply.Games do
      if FClubs.FindClubBySeq(pbgame.ClubSeq, club) then
        club.Games.AddGame(pbgame);

    tables_close := TObjectList<TTable>.Create(FALSE);
    try
      for C1 := 0 to tables_ids.Count - 1 do
        if not Tables.Items[C1].ReassignObjects(tables_ids[C1]) then
          tables_close.Add(Tables.Items[C1]);

      for C1 := 0 to tables_close.Count - 1 do
        Tables.Remove(tables_close[C1]);
    finally
      tables_close.Free;
    end;
  finally
    tables_ids.Free;
  end;
end;


{ TPlayerInfos }



end.
