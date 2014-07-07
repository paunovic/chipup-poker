unit Poker.Players.Stats;

interface

uses
  System.SysUtils, System.Generics.Collections,
  Poker.Protobufs.Objects.TablePlayerStats;

type
  TPlayerStats = class
  private
    FUserId: TBytes;
    FBalance: Int64;
    FBuyins: TList<UINT32>;
    FCashouts: TList<UINT32>;
    FRakeContrib: Int64;
    FSecondsPlayed: Int64;
    FChipsInPlay: Int64;

    function GetBuyinsTotal: UINT32;
    function GetCashoutsTotal: UINT32;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(const AProtobuf: TPB_TablePlayerStats); overload;
    procedure Assign(const APlayerStats: TPlayerStats); overload;
    procedure Merge(const APlayerStats: TPlayerStats);

    property UserId: TBytes read FUserId;
    property Balance: Int64 read FBalance;
    property Buyins: TList<UINT32> read FBuyins;
    property Cashouts: TList<UINT32> read FCashouts;
    property RakeContrib: Int64 read FRakeContrib;
    property SecondsPlayed: Int64 read FSecondsPlayed;
    property CashoutsTotal: UINT32 read GetCashoutsTotal;
    property BuyinsTotal: UINT32 read GetBuyinsTotal;
    property ChipsInPlay: Int64 read FChipsInPlay;
  end;

implementation

uses
  Poker.Common.Misc;

{ TPlayerStats }

constructor TPlayerStats.Create;
begin
  FBuyins := TList<UINT32>.Create;
  FCashouts := TList<UINT32>.Create;
end;

destructor TPlayerStats.Destroy;
begin
  FCashouts.Free;
  FBuyins.Free;
  inherited;
end;

function TPlayerStats.GetBuyinsTotal: UINT32;
var
  val: UINT32;
begin
  result := 0;
  for val in FBuyins do
    Inc(result, val);
end;

function TPlayerStats.GetCashoutsTotal: UINT32;
var
  val: UINT32;
begin
  result := 0;
  for val in FCashouts do
    Inc(result, val);
end;

procedure TPlayerStats.Merge(const APlayerStats: TPlayerStats);
begin
  Inc(FBalance, APlayerStats.Balance);
  FBuyins.AddRange(APlayerStats.Buyins);
  FCashouts.AddRange(APlayerStats.Cashouts);
  Inc(FRakeContrib, APlayerStats.RakeContrib);
  Inc(FSecondsPlayed, APlayerStats.SecondsPlayed);
  Inc(FChipsInPlay, APlayerStats.ChipsInPlay);
end;

procedure TPlayerStats.Assign(const AProtobuf: TPB_TablePlayerStats);
begin
  FUserId := AProtobuf.Userid;
  FBalance := AProtobuf.Balance;
  FBuyins.Clear;
  FBuyins.AddRange(AProtobuf.Buyins);
  FCashouts.Clear;
  FCashouts.AddRange(AProtobuf.Cashouts);
  FRakeContrib := AProtobuf.Rakecontrib;
  FSecondsPlayed := AProtobuf.Secondsplayed;
  FChipsInPlay := AProtobuf.Chipsinplay;
end;

procedure TPlayerStats.Assign(const APlayerStats: TPlayerStats);
begin
  FUserId := APlayerStats.Userid;
  FBalance := APlayerStats.Balance;
  FBuyins.Clear;
  FBuyins.AddRange(APlayerStats.Buyins);
  FCashouts.Clear;
  FCashouts.AddRange(APlayerStats.Cashouts);
  FRakeContrib := APlayerStats.Rakecontrib;
  FSecondsPlayed := APlayerStats.Secondsplayed;
  FChipsInPlay := APlayerStats.Chipsinplay;
end;



end.
