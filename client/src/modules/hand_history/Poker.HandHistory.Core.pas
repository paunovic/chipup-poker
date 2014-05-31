unit Poker.HandHistory.Core;

interface

uses
  System.Classes, System.SysUtils, Poker.Protobufs.Objects.ClubHandHistoryReply, Poker.HandHistory.HandHistoryItem;

type
  THandHistory = class
  private
    FItems: THandHistoryItems;
  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
    destructor Destroy; override;

    function IndexOf(const AHandId: UINT32): Integer;
    function Find(const AHandId: UINT32; out AHandHistoryItem: THandHistoryItem): Boolean;
    function FindLastHandForClub(const AClubId: TBytes; out AHandHistoryItem: THandHistoryItem): Boolean;

    procedure Add(const AClubHandHistoryInfo: TPB_ClubHandHistoryReply);

    property Items: THandHistoryItems read FItems;
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
  FItems := THandHistoryItems.Create;
end;

destructor THandHistory.Destroy;
begin
  FItems.Free;
  inherited;
end;

procedure THandHistory.Add(const AClubHandHistoryInfo: TPB_ClubHandHistoryReply);
var
  pbhh: TPB_HandHistory;
  index: Integer;
  handcount: Integer;
begin
  for pbhh in AClubHandHistoryInfo.Rows do
  begin
    index := IndexOf(pbhh.Seq);
    if index = -1 then
    begin
      // dont let hand count per table to go over max limit
      handcount := FItems.HandCountForTable(AClubHandHistoryInfo.Gameid);
      if handcount >= Settings.Hardcoded.HAND_HISTORY_HAND_LIMIT_PER_TABLE then
        FItems.DeleteFirstHandsForTable(AClubHandHistoryInfo.Gameid, handcount - Settings.Hardcoded.HAND_HISTORY_HAND_LIMIT_PER_TABLE + 1);

      // add new hand history item
      FItems.Add(THandHistoryItem.Create(AClubHandHistoryInfo.Clubid, AClubHandHistoryInfo.Gameid, pbhh));
    end
    else
      FItems[index].Assign(AClubHandHistoryInfo.Clubid, AClubHandHistoryInfo.Gameid, pbhh);
  end;
end;

function THandHistory.IndexOf(const AHandId: UINT32): Integer;
var
  C1: Integer;
begin
  for C1 := 0 to FItems.Count - 1 do
    if FItems[C1].HandId = AHandId then
      Exit(C1);
  Exit(-1);
end;

function THandHistory.Find(const AHandId: UINT32; out AHandHistoryItem: THandHistoryItem): Boolean;
var
  index: Integer;
begin
  index := IndexOf(AHandId);
  if index = -1 then
    Exit(FALSE);
  AHandHistoryItem := FItems[index];
  Exit(TRUE);
end;

function THandHistory.FindLastHandForClub(const AClubId: TBytes; out AHandHistoryItem: THandHistoryItem): Boolean;
var
  C1: Integer;
  maxid: UINT32;
begin
  maxid := 0;
  AHandHistoryItem := nil;
  for C1 := 0 to FItems.Count - 1 do
    if (CompareBytes(FItems[C1].Clubid, AClubId)) and
       (FItems[C1].HandId > maxid) then
    begin
      AHandHistoryItem := FItems[C1];
      maxid := FItems[C1].HandId;
    end;
  Exit(Assigned(AHandHistoryItem));
end;

end.
