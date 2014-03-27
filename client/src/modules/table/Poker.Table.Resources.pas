unit Poker.Table.Resources;

interface

uses
  AsphyreImages, AsphyreArchives, AsphyreFonts, AbstractCanvas, GR32, GR32_Resamplers, Poker.Cards;

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
      FSeatEmptyLeftImage: TAsphyreImage;
      FSeatEmptyRightImage: TAsphyreImage;
      FSeatDarkLeftImage: TAsphyreImage;
      FSeatDarkRightImage: TAsphyreImage;
      FSeatLightLeftImage: TAsphyreImage;
      FSeatLightRightImage: TAsphyreImage;
      FActiveSeatDarkLeftImage: TasphyreImage;
      FActiveSeatDarkRightImage: TAsphyreImage;
      FActiveSeatLightLeftImage: TAsphyreImage;
      FActiveSeatLightRightImage: TAsphyreImage;
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
      FRaiseSliderBackgroundImage: TAsphyreImage;
      FRaiseSliderButtonImage: TAsphyreImage;
      FActionButtonNormalImage: TAsphyreImage;
      FActionButtonHotImage: TAsphyreImage;
      FActionButtonPressedImage: TAsphyreImage;
      FRaisePresetButtonNormalImage: TAsphyreImage;
      FRaisePresetButtonHotImage: TAsphyreImage;
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

    procedure AddDXImage(const AName: String; var AReceiver: TAsphyreImage; out AAspectRatio: Single); overload;
    procedure AddDXImage(const AName: String; var AReceiver: TAsphyreImage); overload;
    procedure AddDXFont(const AName: String; var AReceiver: TAsphyreFont);

  public
    const
      SEAT_POINTS: array[2..10, 0..9] of Double = (
         (0, pi, 0, 0, 0, 0, 0, 0, 0, 0), // 2
         (0, pi/2, pi, 0, 0, 0, 0, 0, 0, 0), // 3
         (-pi/4, pi/4, pi*3/4, pi*5/4, 0, 0, 0, 0, 0, 0), // 4
         (-pi/5.5, pi/7, pi/2, pi-pi/7, pi+pi/5.5, 0, 0, 0, 0, 0), // 5
         (-pi/3, 0, pi/2.7, pi-pi/2.7, pi, pi+pi/3, 0, 0, 0, 0), // 6
         (-pi/4, 0, pi/4, pi/2, pi*3/4, pi, pi*5/4, 0, 0, 0), // 7
         (-pi/3.4, -pi/13.5, pi/6.8, pi/2.3, pi-pi/2.3, pi-pi/6.8, pi+pi/13.5, pi+pi/3.4, 0, 0), // 8
         (-pi/2.7, -pi/10, pi/32, pi/3.4, pi/2, pi-pi/3.4, pi-pi/32, pi+pi/10, pi+pi/2.7, 0), // 9
         (-pi/2.7, -pi/7.7, pi/128, pi/6, pi/2.3, pi-pi/2.3, pi-pi/6, pi-pi/128, pi+pi/7.7, pi+pi/2.7) // 10

      );

      RAISE_VALUEBOX_WIDTH      = 109;
      RAISE_VALUEBOX_HEIGHT     = 18;
      RAISE_VALUEBOX_X          = 14;
      RAISE_VALUEBOX_Y          = 6;
      RAISE_SLIDER_X            = 140;
      RAISE_SLIDER_Y            = 9;
      RAISE_SLIDER_WIDTH        = 283;
      RAISE_SLIDER_HEIGHT       = 9;
      STANDUP_BUTTON_TRIANGLE_W = 26;
      SEAT_AVATAR_WIDTH         = 66;
      SEAT_AVATAR_HEIGHT        = 66;
      SEAT_LEFT_AVATAR_X        = 199;
      SEAT_RIGHT_AVATAR_X       = 43;

            {
    class var
      SEAT_POINTS: array[2..10, 0..9] of Extended;

                 }
    class procedure Initialize(const ADXCanvas: TAsphyreCanvas);
    class procedure Deinitialize;

    constructor Create(const ADXCanvas: TAsphyreCanvas);
    destructor Destroy; override;

    function GetCardArtwork(const ACard: TCard): TAsphyreImage;

    property DXImages: TAsphyreImages read FDXImages;

    property RoomBackgroundImage: TAsphyreImage read FRoomBackgroundImage;
    property TableImage: TAsphyreImage read FTableImage;
    property CardBackgroundImage: TAsphyreImage read FCardBackgroundImage;
    property SeatEmptyLeftImage: TAsphyreImage read FSeatEmptyLeftImage;
    property SeatEmptyRightImage: TAsphyreImage read FSeatEmptyRightImage;
    property SeatDarkLeftImage: TAsphyreImage read FSeatDarkLeftImage;
    property SeatDarkRightImage: TAsphyreImage read FSeatDarkRightImage;
    property SeatLightLeftImage: TAsphyreImage read FSeatLightLeftImage;
    property SeatLightRightImage: TAsphyreImage read FSeatLightRightImage;
    property ActiveSeatDarkLeftImage: TAsphyreImage read FActiveSeatDarkLeftImage;
    property ActiveSeatDarkRightImage: TAsphyreImage read FActiveSeatDarkRightImage;
    property ActiveSeatLightLeftImage: TAsphyreImage read FActiveSeatLightLeftImage;
    property ActiveSeatLightRightImage: TAsphyreImage read FActiveSeatLightRightImage;
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
    property ActionButtonHotImage: TAsphyreImage read FActionButtonHotImage;
    property ActionButtonPressedImage: TAsphyreImage read FActionButtonPressedImage;
    property RaisePresetButtonNormalImage: TAsphyreImage read FRaisePresetButtonNormalImage;
    property RaisePresetButtonHotImage: TAsphyreImage read FRaisePresetButtonHotImage;
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
  Winapi.Windows, System.Classes, System.SysUtils;



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
  ArchiveTypeAccess := ataResource;

  FDXMediaFile := TAsphyreArchive.Create;
  FDXMediaFile.OpenMode := aomReadOnly;
  FDXMediaFile.FileName := 'RoomMedia';

  FDXImages := TAsphyreImages.Create;

  AddDXImage('TableBackground.image', FRoomBackgroundImage);
  AddDXImage('Table.image', FTableImage, FTableAspectRatio);
  AddDXImage('EmptySeatLeft.image', FSeatEmptyLeftImage, FSeatAspectRatio);
  AddDXImage('EmptySeatRight.image', FSeatEmptyRightImage);
  AddDXImage('SeatDarkLeft.image', FSeatDarkLeftImage);
  AddDXImage('SeatDarkRight.image', FSeatDarkRightImage);
  AddDXImage('SeatLightLeft.image', FSeatLightLeftImage);
  AddDXImage('SeatLightRight.image', FSeatLightRightImage);
  AddDXImage('ActiveSeatDarkLeft.image', FActiveSeatDarkLeftImage);
  AddDXImage('ActiveSeatDarkRight.image', FActiveSeatDarkRightImage);
  AddDXImage('ActiveSeatLightLeft.image', FActiveSeatLightLeftImage);
  AddDXImage('ActiveSeatLightRight.image', FActiveSeatLightRightImage);
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
  AddDXImage('ActionButtonHot.image', FActionButtonHotImage);
  AddDXImage('ActionButtonPressed.image', FActionButtonPressedImage);
  AddDXImage('RaisePresetButtonNormal.image', FRaisePresetButtonNormalImage, FRaisePresetButtonAspectRatio);
  AddDXImage('RaisePresetButtonHot.image', FRaisePresetButtonHotImage);
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

  AddDXFont('CardCharacters_19px', FCardCharactersFont_19px);
  for C1 := Low(FSintonyFonts) to High(FSintonyFonts) do
    AddDXFont(Format('Sintony_%dpx', [C1]), FSintonyFonts[C1]);
  for C1 := Low(FBarmenoFonts) to High(FBarmenoFonts) do
    AddDXFont(Format('Barmeno_%dpx', [C1]), FBarmenoFonts[C1]);
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
  if id <> -1 then
  begin
    AReceiver := FDXImages[id];
    AAspectRatio := AReceiver.Texture[0].Width / AReceiver.Texture[0].Height;
  end
  else
  begin
    {$IFDEF DEBUG} DebugLn(Format('Failed to load DX image resource: %s', [AName]), ditException); {$ENDIF}
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
  id := FDXFonts.Insert(Format('RoomMedia | %s.xml', [AName]), Format('%s.image', [AName]));
  AReceiver := FDXFonts[id];
end;


function TTableResources.GetCardArtwork(const ACard: TCard): TAsphyreImage;
var
  valueint, suitint: Integer;
begin
  valueint := Integer(ACard.Value) - 1;
  suitint := Integer(ACard.Suit) - 1;
  result := FCardArtworksImages[valueint * 4 + suitint];
end;


end.
