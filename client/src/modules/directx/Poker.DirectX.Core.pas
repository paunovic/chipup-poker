unit Poker.DirectX.Core;

interface

uses
  Winapi.Windows, AsphyreFonts, AbstractDevices, AbstractCanvas, DX9Canvas;

type
  TDXCore = class
  private
    FDevice: TAsphyreDevice;
    FCanvas: TAsphyreCanvas;
    FFonts: TAsphyreFonts;
    FDummyWindow: HWND;
  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
    destructor Destroy; override;

    function GetFreeSwapChain: Integer;
    procedure AcquireSwapChain(const AIndex: Integer; const AHandle: THandle);
    procedure ReleaseSwapChain(const AIndex: Integer);

    property Device: TAsphyreDevice read FDevice;
    property Canvas: TAsphyreCanvas read FCanvas;
    property Fonts: TAsphyreFonts read FFonts;
    property DummyWindow: HWND read FDummyWindow;
  end;

var
  DXCore: TDXCore;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  System.SysUtils, System.Classes, AsphyreFactory, Vectors2px, DX9Providers, AsphyreD3D9, Poker.Helpers.DX9Canvas;


class procedure TDXCore.Initialize;
begin
  DXCore := TDXCore.Create;
end;

class procedure TDXCore.Deinitialize;
begin
  FreeAndNil(DXCore);
end;


constructor TDXCore.Create;
var
  C1: Integer;
begin
  FDummyWindow := AllocateHwnd(nil);

  Factory.UseProvider(idDirectX9);
  FDevice := Factory.CreateDevice;
  FCanvas := Factory.CreateCanvas;
  FFonts := TAsphyreFonts.Create;
  FFonts.Canvas := FCanvas;

  FCanvas.Antialias := TRUE;
  FCanvas.MipMapping := TRUE;

  for C1 := 0 to 32 do
    FDevice.SwapChains.Add(FDummyWindow, Point2px(1, 1));

  if FDevice.Connect then
  begin
    (FCanvas as TDX9Canvas).ImproveQuality;
  end
  else
  begin
    {$IFDEF DEBUG} DebugLn('Failed to connect to DX device!', ditException); {$ENDIF}
  end;
end;

destructor TDXCore.Destroy;
begin
  if Assigned(FDevice) then
    FDevice.Disconnect;

  FreeAndNil(FFonts);
  FreeAndNil(FCanvas);
  FreeAndNil(FDevice);

  DeallocateHWnd(FDummyWindow);

  inherited;
end;

function TDXCore.GetFreeSwapChain: Integer;
var
  C1: Integer;
begin
  for C1 := 1 to FDevice.SwapChains.Count - 1 do
   if FDevice.SwapChains[C1].WindowHandle = FDummyWindow then
     Exit(C1);
  Exit(-1);
end;

procedure TDXCore.AcquireSwapChain(const AIndex: Integer; const AHandle: THandle);
begin
  FDevice.SwapChains.Items[AIndex]^.WindowHandle := AHandle;
end;

procedure TDXCore.ReleaseSwapChain(const AIndex: Integer);
begin
  FDevice.SwapChains.Items[AIndex]^.WindowHandle := FDummyWindow;
end;

end.
