unit Poker.HandHistory.Core;

interface

uses
  System.Classes, System.SysUtils, Poker.Protobufs.Objects.HandHistoryReply,
  Poker.HandHistory.Items, Poker.Types, System.Generics.Collections, Poker.Common.SafeMutex;

type
  THandHistory = class(TObjectDictionary<TMongoId, THandHistoryItems>)
  private
    FLock: TSafeMutex;
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
  FLock := TSafeMutex.Create;
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
  FLock.Acquire;
  try
    if not TryGetValue(AHandHistoryInfo.Gameid, hhis) then
    begin
      if not AHandHistoryInfo.Clubid.IsEmpty then
        parentid := AHandHistoryInfo.ClubId
      else
        parentid := AHandHistoryInfo.TournamentId;

      inherited Add(AHandHistoryInfo.Gameid, THandHistoryItems.Create(parentid, AHandHistoryInfo.Gameid));
      if not TryGetValue(AHandHistoryInfo.Gameid, hhis) then
        Exit(FALSE);
    end;

    for pbhh in AHandHistoryInfo.Rows do
      hhis.AddHand(pbhh);
    Exit(TRUE);
  finally
    FLock.Release;
  end;
end;

procedure THandHistory.Lock;
begin
  FLock.Acquire;
end;

procedure THandHistory.Unlock;
begin
  FLock.Release;
end;

end.
