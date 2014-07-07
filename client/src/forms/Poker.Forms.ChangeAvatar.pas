unit Poker.Forms.ChangeAvatar;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  cxButtons,
  Vcl.ActnList, cxImage, Vcl.Imaging.jpeg, OverbyteIcsHttpProt, cxProgressBar,
  OverbyteIcsWSocket, cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, Vcl.Menus, dxSkinsCore, ChipUpPokerDarkSkin, cxControls,
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
    SslHttp: TSslHttpCli;
    SslContext: TSslContext;
    pbUpload: TcxProgressBar;
    procedure acCloseExecute(Sender: TObject);
    procedure acChangeExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HTTPRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SslHttpSendData(Sender: TObject; Buffer: Pointer; Len: Integer);
  private
    FCallbacksId: Integer;
    FAvatarId : TBytes;
    FAvatarJPG: TJPEGImage;
    FAvatarChanged: Boolean;
    {$IFDEF DEBUG} FDebugId: Integer; {$ENDIF}

    procedure CloseModalCallback(Sender: TObject);
    procedure CSRSetAvatar(const AMethodId: Integer; const AObject: TObject);

    procedure UploadAvatar;

  protected
  public
  end;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  PNGImage, Poker.Avatars.Avatar, Poker.Server.MessageCallbacks, Poker.Protobufs.Objects.SetAvatarReply, Poker.Server.MessageContainer,
  Poker.Protobufs.Enum.ServerCodes, Poker.Server.Socket.Commands, Poker.Common.Misc, Poker.Common.Encryption, Poker.Settings,
  Poker.DataModule, Poker.Players.PlayerList, Poker.Common.FormsContainer, Poker.Forms.ImageCrop, Poker.Players.Player, Poker.Avatars.AvatarList;


procedure TfrmChangeAvatar.FormCreate(Sender: TObject);
var
  avatar: TAvatar;
begin
  {$IFDEF DEBUG} FDebugId := RegisterDebugObject(Name); {$ENDIF}

  FCallbacksId := MessageContainer.AddCallbacks([
                     TServerMessageCallback.Create(srSetAvatarReply, CSRSetAvatar)
  ]);

  SslHttp.RcvdStream := TMemoryStream.Create;

  FAvatarJPG := TJPEGImage.Create;

  avatar := Avatars.Add(dmMain.SelfInfo.AvatarId, nil);
  imgAvatar.Picture.Assign(avatar.GetImage);
end;

procedure TfrmChangeAvatar.FormDestroy(Sender: TObject);
begin
  if Assigned(SslHttp.SendStream) then
    SslHttp.SendStream.Free;

  if Assigned(SslHttp.RcvdStream) then
    SslHttp.RcvdStream.Free;

  FAvatarJPG.Free;

  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.Remove(self);

  {$IFDEF DEBUG} UnregisterDebugObject(FDebugId); {$ENDIF}
end;

procedure TfrmChangeAvatar.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if SslHttp.State <> httpReady then
  begin
    SslHttp.OnRequestDone := nil;
    SslHttp.Abort;
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
     (SslHttp.StatusCode = 200) and
     (SslHttp.RcvdStream.Size > 0) then
  begin
    {$IFDEF DEBUG} DebugLn(FDebugId, Format('Avatar received. Size: %d', [SslHttp.RcvdStream.Size]), ditNetInc); {$ENDIF}
    SslHttp.RcvdStream.Position := 0;
    SetLength(FAvatarId, SslHttp.RcvdStream.Size);
    Move((SslHttp.RcvdStream as TMemoryStream).Memory^, FAvatarId[0], SslHttp.RcvdStream.Size);
    ServerSocket.SetAvatar(FAvatarId);
  end
  else
    error := 'Invalid response from server';

  if error <> '' then
  begin
    pbUpload.Visible := FALSE;
    MessageDlg(error, mtError, [mbOK], 0);
    acChange.Enabled := TRUE;
  end;
end;

procedure TfrmChangeAvatar.SslHttpSendData(Sender: TObject; Buffer: Pointer; Len: Integer);
begin
  pbUpload.Position := (SslHttp.SentCount / SslHttp.SendStream.Size) * 100;
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
  if not Assigned(SslHttp.SendStream) then
    SslHttp.SendStream := TMemoryStream.Create;

  boundary := AnsiString(FormatDateTime('mmddyyhhnnsszzz', Now));
  buf := '--' + boundary + sLineBreak + 'Content-Disposition: form-data; name="avatar" filename="avatar.jpg"' + sLineBreak + 'Content-Type: image/jpeg' + sLineBreak + sLineBreak;
  SslHttp.SendStream.Write(buf[1], Length(buf));
  FAvatarJPG.SaveToStream(SslHttp.SendStream);
  buf := sLineBreak + '--' + boundary + '--' + sLineBreak;
  SslHttp.SendStream.Write(buf[1], Length(buf));

  {$IFDEF DEBUG}  DebugLn(FDebugId, Format('Uploading avatar to server [size: %d]', [SslHttp.SendStream.Size]), ditNetOut);  {$ENDIF}

  SslHttp.SendStream.Position := 0;
  SslHttp.URL := Settings.Hardcoded.SERVER_CONFIG[Settings.ServerIndex].URL + Settings.Hardcoded.URL.UPLOAD_AVATAR;
  SslHttp.ContentTypePost := Format('multipart/form-data; boundary=%s', [boundary]);
  SslHttp.OnRequestDone := HTTPRequestDone;
  SslHttp.PostASync;
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

  if GetFileSize(fname) > 5 * 1024 * 1024 then
    error := 'File size is too big (must be below 5Mb)';

  if error = '' then
    FormsContainer.Add(RunModalForm(TfrmImageCrop, self, [@fname], CloseModalCallback))
  else
    MessageDlg(error, mtError, [mbOK], 0);
end;

procedure TfrmChangeAvatar.CloseModalCallback(Sender: TObject);
var
  bmp: TBitmap;
  sha256: RawByteString;
  mstream: TMemoryStream;
begin
  if (Sender is TfrmImageCrop) and
     ((Sender as TfrmImageCrop).ModalResult = mrOk) then
  begin
    acChange.Enabled := FALSE;
    FAvatarChanged := TRUE;

    bmp := TBitmap.Create;
    try
      mstream := TMemoryStream.Create;
      try
        (Sender as TfrmImageCrop).SelectionBitmap.SaveToStream(mstream, TRUE);
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

  EnableWindow(Handle, TRUE);
end;

procedure TfrmChangeAvatar.CSRSetAvatar(const AMethodId: Integer; const AObject: TObject);
var
  avatar: TAvatar;
  pbreply: TPB_SetAvatarReply;
  player_info: TPlayerInfo;
begin
  pbreply := AObject as TPB_SetAvatarReply;

  case pbreply.Status of
    saSuccess: begin
      dmMain.SelfInfo.AvatarId := FAvatarId;
      avatar := Avatars.Add(dmMain.SelfInfo.AvatarId, FAvatarJPG);
      if Players.TryGetValue(dmMain.SelfInfo.Id, player_info) then
        player_info.AvatarId := dmMain.SelfInfo.AvatarId;
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
        MessageDlg('Invalid avatar ID', mtError, [mbOK], 0);
        acChange.Enabled := TRUE;
      end;
    end;
  end;
end;



end.


