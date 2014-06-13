unit Poker.Objects.PlayerInfo;

interface

uses
  System.Generics.Collections, System.SysUtils, Poker.Objects.ClubInfo, Poker.Protobufs.Objects.StatusReply,
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
    FClubs: TClubsInfo;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Flush;

    procedure LoadFromStatusProtobuf(const AStatusReply: TPB_StatusReply);

    property Id      : TBytes read FId write FId;
    property Nick    : String read FNick write FNick;
    property Password: String read FPassword write FPassword;
    property EMail   : String read FEMail write FEMail;
    property Balance : UINT32 read FBalance write FBalance;
    property Authed  : Boolean read FAuthed write FAuthed;
    property AvatarId: TBytes read FAvatarId write FAvatarId;
    property Clubs   : TClubsInfo read FClubs;
  end;

  TPB_Users = TList<TPB_User>;

  TPlayers = class(TObjectList<TPlayerInfo>)
  public
    class procedure Initialize;
    class procedure Deinitialize;

    function AddPlayer(const AId: TBytes; const ANick, AEMail: String; const AChips: UINT32; const AAvatarId: TBytes): TPlayerInfo; overload;
    function AddPlayer(const AUser: TPB_User): TPlayerInfo; overload;
    function FindPlayerById(const AId: TBytes; var APlayerInfo: TPlayerInfo): Boolean;
    procedure LoadFromUsersProtobuf(const AUsers: TPB_Users);
  end;

var
  Players: TPlayers;

implementation

uses
  PNGImage,
  {$IFDEF DEBUG} {$ENDIF}
  Poker.Objects.GameInfo, Poker.Table.Tables, Poker.Protobufs.Objects.Club, Poker.Protobufs.Objects.Game, Poker.Common.Misc;


constructor TPlayerInfo.Create;
begin
  FClubs := TClubsInfo.Create;
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
      if FClubs.FindClub(pbgame.ClubSeq, club) then
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

class procedure TPlayers.Initialize;
begin
  Players := TPlayers.Create;
end;

class procedure TPlayers.Deinitialize;
begin
  FreeAndNil(Players);
end;

function TPlayers.AddPlayer(const AId: TBytes; const ANick, AEMail: String; const AChips: UINT32; const AAvatarId: TBytes): TPlayerInfo;
var
  player: TPlayerInfo;
begin
  if not FindPlayerById(AId, player) then
  begin
    player := TPlayerInfo.Create;
    Add(player);
  end;

  player.FId := AId;
  player.FNick := ANick;
  player.FEMail := AEMail;
  player.FBalance := AChips;
  player.AvatarId := AAvatarId;
  result := player;
end;

function TPlayers.AddPlayer(const AUser: TPB_User): TPlayerInfo;
begin
  result := AddPlayer(AUser.MongoId, AUser.Displayname, AUser.Email, AUser.Chips, AUser.Avatar);
end;

function TPlayers.FindPlayerById(const AId: TBytes; var APlayerInfo: TPlayerInfo): Boolean;
var
  player: TPlayerInfo;
begin
  for player in self.ToArray do
    if CompareBytes(AId, player.Id) then
    begin
      APlayerInfo := player;
      Exit(TRUE);
    end;
  Exit(FALSE);
end;

procedure TPlayers.LoadFromUsersProtobuf(const AUsers: TPB_Users);
var
  user: TPB_User;
begin
  for user in AUsers do
    AddPlayer(user.MongoId, user.DisplayName, user.EMail, user.Chips, user.Avatar);
end;

end.
