unit uPlayerInfo;

interface

uses
  System.Generics.Collections,
  uClubInfo, uPB_StatusReply;

type
  TPlayerInfo = class
  private
    FId      : String;
    FNick    : String;
    FEMail   : String;
    FPassword: String;
    FTokens  : Integer;
    FBalance : Integer;
    FAuthed  : Boolean;
    FAvatarId: String;
    FClubs   : TClubsInfo;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Flush;

    function ParseStatus(const AStatusReply: TPB_StatusReply): Boolean;

    property Id      : String read FId write FId;
    property Nick    : String read FNick write FNick;
    property Password: String read FPassword write FPassword;
    property EMail   : String read FEMail write FEMail;
    property Tokens  : Integer read FTokens write FTokens;
    property Balance : Integer read FBalance write FBalance;
    property Authed  : Boolean read FAuthed write FAuthed;
    property AvatarId: String read FAvatarId write FAvatarId;
    property Clubs   : TClubsInfo read FClubs;
  end;

  TPlayerInfos = class(TObjectList<TPlayerInfo>)
  public
    function AddPlayer(const AId, ANick, AEMail: String; const AChips: Integer): TPlayerInfo;
    function FindPlayerById(const AId: String; var APlayerInfo: TPlayerInfo): Boolean;
    function ParseStatus(const AStatusReply: TPB_StatusReply): Boolean;
  end;

implementation

uses
  System.SysUtils, System.Classes, PNGImage,
  {$IFDEF DEBUG} uDebugForm, {$ENDIF}
  uMainDataModule, uSettings, uCommon, uAvatar, uGameInfo,
  uPB_Club, uPB_Game;


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
  FId := '';
  FNick := '';
  FClubs.Clear;
end;

function TPlayerInfo.ParseStatus(const AStatusReply: TPB_StatusReply): Boolean;
var
  club_name   : String;
  club_balance: Integer;
  club_mongoid: String;
  club_id     : Int64;
  club_ownerid: String;
  club_invcode: String;
  club_private: Boolean;
  game_clubid : Int64;
  game_type   : TGameType;
  game_limit  : TGameLimit;
  club        : TClubInfo;
  pbclub      : TPB_Club;
  pbgame      : TPB_Game;
  C1, C2      : Integer;
begin
  FId := String(AStatusReply.Self.MongoId);
  FEMail := String(AStatusReply.Self.EMail);
  FNick := String(AStatusReply.Self.DisplayName);
  FTokens := AStatusReply.Self.Tokens;
  FAuthed := AStatusReply.Self.Authed;
  FAvatarId := String(AStatusReply.Self.AvatarMongoId);
  FBalance := AStatusReply.Self.Chips;

  FClubs.Clear;
  for C1 := 0 to AStatusReply.Clubs.Count - 1 do
  begin
    pbclub := AStatusReply.Clubs[C1];

    club_mongoid := String(pbclub.MongoId);
    club_id := pbclub.Seq;
    club_name := String(pbclub.Name);
    club_balance := pbclub.Chips;
    club_ownerid := String(pbclub.OwnerMongoId);
    club_private := pbclub.Private;
    club_invcode := String(pbclub.Password);
    club := FClubs.AddClub(club_mongoid, club_ownerid, club_id, club_name, club_balance, club_private, club_invcode);
    club.Players.Add(club_ownerid);
    for C2 := 0 to pbclub.Members.Count - 1 do
      club.Players.Add(pbclub.Members[C2]);
  end;

  for C1 := 0 to AStatusReply.Games.Count - 1 do
  begin
    pbgame := AStatusReply.Games[C1];

    game_clubid := pbgame.ClubSeq;
    if FClubs.FindClub(game_clubid, club) then
    begin
      game_type := TGameType(pbgame.GameType);
      game_limit := TGameLimit(pbgame.GameLimit);

      club.Games.AddGame(String(pbgame.MongoId), String(pbgame.CreatorMongoId), game_clubid, String(pbgame.Name),
                         game_type, game_limit, pbgame.SmallBlind, pbgame.BigBlind, pbgame.Seats);
    end;

  end;

  Exit(TRUE);
end;


{ TPlayerInfos }

function TPlayerInfos.AddPlayer(const AId, ANick, AEMail: String; const AChips: Integer): TPlayerInfo;
var
  player: TPlayerInfo;
begin
  if not FindPlayerById(AId, player) then
    player := TPlayerInfo.Create;

  player.FId := AId;
  player.FNick := ANick;
  player.FEMail := AEMail;
  player.FBalance := AChips;
  Add(player);
  result := player;
end;

function TPlayerInfos.FindPlayerById(const AId: String; var APlayerInfo: TPlayerInfo): Boolean;
var
  player: TPlayerInfo;
begin
  for player in self.ToArray do
    if LowerCase(player.Id) = LowerCase(AId) then
    begin
      APlayerInfo := player;
      Exit(TRUE);
    end;
  Exit(FALSE);
end;

function TPlayerInfos.ParseStatus(const AStatusReply: TPB_StatusReply): Boolean;
var
  playerid: String;
  email   : String;
  nick    : String;
  chips   : Integer;
  C1      : Integer;
begin
  Clear;
  for C1 := 0 to AStatusReply.Users.Count - 1 do
  begin
    playerid := String(AStatusReply.Users[C1].MongoId);
    email := String(AStatusReply.Users[C1].EMail);
    nick := String(AStatusReply.Users[C1].DisplayName);
    chips := AStatusReply.Users[C1].Chips;
    AddPlayer(playerid, nick, email, chips);
  end;

  Exit(TRUE);
end;

end.
