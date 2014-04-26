unit Poker.Stats.Table;

interface

uses
  System.Generics.Collections, System.SysUtils, Poker.Protobufs.Objects.TablePlayerStats, Poker.Protobufs.Objects.TableStatsReply,
  Poker.Stats.Player;

type
  TTableStats = class
  private
    FClubId: TBytes;
    FGameId: TBytes;
    FHands: UINT32;
    FPlayers: TObjectList<TPlayerStats>;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(const AProtobuf: TPB_TableStatsReply);

    property ClubId: TBytes read FClubId;
    property GameId: TBytes read FGameId;
    property Hands: UINT32 read FHands;
    property Players: TObjectList<TPlayerStats> read FPlayers;
  end;

  TTablesStats = class(TObjectList<TTableStats>)
  private
  public
    class procedure Initialize;
    class procedure Deinitialize;

    function IndexOf(const ATableId: TBytes): Integer;
    function Find(const ATableId: TBytes; var ATableStats: TTableStats): Boolean;
  end;

var
  TablesStats: TTablesStats;

implementation

uses
  Poker.Common.Misc;

{ TTableStats }

constructor TTableStats.Create;
begin
  FPlayers := TObjectList<TPlayerStats>.Create
end;

destructor TTableStats.Destroy;
begin
  FPlayers.Free;
end;

procedure TTableStats.Assign(const AProtobuf: TPB_TableStatsReply);
var
  player: TPlayerStats;
  pbplayer: TPB_TablePlayerStats;
begin
  FClubId := AProtobuf.Clubid;
  FGameId := AProtobuf.Gameid;
  FHands := AProtobuf.Hands;

  FPlayers.Clear;
  for pbplayer in AProtobuf.Playerstats do
  begin
    player := TPlayerStats.Create;
    player.Assign(pbplayer);
    FPlayers.Add(player);
  end;
end;


{ TTablesStats }

class procedure TTablesStats.Initialize;
begin
  TablesStats := TTablesStats.Create;
end;

class procedure TTablesStats.Deinitialize;
begin
  FreeAndNil(TablesStats);
end;

function TTablesStats.IndexOf(const ATableId: TBytes): Integer;
var
  C1: Integer;
begin
  for C1 := 0 to Length(ToArray) - 1 do
     if CompareBytes(ToArray[C1].FGameId, ATableId) then
       Exit(C1);
  Exit(-1);
end;

function TTablesStats.Find(const ATableId: TBytes; var ATableStats: TTableStats): Boolean;
var
  index: Integer;
begin
  index := IndexOf(ATableId);
  if index = -1 then
    Exit(FALSE);
  ATableStats := ToArray[index];
  Exit(TRUE);
end;

end.
