unit Poker.Forms.Updater;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  cxLabel, cxProgressBar, dxGDIPlusClasses, cxImage, OverbyteIcsWndControl, OverbyteIcsHttpCCodZlib,
  OverbyteIcsHttpProt, Vcl.Menus, Vcl.StdCtrls, cxButtons, Vcl.ImgList, Vcl.Buttons, Vcl.ExtCtrls, ChipUpPokerDarkSkin;

type
  TfrmUpdater = class(TForm)
    pbProgress: TcxProgressBar;
    HttpClient: THttpCli;
    lbsCaption: TcxLabel;
    imgHeader: TcxImage;
    imgClose: TcxImage;
    imgMinimize: TcxImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure HttpClientDocData(Sender: TObject; Buffer: Pointer; Len: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure imgCloseClick(Sender: TObject);
    procedure imgMinimizeClick(Sender: TObject);
    procedure HttpClientRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FUpdateFileIndex: Integer;
    FUpdateDir: String;
    FQuitMsgPosted: Boolean;
    FTotalSize: UINT32;
    FDownloadedSize: UINT32;
    FCurrentDownloadedSize: UINT32;
    FFullInstaller: Boolean;

    procedure PostQuitMessage;
    function ProcessNextFile: Boolean;
    function StoreDownloadedFile: Boolean;
    function MakeBatchUpdater(out ABatchFile: String): Boolean;
    procedure DownloadFullInstaller;
  protected
    procedure CreateParams(var AParams: TCreateParams); override;
  public
  end;

implementation

{$R *.dfm}

uses
  Poker.Common.Misc, Poker.Common.FormsContainer, Poker.Forms.Main, Poker.Forms.Debug, Poker.Settings, Poker.DataModule,
  Poker.Protobufs.Objects.UpdateFileInfo;


procedure TfrmUpdater.FormCreate(Sender: TObject);
var
  ufi: TPB_UpdateFileInfo;
begin
  dmMain.il20px.GetImage(0, imgClose.Picture.Bitmap);
  dmMain.il20px.GetImage(2, imgMinimize.Picture.Bitmap);

  FUpdateFileIndex := -1;
  HttpClient.RcvdStream := TMemoryStream.Create;

  FUpdateDir := IncludeTrailingPathDelimiter(AppDataPath + IncludeTrailingPathDelimiter('update'));

  FTotalSize := 0;
  FCurrentDownloadedSize := 0;
  for ufi in dmMain.UpdateFiles do
    Inc(FTotalSize, ufi.FileSize);
end;

procedure TfrmUpdater.FormDestroy(Sender: TObject);
var
  obj: TObject;
begin
  obj := HttpClient.RcvdStream;
  HttpClient.RcvdStream := nil;
  (obj as TMemoryStream).Free;

  FormsContainer.Remove(self);
  PostQuitMessage;
end;

procedure TfrmUpdater.CreateParams(var AParams: TCreateParams);
begin
  inherited;
  AParams.ExStyle := AParams.ExStyle or WS_EX_APPWINDOW;
end;

procedure TfrmUpdater.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  HttpClient.OnDocData := nil;
  HttpClient.OnRequestDone := nil;
  HttpClient.ContentCodingHnd.Enabled := FALSE;
  HttpClient.Abort;

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

procedure TfrmUpdater.PostQuitMessage;
begin
  if not FQuitMsgPosted then
  begin
    PostMessage(frmChipUpMain.Handle, WM_QUIT, 0, 0);
    FQuitMsgPosted := TRUE;
  end;
end;

procedure TfrmUpdater.DownloadFullInstaller;
begin
  FFullInstaller := TRUE;
  (HttpClient.RcvdStream as TMemoryStream).Clear;
  HttpClient.URL := Settings.DomainURL + Settings.Hardcoded.URL.LATEST_VERSION;
  HttpClient.GetASync;
end;

function TfrmUpdater.MakeBatchUpdater(out ABatchFile: String): Boolean;
var
  ufi: TPB_UpdateFileInfo;
  ufipath: String;
  newfile: String;
  oldfile: String;
  batch: TStringList;
  res: Boolean;
begin
  batch := TStringList.Create;
  try
    batch.Add('PING 127.0.0.1 -n 2');
    for ufi in dmMain.UpdateFiles do
    begin
      ufipath := StringReplace(ufi.Path, '/', '\', [rfReplaceAll]);
      case ufi.FileType of
        ufRemove: batch.Add(Format('DEL /S /Q "%s"', [SelfPath + ufipath]));
        ufFull, ufDiff: begin
          newfile := FUpdateDir + ufipath;
          if not FileExists(newfile) then
            Exit(FALSE);

          oldfile := SelfPath + ufipath;
          ForceDirectories(ExtractFilePath(oldfile));

          case ufi.FileType of
            ufFull: batch.Add(Format('COPY /Y "%s" "%s"', [newfile, oldfile]));
            ufDiff: batch.Add(Format('bspatch.exe "%s" "%s" "%s"', [oldfile, oldfile, newfile]));
          end;
        end;
      end;
    end;
    batch.Add(Format('START "" "%s"', [ParamStr(0)]));
    batch.Add(Format('RMDIR /S /Q "%s"', [FUpdateDir]));
    ABatchFile := FUpdateDir + 'updater.bat';

    DeleteFile(ABatchFile);
    if FileExists(ABatchFile) then
    begin
      {$IFDEF DEBUG} DebugLn('Error while deleting old batch file', ditApplication); {$ENDIF}
      Exit(FALSE);
    end;

    ForceDirectories(ExtractFilePath(ABatchFile));
    batch.SaveToFile(ABatchFile);
    res := FileExists(ABatchFile);
    {$IFDEF DEBUG}
    if res then
      DebugLn('Batch file saved', ditApplication)
    else
      DebugLn('Error while saving batch file', ditException);
    {$ENDIF}
    Exit(res);
  finally
    batch.Free;
  end;
end;

function TfrmUpdater.StoreDownloadedFile: Boolean;
var
  fname: String;
  res: Boolean;
begin
  fname := FUpdateDir + dmMain.UpdateFiles[FUpdateFileIndex].Path;
  fname := StringReplace(fname, '/', '\', [rfReplaceAll]);
  ForceDirectories(ExtractFilePath(fname));
  DeleteFile(fname);
  if FileExists(fname) then
  begin
    {$IFDEF DEBUG} DebugLn(Format('Error while storing file [%d/%d]: cannot delete old file ', [FUpdateFileIndex + 1, dmMain.UpdateFiles.Count]), ditApplication); {$ENDIF}
    Exit(FALSE);
  end;
  (HttpClient.RcvdStream as TMemoryStream).SaveToFile(fname);
  res := FileExists(fname);
  {$IFDEF DEBUG}
  if res then
    DebugLn(Format('File [%d/%d] saved', [FUpdateFileIndex + 1, dmMain.UpdateFiles.Count]), ditApplication)
  else
    DebugLn(Format('Error while storing file [%d/%d]: cannot save file ', [FUpdateFileIndex + 1, dmMain.UpdateFiles.Count]), ditApplication);
  {$ENDIF}
  Exit(res);
end;

function TfrmUpdater.ProcessNextFile: Boolean;
var
  batch_file: String;
begin
  (HttpClient.RcvdStream as TMemoryStream).Clear;
  Inc(FDownloadedSize, FCurrentDownloadedSize);
  FCurrentDownloadedSize := 0;
  Inc(FUpdateFileIndex);
  if FUpdateFileIndex > dmMain.UpdateFiles.Count - 1 then
  begin
    if MakeBatchUpdater(batch_file) then
    begin
      Close;
      dmMain.SetUpdaterBatchFile(batch_file)
    end
    else
      DownloadFullInstaller;
    Exit(FALSE);
  end
  else
  begin
    case dmMain.UpdateFiles[FUpdateFileIndex].FileType of
      ufRemove: result := ProcessNextFile;
    else
      HttpClient.URL := dmMain.UpdateFiles[FUpdateFileIndex].Url;
      {$IFDEF DEBUG} DebugLn(Format('Downloading update file [%d/%d] [%.2fMB] %s',
        [FUpdateFileIndex + 1, dmMain.UpdateFiles.Count, dmMain.UpdateFiles[FUpdateFileIndex].FileSize / 1024 / 1024, HttpClient.URL]), ditNetInc); {$ENDIF}
      HttpClient.GetASync;
      Exit(TRUE);
    end;
  end;
end;

procedure TfrmUpdater.HttpClientDocData(Sender: TObject; Buffer: Pointer; Len: Integer);
begin
  FCurrentDownloadedSize := Round(HttpClient.RcvdCount / HttpClient.ContentLength * dmMain.UpdateFiles[FUpdateFileIndex].FileSize);

  pbProgress.Position := ((FDownloadedSize + FCurrentDownloadedSize) / FTotalSize) * 100;
  Caption := Format('ChipUP Poker - Updating [%d%%]', [Trunc(pbProgress.Position)]);
  lbsCaption.Caption := Caption;
end;

procedure TfrmUpdater.HttpClientRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
begin
  if (ErrCode = 0) and
     (Assigned(HttpClient.RcvdStream)) then
  begin
    if FFullInstaller then
    begin
      (HttpClient.RcvdStream as TMemoryStream).SaveToFile(AppDataPath + 'install_chipuppoker.exe');
      dmMain.SetUpdaterInstaller(AppDataPath + 'install_chipuppoker.exe');
      Close;
      Exit;
    end;

    if not StoreDownloadedFile then
    begin
      DownloadFullInstaller;
      Exit;
    end;

    ProcessNextFile;
  end;
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
  cpos: TPoint;
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
    dmMain.il20px.GetImage(img_close, imgClose.Picture.Bitmap);
    imgClose.Tag := img_close;
  end;

  if imgMinimize.Tag <> img_min then
  begin
    dmMain.il20px.GetImage(img_min, imgMinimize.Picture.Bitmap);
    imgMinimize.Tag := img_min;
  end;
end;

procedure TfrmUpdater.FormShow(Sender: TObject);
begin
  ProcessNextFile;
end;

end.
