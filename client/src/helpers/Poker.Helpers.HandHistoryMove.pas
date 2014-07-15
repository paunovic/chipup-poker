unit Poker.Helpers.HandHistoryMove;

interface

uses
  Poker.Protobufs.Objects.HandHistoryMove, Poker.Protobufs.Objects.TableEvent;

type
  TPB_HandHistoryMoveHelper = class helper for TPB_HandHistoryMove
    function ContainsEvent(const AEvent: TTableEventType): Boolean;
  end;


implementation

function TPB_HandHistoryMoveHelper.ContainsEvent(const AEvent: TTableEventType): Boolean;
var
  event: TTableEventType;
begin
  for event in self.Code do
    if event = AEvent then
      Exit(TRUE);
  Exit(FALSE);
end;


end.
