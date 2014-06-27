unit Poker.Forms.Updater;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, cxGraphics, cxEdit, cxLabel,
  cxProgressBar, cxImage, OverbyteIcsHttpProt, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, dxSkinsCore,
  ChipUpPokerDarkSkin, OverbyteIcsWndControl, dxGDIPlusClasses, Poker.Interfaces.ModalForm;

type
  TfrmUpdater = class(TForm, IModalForm)
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
    FCloseCallback: TNotifyEvent;
    FUpdateFileIndex: Integer;
    FUpdateDir: String;
    FTotalSize: UINT32;
    FDownloadedSize: UINT32;
    FCurrentDownloadedSize: UINT32;
    FFullInstaller: Boolean;
    FRequiresReboot: Boolean;

    function PatchNonRebootFiles: Integer;
    function ProcessNextFile: Boolean;
    function StoreDownloadedFile: Boolean;
    function MakeBatchUpdater(out ABatchFile: String): Integer;
    procedure DownloadFullInstaller;
    procedure DoUpdate;
  protected
    procedure CreateParams(var AParams: TCreateParams); override;
  public
    procedure SetCloseCallback(const ACallback: TNotifyEvent);

    property RequiresReboot: Boolean read FRequiresReboot;
  end;

implementation

{$R *.dfm}

uses
  Poker.Common.FormsContainer, Poker.Forms.Main, Poker.Forms.Debug, Poker.Settings, Poker.DataModule, Poker.Protobufs.Objects.UpdateFileInfo,
  Poker.Common.Misc, Poker.HardcodedSettings, Winapi.ShellApi;


procedure TfrmUpdater.FormCreate(Sender: TObject);
var
  ufi: TPB_UpdateFileInfo;
begin
  dmMain.il20px.GetImage(0, imgClose.Picture.Bitmap);
  dmMain.il20px.GetImage(2, imgMinimize.Picture.Bitmap);

  FUpdateFileIndex := -1;
  HttpClient.RcvdStream := TMemoryStream.Create;

  FUpdateDir := IncludeTrailingPathDelimiter(TempPath + IncludeTrailingPathDelimiter('chipuppoker_update'));

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

  if Assigned(FCloseCallback) then
    FCloseCallback(self);
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
  if HttpClient.State <> httpReady then
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

function TfrmUpdater.PatchNonRebootFiles: Integer;
{
  1 - success
  2 - fatal error
}
var
  ufi: TPB_UpdateFileInfo;
  requires_reboot: Boolean;
  update_file: TUpdateFile;
  ufipath: String;
  newfile, oldfile: String;
  exec_info: TShellExecuteInfo;
begin
  result := 1;

  for ufi in dmMain.UpdateFiles do
  begin
    requires_reboot := TRUE;
    for update_file in Settings.Hardcoded.UPDATE_FILES do
      if LowerCase(update_file.Path) = LowerCase(ufi.Path) then
      begin
        requires_reboot := update_file.RequiresReboot;
        Break;
      end;

    if not requires_reboot then
    begin
      ufipath := StringReplace(ufi.Path, '/', '\', [rfReplaceAll]);
      case ufi.FileType of
        ufFull, ufDiff: begin
          newfile := FUpdateDir + ufipath;
          if not FileExists(newfile) then
            Exit(2);

          oldfile := SelfPath + ufipath;
          ForceDirectories(ExtractFilePath(oldfile));

          case ufi.FileType of
            ufFull: CopyFile(PChar(newfile), PChar(oldfile), FALSE);
            ufDiff: begin
              if ShellOpen(PChar(SelfPath + 'bspatch.exe'), @exec_info, PChar(Format('"%s" "%s" "%s"', [oldfile, oldfile, newfile])), nil, SW_HIDE) then
                WaitForSingleObject(exec_info.hProcess, INFINITE)
              else
                Exit(2);
            end;
          end;
        end;
        ufRemove: DeleteFile(SelfPath + ufipath);
      end;
    end;
  end;
end;

procedure TfrmUpdater.DoUpdate;
var
  batch_file: String;
  pnr_res, mbu_res: Integer;
begin
  pnr_res := PatchNonRebootFiles;
  mbu_res := MakeBatchUpdater(batch_file);
  if (pnr_res = 2) or
     (mbu_res = 2) then
    DownloadFullInstaller;

  FRequiresReboot := mbu_res = 1;
  if FRequiresReboot then
    dmMain.SetUpdaterBatchFile(batch_file);
  Close;
end;

procedure TfrmUpdater.DownloadFullInstaller;
begin
  FFullInstaller := TRUE;
  (HttpClient.RcvdStream as TMemoryStream).Clear;
  HttpClient.URL := DomainURL + Settings.Hardcoded.URL.LATEST_VERSION;
  HttpClient.GetASync;
end;

function TfrmUpdater.MakeBatchUpdater(out ABatchFile: String): Integer;
{
  0 - no files to patch
  1 - success
  2 - fatal error
}
var
  ufi: TPB_UpdateFileInfo;
  update_file: TUpdateFile;
  ufipath: String;
  newfile: String;
  oldfile: String;
  batch: TStringList;
  requires_reboot: Boolean;
begin
  result := 0;
  batch := TStringList.Create;
  try
    batch.Add('PING 127.0.0.1 -n 2');
    for ufi in dmMain.UpdateFiles do
    begin
      requires_reboot := TRUE;
      for update_file in Settings.Hardcoded.UPDATE_FILES do
        if LowerCase(update_file.Path) = LowerCase(ufi.Path) then
        begin
          requires_reboot := update_file.RequiresReboot;
          Break;
        end;

      if not requires_reboot then
        Continue;

      ufipath := StringReplace(ufi.Path, '/', '\', [rfReplaceAll]);
      case ufi.FileType of
        ufRemove: batch.Add(Format('DEL /S /Q "%s"', [SelfPath + ufipath]));
        ufFull, ufDiff: begin
          newfile := FUpdateDir + ufipath;
          if not FileExists(newfile) then
            Exit(2);

          oldfile := SelfPath + ufipath;
          ForceDirectories(ExtractFilePath(oldfile));

          case ufi.FileType of
            ufFull: batch.Add(Format('COPY /Y "%s" "%s"', [newfile, oldfile]));
            ufDiff: batch.Add(Format('bspatch.exe "%s" "%s" "%s"', [oldfile, oldfile, newfile]));
          end;
        end;
      end;
      result := 1;
    end;

    if result = 0 then
      Exit;

    batch.Add(Format('START "" "%s"', [ParamStr(0)]));
    batch.Add(Format('RMDIR /S /Q "%s"', [FUpdateDir]));
    ABatchFile := FUpdateDir + 'updater.bat';

    DeleteFile(ABatchFile);
    if FileExists(ABatchFile) then
    begin
      {$IFDEF DEBUG} DebugLn('Error while deleting old batch file', ditException); {$ENDIF}
      Exit(2);
    end;

    ForceDirectories(ExtractFilePath(ABatchFile));
    batch.SaveToFile(ABatchFile);
    if FileExists(ABatchFile) then
    begin
      result := 1;
      {$IFDEF DEBUG} DebugLn('Batch file saved', ditApplication); {$ENDIF}
    end
    else
    begin
      result := 2;
      {$IFDEF DEBUG} DebugLn('Error while saving batch file', ditException); {$ENDIF}
    end;
  finally
    batch.Free;
  end;
end;

procedure TfrmUpdater.SetCloseCallback(const ACallback: TNotifyEvent);
begin
  FCloseCallback := ACallback;
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
    {$IFDEF DEBUG} DebugLn(Format('Error while storing file [%d/%d]: cannot delete old file ', [FUpdateFileIndex + 1, dmMain.UpdateFiles.Count]), ditException); {$ENDIF}
    Exit(FALSE);
  end;
  (HttpClient.RcvdStream as TMemoryStream).SaveToFile(fname);
  res := FileExists(fname);
  {$IFDEF DEBUG}
  if res then
    DebugLn(Format('File [%d/%d] saved', [FUpdateFileIndex + 1, dmMain.UpdateFiles.Count]), ditApplication)
  else
    DebugLn(Format('Error while storing file [%d/%d]: cannot save file ', [FUpdateFileIndex + 1, dmMain.UpdateFiles.Count]), ditException);
  {$ENDIF}
  Exit(res);
end;

function TfrmUpdater.ProcessNextFile: Boolean;
begin
  (HttpClient.RcvdStream as TMemoryStream).Clear;
  Inc(FDownloadedSize, FCurrentDownloadedSize);
  FCurrentDownloadedSize := 0;
  Inc(FUpdateFileIndex);
  if FUpdateFileIndex > dmMain.UpdateFiles.Count - 1 then
  begin
    DoUpdate;
    Exit(FALSE);
  end
  else
  begin
    case dmMain.UpdateFiles[FUpdateFileIndex].FileType of
      ufRemove: result := ProcessNextFile;
    else
      HttpClient.URL := dmMain.UpdateFiles[FUpdateFileIndex].Url;
      {$IFDEF DEBUG} DebugLn(Format('Downloading update file [%d/%d] [%s] [%.2fMB] %s',
          [FUpdateFileIndex + 1, dmMain.UpdateFiles.Count, dmMain.UpdateFiles[FUpdateFileIndex].Path,
           dmMain.UpdateFiles[FUpdateFileIndex].FileSize / 1024 / 1024, HttpClient.URL]), ditNetInc); {$ENDIF}
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
      (HttpClient.RcvdStream as TMemoryStream).SaveToFile(TempPath + 'install_chipuppoker.exe');
      dmMain.SetUpdaterInstaller(TempPath + 'install_chipuppoker.exe');
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
