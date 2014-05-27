unit Poker.HandHistory.Core;

interface

uses
  System.Classes, Poker.Protobufs.Objects.ClubHandHistoryReply, Poker.HandHistory.HandHistoryItem;

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

    procedure Add(const AClubHandHistoryInfo: TPB_ClubHandHistoryReply);

    property Items: THandHistoryItems read FItems;
  end;

var
  HandHistory: THandHistory;

implementation

uses
  System.SysUtils, Poker.Protobufs.Objects.HandHistory;


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
begin
  for pbhh in AClubHandHistoryInfo.Rows do
  begin
    index := IndexOf(pbhh.Seq);
    if index = -1 then
    begin
      FItems.Add(THandHistoryItem.Create(AClubHandHistoryInfo.Clubid, AClubHandHistoryInfo.Gameid, pbhh));
    end
    else
    begin
      // ASSIGN HERE
      FItems[index].Assign(AClubHandHistoryInfo.Clubid, AClubHandHistoryInfo.Gameid, pbhh);
    end;
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

end.
