unit Poker.HandHistory.Players;

interface

uses
  System.SysUtils, System.Generics.Collections, Poker.Protobufs.Objects.PlayerHandHistory,
  Poker.Protobufs.Objects.SeatInfo;

type
  TPlayerHandHistories = class(TPB_PlayerHandHistoryList)
  private
    procedure NotifyEvent(Sender: TObject; const AValue: TPB_PlayerHandHistory; AAction: TCollectionNotification);
  public
    constructor Create;
    procedure Sort;
    function FindPlayer(const ASeat: Integer; out APlayer: TPB_PlayerHandHistory): Boolean;
  end;

implementation

uses
  Poker.Cards, System.Generics.Defaults;

{ TPlayerHandHistories }

constructor TPlayerHandHistories.Create;
begin
  inherited Create(TRUE);
  OnNotify := NotifyEvent;
end;

procedure TPlayerHandHistories.NotifyEvent(Sender: TObject; const AValue: TPB_PlayerHandHistory; AAction: TCollectionNotification);
begin
  Sort;
end;

procedure TPlayerHandHistories.Sort;
var
  comparer: IComparer<TPB_PlayerHandHistory>;
begin
  comparer := TComparer<TPB_PlayerHandHistory>.Construct(
    function(const APlayerHandHistory1, APlayerHandHistory2: TPB_PlayerHandHistory): Integer
    begin
      if APlayerHandHistory1.Seat < APlayerHandHistory2.Seat then
        result := -1
      else
        if APlayerHandHistory1.Seat > APlayerHandHistory2.Seat then
          result := 1
        else
          result := 0;
    end
  );

  inherited Sort(comparer);
end;

function TPlayerHandHistories.FindPlayer(const ASeat: Integer; out APlayer: TPB_PlayerHandHistory): Boolean;
var
  phh: TPB_PlayerHandHistory;
begin
  for phh in ToArray do
    if phh.Seat = ASeat then
    begin
      APlayer := phh;
      Exit(TRUE);
    end;
  Exit(FALSE);
end;

end.
