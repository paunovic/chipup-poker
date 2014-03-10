unit uTableResources;

interface

uses
  AsphyreImages, AsphyreArchives, AsphyreFonts, AbstractCanvas,
  GR32, GR32_PNG, GR32_Resamplers, uCards, System.Generics.Collections;

type
  TSeatPointsArray = array[2..10, 0..9] of TPoint;

  TTableResources = class
  private
    FDXImages: TAsphyreImages;
    FDXMediaFile: TAsphyreArchive;
    FDXFonts: TAsphyreFonts;

    FBackgroundImage: TAsphyreImage;
    FTableImage: TAsphyreImage;
    FCardBackgroundImage: TAsphyreImage;
    FSeatEmptyLeftImage: TAsphyreImage;
    FSeatEmptyRightImage: TAsphyreImage;
    FSeatDarkLeftImage: TAsphyreImage;
    FSeatDarkRightImage: TAsphyreImage;
    FSeatLightLeftImage: TAsphyreImage;
    FSeatLightRightImage: TAsphyreImage;
    FDealerButtonImage: TAsphyreImage;
    FChip1Image: TAsphyreImage;
    FChip5Image: TAsphyreImage;
    FChip25Image: TAsphyreImage;
    FChip100Image: TAsphyreImage;
    FChip500Image: TAsphyreImage;
    FChip1000Image: TAsphyreImage;
    FTimebarImage: TAsphyreImage;
    FTimebankImage: TAsphyreImage;
    FCardFrontBackgroundImage: TAsphyreImage;
    FCardArtworksImages: array of TAsphyreImage;

    FBarmenoFont_19px: TAsphyreFont;
    FCardCharactersFont_19px: TAsphyreFont;

    FTableAspectRatio: Single;
    FSeatAspectRatio: Single;
    FCardAspectRatio: Single;
    FDealerButtonAspectRatio: Single;
    FChipAspectRatio: Single;
    FTimebarAspectRatio: Single;
    FCardArtworkAspectRatio: Single;

    procedure AddDXImage(const AName: String; var AReceiver: TAsphyreImage; out AAspectRatio: Single); overload;
    procedure AddDXImage(const AName: String; var AReceiver: TAsphyreImage); overload;

  public
    const
      SEAT_POINTS: array[2..10, 0..9] of Double = (
        (0, pi, 0, 0, 0, 0, 0, 0, 0, 0), // 2
        (0, pi/2, pi, 0, 0, 0, 0, 0, 0, 0), // 3
        (-pi/4, pi/4, pi*3/4, pi*5/4, 0, 0, 0, 0, 0, 0), // 4
        (-pi/6, pi/6, pi/2, pi*5/6, pi*7/6, 0, 0, 0, 0, 0), // 5
        (-pi/3.5, 0, pi/3, pi-pi/3, pi, pi+pi/3.5, 0, 0, 0, 0), // 6
        (-pi/4, 0, pi/4, pi/2, pi*3/4, pi, pi*5/4, 0, 0, 0), // 7
        (-pi/3, -pi/8.5, pi/8.5, pi/2.8, pi-pi/2.8, pi-pi/8.5, pi+pi/8.5, pi*4/3, 0, 0), // 8
        (-pi/3, -pi/7.5, pi/16, pi/3.5, pi/2, pi-pi/3.5, pi-pi/16, pi+pi/7.5, pi*4/3, 0), // 9
        (-pi/3, -pi/6.9, pi/64, pi/5.1, pi/2.5, pi-pi/2.5, pi-pi/5.1, pi-pi/64, pi+pi/6.9, pi*4/3) // 10
      );

    constructor Create(const ADXCanvas: TAsphyreCanvas);
    destructor Destroy; override;

    function GetCardArtwork(const ACard: TCard): TAsphyreImage;

    property DXImages: TAsphyreImages read FDXImages;

    property BackgroundImage: TAsphyreImage read FBackgroundImage;
    property TableImage: TAsphyreImage read FTableImage;
    property CardBackgroundImage: TAsphyreImage read FCardBackgroundImage;
    property SeatEmptyLeftImage: TAsphyreImage read FSeatEmptyLeftImage;
    property SeatEmptyRightImage: TAsphyreImage read FSeatEmptyRightImage;
    property SeatDarkLeftImage: TAsphyreImage read FSeatDarkLeftImage;
    property SeatDarkRightImage: TAsphyreImage read FSeatDarkRightImage;
    property SeatLightLeftImage: TAsphyreImage read FSeatLightLeftImage;
    property SeatLightRightImage: TAsphyreImage read FSeatLightRightImage;
    property DealerButtonImage: TAsphyreImage read FDealerButtonImage;
    property Chip1Image: TAsphyreImage read FChip1Image;
    property Chip5Image: TAsphyreImage read FChip5Image;
    property Chip25Image: TAsphyreImage read FChip25Image;
    property Chip100Image: TAsphyreImage read FChip100Image;
    property Chip500Image: TAsphyreImage read FChip500Image;
    property Chip1000Image: TAsphyreImage read FChip1000Image;
    property TimebarImage: TAsphyreImage read FTimebarImage;
    property TimebankImage: TAsphyreImage read FTimebankImage;
    property CardFrontBackgroundImage: TAsphyreImage read FCardFrontBackgroundImage;

    property BarmenoFont_19px: TAsphyreFont read FBarmenoFont_19px;
    property CardCharactersFont_19px: TAsphyreFont read FCardCharactersFont_19px;

    property TableAspectRatio: Single read FTableAspectRatio;
    property SeatAspectRatio: Single read FSeatAspectRatio;
    property CardAspectRatio: Single read FCardAspectRatio;
    property DealerButtonAspectRatio: Single read FDealerButtonAspectRatio;
    property ChipAspectRatio: Single read FChipAspectRatio;
    property TimebarAspectRatio: Single read FTimebarAspectRatio;
    property CardArtworkAspectRatio: Single read FCardArtworkAspectRatio;
  end;

procedure InitializeTableResources(const ADXCanvas: TAsphyreCanvas);

var
  TableResources: TTableResources;

implementation

uses
  Winapi.Windows, System.Classes, System.SysUtils;



procedure InitializeTableResources(const ADXCanvas: TAsphyreCanvas);
begin
  TableResources := TTableResources.Create(ADXCanvas);
end;


constructor TTableResources.Create(const ADXCanvas: TAsphyreCanvas);
var
  C1, id: Integer;
  CCV   : TCardValue;
  CCS   : TCardSuit;
begin
  ArchiveTypeAccess := ataResource;

  FDXMediaFile := TAsphyreArchive.Create;
  FDXMediaFile.OpenMode := aomReadOnly;
  FDXMediaFile.FileName := 'RoomMedia';

  FDXImages := TAsphyreImages.Create;

  AddDXImage('RoomBackground.image', FBackgroundImage);
  AddDXImage('Table.image', FTableImage, FTableAspectRatio);
  AddDXImage('EmptySeatLeft.image', FSeatEmptyLeftImage, FSeatAspectRatio);
  AddDXImage('EmptySeatRight.image', FSeatEmptyRightImage);
  AddDXImage('SeatDarkLeft.image', FSeatDarkLeftImage);
  AddDXImage('SeatDarkRight.image', FSeatDarkRightImage);
  AddDXImage('SeatLightLeft.image', FSeatLightLeftImage);
  AddDXImage('SeatLightRight.image', FSeatLightRightImage);
  AddDXImage('SeatLightRight.image', FSeatLightRightImage);
  AddDXImage('CardBackground.image', FCardBackgroundImage, FCardAspectRatio);
  AddDXImage('DealerButton.image', FDealerButtonImage, FDealerButtonAspectRatio);
  AddDXImage('Chip1.image', FChip1Image, FChipAspectRatio);
  AddDXImage('Chip5.image', FChip5Image);
  AddDXImage('Chip25.image', FChip25Image);
  AddDXImage('Chip100.image', FChip100Image);
  AddDXImage('Chip500.image', FChip500Image);
  AddDXImage('Chip1000.image', FChip1000Image);
  AddDXImage('Timebar.image', FTimebarImage, FTimebarAspectRatio);
  AddDXImage('Timebank.image', FTimebankImage);
  AddDXImage('CardFrontBackground.image', FCardFrontBackgroundImage);

  C1 := 0;
  for CCV := Low(TCardValue) to High(TCardValue) do
    for CCS := Low(TCardSuit) to High(TCardSuit) do
      if (CCV <> cvUnknown) and (CCS <> csUnknown) then
      begin
        SetLength(FCardArtworksImages, C1 + 1);
        AddDXImage(Format('CardArtwork%s.image', [TCard.GetAsString(CCV, CCS)]),
           FCardArtworksImages[C1], FCardArtworkAspectRatio);
        Inc(C1);
      end;

  FDXFonts := TAsphyreFonts.Create;
  FDXFonts.Canvas := ADXCanvas;
  FDXFonts.Images := FDXImages;

  FDXImages.AddFromArchive('Barmeno_19px.image', FDXMediaFile);
  FDXImages.AddFromArchive('CardCharacters_19px.image', FDXMediaFile);

  id := FDXFonts.Insert('RoomMedia | Barmeno_19px.xml', 'Barmeno_19px.image');
  FBarmenoFont_19px := FDXFonts[id];

  id := FDXFonts.Insert('RoomMedia | CardCharacters_19px.xml', 'CardCharacters_19px.image');
  FCardCharactersFont_19px := FDXFonts[id];
end;

destructor TTableResources.Destroy;
begin
  FDXFonts.Free;
  FDXImages.Free;
  FDXMediaFile.Free;
end;

procedure TTableResources.AddDXImage(const AName: String; var AReceiver: TAsphyreImage; out AAspectRatio: Single);
var
  id: Integer;
begin
  id := FDXImages.AddFromArchive(AName, FDXMediaFile);
  AReceiver := FDXImages[id];
  AAspectRatio := AReceiver.Texture[0].Width / AReceiver.Texture[0].Height;
end;

procedure TTableResources.AddDXImage(const AName: String; var AReceiver: TAsphyreImage);
var
  ar: Single;
begin
  AddDXImage(AName, AReceiver, ar);
end;

function TTableResources.GetCardArtwork(const ACard: TCard): TAsphyreImage;
var
  valueint, suitint: Integer;
begin
  valueint := Integer(ACard.Value) - 1;
  suitint := Integer(ACard.Suit) - 1;
  result := FCardArtworksImages[valueint * 4 + suitint];
end;


initialization

finalization
  if Assigned(TableResources) then
    FreeAndNil(TableResources);

end.
