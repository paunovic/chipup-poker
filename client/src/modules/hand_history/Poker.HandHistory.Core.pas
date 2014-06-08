unit Poker.HandHistory.Core;

interface

uses
  System.Classes, System.SysUtils, Poker.Protobufs.Objects.ClubHandHistoryReply, Poker.HandHistory.Items,
  System.Generics.Collections, System.SyncObjs;

type
  THandHistory = class
  private
    FItems: TObjectList<THandHistoryItems>;
    FLock: TCriticalSection;
  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
    destructor Destroy; override;

    function FindGame(const AGameId: TBytes; out AHandHistoryItems: THandHistoryItems): Boolean;

    function Add(const AClubHandHistoryInfo: TPB_ClubHandHistoryReply): Boolean;

    property Items: TObjectList<THandHistoryItems> read FItems;
  end;

var
  HandHistory: THandHistory;

implementation

uses
  Poker.Protobufs.Objects.HandHistory, Poker.Common.Misc, Poker.Settings;


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
  FItems := TObjectList<THandHistoryItems>.Create;
end;

destructor THandHistory.Destroy;
begin
  FItems.Free;
  FLock.Free;
  inherited;
end;

function THandHistory.Add(const AClubHandHistoryInfo: TPB_ClubHandHistoryReply): Boolean;
var
  pbhh: TPB_HandHistory;
  hhis: THandHistoryItems;
  hhi: THandHistoryItem;
begin
  if not FindGame(AClubHandHistoryInfo.Gameid, hhis) then
  begin
    FLock.Enter;
    try
      FItems.Add(THandHistoryItems.Create(AClubHandHistoryInfo.Clubid, AClubHandHistoryInfo.Gameid));
    finally
      FLock.Leave;
    end;

    if not FindGame(AClubHandHistoryInfo.Gameid, hhis) then
      Exit(FALSE);
  end;

  for pbhh in AClubHandHistoryInfo.Rows do
    if not hhis.FindHand(pbhh.Seq, hhi) then
      hhis.AddHand(pbhh)
    else
      hhi.Assign(pbhh);
  Exit(TRUE);
end;

function THandHistory.FindGame(const AGameId: TBytes; out AHandHistoryItems: THandHistoryItems): Boolean;
var
  C1: Integer;
begin
  FLock.Enter;
  try
    for C1 := 0 to FItems.Count - 1 do
      if CompareBytes(FItems[C1].FGameId, AGameId) then
      begin
        AHandHistoryItems := FItems[C1];
        Exit(TRUE);
      end;
    Exit(FALSE);
  finally
    FLock.Leave;
  end;
end;

end.
