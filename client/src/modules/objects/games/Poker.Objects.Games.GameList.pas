unit Poker.Objects.Games.GameList;

interface

uses
  Winapi.Windows, System.SysUtils, System.Generics.Collections, Poker.Objects.Games.Game, Poker.Protobufs.Objects.Game;

type
  TGamesInfo = class(TObjectDictionary<TBytes, TGameInfo>)
  public
    constructor Create;

    procedure UpdateFromProtobufObjects(const AProtobufObjects: TList<TPB_Game>);

    function AddGame(const AProtobufObject: TPB_Game): TGameInfo;
  end;

implementation

uses
  Poker.Common.Misc;

{ TGamesInfo }


constructor TGamesInfo.Create;
begin
  inherited Create([doOwnsValues]);
end;

function TGamesInfo.AddGame(const AProtobufObject: TPB_Game): TGameInfo;
var
  game: TGameInfo;
begin
  if not TryGetValue(AProtobufObject.MongoId, game) then
  begin
    game := TGameInfo.Create;
    game.Assign(AProtobufObject);
    Add(game.MongoId, game);
  end
  else
    game.Assign(AProtobufObject);

  result := game;
end;

procedure TGamesInfo.UpdateFromProtobufObjects(const AProtobufObjects: TList<TPB_Game>);
var
  game: TPB_Game;
begin
  Clear;
  for game in AProtobufObjects do
    AddGame(game);
end;

end.
