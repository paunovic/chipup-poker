unit uTableResources;

interface

uses
  GR32;

type
  TSeatPointsArray = array[2..10, 0..9] of TPoint;

  TTableResources = class
  private
    class var
      FInitialized        : Boolean;
      FImg_TableBackground: TBitmap32;
      FImg_Table          : TBitmap32;
      FTableOriginalWidth : Integer;
      FTableOriginalHeight: Integer;
      FSeatPoints         : TSeatPointsArray;

    class procedure ConfigureSeatPoints;

  public
    class procedure Initialize;
    class procedure Deinitialize;
    class function IsInitialized: Boolean;

    class property BackgroundImage: TBitmap32 read FImg_TableBackground;
    class property TableImage: TBitmap32 read FImg_Table;
    class property TableOriginalWidth: Integer read FTableOriginalWidth;
    class property TableOriginalHeight: Integer read FTableOriginalHeight;
    class property SeatPoints: TSeatPointsArray read FSeatPoints;
  end;

implementation

uses
  Winapi.Windows, System.Classes, System.Types, JPEG, PNGImage, GR32_Resamplers, GR32_PNG;


class procedure TTableResources.Initialize;
var
  jpg    : TJPEGImage;
  png    : TPortableNetworkGraphic32;
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

  png := TPortableNetworkGraphic32.Create;
  try
    rstream := TResourceStream.Create(HInstance, 'Table', RT_RCDATA);
    try
      png.LoadFromStream(rstream);
      FImg_Table := TBitmap32.Create;
      FImg_Table.DrawMode := dmBlend;
      FImg_Table.Assign(png);
      FTableOriginalWidth := FImg_Table.Width;
      FTableOriginalHeight := FImg_Table.Height;
      FImg_Table.Resampler := TDraftResampler.Create;
      // Alternative is KernelResampler. Slower, but slightly higher quality resample. Code below:
  {
      FImg_TableBitmap.Resampler := TKernelResampler.Create;
      (FImg_TableBitmap.Resampler as TKernelResampler).Kernel := TLanczosKernel.Create;
  }
    finally
      rstream.Free;
    end;
  finally
    png.Free;
  end;

  ConfigureSeatPoints;

  FInitialized := TRUE;
end;

class procedure TTableResources.ConfigureSeatPoints;
var
  y_center_point: Integer;
  x_center_point: Integer;
begin
  y_center_point := FTableOriginalHeight div 2 - 60;
  x_center_point := FTableOriginalWidth div 2;

  FSeatPoints[2, 0] := GR32.Point(FTableOriginalWidth - 75, y_center_point);
  FSeatPoints[2, 1] := GR32.Point(75, y_center_point);

  FSeatPoints[3, 0] := GR32.Point(FTableOriginalWidth - 75, y_center_point);
  FSeatPoints[3, 1] := GR32.Point(x_center_point, FTableOriginalHeight - 170);
  FSeatPoints[3, 2] := GR32.Point(75, y_center_point);

  FSeatPoints[4, 0] := GR32.Point(FTableOriginalWidth - 175, FTableOriginalHeight div 2 - 218);
  FSeatPoints[4, 1] := GR32.Point(FTableOriginalWidth - 175, FTableOriginalHeight div 2 + 100);
  FSeatPoints[4, 2] := GR32.Point(175, FTableOriginalHeight div 2 + 100);
  FSeatPoints[4, 3] := GR32.Point(175, FTableOriginalHeight div 2 - 218);

  FSeatPoints[5, 0] := GR32.Point(FTableOriginalWidth - 175, FTableOriginalHeight div 2 - 218);
  FSeatPoints[5, 1] := GR32.Point(FTableOriginalWidth - 175, FTableOriginalHeight div 2 + 100);
  FSeatPoints[5, 2] := GR32.Point(x_center_point, FTableOriginalHeight - 170);
  FSeatPoints[5, 3] := GR32.Point(175, FTableOriginalHeight div 2 + 100);
  FSeatPoints[5, 4] := GR32.Point(175, FTableOriginalHeight div 2 - 218);

  FSeatPoints[6, 0] := GR32.Point(FTableOriginalWidth - 285, FTableOriginalHeight div 2 - 263);
  FSeatPoints[6, 1] := GR32.Point(FTableOriginalWidth - 75, y_center_point);
  FSeatPoints[6, 2] := GR32.Point(FTableOriginalWidth - 285, FTableOriginalHeight div 2 + 145);
  FSeatPoints[6, 3] := GR32.Point(285, FTableOriginalHeight div 2 + 145);
  FSeatPoints[6, 4] := GR32.Point(75, y_center_point);
  FSeatPoints[6, 5] := GR32.Point(285, FTableOriginalHeight div 2 - 263);

  FSeatPoints[7, 0] := GR32.Point(FTableOriginalWidth - 285, FTableOriginalHeight div 2 - 263);
  FSeatPoints[7, 1] := GR32.Point(FTableOriginalWidth - 75, y_center_point);
  FSeatPoints[7, 2] := GR32.Point(FTableOriginalWidth - 285, FTableOriginalHeight div 2 + 155);
  FSeatPoints[7, 3] := GR32.Point(x_center_point, FTableOriginalHeight - 170);
  FSeatPoints[7, 4] := GR32.Point(285, FTableOriginalHeight div 2 + 155);
  FSeatPoints[7, 5] := GR32.Point(75, y_center_point);
  FSeatPoints[7, 6] := GR32.Point(285, FTableOriginalHeight div 2 - 263);

  // FIXME
end;

class procedure TTableResources.Deinitialize;
begin
  FImg_TableBackground.Free;
  FImg_Table.Free;

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
