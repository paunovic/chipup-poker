unit Poker.Helpers.DX9Canvas;

interface

uses
  DX9Canvas, DX9Types, AsphyreD3D9;

type
  TDX9CanvasHelper = class helper for TDX9Canvas
  public
    procedure SetSamplerToCLAMP;
  end;

implementation

{ TDX9CanvasHelper }

procedure TDX9CanvasHelper.SetSamplerToCLAMP;
begin
  D3D9Device.SetSamplerState(0, D3DSAMP_ADDRESSU, D3DTADDRESS_CLAMP);
  D3D9Device.SetSamplerState(0, D3DSAMP_ADDRESSV, D3DTADDRESS_CLAMP);
  D3D9Device.SetSamplerState(0, D3DSAMP_ADDRESSW, D3DTADDRESS_CLAMP);
end;

end.
