unit uDXCore;

interface

uses
  Winapi.Windows, AsphyreFonts,
  AbstractDevices, AbstractCanvas, AsphyreEvents, AsphyreEventTypes, AsphyreFactory, DX9Providers, NativeConnectors;

type
  TDXCore = class
  private
    FDevice     : TAsphyreDevice;
    FCanvas     : TAsphyreCanvas;
    FFonts      : TAsphyreFonts;
    FDummyWindow: HWND;

    procedure OnAsphyreCreate(Sender: TObject; Param: Pointer; var Handled: Boolean);
    procedure OnAsphyreDestroy(Sender: TObject; Param: Pointer; var Handled: Boolean);
    procedure OnDeviceInit(Sender: TObject; Param: Pointer; var Handled: Boolean);
    procedure OnDeviceCreate(Sender: TObject; Param: Pointer; var Handled: Boolean);
  public
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

  procedure InitializeDXCore;

var
  DXCore: TDXCore;

implementation

uses
  System.SysUtils, System.Classes, Vectors2px, uTableResources;


procedure InitializeDXCore;
begin
  DXCore := TDXCore.Create;
end;


constructor TDXCore.Create;
begin
  FDummyWindow := AllocateHwnd(nil);

  Factory.UseProvider(idDirectX9);

  EventAsphyreCreate.Subscribe(ClassName, OnAsphyreCreate);
  EventAsphyreDestroy.Subscribe(ClassName, OnAsphyreDestroy);
  EventDeviceInit.Subscribe(ClassName, OnDeviceInit);
  EventDeviceCreate.Subscribe(ClassName, OnDeviceCreate);

  NativeAsphyreConnect.Init;
end;

destructor TDXCore.Destroy;
begin
  if Assigned(FDevice) then
    FDevice.Disconnect;
  NativeAsphyreConnect.Done;
  EventProviders.Unsubscribe(ClassName);

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

procedure TDXCore.OnAsphyreCreate(Sender: TObject; Param: Pointer; var Handled: Boolean);
begin
  FDevice := Factory.CreateDevice;
  FCanvas := Factory.CreateCanvas;
  FFonts := TAsphyreFonts.Create;
  FFonts.Canvas := FCanvas;

  FCanvas.Antialias := TRUE;
  FCanvas.MipMapping := TRUE;

  FDevice.Connect;
end;

procedure TDXCore.OnAsphyreDestroy(Sender: TObject; Param: Pointer; var Handled: Boolean);
begin
  FreeAndNil(FFonts);
  FreeAndNil(FCanvas);
  FreeAndNil(FDevice);
end;

procedure TDXCore.OnDeviceCreate(Sender: TObject; Param: Pointer; var Handled: Boolean);
begin
end;

procedure TDXCore.OnDeviceInit(Sender: TObject; Param: Pointer; var Handled: Boolean);
var
  C1: Integer;
begin
  for C1 := 0 to 31 do
    FDevice.SwapChains.Add(FDummyWindow, Point2px(1, 1));
end;

procedure TDXCore.AcquireSwapChain(const AIndex: Integer; const AHandle: THandle);
begin
  FDevice.SwapChains.Items[AIndex]^.WindowHandle := AHandle;
end;

procedure TDXCore.ReleaseSwapChain(const AIndex: Integer);
begin
  FDevice.SwapChains.Items[AIndex]^.WindowHandle := FDummyWindow;
end;

initialization

finalization
  if Assigned(DXCore) then
    FreeAndNil(DXCore);

end.
