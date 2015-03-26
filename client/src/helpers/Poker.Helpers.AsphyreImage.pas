unit Poker.Helpers.AsphyreImage;

interface

uses
  System.Classes, Asphyre.Images, Asphyre.Bitmaps.JPG;

type
  TAsphyreImageHelper = class helper for TAsphyreImage
    function LoadFromStream(const AExtension: String; const AStream: TStream): Boolean; overload;
  end;

implementation

uses
  System.SysUtils, Asphyre.Types, Asphyre.TypeDef, Asphyre.Surfaces, Asphyre.Textures, Asphyre.Bitmaps, Asphyre.Formats;


function TAsphyreImageHelper.LoadFromStream(const AExtension: String; const AStream: TStream): Boolean;
var
 surf: TSystemSurface;
 bits: pointer;
 pitch: Integer;
 newtex: TAsphyreLockableTexture;
 writepx: pointer;
 C1: Integer;
begin
  surf := TSystemSurface.Create();
  try
    result := BitmapManager.LoadFromStream(AExtension, AStream, surf);
    if not result then
      Exit;

    RemoveAllTextures();
    PixelFormat := apf_A8R8G8B8;

    newtex := InsertTexture(surf.Width, surf.Height);
    if not Assigned(NewTex) then
      Exit(FALSE);

    newtex.Lock(Bounds(0, 0, newtex.Width, newtex.Height), bits, pitch);
    if (not Assigned(bits)) or
       (pitch < 1) then
    begin
      RemoveAllTextures();
      Exit(FALSE);
    end;

    writepx := bits;

    for C1 := 0 to surf.Height - 1 do
    begin
      Pixel32toXArray(surf.ScanLine[C1], writepx, newtex.Format, surf.Width);
      Inc(PtrInt(writepx), pitch);
    end;

    newtex.Unlock();
  finally
    FreeAndNil(surf);
  end;

  if newtex.MipMapping then
    newtex.UpdateMipmaps();

  result := TRUE;
end;

end.
