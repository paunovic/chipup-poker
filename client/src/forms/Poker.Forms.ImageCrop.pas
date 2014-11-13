unit Poker.Forms.ImageCrop;

interface

uses
  Winapi.Windows, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Poker.Interfaces.ModalForm, Poker.Interfaces.FormParams,
  Vcl.ActnList, cxButtons,
  GR32_Image, GR32, GR32_backends, GR32_Resamplers, cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, Vcl.Menus, dxSkinsCore,
  ChipUpPokerDarkSkin, Vcl.StdCtrls;

const
   PixelCountMax = 32768;

type
  PRGBTripleArray = ^TRGBTripleArray;
  TRGBTripleArray = array[0..PixelCountMax-1] of TRGBTriple;

  TfrmImageCrop = class(TForm, IFormParams, IModalForm)
    btOK: TcxButton;
    btCancel: TcxButton;
    ActionList: TActionList;
    acOK: TAction;
    acCancel: TAction;
    PaintBox: TPaintBox32;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure acOKExecute(Sender: TObject);
    procedure acCancelExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FUnselectedBitmap: TBitmap32;
    FBitmap: TBitmap32;
    FSelectionBitmap: TBitmap32;
    FSelectionRect: TRect;
    FImageX, FImageY: Integer;
    FCloseCallback: TNotifyEvent;
    FInitialX, FInitialY: Integer;
    FMouseDown: TCursor;

    procedure SetSelectionRect(const AX1, AY1, AX2, AY2: Integer);

  public
    procedure SetParams(const AParams: array of pointer);
    procedure SetCloseCallback(const ACallback: TNotifyEvent);

    property SelectionBitmap: TBitmap32 read FSelectionBitmap;
  end;

implementation

uses
  Poker.Common.FormsContainer, Poker.Common.Misc, Poker.Common.ModalDialogs;

{$R *.dfm}

procedure DarkenImage(const ASource: TBitmap32; const APercent: Single);

  function Lerp(a, b: Byte; t: Double): Byte;
  var
    tmp: Double;
  begin
    tmp := t*a + (1-t)*b;
    if tmp < 0 then
      result := 0
    else
      if tmp > 255 then
        result := 255
      else
        result := Round(tmp);
  end;

var
  Bits: PColor32Entry;
  Color: TColor32Entry;
  I, J: Integer;
begin
  Color.ARGB := Color32(clBlack);
  Bits := @ASource.Bits[0];

  for I := 0 to ASource.Height - 1 do
  begin
    for J := 0 to ASource.Width - 1 do
    begin
      Bits.R := Lerp(Bits.R, (Color.R * Bits.R) div 255, APercent);
      Bits.G := Lerp(Bits.G, (Color.G * Bits.G) div 255, APercent);
      Bits.B := Lerp(Bits.B, (Color.B * Bits.B) div 255, APercent);

      Inc(Bits);
    end;
  end;

  ASource.Changed;
end;

{ TfrmImageCrop }

procedure TfrmImageCrop.FormCreate(Sender: TObject);
begin
  FBitmap := TBitmap32.Create;
  FBitmap.Resampler := TKernelResampler.Create;
  (FBitmap.Resampler as TKernelResampler).Kernel := TLanczosKernel.Create;

  FUnselectedBitmap := TBitmap32.Create;
  FUnselectedBitmap.Resampler := TKernelResampler.Create;
  (FUnselectedBitmap.Resampler as TKernelResampler).Kernel := TLanczosKernel.Create;

  FSelectionBitmap := TBitmap32.Create;
  FSelectionBitmap.Resampler := TKernelResampler.Create;
  (FSelectionBitmap.Resampler as TKernelResampler).Kernel := TLanczosKernel.Create;
end;

procedure TfrmImageCrop.FormDestroy(Sender: TObject);
begin
  FUnselectedBitmap.Free;
  FBitmap.Free;
  FSelectionBitmap.Free;
  FormsContainer.Remove(self);
end;

procedure TfrmImageCrop.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    vk_RETURN: acOK.Execute;
    vk_ESCAPE: acCancel.Execute;
  end;
end;

procedure TfrmImageCrop.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;

  if Assigned(FCloseCallback) then
    FCloseCallback(self);
end;

procedure TfrmImageCrop.SetCloseCallback(const ACallback: TNotifyEvent);
begin
  FCloseCallback := ACallback;
end;

procedure TfrmImageCrop.SetParams(const AParams: array of pointer);
var
  rs: Integer;
  pic: TPicture;
  w, h: Integer;
begin
  pic := TPicture.Create;
  try
    pic.LoadFromFile(PString(AParams[0])^);
    FBitmap.SetSize(pic.Width, pic.Height);
    FBitmap.Canvas.Draw(0, 0, pic.Graphic);
  finally
    pic.Free;
  end;

  w := FBitmap.Width + PaintBox.Margins.Left + PaintBox.Margins.Right;
  h := FBitmap.Height + PaintBox.Margins.Top + PaintBox.Margins.Bottom;
  if w > Screen.Width then
    w := Screen.Width;
  if h > Screen.Height then
    h := Screen.Height;

  ClientWidth := w;
  ClientHeight := h;

  FImageX := Trunc((PaintBox.Width - FBitmap.Width) / 2);
  FImageY := Trunc((PaintBox.Height - FBitmap.Height) / 2);

  FUnselectedBitmap.Assign(FBitmap);
  DarkenImage(FUnselectedBitmap, 0.5);

  if FBitmap.Width < FBitmap.Height then
    rs := FBitmap.Width
  else
    rs := FBitmap.Height;

  if rs * 0.8 >= 150 then
    rs := Round(rs * 0.8);

  SetSelectionRect(FImageX, FImageY, FImageX + rs, FImageY + rs);
end;

procedure TfrmImageCrop.SetSelectionRect(const AX1, AY1, AX2, AY2: Integer);
var
  diff: Integer;
begin
  FSelectionRect := Rect(AX1, AY1, AX2, AY2);
  FSelectionRect.NormalizeRect;

  if FSelectionRect.Width > FSelectionRect.Height then
  begin
    diff := FSelectionRect.Width - FSelectionRect.Height;
    FSelectionRect.Width := FSelectionRect.Height;
    if AX1 > AX2 then
      FSelectionRect.Offset(diff, 0);
  end
  else
    if FSelectionRect.Height > FSelectionRect.Width then
    begin
      diff := FSelectionRect.Height - FSelectionRect.Width;
      FSelectionRect.Height := FSelectionRect.Width;
      if AY1 > AY2 then
        FSelectionRect.Offset(0, diff);
    end;

  if FSelectionRect.Right > FImageX + FUnselectedBitmap.Width then
  begin
    diff := FSelectionRect.Right - (FImageX + FUnselectedBitmap.Width);

    if AY1 > AY2 then
    begin
      FSelectionRect.Width := FSelectionRect.Width - diff;
      FSelectionRect.Height := FSelectionRect.Height - diff;
      FSelectionRect.Offset(0, diff)
    end
    else
    begin
      FSelectionRect.Width := FSelectionRect.Width - diff;
      FSelectionRect.Height := FSelectionRect.Height - diff;
    end;
  end;

  if FSelectionRect.Left < FImageX then
  begin
    diff := FImageX - FSelectionRect.Left;

    if AY1 > AY2 then
    begin
      FSelectionRect.Width := FSelectionRect.Width - diff;
      FSelectionRect.Height := FSelectionRect.Height - diff;
      FSelectionRect.Offset(diff, diff)
    end
    else
    begin
      FSelectionRect.Width := FSelectionRect.Width - diff;
      FSelectionRect.Height := FSelectionRect.Height - diff;
      FSelectionRect.Offset(diff, 0)
    end;
  end;

  if FSelectionRect.Top < FImageY then
  begin
    diff := FImageY - FSelectionRect.Top;

    if AX1 > AX2 then
    begin
      FSelectionRect.Width := FSelectionRect.Width - diff;
      FSelectionRect.Height := FSelectionRect.Height - diff;
      FSelectionRect.Offset(diff, diff)
    end
    else
    begin
      FSelectionRect.Width := FSelectionRect.Width - diff;
      FSelectionRect.Height := FSelectionRect.Height - diff;
      FSelectionRect.Offset(0, diff)
    end;
  end;

  if FSelectionRect.Bottom > FImageY + FUnselectedBitmap.Height then
  begin
    diff := FSelectionRect.Bottom - (FImageY + FUnselectedBitmap.Height);

    if AX1 > AX2 then
    begin
      FSelectionRect.Width := FSelectionRect.Width - diff;
      FSelectionRect.Height := FSelectionRect.Height - diff;
      FSelectionRect.Offset(diff, 0)
    end
    else
    begin
      FSelectionRect.Width := FSelectionRect.Width - diff;
      FSelectionRect.Height := FSelectionRect.Height - diff;
    end;
  end;

  FSelectionBitmap.SetSize(FSelectionRect.Width, FSelectionRect.Height);
  if (FSelectionRect.Width > 0) and (FSelectionRect.Height > 0) then
    FSelectionBitmap.Canvas.CopyRect(Rect(0, 0, FSelectionRect.Width, FSelectionRect.Height), FBitmap.Canvas, Rect(FSelectionRect.Left - FImageX, FSelectionRect.Top - FImageY, FSelectionRect.Right - FImageX, FSelectionRect.Bottom - FImageY));

  Repaint;
end;

procedure TfrmImageCrop.FormPaint(Sender: TObject);
begin
  PaintBox.Buffer.Draw(FImageX, FImageY, FUnselectedBitmap);
  PaintBox.Buffer.Draw(FSelectionRect.Left, FSelectionRect.Top, FSelectionBitmap);
  PaintBox.Buffer.FrameRectS(FSelectionRect.Left, FSelectionRect.Top, FSelectionRect.Right, FSelectionRect.Bottom, clMaroon32);
  PaintBox.Flush;
end;

procedure TfrmImageCrop.PaintBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FInitialX := X;
    FInitialY := Y;

    FMouseDown := PaintBox.Cursor;
    if FMouseDown = crCross then
    begin
      SetSelectionRect(FInitialX, FInitialY, FInitialX, FInitialY);
    end;
  end;
end;

procedure TfrmImageCrop.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  bx, by: Integer;
  rect_inner: TRect;
begin
  case FMouseDown of
    crCross: begin
      SetSelectionRect(FInitialX, FInitialY, X, Y);
    end;

    crSizeAll: begin
      bx := FSelectionRect.Left + (X - FInitialX);
      by := FSelectionRect.Top + (Y - FInitialY);
      if bx < FImageX then
        bx := FImageX;
      if by < FImageY then
        by := FImageY;
      if bx > FImageX + FUnselectedBitmap.Width - FSelectionRect.Width then
        bx := FImageX + FUnselectedBitmap.Width - FSelectionRect.Width;
      if by > FImageY + FUnselectedBitmap.Height - FSelectionRect.Height then
        by := FImageY + FUnselectedBitmap.Height - FSelectionRect.Height;

      SetSelectionRect(bx, by, bx + FSelectionRect.Width, by + FSelectionRect.Height);
      FInitialX := X;
      FInitialY := Y;
    end;
  else
    rect_inner := FSelectionRect;
    rect_inner.Inflate(-8, -8);
    if PtInRect(FSelectionRect, Point(X, Y)) then
      PaintBox.Cursor := crSizeAll
    else
      PaintBox.Cursor := crCross;
  end;
end;

procedure TfrmImageCrop.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    FMouseDown := 0;
end;

procedure TfrmImageCrop.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
  Close;
end;

procedure TfrmImageCrop.acOKExecute(Sender: TObject);
begin
  if (FSelectionBitmap.Width = 0) or
     (FSelectionBitmap.Height = 0) then
  begin
    ModalDialogs.ShowWarning('Please make a selection');
    Exit;
  end;

  ModalResult := mrOk;
  Close;
end;

end.
