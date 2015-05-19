unit Poker.Helpers.HandHistoryMove;

interface

uses
  Poker.Protobufs.Objects.HandHistoryMove, Poker.Protobufs.Objects.TableEvent;

type
  TPB_HandHistoryMoveHelper = class helper for TPB_HandHistoryMove
    function ContainsEvent(const AEvent: TTableEventType): Boolean; overload;
    function ContainsEvent(const AEvents: array of TTableEventType; out AContainedEvent: TTableEventType): Boolean; overload;
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

function TPB_HandHistoryMoveHelper.ContainsEvent(const AEvents: array of TTableEventType; out AContainedEvent: TTableEventType): Boolean;
var
  event, array_event: TTableEventType;
begin
  for event in self.Code do
    for array_event in AEvents do
      if event = array_event then
      begin
        AContainedEvent := event;
        Exit(TRUE);
      end;
  Exit(FALSE);
end;


end.
