unit Poker.ChipStackMaker;

interface

uses
  System.Generics.Collections, Asphyre.Images, Poker.ChipStackMaker.ChipStack;

type
  TChipStackMaker = class(TObjectDictionary<UINT32, TChipStack>)
  public
    constructor Create;

    function MakeStack(const AValue: UINT32): TChipStack;
  end;

implementation

uses
  Poker.Tables.Resources;

{ TChipStackMaker }

constructor TChipStackMaker.Create;
begin
  inherited Create([doOwnsValues])
end;

function TChipStackMaker.MakeStack(const AValue: UINT32): TChipStack;
var
  chip_stack: TChipStack;
  val: UINT32;
begin
  val := AValue;
  if val > 1000000 then
    val := 1000000;

  if TryGetValue(val, chip_stack) then
    Exit(chip_stack);

  chip_stack := TChipStack.Create(val);
  Add(val, chip_stack);
  Exit(chip_stack);
end;

end.
