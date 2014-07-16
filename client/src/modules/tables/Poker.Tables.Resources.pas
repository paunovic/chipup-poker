unit Poker.Tables.Resources;

interface

{$I defines.inc}

uses
  Winapi.Windows, Asphyre.Images, Asphyre.Archives, Asphyre.Fonts, Asphyre.Canvas, Poker.Cards, System.Generics.Collections;

type
  TSeatPointsArray = array[2..10, 0..9] of TPoint;

  TTableResources = class
  private
    type
      TBarmenoFonts = array[12..19] of TAsphyreFont;
      TSintonyFonts = array[12..19] of TAsphyreFont;

    var
      FDXImages: TAsphyreImages;
      FDXMediaFile: TAsphyreArchive;
      FDXFonts: TAsphyreFonts;

      FRoomBackgroundImage: TAsphyreImage;
      FTableImage: TAsphyreImage;
      FCardBackgroundImage: TAsphyreImage;
      FSeatLeftImage: TAsphyreImage;
      FSeatLeftActiveImage: TAsphyreImage;
      FSeatLeftEmptyImage: TAsphyreImage;
      FSeatRightImage: TAsphyreImage;
      FSeatRightActiveImage: TAsphyreImage;
      FSeatRightEmptyImage: TAsphyreImage;
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
      FCardArtworksImages: TArray<TAsphyreImage>;
      FRaiseSliderBackgroundImage: TAsphyreImage;
      FRaiseSliderButtonImage: TAsphyreImage;
      FActionButtonNormalImage: TAsphyreImage;
//      FActionButtonHotImage: TAsphyreImage;
      FActionButtonPressedImage: TAsphyreImage;
      FRaisePresetButtonNormalImage: TAsphyreImage;
//      FRaisePresetButtonHotImage: TAsphyreImage;
      FRaisePresetButtonPressedImage: TAsphyreImage;
      FStandUpButtonNormalImage: TAsphyreImage;
      FStandUpButtonPressedImage: TAsphyreImage;
      FPlayNowButtonNormalImage: TAsphyreImage;
      FPlayNowButtonPressedImage: TAsphyreImage;
      FSeatActionCheck: TAsphyreImage;
      FSeatActionCall: TAsphyreImage;
      FSeatActionFold: TAsphyreImage;
      FSeatActionRaise: TAsphyreImage;
      FSeatActionDisconnected: TAsphyreImage;
      FGrayscaleImages: TObjectDictionary<TAsphyreImage, TAsphyreImage>;

      FBarmenoFonts: TBarmenoFonts;
      FCardCharactersFont_19px: TAsphyreFont;
      FSintonyFonts: TSintonyFonts;

      FTableAspectRatio: Single;
      FSeatAspectRatio: Single;
      FCardAspectRatio: Single;
      FDealerButtonAspectRatio: Single;
      FChipAspectRatio: Single;
      FTimebarAspectRatio: Single;
      FCardArtworkAspectRatio: Single;
      FRaiseSliderAspectRatio: Single;
      FRaiseSliderButtonAspectRatio: Single;
      FActionButtonAspectRatio: Single;
      FRaisePresetButtonAspectRatio: Single;
      FStandUpButtonAspectRatio: Single;
      FPlayNowButtonAspectRatio: Single;
      FSeatActionFrameAspectRatio: Single;

      {$IFDEF DEBUG} FDebugId: Integer; {$ENDIF}

    procedure AddDXImage(const AName: String; var AReceiver: TAsphyreImage; out AAspectRatio: Single); overload;
    procedure AddDXImage(const AName: String; var AReceiver: TAsphyreImage); overload;
    procedure AddDXFont(const AName: String; var AReceiver: TAsphyreFont);
    procedure DesaturateImage(const AImage: TAsphyreImage);

  public
    const
      {$IFNDEF SEAT_POSITIONS_CONFIGURATOR}
      SEAT_POINTS: array[2..10, 0..9] of Double = (
        (0, pi, 0, 0, 0, 0, 0, 0, 0, 0), // 2
        (0, pi/2, pi, 0, 0, 0, 0, 0, 0, 0), // 3
        (-pi/4, pi/4, pi*3/4, pi*5/4, 0, 0, 0, 0, 0, 0), // 4
        (-pi/5.5, pi/7, pi/2, pi-pi/7, pi+pi/5.5, 0, 0, 0, 0, 0), // 5
        (-pi/3.5, pi/48, pi/2.7, pi-pi/2.7, pi+pi/48, pi+pi/3.5, 0, 0, 0, 0), // 6
        (-pi/4, 0, pi/4, pi/2, pi*3/4, pi, pi*5/4, 0, 0, 0), // 7
        (-pi/3.25, -pi/13, pi/6.5, pi/2.3, pi-pi/2.3, pi-pi/6.5, pi+pi/13, pi+pi/3.25, 0, 0), // 8
        (-pi/2.65, -pi/9, pi/24, pi/3, pi/2, pi-pi/3, pi-pi/24, pi+pi/9, pi+pi/2.65, 0), // 9
        (-pi/2.65, -pi/6, pi/80, pi/5, pi/2.25, pi-pi/2.25, pi-pi/5, pi-pi/80, pi+pi/6, pi+pi/2.65) // 10
      );
      {$ENDIF}

      RAISE_VALUEBOX_WIDTH      = 109;
      RAISE_VALUEBOX_HEIGHT     = 18;
      RAISE_VALUEBOX_X          = 14;
      RAISE_VALUEBOX_Y          = 6;
      RAISE_TRACK_LEFT_OFFSET   = 140;
      RAISE_TRACK_TOP_OFFSET    = 9;
      RAISE_TRACK_SLIDER_WIDTH  = 283;
      RAISE_TRACK_SLIDER_HEIGHT = 9;
      STANDUP_BUTTON_TRIANGLE_W = 26;
      SEAT_AVATAR_WIDTH         = 66;
      SEAT_AVATAR_HEIGHT        = 66;
      SEAT_LEFT_AVATAR_X        = 199;
      SEAT_RIGHT_AVATAR_X       = 43;

    {$IFDEF SEAT_POSITIONS_CONFIGURATOR}
    class var
      SEAT_POINTS: array[2..10, 0..9] of Extended;
    {$ENDIF}

    class procedure Initialize(const ADXCanvas: TAsphyreCanvas);
    class procedure Deinitialize;

    constructor Create(const ADXCanvas: TAsphyreCanvas);
    destructor Destroy; override;

    function GetCardArtwork(const ACard: TCard): TAsphyreImage;
    function GrayscaleVersion(const AImage: TAsphyreImage): TAsphyreImage;

    property DXImages: TAsphyreImages read FDXImages;

    property RoomBackgroundImage: TAsphyreImage read FRoomBackgroundImage;
    property TableImage: TAsphyreImage read FTableImage;
    property CardBackgroundImage: TAsphyreImage read FCardBackgroundImage;
    property SeatLeftImage: TAsphyreImage read FSeatLeftImage;
    property SeatLeftActiveImage: TAsphyreImage read FSeatLeftActiveImage;
    property SeatLeftEmptyImage: TAsphyreImage read FSeatLeftEmptyImage;
    property SeatRightImage: TAsphyreImage read FSeatRightImage;
    property SeatRightActiveImage: TAsphyreImage read FSeatRightActiveImage;
    property SeatRightEmptyImage: TAsphyreImage read FSeatRightEmptyImage;
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
    property RaiseSliderBackgroundImage: TAsphyreImage read FRaiseSliderBackgroundImage;
    property RaiseSliderButtonImage: TAsphyreImage read FRaiseSliderButtonImage;
    property ActionButtonNormalImage: TAsphyreImage read FActionButtonNormalImage;
//    property ActionButtonHotImage: TAsphyreImage read FActionButtonHotImage;
    property ActionButtonPressedImage: TAsphyreImage read FActionButtonPressedImage;
    property RaisePresetButtonNormalImage: TAsphyreImage read FRaisePresetButtonNormalImage;
//    property RaisePresetButtonHotImage: TAsphyreImage read FRaisePresetButtonHotImage;
    property RaisePresetButtonPressedImage: TAsphyreImage read FRaisePresetButtonPressedImage;
    property StandUpButtonNormalImage: TAsphyreImage read FStandUpButtonNormalImage;
    property StandUpButtonPressedImage: TAsphyreImage read FStandUpButtonPressedImage;
    property PlayNowButtonNormalImage: TAsphyreImage read FPlayNowButtonNormalImage;
    property PlayNowButtonPressedImage: TAsphyreImage read FPlayNowButtonPressedImage;
    property SeatActionCheck: TAsphyreImage read FSeatActionCheck;
    property SeatActionCall: TAsphyreImage read FSeatActionCall;
    property SeatActionFold: TAsphyreImage read FSeatActionFold;
    property SeatActionRaise: TAsphyreImage read FSeatActionRaise;
    property SeatActionDisconnected: TAsphyreImage read FSeatActionDisconnected;

    property BarmenoFonts: TBarmenoFonts read FBarmenoFonts;
    property CardCharactersFont_19px: TAsphyreFont read FCardCharactersFont_19px;
    property SintonyFonts: TSintonyFonts read FSintonyFonts;

    property TableAspectRatio: Single read FTableAspectRatio;
    property SeatAspectRatio: Single read FSeatAspectRatio;
    property CardAspectRatio: Single read FCardAspectRatio;
    property DealerButtonAspectRatio: Single read FDealerButtonAspectRatio;
    property ChipAspectRatio: Single read FChipAspectRatio;
    property TimebarAspectRatio: Single read FTimebarAspectRatio;
    property CardArtworkAspectRatio: Single read FCardArtworkAspectRatio;
    property RaiseSliderAspectRatio: Single read FRaiseSliderAspectRatio;
    property RaiseSliderButtonAspectRatio: Single read FRaiseSliderButtonAspectRatio;
    property ActionButtonAspectRatio: Single read FActionButtonAspectRatio;
    property RaisePresetButtonAspectRatio: Single read FRaisePresetButtonAspectRatio;
    property StandUpButtonAspectRatio: Single read FStandUpButtonAspectRatio;
    property PlayNowButtonAspectRatio: Single read FPlayNowButtonAspectRatio;
    property SeatActionFrameAspectRatio: Single read FSeatActionFrameAspectRatio;
  end;

var
  TableResources: TTableResources;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  System.SysUtils, Poker.DataModule, Poker.Settings, Asphyre.Colors, Asphyre.Types, System.Types;



class procedure TTableResources.Initialize(const ADXCanvas: TAsphyreCanvas);
begin
  TableResources := TTableResources.Create(ADXCanvas);
end;

class procedure TTableResources.Deinitialize;
begin
  FreeAndNil(TableResources);
end;


constructor TTableResources.Create(const ADXCanvas: TAsphyreCanvas);
var
  C1 : Integer;
  CCV: TCardValue;
  CCS: TCardSuit;
begin
  {$IFDEF DEBUG} FDebugId := RegisterDebugObject('TableResources'); {$ENDIF}

  ArchiveTypeAccess := ataAnyFile;
  FDXMediaFile := TAsphyreArchive.Create;
  FDXMediaFile.OpenMode := aomReadOnly;
  FDXMediaFile.FileName := SelfPath + Settings.Hardcoded.ASSETS.DIRECTORY + Settings.Hardcoded.ASSETS.DIRECTX_MEDIA;

  FDXImages := TAsphyreImages.Create;

  AddDXImage('TableBackground.image', FRoomBackgroundImage);
  AddDXImage('Table.image', FTableImage, FTableAspectRatio);
  AddDXImage('SeatLeft.image', FSeatLeftImage, FSeatAspectRatio);
  AddDXImage('SeatLeftActive.image', FSeatLeftActiveImage);
  AddDXImage('SeatLeftEmpty.image', FSeatLeftEmptyImage);
  AddDXImage('SeatRight.image', FSeatRightImage);
  AddDXImage('SeatRightActive.image', FSeatRightActiveImage);
  AddDXImage('SeatRightEmpty.image', FSeatRightEmptyImage);
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
  AddDXImage('RaiseSliderBackground.image', FRaiseSliderBackgroundImage, FRaiseSliderAspectRatio);
  AddDXImage('RaiseSliderButton.image', FRaiseSliderButtonImage, FRaiseSliderButtonAspectRatio);
  AddDXImage('ActionButtonNormal.image', FActionButtonNormalImage, FActionButtonAspectRatio);
//  AddDXImage('ActionButtonHot.image', FActionButtonHotImage);
  AddDXImage('ActionButtonPressed.image', FActionButtonPressedImage);
  AddDXImage('RaisePresetButtonNormal.image', FRaisePresetButtonNormalImage, FRaisePresetButtonAspectRatio);
//  AddDXImage('RaisePresetButtonHot.image', FRaisePresetButtonHotImage);
  AddDXImage('RaisePresetButtonPressed.image', FRaisePresetButtonPressedImage);
  AddDXImage('StandUpButtonNormal.image', FStandUpButtonNormalImage, FStandUpButtonAspectRatio);
  AddDXImage('StandUpButtonPressed.image', FStandUpButtonPressedImage);
  AddDXImage('PlayNowButtonNormal.image', FPlayNowButtonNormalImage, FPlayNowButtonAspectRatio);
  AddDXImage('PlayNowButtonPressed.image', FPlayNowButtonPressedImage);
  AddDXImage('ActionCall.image', FSeatActionCall, FSeatActionFrameAspectRatio);
  AddDXImage('ActionCheck.image', FSeatActionCheck);
  AddDXImage('ActionDisconnected.image', FSeatActionDisconnected);
  AddDXImage('ActionFold.image', FSeatActionFold);
  AddDXImage('ActionRaise.image', FSeatActionRaise);

  FGrayscaleImages := TObjectDictionary<TAsphyreImage, TAsphyreImage>.Create([]);

  C1 := 0;
  for CCV := Low(TCardValue) to High(TCardValue) do
    for CCS := Low(TCardSuit) to High(TCardSuit) do
      if (CCV <> cvUnknown) and (CCS <> csUnknown) then
      begin
        SetLength(FCardArtworksImages, C1 + 1);
        AddDXImage(Format('CardArtwork%s.image', [TCard.GetAsString(CCV, CCS)]), FCardArtworksImages[C1], FCardArtworkAspectRatio);
        Inc(C1);
      end;

  FDXFonts := TAsphyreFonts.Create;
  FDXFonts.Canvas := ADXCanvas;
  FDXFonts.Images := FDXImages;

  AddDXFont('CardCharacters_19px', FCardCharactersFont_19px);
  for C1 := Low(FSintonyFonts) to High(FSintonyFonts) do
    AddDXFont(Format('Sintony_%dpx', [C1]), FSintonyFonts[C1]);
  for C1 := Low(FBarmenoFonts) to High(FBarmenoFonts) do
    AddDXFont(Format('Barmeno_%dpx', [C1]), FBarmenoFonts[C1]);
end;

destructor TTableResources.Destroy;
begin
  FGrayscaleImages.Free;
  FDXFonts.Free;
  FDXImages.Free;
  FDXMediaFile.Free;

  {$IFDEF DEBUG} UnregisterDebugObject(FDebugId); {$ENDIF}
end;

procedure TTableResources.AddDXImage(const AName: String; var AReceiver: TAsphyreImage; out AAspectRatio: Single);
var
  id: Integer;
begin
  id := FDXImages.AddFromArchive(AName, FDXMediaFile);
  if id <> -1 then
  begin
    AReceiver := FDXImages[id];
    AReceiver.Name := AName;
    AAspectRatio := AReceiver.Texture[0].Width / AReceiver.Texture[0].Height;
  end
  else
  begin
    {$IFDEF DEBUG} DebugLn(FDebugId, Format('Failed to load DX image resource: %s', [AName]), ditException); {$ENDIF}
  end;
end;

procedure TTableResources.AddDXImage(const AName: String; var AReceiver: TAsphyreImage);
var
  ar: Single;
begin
  AddDXImage(AName, AReceiver, ar);
end;

procedure TTableResources.AddDXFont(const AName: String; var AReceiver: TAsphyreFont);
var
  id: Integer;
begin
  FDXImages.AddFromArchive(Format('%s.image', [AName]), FDXMediaFile);
  id := FDXFonts.Insert(Format('\%s%s | %s.xml', [Settings.Hardcoded.ASSETS.DIRECTORY, Settings.Hardcoded.ASSETS.DIRECTX_MEDIA, AName]), Format('%s.image', [AName]));
  if id <> -1 then
    AReceiver := FDXFonts[id]
  else
  begin
    {$IFDEF DEBUG} DebugLn(FDebugId, Format('Failed to insert DX font resource: %s', [AName]), ditException); {$ENDIF}
  end;
end;

function TTableResources.GetCardArtwork(const ACard: TCard): TAsphyreImage;
var
  valueint, suitint: Integer;
begin
  valueint := Integer(ACard.Value) - 1;
  suitint := Integer(ACard.Suit) - 1;
  result := FCardArtworksImages[valueint * 4 + suitint];
end;

function TTableResources.GrayscaleVersion(const AImage: TAsphyreImage): TAsphyreImage;
begin
  if not FGrayscaleImages.TryGetValue(AImage, result) then
  begin
    AddDXImage(AImage.Name, result);
    DesaturateImage(result);
    FGrayscaleImages.Add(AImage, result);
  end;
end;

procedure TTableResources.DesaturateImage(const AImage: TAsphyreImage);
type
  PPixelRec = ^TPixelRec;
  TPixelRec = packed record
    B: Byte;
    G: Byte;
    R: Byte;
    A: Byte;
  end;
var
  C1, x, y: Integer;
  bitsp: pointer;
  pitch: Integer;
  bytes_per_pixel: Integer;
  pixel: PPixelRec;
  gray_value: Byte;
begin
  for C1 := 0 to AImage.TextureCount - 1 do
  begin
    AImage.Texture[C1].Lock(Rect(0, 0, AImage.Texture[C1].Width, AImage.Texture[C1].Height), bitsp, pitch);
    try
      bytes_per_pixel := pitch div AImage.Texture[C1].Width;
      for y := 0 to AImage.Texture[C1].Height - 1 do
        for x := 0 to AImage.Texture[C1].Width - 1 do
        begin
          pixel := PPixelRec(Integer(bitsp) + y * pitch + x * bytes_per_pixel);
          gray_value := Round(0.30 * pixel^.r + 0.59 * pixel^.g + 0.11 * pixel^.b);
          pixel^.r := gray_value;
          pixel^.g := gray_value;
          pixel^.b := gray_value;
        end;
    finally
      AImage.Texture[C1].Unlock;
    end;
  end;
end;

end.
