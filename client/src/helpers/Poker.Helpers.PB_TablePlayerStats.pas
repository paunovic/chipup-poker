unit Poker.Helpers.PB_TablePlayerStats;

interface

uses
  Poker.Protobufs.Objects.TablePlayerStats;

type
  TTablePlayerStatsHelper = class helper for TPB_TablePlayerStats
    function GetBuyinsTotal: UINT32;
    function GetCashoutsTotal: UINT32;
    procedure Merge(const APlayerStats: TPB_TablePlayerStats);
  end;

implementation


function TTablePlayerStatsHelper.GetBuyinsTotal: UINT32;
var
  val: UINT32;
begin
  result := 0;
  for val in self.Buyins do
    Inc(result, val);
end;

function TTablePlayerStatsHelper.GetCashoutsTotal: UINT32;
var
  val: UINT32;
begin
  result := 0;
  for val in self.Cashouts do
    Inc(result, val);
end;

procedure TTablePlayerStatsHelper.Merge(const APlayerStats: TPB_TablePlayerStats);
var
  tmppb: TPB_TablePlayerStats;
begin
  tmppb := TPB_TablePlayerStats.Create(self);
  try
    self.Clear;
    self.Balance := tmppb.Balance + APlayerStats.Balance;
    self.Buyins.AddRange(tmppb.Buyins);
    self.Buyins.AddRange(APlayerStats.Buyins);
    self.Cashouts.AddRange(tmppb.Cashouts);
    self.Cashouts.AddRange(APlayerStats.Cashouts);
    self.Rakecontrib := tmppb.Rakecontrib + APlayerStats.Rakecontrib;
    self.Secondsplayed := tmppb.Secondsplayed + APlayerStats.Secondsplayed;
    self.Chipsinplay := APlayerStats.Chipsinplay;
  finally
    tmppb.Free;
  end;
end;

end.
