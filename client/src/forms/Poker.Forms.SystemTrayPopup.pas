unit Poker.Forms.SystemTrayPopup;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  cxGraphics, cxControls, cxEdit, cxImage, cxLabel, Vcl.ExtCtrls, dxBevel, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, dxSkinsCore, ChipUPPokerDarkSkin, dxGDIPlusClasses;

type
  TfrmSystemTrayPopup = class(TForm)
    imgClose: TcxImage;
    imgHeader: TcxImage;
    lbsMessage: TcxLabel;
    tiAlphaBlend: TTimer;
    tiClosePopup: TTimer;
    Bevel1: TdxBevel;
    tiCursorCheck: TTimer;
    lbsCaption: TcxLabel;
    procedure FormCreate(Sender: TObject);
    procedure tiAlphaBlendTimer(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure imgCloseClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure tiClosePopupTimer(Sender: TObject);
    procedure tiCursorCheckTimer(Sender: TObject);
  private
    FPopupText: String;
    FAlphaBlendStep: Integer;

    procedure SetPopupText(const AValue: String);
    procedure SetFormSize;
    procedure ClosePopup;
  protected
    procedure CreateParams(var AParams: TCreateParams); override;
  public
    class procedure ShowPopup(const AText: String);
    class procedure DestroyIfExists;

    property PopupText: String read FPopupText write SetPopupText;
  end;

implementation

{$R *.dfm}

uses
  Poker.DataModule, Poker.Common.Misc, Poker.Common.FormsContainer, Poker.Settings;

var
  frmSystemTrayPopup: TfrmSystemTrayPopup;


class procedure TfrmSystemTrayPopup.ShowPopup(const AText: String);
begin
  if not Assigned(frmSystemTrayPopup) then
    frmSystemTrayPopup := RunForm(TfrmSystemTrayPopup, nil, [], TRUE) as TfrmSystemTrayPopup;
  frmSystemTrayPopup.PopupText := AText;
end;

procedure TfrmSystemTrayPopup.FormCreate(Sender: TObject);
begin
  AlphaBlendValue := 0;
  SetFormSize;

  lbsCaption.Caption := Settings.Hardcoded.PROJECT_CAPTION;

  dmMain.il20px.GetImage(0, imgClose.Picture.Bitmap);
  FPopupText := '';
end;

procedure TfrmSystemTrayPopup.FormDestroy(Sender: TObject);
begin
  frmSystemTrayPopup := nil;
end;

procedure TfrmSystemTrayPopup.CreateParams(var AParams: TCreateParams);
begin
  inherited;

  AParams.ExStyle := AParams.ExStyle or WS_EX_TOOLWINDOW or WS_EX_NOACTIVATE;
  AParams.WndParent := 0;
end;

class procedure TfrmSystemTrayPopup.DestroyIfExists;
begin
  if Assigned(frmSystemTrayPopup) then
    FreeAndNil(frmSystemTrayPopup);
end;

procedure TfrmSystemTrayPopup.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmSystemTrayPopup.ClosePopup;
begin
  FAlphaBlendStep := -10;
  tiAlphaBlend.Enabled := TRUE;
  tiClosePopup.Enabled := FALSE;
end;

procedure TfrmSystemTrayPopup.tiAlphaBlendTimer(Sender: TObject);
begin
  if FAlphaBlendStep > 0 then
    if AlphaBlendValue + FAlphaBlendStep > 255 then
    begin
      AlphaBlendValue := 255;
      tiAlphaBlend.Enabled := FALSE;
      tiClosePopup.Enabled := FALSE;
      tiClosePopup.Enabled := TRUE;
    end
    else
      AlphaBlendValue := AlphaBlendValue + FAlphaBlendStep
  else
    if FAlphaBlendStep < 0 then
      if AlphaBlendValue + FAlphaBlendStep < 0 then
      begin
        AlphaBlendValue := 0;
        tiAlphaBlend.Enabled := FALSE;
        Close;
      end
      else
        AlphaBlendValue := AlphaBlendValue + FAlphaBlendStep;
end;

procedure TfrmSystemTrayPopup.tiClosePopupTimer(Sender: TObject);
begin
  ClosePopup;
end;

procedure TfrmSystemTrayPopup.tiCursorCheckTimer(Sender: TObject);
begin
  imgClose.Visible := PtInRect(Rect(Left, Top, Left + Width, Top + Width), Mouse.CursorPos);
end;

procedure TfrmSystemTrayPopup.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  img_close: Integer;
  cpos: TPoint;
begin
  cpos := ScreenToClient(Mouse.CursorPos);

  img_close := 0;
  if PtInRect(Rect(imgClose.Left, imgClose.Top, imgClose.Left + imgClose.Width, imgClose.Top + imgClose.Height), cpos) then
    img_close := 1;

  if imgClose.Tag <> img_close then
  begin
    dmMain.il20px.GetImage(img_close, imgClose.Picture.Bitmap);
    imgClose.Tag := img_close;
  end;
end;

procedure TfrmSystemTrayPopup.imgCloseClick(Sender: TObject);
begin
  ClosePopup;
end;

procedure TfrmSystemTrayPopup.SetFormSize;
var
  lbwidth: Integer;
  fwidth: Integer;
  fheight: Integer;
  minwidth: Integer;
  lines: Integer;
  sl: TStringList;
  C1: Integer;
begin
  minwidth := Screen.Width div 8; // min width is 1/8 of screen width

  sl := TStringList.Create;
  try
    sl.Text := FPopupText;
    lines := sl.Count;

    fheight := lines * lbsMessage.Canvas.TextHeight(lbsMessage.Caption) + 45;

    fwidth := minwidth;
    for C1 := 0 to sl.Count - 1 do
    begin
      lbwidth := lbsMessage.Canvas.TextWidth(sl[C1]);
      if lbwidth + 80 > fwidth then
        fwidth := lbwidth + 80;
    end;
  finally
    sl.Free;
  end;

  Width := fwidth;
  Height := fheight;
  Left := Screen.Width - Width - 5;
  Top := Screen.Height - GetTaskbarHeight - Height - 3;
end;

procedure TfrmSystemTrayPopup.SetPopupText(const AValue: String);
begin
  tiClosePopup.Enabled := FALSE;
  FPopupText := AValue;
  lbsMessage.Caption := FPopupText;
  SetFormSize;
  FAlphaBlendStep := 15;
  tiAlphaBlend.Enabled := TRUE;
end;

end.

