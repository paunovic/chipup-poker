unit Poker.ActionMainMenuBarStyle;

interface

uses
  System.Types, Vcl.ActnMan, Vcl.ActnMenus, Vcl.StdActnMenus, Vcl.StdStyleActnCtrls, Vcl.GraphUtil, Vcl.ActnColorMaps;

type
  TActionMainMenuBarStyle = class(TStandardStyleActionBars)
  public
    function GetControlClass(ActionBar: TCustomActionBar; AnItem: TActionClientItem): TCustomActionControlClass; override;
  end;

  TActionMainMenuBarColorMap = class(Vcl.ActnColorMaps.TStandardColorMap)
  public
    procedure UpdateColors; override;
  end;

  TActionMainMenuBarMenuStyle = class(TStandardMenuItem)
  protected
    procedure DrawSeparator(const Offset: Integer); override;
    procedure DrawGlyph(const Location: TPoint); override;
    procedure DrawBackground(var PaintRect: TRect); override;
  public
    procedure CalcBounds; override;
  end;

var
  ActionMainMenuBarStyle: TActionMainMenuBarStyle;
  ActionMainMenuBarColorMap: TActionMainMenuBarColorMap;

implementation

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.ActnList, Vcl.Graphics, Vcl.ImgList, System.UITypes;


{ TActionMainMenuBarStyle }

function TActionMainMenuBarStyle.GetControlClass(ActionBar: TCustomActionBar; AnItem: TActionClientItem): TCustomActionControlClass;
begin
  result := inherited GetControlClass(ActionBar, AnItem);
  if ActionBar is TCustomActionPopupMenu then
    result := TActionMainMenuBarMenuStyle;
end;

{ TMenuStyle }

procedure TActionMainMenuBarMenuStyle.CalcBounds;
begin
  inherited;

  if (not Assigned(ActionClient)) or
     (ActionClient.HasItems) or
     ((ActionClient.Action is TCustomAction) and
      ((ActionClient.Action as TCustomAction).GroupIndex = 0)) then
    TextBounds.Offset(-14, 0)
  else
    TextBounds.Offset(-3, 0);
end;

procedure TActionMainMenuBarMenuStyle.DrawGlyph(const Location: TPoint);
begin
  if not HasGlyph and IsChecked then
  begin
    Canvas.Pen.Color := ActionBar.ColorMap.FontColor;
    DrawCheck(Canvas, Point((TextBounds.Left - 8) div 2, Height div 2), 2);
  end;
end;

procedure TActionMainMenuBarMenuStyle.DrawBackground(var PaintRect: TRect);
begin
  if ActionClient.HasGlyph or IsChecked then
    PaintRect.Left := PaintRect.Left - 21
  else
    PaintRect.Left := PaintRect.Left - 2;

  PaintRect.Width := PaintRect.Width + 2;

  inherited DrawBackground(PaintRect);
end;

procedure TActionMainMenuBarMenuStyle.DrawSeparator(const Offset: Integer);
var
  PaintRect: TRect;
  PR: TPenRecall;
  BR: TBrushRecall;
begin
  BR := TBrushRecall.Create(Canvas.Brush);
  PR := TPenRecall.Create(Canvas.Pen);
  try
    if Assigned(ActionClient) and ActionClient.Unused and not Transparent then
      Canvas.Brush.Style := bsSolid
    else
    begin
      Canvas.Brush.Color := Menu.ColorMap.Color;
      PaintRect := BoundsRect;
      Winapi.Windows.DrawEdge(Canvas.Handle, PaintRect, BDR_RAISEDINNER, BF_LEFT);
      Winapi.Windows.DrawEdge(Canvas.Handle, PaintRect, BDR_RAISEDINNER, BF_RIGHT);
    end;
    Canvas.Pen.Color := Menu.ColorMap.DisabledFontColor;
    Canvas.MoveTo(8, ClientHeight div 2);
    Canvas.LineTo(ClientWidth - 8, ClientHeight div 2);
  finally
    BR.Free;
    PR.Free;
  end;
end;

{ TActionMainMenuBarColorMap }

procedure TActionMainMenuBarColorMap.UpdateColors;
begin
  inherited;

  ShadowColor := clGray;
  Color := $191919;
  DisabledFontColor := $4B4B4B;
  DisabledFontShadow := $191919;
  FontColor := $C7C7C7;
  HighlightColor := $2E2E2E;
  HotColor := $00208C;
  HotFontColor := clWhite;
  MenuColor := $191919;
  FrameTopLeftInner := $191919;
  FrameTopLeftOuter := $00208C;
  FrameBottomRightInner := $191919;
  FrameBottomRightOuter := $00208C;
  BtnFrameColor := $00208C;
  BtnSelectedColor := $00208C;
  BtnSelectedFont := clWhite;
  SelectedColor := $00208C;
  SelectedFontColor := clWhite;
  UnusedColor := $191919;
end;

initialization
  ActionMainMenuBarColorMap := TActionMainMenuBarColorMap.Create(nil);
  ActionMainMenuBarStyle := TActionMainMenuBarStyle.Create;

finalization
  FreeAndNil(ActionMainMenuBarStyle);
  FreeAndNil(ActionMainMenuBarColorMap);


end.
