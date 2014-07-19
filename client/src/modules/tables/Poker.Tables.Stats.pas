unit Poker.Tables.Stats;

interface

uses
  System.Generics.Collections, System.SysUtils, Poker.Protobufs.Objects.TablePlayerStats, Poker.Protobufs.Objects.TableStatsReply,
  Poker.Types;

type
  TTableStats = class
  private
    FClubId: TMongoId;
    FGameId: TMongoId;
    FHands: UINT32;
    FPlayers: TPB_TablePlayerStatsList;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(const AProtobuf: TPB_TableStatsReply);

    property ClubId: TMongoId read FClubId;
    property GameId: TMongoId read FGameId;
    property Hands: UINT32 read FHands;
    property Players: TPB_TablePlayerStatsList read FPlayers;
  end;

implementation

uses
  Poker.Common.Misc;

{ TTableStats }

constructor TTableStats.Create;
begin
  FPlayers := TPB_TablePlayerStatsList.Create
end;

destructor TTableStats.Destroy;
begin
  FPlayers.Free;
end;

procedure TTableStats.Assign(const AProtobuf: TPB_TableStatsReply);
begin
  FClubId := AProtobuf.Clubid;
  FGameId := AProtobuf.Gameid;
  FHands := AProtobuf.Hands;
  FPlayers.Assign(AProtobuf.Playerstats);
end;

end.
