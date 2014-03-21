unit Poker.Forms.Updater;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxsChipUpDark, dxsChipUpDarkTabs, dxsChipUpRedButton, cxLabel, cxProgressBar, dxGDIPlusClasses, cxImage, OverbyteIcsWndControl,
  OverbyteIcsHttpProt;

type
  TfrmUpdater = class(TForm)
    pbProgress: TcxProgressBar;
    imgHeader: TcxImage;
    HttpClient: THttpCli;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure HttpClientDocData(Sender: TObject; Buffer: Pointer; Len: Integer);
    procedure HttpClientDocEnd(Sender: TObject);
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

procedure TfrmUpdater.HttpClientDocData(Sender: TObject; Buffer: Pointer; Len: Integer);
var
  perc: Single;
begin
  perc := (HttpClient.RcvdCount / HttpClient.ContentLength) * 100;
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


end.
