unit Poker.ActionMainMenuBarStyle;

interface

uses
  System.Types, Vcl.ActnMan, Vcl.ActnMenus, Vcl.XPActnCtrls, Vcl.XPStyleActnCtrls, Vcl.GraphUtil;

type
  TBarStyle = class(TXPStyleActionBars)
  public
    function GetControlClass(ActionBar: TCustomActionBar; AnItem: TActionClientItem): TCustomActionControlClass; override;
  end;

  TMenuStyle = class(TXPStyleMenuitem)
  protected
    procedure DrawSeparator(const Offset: Integer); override;
    procedure DrawGlyph(const Location: TPoint); override;
  public
    procedure CalcBounds; override;
  end;

var
  ActionMainMenuBarStyle: TBarStyle;

implementation

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.ActnList, Vcl.Graphics, Vcl.ImgList, System.UITypes;

{ TBarStyle }

function TBarStyle.GetControlClass(ActionBar: TCustomActionBar; AnItem: TActionClientItem): TCustomActionControlClass;
begin
  result := inherited GetControlClass(ActionBar, AnItem);
  if ActionBar is TCustomActionPopupMenu then
    result := TMenuStyle;
end;

{ TMenuStyle }

procedure TMenuStyle.CalcBounds;
begin
  inherited;

  if not Assigned(ActionClient) then
    Exit;

  if (ActionClient.HasItems) or
     ((ActionClient.Action is TCustomAction) and
      ((ActionClient.Action as TCustomAction).GroupIndex = 0)) then
    TextBounds.Offset(-16, 0)
  else
    TextBounds.Offset(-7, 0);
end;

procedure TMenuStyle.DrawGlyph(const Location: TPoint);
var
  OldColor, OldBrushColor: TColor;
  NewLocation: TPoint;
  FrameRect: TRect;
  SelBmp: TBitmap;
  ImageList: TCustomImageList;
begin
  if (Assigned(ActionClient) and not ActionClient.HasGlyph) and
     ((Action is TCustomAction) and TCustomAction(Action).Checked) then
  begin
    Canvas.Pen.Color := ActionBar.ColorMap.FontColor;
    with Location do
      DrawCheck(Canvas, Point(X + 5, Y + 2), 2)
  end
  else
  begin
    if IsChecked then
    begin
      FrameRect := System.Types.Rect(Location.X - 1, 1,
        Location.X + 20, Self.Height - 1);
      Canvas.Brush.Color := Menu.ColorMap.SelectedColor;
      Canvas.Pen.Color := ActionBar.ColorMap.BtnFrameColor;
      Canvas.Rectangle(FrameRect);
    end;
    OldColor := Canvas.Brush.Color;
    if (Selected and Enabled) or (Selected and not MouseSelected) then
      Canvas.Brush.Color := Menu.ColorMap.SelectedColor
    else
      Canvas.Brush.Color := Menu.ColorMap.ShadowColor;
    NewLocation := Location;

    if (Selected and Enabled and ActionClient.HasGlyph) then
    begin
      OldBrushColor := Canvas.Brush.Color;
      SelBmp := TBitmap.Create;
      try
        ImageList := FindImageList(False, ActionClient.ImageIndex);
        if Assigned(ImageList) then
        begin
          Canvas.Brush.Color := GetShadowColor(Menu.ColorMap.SelectedColor);
          SelBmp.Width := ImageList.Width;
          SelBmp.Height := ImageList.Width;

          SelBmp.Canvas.FillRect(SelBmp.Canvas.ClipRect);

          if ImageList.ColorDepth = cdDeviceDependent then
            ImageList.Draw(SelBmp.Canvas, 0, 0, ActionClient.ImageIndex, dsNormal, itMask)
          else
            ImageList.Draw( SelBmp.Canvas, 0, 0, ActionClient.ImageIndex);


          DrawState(Canvas.Handle, Canvas.Brush.Handle, nil, LPARAM(SelBmp.Handle), 0,
            NewLocation.X + 3, NewLocation.Y + 2, 0, 0, DST_BITMAP or DSS_MONO);
        end;
      finally
        SelBmp.Free;
        Canvas.Brush.Color := OldBrushColor;
      end;

      Inc(NewLocation.X, 1);
      inherited DrawGlyph(NewLocation);
    end
    else begin
      Inc(NewLocation.X, 2);
      Inc(NewLocation.Y, 1);
      inherited DrawGlyph(NewLocation);
    end;
    Canvas.Brush.Color := OldColor;
  end;
end;

procedure TMenuStyle.DrawSeparator(const Offset: Integer);
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

initialization
  ActionMainMenuBarStyle := TBarStyle.Create;

finalization
  FreeAndNil(ActionMainMenuBarStyle);


end.
