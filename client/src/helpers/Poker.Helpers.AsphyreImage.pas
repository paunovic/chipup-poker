unit Poker.Helpers.AsphyreImage;

interface

uses
  System.Classes, AsphyreImages;

type
  TAsphyreImageHelper = class helper for TAsphyreImage
    function LoadFromStream(const AExtension: String; const AStream: TStream): Boolean; overload;
  end;

implementation

uses
  System.SysUtils, AsphyreTypes, AsphyreDef, AsphyreConv, SystemSurfaces,
  AbstractTextures, AsphyreBitmaps;


function TAsphyreImageHelper.LoadFromStream(const AExtension: String; const AStream: TStream): Boolean;
var
 Surf   : TSystemSurface;
 Bits   : Pointer;
 Pitch  : Integer;
 NewTex : TAsphyreLockableTexture;
 WritePx: Pointer;
 Index  : Integer;
begin
 Surf:= TSystemSurface.Create();

 result := BitmapManager.LoadFromStream(AExtension, AStream, Surf);
 if (not Result) then
  begin
   FreeAndNil(Surf);
   Exit;
  end;

 RemoveAllTextures();

 PixelFormat:= apf_A8R8G8B8;

 NewTex:= InsertTexture(Surf.Width, Surf.Height);
 if (not Assigned(NewTex)) then
  begin
   FreeAndNil(Surf);
   Result:= False;
   Exit;
  end;

 NewTex.Lock(Bounds(0, 0, NewTex.Width, NewTex.Height), Bits, Pitch);
 if (not Assigned(Bits))or(Pitch < 1) then
  begin
   RemoveAllTextures();
   FreeAndNil(Surf);
   Result:= False;
   Exit;
  end;

 WritePx:= Bits;

 for Index:= 0 to Surf.Height - 1 do
  begin
   Pixel32toXArray(Surf.ScanLine[Index], WritePx, NewTex.Format, Surf.Width);

   Inc(PtrInt(WritePx), Pitch);
  end;

 NewTex.Unlock();
 FreeAndNil(Surf);

 if (NewTex.MipMapping) then NewTex.UpdateMipmaps();
 Result:= True;

end;

end.
