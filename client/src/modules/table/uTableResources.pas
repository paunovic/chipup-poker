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
      FTableWidth             : Integer;
      FTableHeight            : Integer;
      FTableAspectRatio       : Double;
      FTableXOffset           : Integer;
      FTableYOffset           : Integer;
      FDealerButtonWidth      : Integer;
      FDealerButtonHeight     : Integer;
      FDealerButtonAspectRatio: Double;

  public
    class procedure Initialize;
    class procedure Deinitialize;
    class function IsInitialized: Boolean;

    class property BackgroundImage: TBitmap32 read FImg_TableBackground;
    class property TableImage: TBitmap32 read FImg_Table;
    class property DealerButtonImage: TBitmap32 read FImg_DealerButton;
    class property TableWidth: Integer read FTableWidth;
    class property TableHeight: Integer read FTableHeight;
    class property TableAspectRatio: Double read FTableAspectRatio;
    class property TableXOffset: Integer read FTableXOffset;
    class property TableYOffset: Integer read FTableYOffset;
    class property DealerButtonWidth: Integer read FDealerButtonWidth;
    class property DealerButtonHeight: Integer read FDealerButtonHeight;
    class property DealerButtonAspectRatio: Double read FDealerButtonAspectRatio;
  end;

implementation

uses
  Winapi.Windows, System.Classes, System.Types, JPEG, PNGImage, GR32_Resamplers, GR32_PNG;


procedure LoadPNGResourceToBitmap32(var ABitmap: TBitmap32; const AResourceName: String);
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
      ABitmap.Resampler := TDraftResampler.Create;
      // Alternative is KernelResampler. Slower, but slightly higher quality resample. Code below:
  {
      ABitmap.Resampler := TKernelResampler.Create;
      (ABitmap.Resampler as TKernelResampler).Kernel := TLanczosKernel.Create;
  }
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

  LoadPNGResourceToBitmap32(FImg_Table, 'Table');
  LoadPNGResourceToBitmap32(FImg_DealerButton, 'DealerButton');

  FTableWidth := 962;
  FTableHeight := 492;
  FTableAspectRatio := FTableWidth / FTableHeight;

  FTableXOffset := 65;
  FTableYOffset := 42;

  FDealerButtonWidth := FImg_DealerButton.Width;
  FDealerButtonHeight := FImg_DealerButton.Height;
  FDealerButtonAspectRatio := FDealerButtonWidth / FDealerButtonHeight;

  FInitialized := TRUE;
end;

class procedure TTableResources.Deinitialize;
begin
  FImg_TableBackground.Free;
  FImg_Table.Free;
  FImg_DealerButton.Free;

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
