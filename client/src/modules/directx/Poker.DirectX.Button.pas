unit Poker.DirectX.Button;

interface

uses
  Asphyre.Images, Vcl.ActnList, Asphyre.Canvas, Asphyre.Types, Vcl.Controls,
  System.Classes, Poker.Tables.RenderMetrics;

type
  TDXButton = class
  private
    FId: Integer;
    FImageNormal: TAsphyreImage;
    FImageDown: TAsphyreImage;
    FImageHot: TAsphyreImage;
    FDown: Boolean;
    FAction: TAction;
    FBounds: PPoint4;
    FRenderActionCaption: Boolean;
    FFontScaleRatio: Single;

    function GetCurrentImage: TAsphyreImage;
  public
    procedure RenderTo(const ACanvas: TAsphyreCanvas; const AMetrics: TTableRenderMetrics);

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MouseMove(Shift: TShiftState; X, Y: Integer);
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

    property Id: Integer read FId write FId;
    property IsDown: Boolean read FDown;
    property CurrentImage: TAsphyreImage read GetCurrentImage;
    property ImageNormal: TAsphyreImage read FImageNormal write FImageNormal;
    property ImageDown: TAsphyreImage read FImageDown write FImageDown;
    property ImageHot: TAsphyreImage read FImageHot write FImageHot;
    property Action: TAction read FAction write FAction;
    property Bounds: PPoint4 read FBounds write FBounds;
    property RenderActionCaption: Boolean read FRenderActionCaption write FRenderActionCaption;
    property FontScaleRatio: Single read FFontScaleRatio write FFontScaleRatio;
  end;

implementation

uses
  Poker.Common.Misc, System.Types, Asphyre.Fonts, Poker.Tables.Resources, Asphyre.Math;

{ TDXButton }

function TDXButton.GetCurrentImage: TAsphyreImage;
begin
  if FDown then
    if Assigned(FImageDown) then
      Exit(FImageDown)
    else
      Exit(FImageNormal)
  else
    Exit(FImageNormal);
end;

procedure TDXButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button <> mbLeft) or
     (not Assigned(FAction)) or
     (not FAction.Enabled) then
    Exit;

  FDown := PtInBounds(Point(X, Y), FBounds^);
end;

procedure TDXButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TDXButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FDown then
  begin
    if (Assigned(FAction)) and
       (FAction.Enabled) and
       (PtInBounds(Point(X, Y), FBounds^)) then
      FAction.Execute;

    FDown := FALSE;
  end;
end;

procedure TDXButton.RenderTo(const ACanvas: TAsphyreCanvas; const AMetrics: TTableRenderMetrics);
var
  font: TAsphyreFont;
begin
  if (not Assigned(FAction)) or
     (not FAction.Enabled) then
    Exit;

  ACanvas.UseImage(CurrentImage, TexFull4);
  ACanvas.TexMap(FBounds^, clWhite4);

  if FRenderActionCaption then
  begin
    font := TableResources.SintonyFonts[High(TableResources.SintonyFonts)];
    font.Kerning := 0;
    if FDown then
      font.Scale := AMetrics.TableResizeRatio * (FFontScaleRatio * 0.9)
    else
      font.Scale := AMetrics.TableResizeRatio * FFontScaleRatio;
    font.TextMidF(Point2(FBounds[0].x + (FBounds[1].x - FBounds[0].x) / 2, FBounds[0].y + (FBounds[2].y - FBounds[0].y) / 2), FAction.Caption, clWhite2);
  end;
end;

end.
