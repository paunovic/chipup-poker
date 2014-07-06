unit Poker.Objects.Games.GameList;

interface

uses
  Winapi.Windows, System.SysUtils, System.Generics.Collections, Poker.Objects.Games.Game, Poker.Protobufs.Objects.Game;

type
  TGameList = class(TObjectDictionary<TBytes, TGameInfo>)
  public
    constructor Create;
    procedure UpdateFromProtobufObjects(const AProtobufObjects: TList<TPB_Game>);
    function AddGame(const AProtobufObject: TPB_Game): TGameInfo;
  end;

implementation

uses
  Poker.Common.Misc;

{ TGameList }

constructor TGameList.Create;
begin
  inherited Create([doOwnsValues]);
end;

function TGameList.AddGame(const AProtobufObject: TPB_Game): TGameInfo;
var
  game: TGameInfo;
begin
  if TryGetValue(AProtobufObject.MongoId, game) then
    game.Assign(AProtobufObject)
  else
  begin
    game := TGameInfo.Create;
    game.Assign(AProtobufObject);
    Add(game.MongoId, game);
  end;

  result := game;
end;

procedure TGameList.UpdateFromProtobufObjects(const AProtobufObjects: TList<TPB_Game>);
var
  game: TPB_Game;
begin
  Clear;
  for game in AProtobufObjects do
    AddGame(game);
end;

end.
