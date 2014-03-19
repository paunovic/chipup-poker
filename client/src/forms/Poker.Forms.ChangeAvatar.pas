unit Poker.Forms.ChangeAvatar;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, Vcl.StdCtrls, cxButtons,
  cxLabel, Vcl.ActnList, cxImage, Vcl.Imaging.jpeg, OverbyteIcsWndControl, OverbyteIcsHttpProt, cxProgressBar,
  dxsChipUpDark, dxsChipUpDarkTabs, dxsChipUpRedButton, Vcl.Menus;

type
  TfrmChangeAvatar = class(TForm)
    lbsInfo: TcxLabel;
    btChange: TcxButton;
    btCancel: TcxButton;
    alChangeAvatar: TActionList;
    acChange: TAction;
    acClose: TAction;
    imgAvatar: TcxImage;
    OpenDialog: TOpenDialog;
    procedure acCloseExecute(Sender: TObject);
    procedure acChangeExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HTTPRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FCallbacksId: Integer;
    FAvatarId : TBytes;
    FAvatarJPG: TJPEGImage;
    FAvatarChanged: Boolean;

    procedure CSRSetAvatar(const AMethodId: Integer; const AObject: TObject);

    procedure UploadAvatar;

  protected
  public
  end;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  PNGImage, Poker.Avatars, Poker.Server.MessageCallbacks, Poker.Protobufs.Objects.SetAvatarReply, Poker.Server.MessageContainer,
  Poker.Protobufs.Enum.ServerCodes, Poker.Server.Socket, Poker.Common.Misc, Poker.Common.Encryption, Poker.Settings,
  Poker.DataModule, Poker.Objects.PlayerInfo, Poker.Common.FormsContainer;


procedure TfrmChangeAvatar.FormCreate(Sender: TObject);
var
  avatar: TAvatar;
begin
  FCallbacksId := MessageContainer.AddCallbacks([
                     TServerMessageCallback.Create(srSetAvatarReply, CSRSetAvatar)
  ]);

  FAvatarJPG := TJPEGImage.Create;

  avatar := Avatars.AddAvatar(dmMain.SelfInfo.AvatarId);
  imgAvatar.Picture.Assign(avatar.Image);
end;

procedure TfrmChangeAvatar.FormDestroy(Sender: TObject);
begin
  FAvatarJPG.Free;

  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.Remove(self);
end;

procedure TfrmChangeAvatar.FormClose(Sender: TObject; var Action: TCloseAction);
begin
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
  http : THTTPcli;
begin
  http := Sender as THttpCli;

  error := '';

  if Assigned(http.SendStream) then
    (http.SendStream as TMemoryStream).Free;

  if Assigned(http.RcvdStream) then
  begin
    {$IFDEF DEBUG} DebugLn(Format('Avatar received. Size: %d', [http.RcvdStream.Size]), ditNetInc); {$ENDIF}
    http.RcvdStream.Position := 0;
    SetLength(FAvatarId, http.RcvdStream.Size);
    Move((http.RcvdStream as TMemoryStream).Memory^, FAvatarId[0], http.RcvdStream.Size);
    (http.RcvdStream as TMemoryStream).Free;
    ServerSocket.SetAvatar(FAvatarId);
  end
  else
    error := 'Invalid response from server';

  if error <> '' then
    MessageDlg(error, mtError, [mbOK], 0);

  http.Free;
end;

procedure TfrmChangeAvatar.acCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmChangeAvatar.UploadAvatar;
var
  send_stream: TMemoryStream;
  http       : THTTPCli;
  boundary   : AnsiString;
  buf        : AnsiString;
begin
  send_stream := TMemoryStream.Create;

  boundary := AnsiString(FormatDateTime('mmddyyhhnnsszzz', Now));
  buf := '--' + boundary + sLineBreak + 'Content-Disposition: form-data; name="avatar" filename="avatar.jpg"' + sLineBreak + 'Content-Type: image/jpeg' + sLineBreak + sLineBreak;
  send_stream.Write(buf[1], Length(buf));
  FAvatarJPG.SaveToStream(send_stream);
  buf := sLineBreak + '--' + boundary + '--' + sLineBreak;
  send_stream.Write(buf[1], Length(buf));

  {$IFDEF DEBUG}  DebugLn(Format('Uploading avatar to server [size: %d]', [send_stream.Size]), ditNetOut);  {$ENDIF}

  send_stream.Position := 0;
  http := THTTPCli.Create(nil);
  http.Connection := 'Keep-Alive';
  http.BandwidthLimit := 0;
  http.RequestVer := '1.1';
  http.URL := Settings.Hardcoded.URL.UPLOAD_AVATAR;
  http.ContentTypePost := Format('multipart/form-data; boundary=%s', [boundary]);
  http.SendStream := send_stream;
  http.RcvdStream := TMemoryStream.Create;
  http.OnRequestDone := HTTPRequestDone;
  http.PostASync;
end;

procedure TfrmChangeAvatar.acChangeExecute(Sender: TObject);
var
  ms     : TMemoryStream;
  fname  : String;
  picture: TPicture;
  bmp    : TBitmap;
  error  : String;
  sha256 : RawByteString;
begin
  if not OpenDialog.Execute(Handle) then
    Exit;

  error := '';
  fname := OpenDialog.FileName;
  if not FileExists(fname) then
    error := 'File doesn''t exist';

  if GetFileSize(fname) > 100 * 1024 then
    error := 'File size is too big';

  if error = '' then
  begin
    picture := TPicture.Create;
    try
      picture.LoadFromFile(fname);
      if (picture.Width > 150) or (picture.Height > 150) then
        error := 'Avatar has dimensions larger than 150x150px'
      else
      begin
        bmp := TBitmap.Create;
        try
          bmp.SetSize(picture.Width, picture.Height);
          bmp.Canvas.Draw(0, 0, picture.Graphic);
          FAvatarJPG.Assign(bmp);
        finally
          bmp.Free;
        end;
      end;
    finally
      picture.Free;
    end;
  end;

  if error = '' then
  begin
    acChange.Enabled := FALSE;
    FAvatarChanged := TRUE;
    ms := TMemoryStream.Create;
    try
      FAvatarJPG.SaveToStream(ms);
      ms.Position := 0;
      sha256 := SHA256Stream(ms);
      SetLength(FAvatarId, Length(sha256));
      Move(sha256[1], FAvatarId[0], Length(sha256));
    finally
      ms.Free;
    end;
    ServerSocket.SetAvatar(FAvatarId);
  end
  else
    MessageDlg(error, mtError, [mbOK], 0);
end;

procedure TfrmChangeAvatar.CSRSetAvatar(const AMethodId: Integer; const AObject: TObject);
var
  avatar     : TAvatar;
  pbreply    : TPB_SetAvatarReply;
  player_info: TPlayerInfo;
begin
  pbreply := AObject as TPB_SetAvatarReply;

  case pbreply.Status of
    saSuccess: begin
      dmMain.SelfInfo.AvatarId := FAvatarId;
      avatar := Avatars.AddAvatar(dmMain.SelfInfo.AvatarId, FAvatarJPG);
      if dmMain.Players.FindPlayerById(dmMain.SelfInfo.Id, player_info) then
        player_info.AvatarId := dmMain.SelfInfo.AvatarId;
      imgAvatar.Picture.Assign(avatar.Image);

      FAvatarChanged := FALSE;
      acChange.Enabled := TRUE;
    end;
    saNotFound: begin
      if FAvatarChanged then
        UploadAvatar
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


