unit uChipsStackMaker;

interface

uses
  System.Generics.Collections,
  GR32;

type
  TChipsStack = class
  private
    FValue     : Integer;
    FImage     : TBitmap32;
    FTopChipVal: String;
    FChipCount : Integer;

    procedure MakeBitmap;

  public
    constructor Create(const AValue: Integer);
    destructor Destroy; override;

    property Value: Integer read FValue;
    property ChipCount: Integer read FChipCount;
    property TopChipVal: String read FTopChipVal;
    property Image: TBitmap32 read FImage;
  end;

  TChipsStackMaker = class
  private
    FStacks: TObjectList<TChipsStack>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;

    function MakeStack(const AValue: Integer): TChipsStack;
    function IndexOf(const AValue: Integer): Integer;
  end;

implementation

uses
  uTableResources, Vcl.Graphics;

{ TChipsStack }

constructor TChipsStack.Create(const AValue: Integer);
begin
  FValue := AValue;
  FImage := TBitmap32.Create;
  FImage.DrawMode := dmBlend;
  MakeBitmap;
end;

destructor TChipsStack.Destroy;
begin
   FImage.Free;

  inherited;
end;

procedure TChipsStack.MakeBitmap;
const
  CHIPS_DELTA_Y = 5;

  function DrawChips(const ACount: Integer; var AChipIndex: Integer; AChipImage: TBitmap32): Boolean;
  var
    C1: Integer;
  begin
    result := FALSE;
    for C1 := 1 to ACount do
    begin
      FImage.Draw(0, FImage.Height - TTableResources.ChipHeight - (AChipIndex * CHIPS_DELTA_Y), AChipImage);
      Inc(AChipIndex);
      result := TRUE;
    end;
  end;

var
  chip_index, ccount, c1k, c500, c100, c25, c5: Integer;
begin
  ccount := FValue;

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
  FImage.SetSize(TTableResources.ChipWidth, (FChipCount - 1) * CHIPS_DELTA_Y + TTableResources.ChipHeight);
  chip_index := 0;
  if DrawChips(ccount, chip_index, TTableResources.Chip1Image) then
    FTopChipVal := '1';
  if DrawChips(c5, chip_index, TTableResources.Chip5Image) then
    FTopChipVal := '5';
  if DrawChips(c25, chip_index, TTableResources.Chip25Image) then
    FTopChipVal := '25';
  if DrawChips(c100, chip_index, TTableResources.Chip100Image) then
    FTopChipVal := '100';
  if DrawChips(c500, chip_index, TTableResources.Chip500Image) then
    FTopChipVal := '500';
  if DrawChips(c1k, chip_index, TTableResources.Chip1000Image) then
    FTopChipVal := '1k';
end;

{ TChipsStacks }

constructor TChipsStackMaker.Create;
begin
  FStacks := TObjectList<TChipsStack>.Create;
end;

destructor TChipsStackMaker.Destroy;
begin
  FStacks.Free;

  inherited;
end;

function TChipsStackMaker.IndexOf(const AValue: Integer): Integer;
var
  C1: Integer;
begin
  for C1 := 0 to FStacks.Count - 1 do
    if FStacks[C1].Value = AValue then
      Exit(C1);
  Exit(-1);
end;

function TChipsStackMaker.MakeStack(const AValue: Integer): TChipsStack;
var
  index: Integer;
begin
  index := IndexOf(AValue);
  if index <> -1 then
    Exit(FStacks[index]);

  result := TChipsStack.Create(AValue);
  FStacks.Add(result);
end;

procedure TChipsStackMaker.Clear;
begin
  FStacks.Clear;
end;


end.
