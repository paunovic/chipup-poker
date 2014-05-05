unit Poker.Stats.Player;

interface

uses
  System.SysUtils,
  Poker.Protobufs.Objects.TablePlayerStats;

type
  TPlayerStats = class
  private
    FUserId: TBytes;
    FBalance: UINT32;
    FBuyins: TArray<UINT32>;
    FCashouts: TArray<UINT32>;
    FRakeContrib: UINT32;
    FSecondsPlayed: UINT32;
    FChipsInPlay: UINT32;

    function GetBuyinsTotal: UINT32;
    function GetCashoutsTotal: UINT32;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(const AProtobuf: TPB_TablePlayerStats); overload;
    procedure Assign(const APlayerStats: TPlayerStats); overload;
    procedure Merge(const APlayerStats: TPlayerStats);

    property UserId: TBytes read FUserId;
    property Balance: UINT32 read FBalance;
    property Buyins: TArray<UINT32> read FBuyins;
    property Cashouts: TArray<UINT32> read FCashouts;
    property RakeContrib: UINT32 read FRakeContrib;
    property SecondsPlayed: UINT32 read FSecondsPlayed;
    property CashoutsTotal: UINT32 read GetCashoutsTotal;
    property BuyinsTotal: UINT32 read GetBuyinsTotal;
    property ChipsInPlay: UINT32 read FChipsInPlay;
  end;

implementation

uses
  Poker.Common.Misc;

{ TPlayerStats }

constructor TPlayerStats.Create;
begin

end;

destructor TPlayerStats.Destroy;
begin

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
  AppendArray(FBuyins, APlayerStats.Buyins);
  AppendArray(FCashouts, APlayerStats.Cashouts);
  Inc(FRakeContrib, APlayerStats.RakeContrib);
  Inc(FSecondsPlayed, APlayerStats.SecondsPlayed);
  Inc(FChipsInPlay, APlayerStats.ChipsInPlay);
end;

procedure TPlayerStats.Assign(const AProtobuf: TPB_TablePlayerStats);
begin
  FUserId := AProtobuf.Userid;
  FBalance := AProtobuf.Balance;
  FBuyins := AProtobuf.Buyins;
  FCashouts := AProtobuf.Cashouts;
  FRakeContrib := AProtobuf.Rakecontrib;
  FSecondsPlayed := AProtobuf.Secondsplayed;
  FChipsInPlay := AProtobuf.Chipsinplay;
end;

procedure TPlayerStats.Assign(const APlayerStats: TPlayerStats);
begin
  FUserId := APlayerStats.Userid;
  FBalance := APlayerStats.Balance;
  FBuyins := APlayerStats.Buyins;
  FCashouts := APlayerStats.Cashouts;
  FRakeContrib := APlayerStats.Rakecontrib;
  FSecondsPlayed := APlayerStats.Secondsplayed;
  FChipsInPlay := APlayerStats.Chipsinplay;
end;



end.
