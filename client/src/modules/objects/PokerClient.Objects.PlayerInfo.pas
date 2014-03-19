unit PokerClient.Objects.PlayerInfo;

interface

uses
  System.Generics.Collections, System.SysUtils,
  PokerClient.Objects.ClubInfo, PokerClient.Protobufs.Objects.StatusReply, PokerClient.Protobufs.Objects.User, PokerClient.Common.Misc;

type
  TPlayerInfo = class
  private
    FId      : TBytes;
    FNick    : String;
    FEMail   : String;
    FPassword: String;
    FBalance : Integer;
    FAuthed  : Boolean;
    FAvatarId: TBytes;
    FClubs   : TClubsInfo;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Flush;

    procedure LoadFromStatusProtobuf(const AStatusReply: TPB_StatusReply);

    property Id      : TBytes read FId write FId;
    property Nick    : String read FNick write FNick;
    property Password: String read FPassword write FPassword;
    property EMail   : String read FEMail write FEMail;
    property Balance : Integer read FBalance write FBalance;
    property Authed  : Boolean read FAuthed write FAuthed;
    property AvatarId: TBytes read FAvatarId write FAvatarId;
    property Clubs   : TClubsInfo read FClubs;
  end;

  TPlayerInfos = class(TObjectList<TPlayerInfo>)
  public
    function AddPlayer(const AId: TBytes; const ANick, AEMail: String; const AChips: Integer; const AAvatarId: TBytes): TPlayerInfo; overload;
    function AddPlayer(const AUser: TPB_User): TPlayerInfo; overload;
    function FindPlayerById(const AId: TBytes; var APlayerInfo: TPlayerInfo): Boolean;
    procedure LoadFromUsersProtobuf(const AUsers: TPB_Users);
  end;

implementation

uses
  System.Classes, PNGImage,
  {$IFDEF DEBUG} {$ENDIF}
  PokerClient.Objects.GameInfo,
  PokerClient.Protobufs.Objects.Club, PokerClient.Protobufs.Objects.Game;


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
  club  : TClubInfo;
  pbgame: TPB_Game;
  C1    : Integer;
begin
  FId := AStatusReply.Self.MongoId;
  FEMail := AStatusReply.Self.EMail;
  FNick := AStatusReply.Self.DisplayName;
  FAuthed := AStatusReply.Self.Authed;
  FAvatarId := AStatusReply.Self.Avatar;
  FBalance := AStatusReply.Self.Chips;

  FClubs.Clear;
  for C1 := 0 to AStatusReply.Clubs.Count - 1 do
    FClubs.AddClub(AStatusReply.Clubs[C1]);

  for C1 := 0 to AStatusReply.Games.Count - 1 do
  begin
    pbgame := AStatusReply.Games[C1];
    if FClubs.FindClub(pbgame.ClubSeq, club) then
      club.Games.AddGame(pbgame);
  end;
end;


{ TPlayerInfos }

function TPlayerInfos.AddPlayer(const AId: TBytes; const ANick, AEMail: String; const AChips: Integer; const AAvatarId: TBytes): TPlayerInfo;
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

function TPlayerInfos.AddPlayer(const AUser: TPB_User): TPlayerInfo;
begin
  result := AddPlayer(AUser.MongoId, AUser.Displayname, AUser.Email, AUser.Chips, AUser.Avatar);
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

procedure TPlayerInfos.LoadFromUsersProtobuf(const AUsers: TPB_Users);
var
  user: TPB_User;
begin
  for user in AUsers do
    AddPlayer(user.MongoId, user.DisplayName, user.EMail, user.Chips, user.Avatar);
end;

end.
