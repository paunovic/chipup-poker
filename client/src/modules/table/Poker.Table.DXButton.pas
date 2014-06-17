unit Poker.Table.DXButton;

interface

uses
  AsphyreImages, Vcl.ActnList, AbstractCanvas, AsphyreTypes, Vcl.Controls, System.Classes;

type
  TDXButton = class
  private
    FImageNormal: TAsphyreImage;
    FImageDown: TAsphyreImage;
    FImageHot: TAsphyreImage;
    FDown: Boolean;
    FAction: TAction;
    FBounds: PPoint4;

    function GetCurrentImage: TAsphyreImage;
  public
    procedure RenderTo(const ACanvas: TAsphyreCanvas);

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MouseMove(Shift: TShiftState; X, Y: Integer);
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

    property IsDown: Boolean read FDown;
    property CurrentImage: TAsphyreImage read GetCurrentImage;
    property ImageNormal: TAsphyreImage read FImageNormal write FImageNormal;
    property ImageDown: TAsphyreImage read FImageDown write FImageDown;
    property ImageHot: TAsphyreImage read FImageHot write FImageHot;
    property Action: TAction read FAction write FAction;
    property Bounds: PPoint4 read FBounds write FBounds;
  end;

implementation

uses
  Poker.Common.Misc, System.Types;

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
    if (FAction.Enabled) and
       (PtInBounds(Point(X, Y), FBounds^)) then
      FAction.Execute;

    FDown := FALSE;
  end;
end;

procedure TDXButton.RenderTo(const ACanvas: TAsphyreCanvas);
begin
  if not FAction.Enabled then
    Exit;

  ACanvas.UseImage(CurrentImage, TexFull4);
  ACanvas.TexMap(FBounds^, clWhite4);
end;

end.
