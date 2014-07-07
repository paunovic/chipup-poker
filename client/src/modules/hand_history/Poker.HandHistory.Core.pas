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
  FreeAndNil(FLock);
  inherited;
end;

function THandHistory.Add(const AClubHandHistoryInfo: TPB_ClubHandHistoryReply): Boolean;
var
  pbhh: TPB_HandHistory;
  hhis: THandHistoryItems;
  hhi: THandHistoryItem;
begin
  if not TryGetValue(AClubHandHistoryInfo.Gameid, hhis) then
  begin
    FLock.Enter;
    try
      inherited Add(AClubHandHistoryInfo.Gameid, THandHistoryItems.Create(AClubHandHistoryInfo.Clubid, AClubHandHistoryInfo.Gameid));
    finally
      FLock.Leave;
    end;

    if not TryGetValue(AClubHandHistoryInfo.Gameid, hhis) then
      Exit(FALSE);
  end;

  for pbhh in AClubHandHistoryInfo.Rows do
    if not hhis.FindHand(pbhh.Seq, hhi) then
      hhis.AddHand(pbhh)
    else
      hhi.Assign(pbhh);
  Exit(TRUE);
end;

end.
