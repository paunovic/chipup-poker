unit uTableResources;

interface

uses
  GR32;

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
      FImg_SeatDarkLeftImage  : TBitmap32;
      FImg_SeatLightLeftImage : TBitmap32;
      FImg_SeatDarkRightImage : TBitmap32;
      FImg_SeatLightRightImage: TBitmap32;
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

  public
    class procedure Initialize;
    class procedure Deinitialize;
    class function IsInitialized: Boolean;

    class property BackgroundImage: TBitmap32 read FImg_TableBackground;
    class property TableImage: TBitmap32 read FImg_Table;
    class property DealerButtonImage: TBitmap32 read FImg_DealerButton;
    class property SeatEmptyLeftImage: TBitmap32 read FImg_SeatEmptyLeft;
    class property SeatEmptyRightImage: TBitmap32 read FImg_SeatEmptyRight;
    class property SeatDarkLeftImage: TBitmap32 read FImg_SeatDarkLeftImage;
    class property SeatLightLeftImage: TBitmap32 read FImg_SeatLightLeftImage;
    class property SeatDarkRightImage: TBitmap32 read FImg_SeatDarkRightImage;
    class property SeatLightRightImage: TBitmap32 read FImg_SeatLightRightImage;
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
  end;

implementation

uses
  Winapi.Windows, System.Classes, System.Types, JPEG, PNGImage, GR32_Resamplers, GR32_PNG;

type
  TBitmapResampler = (bsDraft, bsKernel);


procedure LoadPNGResourceToBitmap32(var ABitmap: TBitmap32; const AResourceName: String; const AResampler: TBitmapResampler);
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

  LoadPNGResourceToBitmap32(FImg_Table, 'Table', bsDraft);
  LoadPNGResourceToBitmap32(FImg_DealerButton, 'DealerButton', bsKernel);
  LoadPNGResourceToBitmap32(FImg_SeatEmptyLeft, 'EmptySeatLeft', bsKernel);
  LoadPNGResourceToBitmap32(FImg_SeatEmptyRight, 'EmptySeatRight', bsKernel);
  LoadPNGResourceToBitmap32(FImg_SeatDarkLeftImage, 'SeatDarkLeft', bsKernel);
  LoadPNGResourceToBitmap32(FImg_SeatLightLeftImage, 'SeatLightLeft', bsKernel);
  LoadPNGResourceToBitmap32(FImg_SeatDarkRightImage, 'SeatDarkRight', bsKernel);
  LoadPNGResourceToBitmap32(FImg_SeatLightRightImage, 'SeatLightRight', bsKernel);

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

  FInitialized := TRUE;
end;

class procedure TTableResources.Deinitialize;
begin
  FImg_TableBackground.Free;
  FImg_Table.Free;
  FImg_DealerButton.Free;
  FImg_SeatEmptyLeft.Free;
  FImg_SeatEmptyRight.Free;
  FImg_SeatDarkLeftImage.Free;
  FImg_SeatLightLeftImage.Free;
  FImg_SeatDarkRightImage.Free;
  FImg_SeatLightRightImage.Free;

  FInitialized := FALSE;
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
