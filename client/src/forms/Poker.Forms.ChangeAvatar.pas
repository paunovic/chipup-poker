unit Poker.Forms.ChangeAvatar;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, cxButtons, Vcl.ActnList, cxImage, Vcl.Imaging.jpeg,
  OverbyteIcsHttpProt, cxProgressBar, OverbyteIcsWSocket, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, Vcl.Menus, dxSkinsCore, ChipUPPokerDarkSkin, cxControls,
  cxContainer, cxEdit, OverbyteIcsWndControl, Vcl.StdCtrls;

type
  TfrmChangeAvatar = class(TForm)
    btChange: TcxButton;
    btCancel: TcxButton;
    alChangeAvatar: TActionList;
    acChange: TAction;
    acClose: TAction;
    imgAvatar: TcxImage;
    OpenDialog: TOpenDialog;
    HttpClient: TSslHttpCli;
    SslContext: TSslContext;
    pbUpload: TcxProgressBar;
    procedure acCloseExecute(Sender: TObject);
    procedure acChangeExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HTTPRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure HttpClientSendData(Sender: TObject; Buffer: Pointer; Len: Integer);
  private
    FCallbacksId: Integer;
    FAvatarId: TBytes;
    FAvatarJPG: TJPEGImage;
    FAvatarChanged: Boolean;

    procedure CloseModalCallback(Sender: TObject);
    procedure CSRSetAvatar(const AMethodId: Integer; const AObject: TObject);

    procedure UploadAvatar;
  public
  end;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  PNGImage, Poker.Avatars.Avatar, Poker.Server.MessageCallbacks, Poker.Protobufs.Objects.SetAvatarReply, Poker.Server.MessageContainer,
  Poker.Protobufs.Enum.ServerCodes, Poker.Server.Socket, Poker.Common.Misc, Poker.Common.Encryption, Poker.Settings, Poker.Types,
  Poker.DataModule, Poker.Players.PlayerList, Poker.Common.FormsContainer, Poker.Forms.ImageCrop, Poker.Players.Player, Poker.Avatars.AvatarList,
  Poker.Common.ModalDialogs;


procedure TfrmChangeAvatar.FormCreate(Sender: TObject);
var
  avatar: TAvatar;
begin
  FCallbacksId := MessageContainer.AddCallbacks(self.Name, [
                     TServerMessageCallback.Create(srSetAvatarReply, CSRSetAvatar)
  ]);

  HttpClient.Agent := Format('%s client', [Settings.Hardcoded.PROJECT_CAPTION]);
  HttpClient.RcvdStream := TMemoryStream.Create;

  FAvatarJPG := TJPEGImage.Create;

  avatar := Avatars.Add(dmMain.SelfInfo.Avatar, nil);
  imgAvatar.Picture.Assign(avatar.GetImage);
end;

procedure TfrmChangeAvatar.FormDestroy(Sender: TObject);
begin
  if Assigned(HttpClient.SendStream) then
    HttpClient.SendStream.Free;

  if Assigned(HttpClient.RcvdStream) then
    HttpClient.RcvdStream.Free;

  FAvatarJPG.Free;

  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.Remove(self);
end;

procedure TfrmChangeAvatar.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if HttpClient.State <> httpReady then
  begin
    HttpClient.OnRequestDone := nil;
    HttpClient.Abort;
  end;

  Action := caFree;
end;

procedure TfrmChangeAvatar.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Ord(Key) of
    VK_ESCAPE: begin
      acClose.Execute;
      Key := #0;
    end;
  end;
end;

procedure TfrmChangeAvatar.HTTPRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
var
  error: String;
begin
  error := '';

  if (ErrCode = 0) and
     (HttpClient.StatusCode = 200) and
     (HttpClient.RcvdStream.Size > 0) then
  begin
    HttpClient.RcvdStream.Position := 0;
    SetLength(FAvatarId, HttpClient.RcvdStream.Size);
    Move((HttpClient.RcvdStream as TMemoryStream).Memory^, FAvatarId[0], HttpClient.RcvdStream.Size);
    {$IFDEF DEBUG} DebugLn('Avatar received', ditNetInc, BytesToHex(FAvatarId)); {$ENDIF}
    ServerSocket.SetAvatar(FAvatarId);
  end
  else
    error := 'Invalid response from server';

  if error <> '' then
  begin
    pbUpload.Visible := FALSE;
    ModalDialogs.ShowWarning(error);
    acChange.Enabled := TRUE;
  end;
end;

procedure TfrmChangeAvatar.HttpClientSendData(Sender: TObject; Buffer: Pointer; Len: Integer);
begin
  pbUpload.Position := (HttpClient.SentCount / HttpClient.SendStream.Size) * 100;
end;

procedure TfrmChangeAvatar.acCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmChangeAvatar.UploadAvatar;
var
  boundary: AnsiString;
  buf: AnsiString;
begin
  if not Assigned(HttpClient.SendStream) then
    HttpClient.SendStream := TMemoryStream.Create;

  boundary := AnsiString(FormatDateTime('mmddyyhhnnsszzz', Now));
  buf := '--' + boundary + sLineBreak + 'Content-Disposition: form-data; name="avatar" filename="avatar.jpg"' + sLineBreak + 'Content-Type: image/jpeg' + sLineBreak + sLineBreak;
  HttpClient.SendStream.Write(buf[1], Length(buf));
  FAvatarJPG.SaveToStream(HttpClient.SendStream);
  buf := sLineBreak + '--' + boundary + '--' + sLineBreak;
  HttpClient.SendStream.Write(buf[1], Length(buf));
  HttpClient.SendStream.Position := 0;
  HttpClient.URL := Settings.Hardcoded.SERVER_LIST[Settings.ServerIndex].URL + Settings.Hardcoded.URL.UPLOAD_AVATAR;
  HttpClient.ContentTypePost := Format('multipart/form-data; boundary=%s', [boundary]);
  HttpClient.OnRequestDone := HTTPRequestDone;
  HttpClient.PostASync;

  {$IFDEF DEBUG} DebugLn(Format('Uploading avatar [size: %.2fkb]', [HttpClient.SendStream.Size / 1024]), ditNetOut); {$ENDIF}
end;

procedure TfrmChangeAvatar.acChangeExecute(Sender: TObject);
var
  fname: String;
  error: String;
begin
  if not OpenDialog.Execute(Handle) then
    Exit;

  error := '';
  fname := OpenDialog.FileName;
  if not FileExists(fname) then
    error := 'File doesn''t exist';

  if GetFileSize(fname) > 10 * 1024 * 1024 then
    error := 'File size is too big (must be below 10Mb)';

  if error = '' then
    FormsContainer.Add(RunModalForm(TfrmImageCrop, self, [@fname], CloseModalCallback))
  else
    ModalDialogs.ShowWarning(error);
end;

procedure TfrmChangeAvatar.CloseModalCallback(Sender: TObject);
var
  bmp: TBitmap;
  sha256: RawByteString;
  mstream: TMemoryStream;
  form: TfrmImageCrop;
begin
  if Sender is TfrmImageCrop then
  begin
    form := Sender as TfrmImageCrop;
    if form.ModalResult = mrOk then
    begin
      acChange.Enabled := FALSE;
      FAvatarChanged := TRUE;

      bmp := TBitmap.Create;
      try
        mstream := TMemoryStream.Create;
        try
          if form.NoCrop then
            form.Bitmap.SaveToStream(mstream, TRUE)
          else
            form.SelectionBitmap.SaveToStream(mstream, TRUE);
          mstream.Position := 0;
          bmp.LoadFromStream(mstream);
          FAvatarJPG.Assign(bmp);
        finally
          mstream.Free;
        end;
      finally
        bmp.Free;
      end;

      mstream := TMemoryStream.Create;
      try
        FAvatarJPG.SaveToStream(mstream);
        mstream.Position := 0;
        sha256 := SHA256Stream(mstream);
        SetLength(FAvatarId, Length(sha256));
        Move(sha256[1], FAvatarId[0], Length(sha256));
      finally
        mstream.Free;
      end;
      ServerSocket.SetAvatar(FAvatarId);
    end;
  end;

  EnableWindow(Handle, TRUE);
end;

procedure TfrmChangeAvatar.CSRSetAvatar(const AMethodId: Integer; const AObject: TObject);
var
  avatar: TAvatar;
  pbreply: TPB_SetAvatarReply;
  player_info: TPlayerInfo;
begin
  if not TTypes.TryCast<TPB_SetAvatarReply>(AObject, pbreply) then
    Exit;

  case pbreply.Status of
    saSuccess: begin
      dmMain.SelfInfo.Avatar := FAvatarId;
      avatar := Avatars.Add(dmMain.SelfInfo.Avatar, FAvatarJPG);
      if Players.TryGetValue(dmMain.SelfInfo.MongoId, player_info) then
        player_info.Avatar := dmMain.SelfInfo.Avatar;
      imgAvatar.Picture.Assign(avatar.GetImage);

      FAvatarChanged := FALSE;
      acChange.Enabled := TRUE;
      pbUpload.Visible := FALSE;
    end;
    saNotFound: begin
      if FAvatarChanged then
      begin
        pbUpload.Position := 0;
        pbUpload.Visible := TRUE;
        UploadAvatar;
      end
      else
      begin
        FAvatarChanged := FALSE;
        ModalDialogs.ShowWarning('Invalid avatar ID');
        acChange.Enabled := TRUE;
      end;
    end;
  end;
end;



end.



