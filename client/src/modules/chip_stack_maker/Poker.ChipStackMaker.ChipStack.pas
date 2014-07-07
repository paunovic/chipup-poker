unit Poker.ChipStackMaker.ChipStack;

interface

uses
  System.Generics.Collections, AsphyreImages;

type
  TChipImages = TArray<TAsphyreImage>;

  TChipStack = class
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

implementation

uses
  Poker.Tables.Resources;

{ TChipStack }

constructor TChipStack.Create(const AValue: UINT32);
begin
  FValue := AValue;
  SetLength(FImages, 0);
  MakeImages;
end;

procedure TChipStack.MakeImages;

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

end.
