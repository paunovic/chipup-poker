unit Poker.HandHistory.Core;

interface

uses
  System.Classes, System.SysUtils, Poker.Protobufs.Objects.ClubHandHistoryReply, Poker.HandHistory.Items,
  System.Generics.Collections, System.SyncObjs;

type
  THandHistory = class(TObjectDictionary<TBytes, THandHistoryItems>)
  private
    FLock: TCriticalSection;
  public
    class procedure Initialize;
    class procedure Deinitialize;

    procedure Lock;
    procedure Unlock;

    constructor Create;
    destructor Destroy; override;

    function Add(const AClubHandHistoryInfo: TPB_ClubHandHistoryReply): Boolean;
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

function THandHistory.Add(const AClubHandHistoryInfo: TPB_ClubHandHistoryReply): Boolean;
var
  pbhh: TPB_HandHistory;
  hhis: THandHistoryItems;
  hhi: THandHistoryItem;
begin
  FLock.Enter;
  try
    if not TryGetValue(AClubHandHistoryInfo.Gameid, hhis) then
    begin
      inherited Add(AClubHandHistoryInfo.Gameid, THandHistoryItems.Create(AClubHandHistoryInfo.Clubid, AClubHandHistoryInfo.Gameid));
      if not TryGetValue(AClubHandHistoryInfo.Gameid, hhis) then
        Exit(FALSE);
    end;

    for pbhh in AClubHandHistoryInfo.Rows do
      if not hhis.GetAndLockHand(pbhh.Seq, hhi) then
        hhis.AddHand(pbhh)
      else
      begin
        hhi.Assign(pbhh);
        hhis.Unlock;
      end;

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
