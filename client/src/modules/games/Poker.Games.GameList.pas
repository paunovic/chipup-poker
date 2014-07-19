unit Poker.Games.GameList;

interface

uses
  Winapi.Windows, System.SysUtils, System.Generics.Collections, Poker.Games.Game, Poker.Protobufs.Objects.Game, System.SyncObjs, Poker.Types;

type
  TGameList = class(TObjectDictionary<TMongoId, TGameInfo>)
  private
    FLock: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(const AGameList: TList<TPB_Game>);
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
  FreeAndNil(FLock);
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

procedure TGameList.Assign(const AGameList: TList<TPB_Game>);
var
  gameinfo: TGameInfo;
  gamepb: TPB_Game;
  found: Boolean;
  to_remove: TList<TMongoId>;
  mongoid: TMongoId;
begin
  FLock.Enter;
  try
    if not Assigned(AGameList) then
    begin
      Clear;
      Exit;
    end;

    to_remove := TList<TMongoId>.Create;
    try
      for gameinfo in Values do
      begin
        found := FALSE;
        for gamepb in AGameList do
          if CompareMongoId(gamepb.MongoId, gameinfo.MongoId) then
          begin
            found := TRUE;
            Break;
          end;
        if not found then
          to_remove.Add(gameinfo.MongoId);
      end;
      for mongoid in to_remove do
        Remove(mongoid);
      for gamepb in AGameList do
        AddGame(gamepb);
    finally
      to_remove.Free;
    end;
  finally
    FLock.Leave;
  end;
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
