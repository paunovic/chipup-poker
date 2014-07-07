unit Poker.Tables.StatsList;

interface

uses
  System.Generics.Collections, System.SysUtils, Poker.Protobufs.Objects.TablePlayerStats, Poker.Protobufs.Objects.TableStatsReply,
  Poker.Tables.Stats;

type
  TTablesStatsList = class(TObjectDictionary<TBytes, TTableStats>)
  private
  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
  end;

var
  TablesStats: TTablesStatsList;

implementation

uses
  Poker.Common.Misc;

{ TTablesStatsList }

class procedure TTablesStatsList.Initialize;
begin
  TablesStats := TTablesStatsList.Create;
end;

class procedure TTablesStatsList.Deinitialize;
begin
  FreeAndNil(TablesStats);
end;

constructor TTablesStatsList.Create;
begin
  inherited Create([doOwnsValues]);
end;

end.
