unit uTableResources;

interface

uses
  GR32, uCards;

type
  TSeatPointsArray = array[2..10, 0..9] of TPoint;

  TTableResources = class
  private
    class var
      FInitialized            : Boolean;
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
      FImg_Cards              : array[0..51] of TBitmap32;
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

    class function GetCardImage(const ACard: TCard): TBitmap32;

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
  end;

implementation

uses
  Winapi.Windows, System.Classes, System.Types, JPEG, PNGImage, GR32_Resamplers, GR32_PNG, System.SysUtils;

type
  TBitmapResampler = (bsDraft, bsKernel);


procedure CreateBitmap32FromPNGResource(var ABitmap: TBitmap32; const AResourceName: String; const AResampler: TBitmapResampler);
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
      end;
    finally
      rstream.Free;
    end;
  finally
    png.Free;
  end;
end;

class procedure TTableResources.Initialize;
var
  jpg    : TJPEGImage;
  rstream: TResourceStream;
  C1     : Integer;
  CCV    : TCardValue;
  CCS    : TCardSuit;
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

  CreateBitmap32FromPNGResource(FImg_Table, 'Table', bsDraft);
  CreateBitmap32FromPNGResource(FImg_DealerButton, 'DealerButton', bsKernel);
  CreateBitmap32FromPNGResource(FImg_SeatEmptyLeft, 'EmptySeatLeft', bsKernel);
  CreateBitmap32FromPNGResource(FImg_SeatEmptyRight, 'EmptySeatRight', bsKernel);
  CreateBitmap32FromPNGResource(FImg_SeatDarkLeft, 'SeatDarkLeft', bsKernel);
  CreateBitmap32FromPNGResource(FImg_SeatLightLeft, 'SeatLightLeft', bsKernel);
  CreateBitmap32FromPNGResource(FImg_SeatDarkRight, 'SeatDarkRight', bsKernel);
  CreateBitmap32FromPNGResource(FImg_SeatLightRight, 'SeatLightRight', bsKernel);
  CreateBitmap32FromPNGResource(FImg_CardBackground, 'CardBackground', bsKernel);

  C1 := 0;
  for CCV := Low(TCardValue) to High(TCardValue) do
    for CCS := Low(TCardSuit) to High(TCardSuit) do
      if (CCV <> cvUnknown) and (CCS <> csUnknown) then
      begin
        CreateBitmap32FromPNGResource(FImg_Cards[C1], Format('Card%s', [TCard.GetAsString(CCV, CCS)]), bsKernel);
        Inc(C1);
      end;

  FTableWidth := 962;
  FTableHeight := 492;
  FTableAspectRatio := FTableWidth / FTableHeight;

  FTableXOffset := 65;
  FTableYOffset := 42;

  FDealerButtonWidth := FImg_DealerButton.Width;
  FDealerButtonHeight := FImg_DealerButton.Height;
  FDealerButtonAspectRatio := FDealerButtonWidth / FDealerButtonHeight;

  FSeatWidth := FImg_SeatEmptyLeft.Width;
  FSeatHeight := FImg_SeatEmptyLeft.Height;
  FSeatAspectRatio := FSeatWidth / FSeatHeight;

  FCardWidth := FImg_CardBackground.Width;
  FCardHeight := FImg_CardBackground.Height;
  FCardAspectRatio := FCardWidth / FCardHeight;

  FInitialized := TRUE;
end;

class procedure TTableResources.Deinitialize;
var
  C1: Integer;
begin
  FImg_TableBackground.Free;
  FImg_Table.Free;
  FImg_DealerButton.Free;
  FImg_SeatEmptyLeft.Free;
  FImg_SeatEmptyRight.Free;
  FImg_SeatDarkLeft.Free;
  FImg_SeatLightLeft.Free;
  FImg_SeatDarkRight.Free;
  FImg_SeatLightRight.Free;
  FImg_CardBackground.Free;

  for C1 := Low(FImg_Cards) to High(FImg_Cards) do
    FImg_Cards[C1].Free;

  FInitialized := FALSE;
end;

class function TTableResources.GetCardImage(const ACard: TCard): TBitmap32;
var
  valueint, suitint: Integer;
begin
  valueint := Integer(ACard.Value) - 1;
  suitint := Integer(ACard.Suit) - 1;
  result := FImg_Cards[valueint * 4 + suitint];
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
