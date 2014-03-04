unit uTableResources;

interface

uses
  GR32, GR32_PNG, GR32_Resamplers, uCards, System.Generics.Collections;

type
  TSeatPointsArray = array[2..10, 0..9] of TPoint;

  TTableResources = class
  private
    type
      TBitmapResampler = (bsNone, bsDraft, bsKernel, bsLinear);

    class var
      FInitialized            : Boolean;
      FCreatedBitmaps32       : TObjectList<TBitmap32>;
      FImg_TableBackground    : TBitmap32;
      FImg_Table              : TBitmap32;
      FImg_DealerButton       : TBitmap32;
      FImg_SeatEmptyLeft      : TBitmap32;
      FImg_SeatEmptyRight     : TBitmap32;
      FImg_SeatDarkLeft       : TBitmap32;
      FImg_SeatLightLeft      : TBitmap32;
      FImg_SeatDarkRight      : TBitmap32;
      FImg_SeatLightRight     : TBitmap32;
      FImg_CardBackground     : TBitmap32;
      FImg_CardFrontBackground: TBitmap32;
      FImg_CardArtworks       : array[0..51] of TBitmap32;
      FImg_Chip1              : TBitmap32;
      FImg_Chip5              : TBitmap32;
      FImg_Chip25             : TBitmap32;
      FImg_Chip100            : TBitmap32;
      FImg_Chip500            : TBitmap32;
      FImg_Chip1000           : TBitmap32;
      FImg_Timebar            : TBitmap32;
      FTableWidth             : Integer;
      FTableHeight            : Integer;
      FTableAspectRatio       : Double;
      FTableXOffset           : Integer;
      FTableYOffset           : Integer;
      FDealerButtonWidth      : Integer;
      FDealerButtonHeight     : Integer;
      FDealerButtonAspectRatio: Double;
      FSeatWidth              : Integer;
      FSeatHeight             : Integer;
      FSeatAspectRatio        : Double;
      FCardWidth              : Integer;
      FCardHeight             : Integer;
      FCardAspectRatio        : Double;
      FArtworkWidth           : Integer;
      FArtworkHeight          : Integer;
      FArtworkAspectRatio     : Double;
      FChipWidth              : Integer;
      FChipHeight             : Integer;
      FChipAspectRatio        : Double;
      FTimebarWidth           : Integer;
      FTimebarHeight          : Integer;
      FTimebarAspectRatio     : Double;

    class procedure CreateBitmap32FromPNGResource(var ABitmap: TBitmap32; const AResourceName: String; const AResampler: TBitmapResampler; out AWidth, AHeight: Integer; out AAspectRatio: Double); overload;
    class procedure CreateBitmap32FromPNGResource(var ABitmap: TBitmap32; const AResourceName: String; const AResampler: TBitmapResampler); overload;

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

    class procedure Initialize;
    class procedure Deinitialize;
    class function IsInitialized: Boolean;

    class function GetCardArtwork(const ACard: TCard): TBitmap32;

    class property BackgroundImage: TBitmap32 read FImg_TableBackground;
    class property TableImage: TBitmap32 read FImg_Table;
    class property DealerButtonImage: TBitmap32 read FImg_DealerButton;
    class property SeatEmptyLeftImage: TBitmap32 read FImg_SeatEmptyLeft;
    class property SeatEmptyRightImage: TBitmap32 read FImg_SeatEmptyRight;
    class property SeatDarkLeftImage: TBitmap32 read FImg_SeatDarkLeft;
    class property SeatLightLeftImage: TBitmap32 read FImg_SeatLightLeft;
    class property SeatDarkRightImage: TBitmap32 read FImg_SeatDarkRight;
    class property SeatLightRightImage: TBitmap32 read FImg_SeatLightRight;
    class property CardBackgroundImage: TBitmap32 read FImg_CardBackground;
    class property CardFrontBackgroundImage: TBitmap32 read FImg_CardFrontBackground;
    class property Chip1Image: TBitmap32 read FImg_Chip1;
    class property Chip5Image: TBitmap32 read FImg_Chip5;
    class property Chip25Image: TBitmap32 read FImg_Chip25;
    class property Chip100Image: TBitmap32 read FImg_Chip100;
    class property Chip500Image: TBitmap32 read FImg_Chip500;
    class property Chip1000Image: TBitmap32 read FImg_Chip1000;
    class property TimebarImage: TBitmap32 read FImg_Timebar;
    class property TableWidth: Integer read FTableWidth;
    class property TableHeight: Integer read FTableHeight;
    class property TableAspectRatio: Double read FTableAspectRatio;
    class property TableXOffset: Integer read FTableXOffset;
    class property TableYOffset: Integer read FTableYOffset;
    class property DealerButtonWidth: Integer read FDealerButtonWidth;
    class property DealerButtonHeight: Integer read FDealerButtonHeight;
    class property DealerButtonAspectRatio: Double read FDealerButtonAspectRatio;
    class property SeatWidth: Integer read FSeatWidth;
    class property SeatHeight: Integer read FSeatHeight;
    class property SeatAspectRatio: Double read FSeatAspectRatio;
    class property CardWidth: Integer read FCardWidth;
    class property CardHeight: Integer read FCardHeight;
    class property CardAspectRatio: Double read FCardAspectRatio;
    class property ArtworkWidth: Integer read FArtworkWidth;
    class property ArtworkHeight: Integer read FArtworkHeight;
    class property ArtworkAspectRatio: Double read FArtworkAspectRatio;
    class property ChipWidth: Integer read FChipWidth;
    class property ChipHeight: Integer read FChipHeight;
    class property ChipAspectRatio: Double read FChipAspectRatio;
    class property TimebarWidth: Integer read FTimebarWidth;
    class property TimebarHeight: Integer read FTimebarHeight;
    class property TimebarAspectRatio: Double read FTimebarAspectRatio;
  end;

implementation

uses
  Winapi.Windows, System.Classes, System.Types, JPEG, PNGImage, System.SysUtils;



class procedure TTableResources.CreateBitmap32FromPNGResource(var ABitmap: TBitmap32; const AResourceName: String; const AResampler: TBitmapResampler; out AWidth, AHeight: Integer; out AAspectRatio: Double);
var
  png    : TPortableNetworkGraphic32;
  rstream: TResourceStream;
begin
  png := TPortableNetworkGraphic32.Create;
  try
    rstream := TResourceStream.Create(HInstance, AResourceName, RT_RCDATA);
    try
      png.LoadFromStream(rstream);
      ABitmap := TBitmap32.Create;
      ABitmap.DrawMode := dmBlend;
      ABitmap.Assign(png);
      case AResampler of
        bsDraft: ABitmap.Resampler := TDraftResampler.Create;
        bsKernel: begin
          ABitmap.Resampler := TKernelResampler.Create;
          (ABitmap.Resampler as TKernelResampler).Kernel := TLanczosKernel.Create;
        end;
        bsLinear: ABitmap.Resampler := TLinearResampler.Create;
        bsNone: ;
      end;
    finally
      rstream.Free;
    end;
  finally
    png.Free;
  end;

  AWidth := ABitmap.Width;
  AHeight := ABitmap.Height;
  AAspectRatio := AWidth / AHeight;

  FCreatedBitmaps32.Add(ABitmap);
end;

class procedure TTableResources.CreateBitmap32FromPNGResource(var ABitmap: TBitmap32; const AResourceName: String; const AResampler: TBitmapResampler);
var
  w, h: Integer;
  ar  : Double;
begin
  CreateBitmap32FromPNGResource(ABitmap, AResourceName, AResampler, w, h, ar);
end;


class procedure TTableResources.Initialize;
var
  jpg     : TJPEGImage;
  rstream : TResourceStream;
  C1      : Integer;
  CCV     : TCardValue;
  CCS     : TCardSuit;
begin
  FImg_TableBackground := TBitmap32.Create;
  jpg := TJPEGImage.Create;
  try
    rstream := TResourceStream.Create(HInstance, 'TableBackground', RT_RCDATA);
    try
      jpg.LoadFromStream(rstream);
      FImg_TableBackground.Assign(jpg);
    finally
      rstream.Free;
    end;
  finally
    jpg.Free;
  end;

  FCreatedBitmaps32 := TObjectList<TBitmap32>.Create;

  CreateBitmap32FromPNGResource(FImg_Table, 'Table', bsDraft);
  CreateBitmap32FromPNGResource(FImg_DealerButton, 'DealerButton', bsKernel, FDealerButtonWidth, FDealerButtonHeight, FDealerButtonAspectRatio);
  CreateBitmap32FromPNGResource(FImg_SeatEmptyLeft, 'EmptySeatLeft', bsKernel, FSeatWidth, FSeatHeight, FSeatAspectRatio);
  CreateBitmap32FromPNGResource(FImg_SeatEmptyRight, 'EmptySeatRight', bsKernel);
  CreateBitmap32FromPNGResource(FImg_SeatDarkLeft, 'SeatDarkLeft', bsKernel);
  CreateBitmap32FromPNGResource(FImg_SeatLightLeft, 'SeatLightLeft', bsKernel);
  CreateBitmap32FromPNGResource(FImg_SeatDarkRight, 'SeatDarkRight', bsKernel);
  CreateBitmap32FromPNGResource(FImg_SeatLightRight, 'SeatLightRight', bsKernel);
  CreateBitmap32FromPNGResource(FImg_CardBackground, 'CardBackground', bsKernel);
  CreateBitmap32FromPNGResource(FImg_CardFrontBackground, 'CardFrontBackground', bsKernel, FCardWidth, FCardHeight, FCardAspectRatio);
  CreateBitmap32FromPNGResource(FImg_Chip1, 'Chip1', bsKernel, FChipWidth, FChipHeight, FChipAspectRatio);
  CreateBitmap32FromPNGResource(FImg_Chip5, 'Chip5', bsKernel);
  CreateBitmap32FromPNGResource(FImg_Chip25, 'Chip25', bsKernel);
  CreateBitmap32FromPNGResource(FImg_Chip100, 'Chip100', bsKernel);
  CreateBitmap32FromPNGResource(FImg_Chip500, 'Chip500', bsKernel);
  CreateBitmap32FromPNGResource(FImg_Chip1000, 'Chip1000', bsKernel);
  CreateBitmap32FromPNGResource(FImg_Timebar, 'Timebar', bsKernel, FTimebarWidth, FTimebarHeight, FTimebarAspectRatio);

  C1 := 0;
  for CCV := Low(TCardValue) to High(TCardValue) do
    for CCS := Low(TCardSuit) to High(TCardSuit) do
      if (CCV <> cvUnknown) and (CCS <> csUnknown) then
      begin
        CreateBitmap32FromPNGResource(FImg_CardArtworks[C1], Format('CardArtwork%s', [TCard.GetAsString(CCV, CCS)]), bsKernel, FArtworkWidth, FArtworkHeight, FArtworkAspectRatio);
        Inc(C1);
      end;

  FTableWidth := 962;
  FTableHeight := 492;
  FTableAspectRatio := FTableWidth / FTableHeight;

  FTableXOffset := 65;
  FTableYOffset := 42;

  FInitialized := TRUE;
end;

class procedure TTableResources.Deinitialize;
begin
  FImg_TableBackground.Free;
  FCreatedBitmaps32.Free;

  FInitialized := FALSE;
end;

class function TTableResources.GetCardArtwork(const ACard: TCard): TBitmap32;
var
  valueint, suitint: Integer;
begin
  valueint := Integer(ACard.Value) - 1;
  suitint := Integer(ACard.Suit) - 1;
  result := FImg_CardArtworks[valueint * 4 + suitint];
end;


class function TTableResources.IsInitialized: Boolean;
begin
  result := FInitialized;
end;

initialization

finalization
  if TTableResources.IsInitialized then
    TTableResources.Deinitialize;

end.
