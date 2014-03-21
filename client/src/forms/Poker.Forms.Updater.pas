unit Poker.Forms.Updater;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxsChipUpDark, dxsChipUpDarkTabs, dxsChipUpRedButton, cxLabel, cxProgressBar, dxGDIPlusClasses, cxImage, OverbyteIcsWndControl,
  OverbyteIcsHttpProt, Vcl.Menus, Vcl.StdCtrls, cxButtons, Vcl.ImgList, Vcl.Buttons;

type
  TfrmUpdater = class(TForm)
    pbProgress: TcxProgressBar;
    HttpClient: THttpCli;
    lbsCaption: TcxLabel;
    imgHeader: TcxImage;
    imgClose: TcxImage;
    ImageList: TcxImageList;
    imgMinimize: TcxImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure HttpClientDocData(Sender: TObject; Buffer: Pointer; Len: Integer);
    procedure HttpClientDocEnd(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure imgCloseClick(Sender: TObject);
    procedure imgMinimizeClick(Sender: TObject);
  private
    FUpdaterFile: String;
  protected
    procedure CreateParams(var AParams: TCreateParams); override;
  public
  end;

implementation

{$R *.dfm}

uses
  Poker.Common.Misc, Poker.Common.FormsContainer, Poker.Forms.Main, Poker.Forms.Debug, Poker.Settings, Poker.DataModule;

procedure TfrmUpdater.FormCreate(Sender: TObject);
begin
  FUpdaterFile := AppDataLocalPath + 'install_chipuppoker.exe';
  DeleteFile(FUpdaterFile);

  ImageList.GetImage(0, imgClose.Picture.Bitmap);
  ImageList.GetImage(2, imgMinimize.Picture.Bitmap);

  HttpClient.URL := Settings.Hardcoded.URL.LATEST_VERSION;
  HttpClient.RcvdStream := TFileStream.Create(FUpdaterFile, fmCreate or fmOpenWrite);
  HttpClient.GetASync;
end;

procedure TfrmUpdater.CreateParams(var AParams: TCreateParams);
begin
  inherited;
  AParams.ExStyle := AParams.ExStyle or WS_EX_APPWINDOW;
end;

procedure TfrmUpdater.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(HttpClient.RcvdStream) then
    HttpClient.Abort;

  FormsContainer.Remove(TfrmUpdater);
  frmChipUpMain.CloseUpdated;
  Action := caFree;
end;

procedure TfrmUpdater.imgCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmUpdater.imgMinimizeClick(Sender: TObject);
begin
  WindowState := wsMinimized;
end;

procedure TfrmUpdater.HttpClientDocData(Sender: TObject; Buffer: Pointer; Len: Integer);
var
  perc: Single;
begin
  perc := (HttpClient.RcvdCount / HttpClient.ContentLength) * 100;
  Caption := Format('ChipUP Poker - Updating [%d%%]', [Trunc(perc)]);
  lbsCaption.Caption := Caption;
  pbProgress.Position := Trunc(perc);
end;

procedure TfrmUpdater.HttpClientDocEnd(Sender: TObject);
begin
  if HttpClient.ContentLength = HttpClient.RcvdStream.Size then
    dmMain.UpdaterFile := FUpdaterFile;

  HttpClient.RcvdStream.Free;
  HttpClient.RcvdStream := nil;

  Close;
end;

procedure TfrmUpdater.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
const
  SC_DRAGMOVE = $F012;
begin
  if Button = mbLeft then
  begin
    ReleaseCapture;
    Perform(WM_SYSCOMMAND, SC_DRAGMOVE, 0);
  end;
end;

procedure TfrmUpdater.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  img_close, img_min: Integer;
  cpos              : TPoint;
begin
  cpos := ScreenToClient(Mouse.CursorPos);

  img_close := 0;
  img_min := 2;
  if (cpos.Y >= imgMinimize.Top) and (cpos.Y <= imgMinimize.Top + imgMinimize.Height) then
  begin
    if (cpos.X >= imgMinimize.Left) and (cpos.X <= imgMinimize.Left + imgMinimize.Width) then
      img_min := 3;
    if (cpos.X >= imgClose.Left) and (cpos.X <= imgClose.Left + imgClose.Width) then
      img_close := 1;
  end;

  if imgClose.Tag <> img_close then
  begin
    ImageList.GetImage(img_close, imgClose.Picture.Bitmap);
    imgClose.Tag := img_close;
  end;
  if imgMinimize.Tag <> img_min then
  begin
    ImageList.GetImage(img_min, imgMinimize.Picture.Bitmap);
    imgMinimize.Tag := img_min;
  end;
end;

end.
