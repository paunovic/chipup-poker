unit Poker.Forms.SystemTrayPopup;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  ChipUpPokerDarkSkin, cxImage, cxLabel, dxGDIPlusClasses, Vcl.ExtCtrls, dxBevel;

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
  public
    class procedure ShowPopup(const AText: String);
    class procedure DestroyIfExists;

    property PopupText: String read FPopupText write SetPopupText;
  end;

implementation

{$R *.dfm}

uses
  Poker.DataModule, Poker.Common.Misc;

var
  frmSystemTrayPopup: TfrmSystemTrayPopup;



class procedure TfrmSystemTrayPopup.ShowPopup(const AText: String);
begin
  if not Assigned(frmSystemTrayPopup) then
    frmSystemTrayPopup := RunForm(TfrmSystemTrayPopup, nil, []) as TfrmSystemTrayPopup;
  frmSystemTrayPopup.PopupText := AText;
end;

procedure TfrmSystemTrayPopup.FormCreate(Sender: TObject);
begin
  AlphaBlendValue := 0;
  SetFormSize;

  dmMain.il20px.GetImage(0, imgClose.Picture.Bitmap);
  FPopupText := '';
end;

procedure TfrmSystemTrayPopup.FormDestroy(Sender: TObject);
begin
  frmSystemTrayPopup := nil;
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
  begin
    if AlphaBlendValue + FAlphaBlendStep > 255 then
    begin
      AlphaBlendValue := 255;
      tiAlphaBlend.Enabled := FALSE;
      tiClosePopup.Enabled := FALSE;
      tiClosePopup.Enabled := TRUE;
    end
    else
      AlphaBlendValue := AlphaBlendValue + FAlphaBlendStep;
  end
  else
    if FAlphaBlendStep < 0 then
    begin
      if AlphaBlendValue + FAlphaBlendStep < 0 then
      begin
        AlphaBlendValue := 0;
        tiAlphaBlend.Enabled := FALSE;
        Close;
      end
      else
        AlphaBlendValue := AlphaBlendValue + FAlphaBlendStep;
    end;
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
  maxwidth: Integer;
  minwidth: Integer;
begin
  lbwidth := lbsMessage.Canvas.TextWidth(lbsMessage.Caption);
  minwidth := Screen.Width div 8; // min width is 1/8 of screen width
  maxwidth := Screen.Width div 4; // max width is 1/6 of screen width

  fwidth := lbwidth + 80;
  if fwidth < minwidth then
    fwidth := minwidth
  else
    if fwidth > maxwidth then
      fwidth := maxwidth;

  Width := fwidth;
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
