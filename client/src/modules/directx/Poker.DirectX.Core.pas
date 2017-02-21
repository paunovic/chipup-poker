unit Poker.DirectX.Core;

interface

uses
  Winapi.Windows, Asphyre.Fonts, Asphyre.Devices, Asphyre.Canvas, Asphyre.Canvas.DX9;

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

    function AcquireSwapChainElement(const AHandle: THandle; out AIndex: Integer): Boolean;
    procedure ModifySwapChainElement(const AIndex: Integer; const ANewHandle: THandle);
    procedure ReleaseSwapChainElement(const AIndex: Integer);

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
  System.SysUtils, System.Classes, Asphyre.Math, Poker.Helpers.DX9Canvas, Poker.Settings, Asphyre.SwapChains, Asphyre.Providers,
  Asphyre.Providers.DX9, Poker.SoftExceptions;


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

  FDevice.Initialize;
  for C1 := 1 to Settings.Hardcoded.DIRECTX_SWAPCHAIN_COUNT + 1 do
    FDevice.SwapChains.Add(FDummyWindow, Point2px(1, 1));

  if FDevice.Connect then
  begin
    (FCanvas as TDX9Canvas).SetSamplerToCLAMP;
  end
  else
    SoftException('DirectX: failed to connect to the device!');
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

function TDXCore.AcquireSwapChainElement(const AHandle: THandle; out AIndex: Integer): Boolean;
var
  C1: Integer;
  rect: TRect;
begin
  for C1 := 1 to FDevice.SwapChains.Count - 1 do
   if FDevice.SwapChains[C1].WindowHandle = FDummyWindow then
   begin
     Winapi.Windows.GetClientRect(AHandle, rect);
     FDevice.SwapChains[AIndex].Width := rect.Width;
     FDevice.SwapChains[AIndex].Height := rect.Height;
     FDevice.SwapChains[AIndex].WindowHandle := AHandle;
     FDevice.SwapChains[AIndex].Multisamples := 4;
     FDevice.SwapChains[AIndex].VSync := TRUE;
     AIndex := C1;
     {$IFDEF DEBUG} DebugLn(Format('DirectX: swap chain element #%d acquired', [AIndex]), ditApplication); {$ENDIF}
     {$IFDEF DEBUG} RefreshDebugForm([dfiSwapChains]); {$ENDIF}
     Exit(TRUE);
   end;

  SoftException('DirectX swap chain element not acquired');
  Exit(FALSE);
end;

procedure TDXCore.ReleaseSwapChainElement(const AIndex: Integer);
begin
  FDevice.SwapChains[AIndex].Width := 1;
  FDevice.SwapChains[AIndex].Height := 1;
  FDevice.SwapChains[AIndex].Multisamples := 0;
  FDevice.SwapChains[AIndex].VSync := FALSE;
  FDevice.SwapChains[AIndex].WindowHandle := FDummyWindow;
  {$IFDEF DEBUG} DebugLn(Format('DirectX: swap chain element #%d released', [AIndex]), ditApplication); {$ENDIF}
  {$IFDEF DEBUG} RefreshDebugForm([dfiSwapChains]); {$ENDIF}
end;

procedure TDXCore.ModifySwapChainElement(const AIndex: Integer; const ANewHandle: THandle);
begin
  FDevice.SwapChains[AIndex].WindowHandle := ANewHandle;
  {$IFDEF DEBUG} DebugLn(Format('DirectX: swap chain element #%d modified', [AIndex]), ditApplication); {$ENDIF}
end;

end.
