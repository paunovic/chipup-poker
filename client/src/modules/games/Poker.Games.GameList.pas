unit Poker.Games.GameList;

interface

uses
  Winapi.Windows, System.SysUtils, System.Generics.Collections, Poker.Games.Game, Poker.Protobufs.Objects.Game, System.SyncObjs;

type
  TGameList = class(TObjectDictionary<TBytes, TGameInfo>)
  private
    FLock: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure UpdateFromProtobufObjects(const AProtobufObjects: TList<TPB_Game>);
    function AddGame(const AProtobufObject: TPB_Game): TGameInfo;

    procedure Lock;
    procedure Unlock;
  end;

implementation

uses
  Poker.Common.Misc;

{ TGameList }

constructor TGameList.Create;
begin
  FLock := TCriticalSection.Create;
  inherited Create([doOwnsValues]);
end;

destructor TGameList.Destroy;
begin
  inherited;
  FLock.Free;
end;

function TGameList.AddGame(const AProtobufObject: TPB_Game): TGameInfo;
var
  game: TGameInfo;
begin
  FLock.Enter;
  try
    if TryGetValue(AProtobufObject.MongoId, game) then
      game.Assign(AProtobufObject)
    else
    begin
      game := TGameInfo.Create;
      game.Assign(AProtobufObject);
      Add(game.MongoId, game);
    end;

    result := game;
  finally
    FLock.Leave;
  end;
end;

procedure TGameList.UpdateFromProtobufObjects(const AProtobufObjects: TList<TPB_Game>);
var
  game: TPB_Game;
begin
  FLock.Enter;
  try
    Clear;
  finally
    FLock.Leave;
  end;

  for game in AProtobufObjects do
    AddGame(game);
end;

procedure TGameList.Lock;
begin
  FLock.Enter;
end;

procedure TGameList.Unlock;
begin
  FLock.Leave;
end;


end.
