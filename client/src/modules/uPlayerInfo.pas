unit uPlayerInfo;

interface

uses
  System.Generics.Collections, System.SysUtils,
  uClubInfo, uPB_StatusReply;

type
  TPlayerInfo = class
  private
    FId      : TBytes;
    FNick    : String;
    FEMail   : String;
    FPassword: String;
    FTokens  : Integer;
    FBalance : Integer;
    FAuthed  : Boolean;
    FAvatarId: TBytes;
    FClubs   : TClubsInfo;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Flush;

    function ParseStatus(const AStatusReply: TPB_StatusReply): Boolean;

    property Id      : TBytes read FId write FId;
    property Nick    : String read FNick write FNick;
    property Password: String read FPassword write FPassword;
    property EMail   : String read FEMail write FEMail;
    property Tokens  : Integer read FTokens write FTokens;
    property Balance : Integer read FBalance write FBalance;
    property Authed  : Boolean read FAuthed write FAuthed;
    property AvatarId: TBytes read FAvatarId write FAvatarId;
    property Clubs   : TClubsInfo read FClubs;
  end;

  TPlayerInfos = class(TObjectList<TPlayerInfo>)
  public
    function AddPlayer(const AId: TBytes; const ANick, AEMail: String; const AChips: Integer; const AAvatarId: TBytes): TPlayerInfo;
    function FindPlayerById(const AId: TBytes; var APlayerInfo: TPlayerInfo): Boolean;
    function ParseStatus(const AStatusReply: TPB_StatusReply): Boolean;
  end;

implementation

uses
  System.Classes, PNGImage, Soap.EncdDecd,
  {$IFDEF DEBUG} uDebugForm, {$ENDIF}
  uMainDataModule, uSettings, uCommon, uAvatars, uGameInfo,
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
  SetLength(FId, 0);
  FNick := '';
  FClubs.Clear;
end;

function TPlayerInfo.ParseStatus(const AStatusReply: TPB_StatusReply): Boolean;
var
  game_clubid: Int64;
  game_type  : TGameType;
  game_limit : TGameLimit;
  club       : TClubInfo;
  pbclub     : TPB_Club;
  pbgame     : TPB_Game;
  C1         : Integer;
  index      : Integer;
begin
  FId := AStatusReply.Self.MongoId;
  FEMail := AStatusReply.Self.EMail;
  FNick := AStatusReply.Self.DisplayName;
  FTokens := AStatusReply.Self.Tokens;
  FAuthed := AStatusReply.Self.Authed;
  FAvatarId := AStatusReply.Self.Avatar;
  FBalance := AStatusReply.Self.Chips;

  FClubs.Clear;
  for C1 := 0 to AStatusReply.Clubs.Count - 1 do
  begin
    pbclub := AStatusReply.Clubs[C1];
    index := FClubs.IndexOf(pbclub.Seq);
    if index = -1 then
      index := FClubs.Add(TClubInfo.Create);
    club := FClubs[index];
    club.UpdateFromProtobufObject(pbclub);
  end;

  for C1 := 0 to AStatusReply.Games.Count - 1 do
  begin
    pbgame := AStatusReply.Games[C1];

    game_clubid := pbgame.ClubSeq;
    if FClubs.FindClub(game_clubid, club) then
    begin
      game_type := TGameType(pbgame.GameType);
      game_limit := TGameLimit(pbgame.GameLimit);

      club.Games.AddGame(pbgame.MongoId, pbgame.CreatorMongoId, game_clubid, pbgame.Gamename,
                         game_type, game_limit, pbgame.SmallBlind, pbgame.BigBlind, pbgame.Seats);
    end;

  end;

  Exit(TRUE);
end;


{ TPlayerInfos }

function TPlayerInfos.AddPlayer(const AId: TBytes; const ANick, AEMail: String; const AChips: Integer; const AAvatarId: TBytes): TPlayerInfo;
var
  player: TPlayerInfo;
begin
  if not FindPlayerById(AId, player) then
    player := TPlayerInfo.Create;

  player.FId := AId;
  player.FNick := ANick;
  player.FEMail := AEMail;
  player.FBalance := AChips;
  player.AvatarId := AAvatarId;
  Add(player);
  result := player;
end;

function TPlayerInfos.FindPlayerById(const AId: TBytes; var APlayerInfo: TPlayerInfo): Boolean;
var
  player: TPlayerInfo;
  a1len : Integer;
begin
  a1len := Length(AId);
  for player in self.ToArray do
    if CompareBytes(AId, player.Id, a1len) then
    begin
      APlayerInfo := player;
      Exit(TRUE);
    end;
  Exit(FALSE);
end;

function TPlayerInfos.ParseStatus(const AStatusReply: TPB_StatusReply): Boolean;
var
  C1: Integer;
begin
  Clear;
  for C1 := 0 to AStatusReply.Users.Count - 1 do
    AddPlayer(AStatusReply.Users[C1].MongoId, AStatusReply.Users[C1].DisplayName, AStatusReply.Users[C1].EMail, AStatusReply.Users[C1].Chips, AStatusReply.Users[C1].Avatar);

  Exit(TRUE);
end;

end.
