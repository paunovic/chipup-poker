unit uLoginForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Dialogs,
  Vcl.Controls, Vcl.Forms, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  Vcl.Menus, cxGraphics, dxSkinsdxStatusBarPainter, dxSkinsForm, Vcl.ExtCtrls, Vcl.ActnList, dxStatusBar, cxLabel, cxTextEdit, Vcl.StdCtrls,
  cxButtons, cxCheckBox, OverbyteIcsWSocket, uMessageItem, dxSkinDarkRoom;

type
  TfrmLogin = class(TForm)
    alLogin: TActionList;
    acLogin: TAction;
    acShowCreateAccountForm: TAction;
    acShowForgotPasswordForm: TAction;
    cbRememberLogin: TcxCheckBox;
    cbRememberPassword: TcxCheckBox;
    btLogin: TcxButton;
    btCreateAccount: TcxButton;
    btForgotPassword: TcxButton;
    edLogin: TcxTextEdit;
    edPassword: TcxTextEdit;
    lbsLogin: TcxLabel;
    lbsPassword: TcxLabel;
    StatusBar: TdxStatusBar;
    SkinController: TdxSkinController;
    tiConnect: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure acLoginExecute(Sender: TObject);
    procedure acShowCreateAccountFormExecute(Sender: TObject);
    procedure acShowForgotPasswordFormExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure tiConnectTimer(Sender: TObject);
  private
    FLoginSuccess: Boolean;

    procedure ApplySettings;
    procedure SaveSettings;

    procedure SetStatus(const AStatus: String);

    procedure CSRLoginSuccess(const AMessage: TMessageItem);
    procedure CSRLoginFail(const AMessage: TMessageItem);
    procedure CSRStatusReply(const AMessage: TMessageItem);
    procedure CSRHello(const AMessage: TMessageItem);

    procedure SocketChangeState(const AOldState, ANewState: TSocketState);

    procedure EnableGUI(const AEnable: Boolean);
  protected
    procedure CreateParams(var AParams: TCreateParams); override;
    procedure WndProc(var AMessage: TMessage); override;
  public
  end;

implementation

{$R *.dfm}

uses
  uCreateAccountForm, uForgotPasswordForm, uSettings, uSocketClient,
  uServerCodes, uCommon, uMainDataModule, uPB_StatusReply, uPB_HelloReply,
  uMessageContainer, uServerMessageCallback;


procedure TfrmLogin.FormCreate(Sender: TObject);
begin
  FLoginSuccess := FALSE;
  edPassword.Properties.PasswordChar := Chr($25CF);
  ApplySettings;

  EnableGUI(SocketClient.IsConnected);
end;

procedure TfrmLogin.FormDestroy(Sender: TObject);
begin
  SaveSettings;
  MessageContainer.RemoveMessageHandler(Handle);
end;

procedure TfrmLogin.CreateParams(var AParams: TCreateParams);
begin
  inherited;
  AParams.ExStyle := AParams.ExStyle or WS_EX_APPWINDOW;
end;

procedure TfrmLogin.FormShow(Sender: TObject);
begin
  MessageContainer.AddMessageHandler(Handle);

  if SocketClient.Socket.State = wsClosed then
    SocketClient.Connect;
end;

procedure TfrmLogin.ApplySettings;
begin
  cbRememberLogin.Checked := Settings.RememberLogin;
  cbRememberPassword.Checked := Settings.RememberPassword;

  if Settings.RememberLogin then
    edLogin.Text := Settings.Login;

  if Settings.RememberPassword then
    edPassword.Text := Settings.Password;
end;

procedure TfrmLogin.SaveSettings;
begin
  Settings.RememberLogin := cbRememberLogin.Checked;
  Settings.RememberPassword := cbRememberPassword.Checked;

  if Settings.RememberLogin then
    Settings.Login := edLogin.Text
  else
    Settings.Login := '';

  if Settings.RememberPassword then
    Settings.Password := edPassword.Text
  else
    Settings.Password := '';
end;


procedure TfrmLogin.WndProc(var AMessage: TMessage);
var
  msg: TMessageItem;
begin
  inherited;

  if MessageContainer.IsNewMessage(AMessage, msg) then
  begin
    case msg.MessageType of
      mtServerResponse: ProcessServerMessage(msg,
                          [
                            TServerMessageCallback.Create(srHello, CSRHello),
                            TServerMessageCallback.Create(srLoginOk, CSRLoginSuccess),
                            TServerMessageCallback.Create(srInvalidLogin, CSRLoginFail),
                            TServerMessageCallback.Create(srStatus, CSRStatusReply)
                          ]
                        );

      mtSocketChangeState: SocketChangeState(msg.OldState, msg.NewState);
    end;

    msg.IncReadCount;
  end;
end;

procedure TfrmLogin.SetStatus(const AStatus: String);
begin
  StatusBar.Panels[0].Text := ' ' + AStatus;
end;

procedure TfrmLogin.SocketChangeState(const AOldState, ANewState: TSocketState);
var
  status: String;
begin
  status := TrimLeft(StatusBar.Panels[0].Text);

  case ANewState of
    wsOpened,
    wsBound,
    wsConnecting: begin
      status := 'Connecting to server...';
      EnableGUI(FALSE);
    end;
    wsClosed: begin
      EnableGUI(FALSE);
      SocketClient.Disconnect;
      tiConnect.Enabled := TRUE;
    end;
  end;

  SetStatus(status)
end;

procedure TfrmLogin.tiConnectTimer(Sender: TObject);
begin
  SocketClient.Connect;
  tiConnect.Enabled := FALSE;
end;

procedure TfrmLogin.EnableGUI(const AEnable: Boolean);
begin
  acLogin.Enabled := AEnable;
  acShowCreateAccountForm.Enabled := AEnable;
  acShowForgotPasswordForm.Enabled := AEnable;
end;

procedure TfrmLogin.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Ord(Key) of
    VK_RETURN: begin
      acLogin.Execute;
      Key := #0;
    end;
  end;
end;

procedure TfrmLogin.acLoginExecute(Sender: TObject);
begin
  SetStatus('Logging in...');
  EnableGUI(FALSE);
  SocketClient.Login(edLogin.Text, edPassword.Text);
end;

procedure TfrmLogin.acShowCreateAccountFormExecute(Sender: TObject);
begin
  if RunModalForm(TfrmCreateAccount, self, []) = mrOk then
  begin
    if edLogin.Text = '' then
    begin
      cbRememberLogin.Checked := TRUE;
      edLogin.Text := Settings.Login;
      edPassword.SetFocus;
    end;
  end;
end;

procedure TfrmLogin.acShowForgotPasswordFormExecute(Sender: TObject);
begin
  RunModalForm(TfrmForgotPassword, self, []);
end;

procedure TfrmLogin.CSRHello(const AMessage: TMessageItem);
var
  pbhello: TPB_HelloReply;
begin
  pbhello := AMessage.Object_ as TPB_HelloReply;

  dmMain.ServerSettings.ParseHelloMessage(pbhello);

  if dmMain.ServerSettings.StringLengths.EMail > dmMain.ServerSettings.StringLengths.Username then
    edLogin.Properties.MaxLength := dmMain.ServerSettings.StringLengths.EMail
  else
    edLogin.Properties.MaxLength := dmMain.ServerSettings.StringLengths.Username;

  edPassword.Properties.MaxLength := dmMain.ServerSettings.StringLengths.Password;

  SetStatus('');
  EnableGUI(SocketClient.IsConnected);
end;

procedure TfrmLogin.CSRLoginFail(const AMessage: TMessageItem);
begin
  SetStatus('');
  MessageDlg('Invalid login/password', mtError, [mbOK], 0);
  EnableGUI(TRUE);
  edLogin.SetFocus;
end;

procedure TfrmLogin.CSRLoginSuccess(const AMessage: TMessageItem);
begin
  dmMain.SelfInfo.Password := edPassword.Text;
  FLoginSuccess := TRUE;
  SocketClient.Status;
end;

procedure TfrmLogin.CSRStatusReply(const AMessage: TMessageItem);
var
  pbstatus: TPB_StatusReply;
begin
  pbstatus := AMessage.Object_ as TPB_StatusReply;

  dmMain.SelfInfo.ParseStatus(pbstatus);
  dmMain.Avatars.AddAvatar(dmMain.SelfInfo.AvatarId);
  dmMain.Players.ParseStatus(pbstatus);

  if FLoginSuccess then
    ModalResult := mrOk;
end;

end.
