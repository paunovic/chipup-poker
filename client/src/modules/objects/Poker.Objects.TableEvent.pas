unit Poker.Objects.TableEvent;

interface

uses
  System.Generics.Collections, System.SysUtils, Poker.Protobufs.Objects.TableEvent, Poker.Pots.PotList;

type
  TTableEvents = class(TObjectList<TPB_TableEvent>)
  public
    procedure Assign(const AEvents: TList<TPB_TableEvent>);
  end;

implementation

{ TTableEvents }

procedure TTableEvents.Assign(const AEvents: TList<TPB_TableEvent>);
var
  pbevent: TPB_TableEvent;
begin
  Clear;
  if Assigned(AEvents) then
    for pbevent in AEvents do
      Add(TPB_TableEvent.Create(pbevent));
end;

end.
