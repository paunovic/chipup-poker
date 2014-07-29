unit Poker.Tournaments;

interface

uses
  Poker.Protobufs.Objects.TournamentList, System.SyncObjs, System.Generics.Collections, Poker.Types, Poker.Tournaments.Info,
  Poker.Protobufs.Objects.TournamentInfo;

type
  TTournamentList = class(TObjectDictionary<TMongoId, TTournamentInfo>)
  private
    FLock: TCriticalSection;
  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
    destructor Destroy; override;

    function GetAndLock(const AId: TMongoId; out ATournament: TTournamentInfo): Boolean;
    function AdjustRegisteredPlayersCount(const AId: TMongoId; const AAdjustment: Integer): Boolean;

    procedure Assign(const ATournamentList: TList<TPB_TournamentInfo>); overload;
    procedure Assign(const ATournamentList: TPB_TournamentList); overload;
    procedure Add(const ATournamentInfo: TPB_TournamentInfo);
    procedure Clear;

    procedure Lock;
    procedure Unlock;
  end;

var
  Tournaments: TTournamentList;

implementation

uses
  System.SysUtils;

{ TTournamentList }

class procedure TTournamentList.Initialize;
begin
  Tournaments := TTournamentList.Create;
end;

class procedure TTournamentList.Deinitialize;
begin
  FreeAndNil(Tournaments);
end;

constructor TTournamentList.Create;
begin
  FLock := TCriticalSection.Create;
  inherited Create([doOwnsValues]);
end;

destructor TTournamentList.Destroy;
begin
  FLock.Free;
  inherited;
end;

procedure TTournamentList.Lock;
begin
  FLock.Enter;
end;

procedure TTournamentList.Unlock;
begin
  FLock.Leave;
end;

procedure TTournamentList.Clear;
begin
  FLock.Enter;
  try
    inherited Clear;
  finally
    FLock.Leave;
  end;
end;

function TTournamentList.AdjustRegisteredPlayersCount(const AId: TMongoId; const AAdjustment: Integer): Boolean;
var
  tournament: TTournamentInfo;
  reg_players: Integer;
begin
  result := FALSE;
  if GetAndLock(AId, tournament) then
  try
    reg_players := tournament.RegisteredPlayers;
    Inc(reg_players, AAdjustment);
    if reg_players < 0 then
      reg_players := 0;
    tournament.clear_RegisteredPlayers;
    tournament.RegisteredPlayers := reg_players;
    result := TRUE;
  finally
    Unlock;
  end;
end;

procedure TTournamentList.Assign(const ATournamentList: TPB_TournamentList);
begin
  Assign(ATournamentList.Items);
end;

procedure TTournamentList.Assign(const ATournamentList: TList<TPB_TournamentInfo>);
var
  pbtournament: TPB_TournamentInfo;
begin
  FLock.Enter;
  try
    Clear;
    for pbtournament in ATournamentList do
      Add(pbtournament);
  finally
    FLock.Leave;
  end;
end;

procedure TTournamentList.Add(const ATournamentInfo: TPB_TournamentInfo);
begin
  FLock.Enter;
  try
    AddOrSetValue(ATournamentInfo.MongoId, TTournamentInfo.Create(ATournamentInfo));
  finally
    FLock.Leave;
  end;
end;

function TTournamentList.GetAndLock(const AId: TMongoId; out ATournament: TTournamentInfo): Boolean;
begin
  FLock.Enter;
  if TryGetValue(AId, ATournament) then
    result := TRUE
  else
  begin
    FLock.Leave;
    result := FALSE;
  end;
end;



end.
