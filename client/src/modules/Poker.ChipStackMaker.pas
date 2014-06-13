unit Poker.ChipStackMaker;

interface

uses
  System.Generics.Collections, AsphyreImages;

type
  TChipImages = TArray<TAsphyreImage>;

  TChipsStack = class
  private
    FValue: UINT32;
    FChipCount: Integer;
    FImages: TChipImages;

    procedure MakeImages;

  public
    constructor Create(const AValue: UINT32);

    property Value: UINT32 read FValue;
    property ChipCount: Integer read FChipCount;
    property Images: TChipImages read FImages;
  end;

  TChipStackMaker = class
  private
    FStacks: TObjectList<TChipsStack>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;

    function MakeStack(const AValue: UINT32): TChipsStack;
    function IndexOf(const AValue: UINT32): Integer;
  end;

implementation

uses
  Poker.Table.Resources;

{ TChipsStack }

constructor TChipsStack.Create(const AValue: UINT32);
begin
  FValue := AValue;
  SetLength(FImages, 0);
  MakeImages;
end;

procedure TChipsStack.MakeImages;

  procedure AddImages(const ACount: Integer; var AIndex: Integer; const AImage: TAsphyreImage);
  var
    C1: Integer;
  begin
    for C1 := AIndex to AIndex + ACount - 1 do
      FImages[C1] := AImage;
    Inc(AIndex, ACount);
  end;

const
  CHIPS_DELTA_Y = 5;
var
  chip_index, ccount, c1k, c500, c100, c25, c5: Integer;
begin
  ccount := FValue div 100;

  c1k := ccount div 1000;
  Dec(ccount, c1k * 1000);

  c500 := ccount div 500;
  Dec(ccount, c500 * 500);

  c100 := ccount div 100;
  Dec(ccount, c100 * 100);

  c25 := ccount div 25;
  Dec(ccount, c25 * 25);

  c5 := ccount div 5;
  Dec(ccount, c5 * 5);

  FChipCount := c1k + c500 + c100 + c25 + c5 + ccount;
  SetLength(FImages, FChipCount);
  chip_index := 0;

  AddImages(ccount, chip_index, TableResources.Chip1Image);
  AddImages(c5, chip_index, TableResources.Chip5Image);
  AddImages(c25, chip_index, TableResources.Chip25Image);
  AddImages(c100, chip_index, TableResources.Chip100Image);
  AddImages(c500, chip_index, TableResources.Chip500Image);
  AddImages(c1k, chip_index, TableResources.Chip1000Image);
{
  AddImages(c1k, chip_index, TableResources.Chip1000Image);
  AddImages(c500, chip_index, TableResources.Chip500Image);
  AddImages(c100, chip_index, TableResources.Chip100Image);
  AddImages(c25, chip_index, TableResources.Chip25Image);
  AddImages(c5, chip_index, TableResources.Chip5Image);
  AddImages(ccount, chip_index, TableResources.Chip1Image);
}
end;

{ TChipsStacks }

constructor TChipStackMaker.Create;
begin
  FStacks := TObjectList<TChipsStack>.Create;
end;

destructor TChipStackMaker.Destroy;
begin
  FStacks.Free;

  inherited;
end;

function TChipStackMaker.IndexOf(const AValue: UINT32): Integer;
var
  C1: Integer;
begin
  for C1 := 0 to FStacks.Count - 1 do
    if FStacks[C1].Value = AValue then
      Exit(C1);
  Exit(-1);
end;

function TChipStackMaker.MakeStack(const AValue: UINT32): TChipsStack;
var
  index: Integer;
begin
  index := IndexOf(AValue);
  if index <> -1 then
    Exit(FStacks[index]);

  result := TChipsStack.Create(AValue);
  FStacks.Add(result);
end;

procedure TChipStackMaker.Clear;
begin
  FStacks.Clear;
end;


end.
