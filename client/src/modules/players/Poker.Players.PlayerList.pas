unit Poker.Players.PlayerList;

interface

uses
  System.Generics.Collections, System.SysUtils, Poker.Protobufs.Objects.User, Poker.Players.Player, Poker.Types;

type
  TPlayerList = class(TObjectDictionary<TMongoId, TPlayerInfo>)
  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;

    function AddPlayer(const AId: TMongoId; const ANick, AEMail: String; const AAvatarId: TBytes): TPlayerInfo; overload;
    function AddPlayer(const AUser: TPB_User): TPlayerInfo; overload;
    procedure LoadFromUsersProtobuf(const AUsers: TList<TPB_User>);
  end;

var
  Players: TPlayerList;


implementation

uses
  Poker.Common.Misc;

{ TPlayerList }

class procedure TPlayerList.Initialize;
begin
  Players := TPlayerList.Create;
end;

class procedure TPlayerList.Deinitialize;
begin
  FreeAndNil(Players);
end;

constructor TPlayerList.Create;
begin
  inherited Create([doOwnsValues]);
end;

function TPlayerList.AddPlayer(const AId: TMongoId; const ANick, AEMail: String; const AAvatarId: TBytes): TPlayerInfo;
var
  player: TPlayerInfo;
begin
  if not TryGetValue(AId, player) then
  begin
    player := TPlayerInfo.Create;
    Add(AId, player);
  end;

  player.MongoId := AId;
  player.Nick := ANick;
  player.EMail := AEMail;
  player.AvatarId := AAvatarId;
  result := player;
end;

function TPlayerList.AddPlayer(const AUser: TPB_User): TPlayerInfo;
begin
  result := AddPlayer(AUser.MongoId, AUser.Displayname, AUser.Email, AUser.Avatar);
end;

procedure TPlayerList.LoadFromUsersProtobuf(const AUsers: TList<TPB_User>);
var
  user: TPB_User;
begin
  for user in AUsers do
    AddPlayer(user.MongoId, user.DisplayName, user.EMail, user.Avatar);
end;

end.
