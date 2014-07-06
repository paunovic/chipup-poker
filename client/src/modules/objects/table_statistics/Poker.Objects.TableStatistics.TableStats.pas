unit Poker.Objects.TableStatistics.TableStats;

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

end.
