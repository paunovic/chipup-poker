unit Poker.HandHistory.Core;

interface

uses
  System.Classes, System.SysUtils, Poker.Protobufs.Objects.HandHistoryReply, Poker.HandHistory.Items, Poker.Types,
  System.Generics.Collections, System.SyncObjs;

type
  THandHistory = class(TObjectDictionary<TMongoId, THandHistoryItems>)
  private
    FLock: TCriticalSection;
  public
    class procedure Initialize;
    class procedure Deinitialize;

    procedure Lock;
    procedure Unlock;

    constructor Create;
    destructor Destroy; override;

    function Add(const AHandHistoryInfo: TPB_HandHistoryReply): Boolean;
  end;

var
  HandHistory: THandHistory;

implementation

uses
  Poker.Protobufs.Objects.HandHistory, Poker.Common.Misc;


class procedure THandHistory.Initialize;
begin
  HandHistory := THandHistory.Create;
end;


class procedure THandHistory.Deinitialize;
begin
  FreeAndNil(HandHistory);
end;


constructor THandHistory.Create;
begin
  FLock := TCriticalSection.Create;
  inherited Create([doOwnsValues]);
end;

destructor THandHistory.Destroy;
begin
  inherited;
  FreeAndNil(FLock);
end;

function THandHistory.Add(const AHandHistoryInfo: TPB_HandHistoryReply): Boolean;
var
  pbhh: TPB_HandHistory;
  hhis: THandHistoryItems;
  parentid: TMongoId;
begin
  FLock.Enter;
  try
    if not TryGetValue(AHandHistoryInfo.Gameid, hhis) then
    begin
      if AHandHistoryInfo.Clubid.IsEmpty then
        parentid := AHandHistoryInfo.TournamentId
      else
        parentid := AHandHistoryInfo.ClubId;

      inherited Add(AHandHistoryInfo.Gameid, THandHistoryItems.Create(parentid, AHandHistoryInfo.Gameid));
      if not TryGetValue(AHandHistoryInfo.Gameid, hhis) then
        Exit(FALSE);
    end;

    for pbhh in AHandHistoryInfo.Rows do
      hhis.AddHand(pbhh);
    Exit(TRUE);
  finally
    FLock.Leave;
  end;
end;

procedure THandHistory.Lock;
begin
  FLock.Enter;
end;

procedure THandHistory.Unlock;
begin
  FLock.Leave;
end;

end.
