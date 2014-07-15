unit Poker.Helpers.PB_Pot;

interface

uses
  Poker.Protobufs.Objects.Pot;

type
  TPB_PotHelper = class helper for TPB_Pot
    function ValueWithoutRake: UINT32;
  end;

implementation

{ TPB_PotHelper }

function TPB_PotHelper.ValueWithoutRake: UINT32;
begin
  if Value <= Rake then
    result := 0
  else
    result := Value - Rake;
end;

end.
