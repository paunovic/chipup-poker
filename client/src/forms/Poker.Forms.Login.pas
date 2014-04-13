unit Poker.Forms.Login;

interface

{$I defines.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Dialogs,
  Vcl.Controls, Vcl.Forms, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  cxGraphics, dxSkinsForm, Vcl.ExtCtrls, Vcl.ActnList, cxLabel, cxTextEdit, Vcl.StdCtrls,
  cxButtons, cxCheckBox, OverbyteIcsWSocket,  dxsChipUpDark, dxsChipUpDarkTabs, cxImage, dxsChipUpRedButton,
  dxGDIPlusClasses, Vcl.Menus, cxMaskEdit, cxDropDownEdit;

type
  TLoginStatus = (lsIdle, lsConnecting, lsConnected, lsLoggingIn, lsLoggedIn, lsUpdating);

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
    tiConnect: TTimer;
    imgHeader: TcxImage;
    tiLoginTimeout: TTimer;
    btForceUpdate: TcxButton;
    acUpdate: TAction;
    procedure FormCreate(Sender: TObject);
    procedure acLoginExecute(Sender: TObject);
    procedure acShowCreateAccountFormExecute(Sender: TObject);
    procedure acShowForgotPasswordFormExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure tiConnectTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tiLoginTimeoutTimer(Sender: TObject);
    procedure acUpdateExecute(Sender: TObject);
  private
    FCurrentStatus: TLoginStatus;
    FCallbacksId: Integer;
    FServerComboBox: TcxComboBox;

    procedure ApplySettings;
    procedure SaveSettings;

    procedure ModalFormClose(Sender: TObject);

    procedure CreateServerCombobox;

    procedure CSRLogin(const AMethodId: Integer; const AObject: TObject);
    procedure CSRStatusReply(const AMethodId: Integer; const AObject: TObject);
    procedure CSRHello(const AMethodId: Integer; const AObject: TObject);

    procedure SocketStateChange(const AOldState, ANewState: TSocketState);

    procedure ServerComboboxChange(Sender: TObject);

    procedure EnableGUI(const AEnable: Boolean);
    procedure SetCurrentStatus(const AValue: TLoginStatus);
  protected
    procedure CreateParams(var AParams: TCreateParams); override;
  public
    property CurrentStatus: TLoginStatus read FCurrentStatus write SetCurrentStatus;
  end;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Poker.Forms.CreateAccount, Poker.Forms.ForgotPassword, Poker.Settings, Poker.Server.Socket,
  Poker.Server.MessageContainer, Poker.Server.Settings, Poker.Protobufs.Enum.ServerCodes, Poker.Common.Misc, Poker.DataModule,
  Poker.Protobufs.Objects.StatusReply, Poker.Protobufs.Objects.HelloReply, Poker.Protobufs.Objects.LoginReply, Poker.Server.MessageCallbacks, Poker.Forms.Main,
  Poker.Common.FormsContainer, Poker.Forms.Updater, Poker.HardcodedSettings, Poker.Common.Encryption;


procedure TfrmLogin.FormCreate(Sender: TObject);
begin
  FCallbacksId := MessageContainer.AddCallbacks([
                     TSocketStateChangeCallback.Create(SocketStateChange),
                     TServerMessageCallback.Create(srHello, CSRHello),
                     TServerMessageCallback.Create(srLoginReply, CSRLogin),
                     TServerMessageCallback.Create(srStatus, CSRStatusReply)
                  ]);

  CurrentStatus := lsIdle;
  edPassword.Properties.PasswordChar := Chr($25CF);
  ApplySettings;

  {$IFDEF DEBUG}
  btForceUpdate.Visible := TRUE;
  {$ENDIF}

  if Settings.DeveloperMode then
    CreateServerCombobox;

  EnableGUI(ServerSocket.IsConnected);
end;

procedure TfrmLogin.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  SaveSettings;
end;

procedure TfrmLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  FormsContainer.Remove(TfrmLogin);
  frmChipUpMain.LoginStatus(FCurrentStatus);
end;

procedure TfrmLogin.CreateParams(var AParams: TCreateParams);
begin
  inherited;
  AParams.ExStyle := AParams.ExStyle or WS_EX_APPWINDOW;
end;

procedure TfrmLogin.CreateServerCombobox;
begin
  FServerComboBox := TcxComboBox.Create(self);
  FServerComboBox.Parent := self;
  FServerComboBox.Style.LookAndFeel.SkinName := edLogin.Style.LookAndFeel.SkinName;
  FServerComboBox.Width := btLogin.Width;
  FServerComboBox.Top := btLogin.Top + btLogin.Height + 4;
  FServerComboBox.Left := btLogin.Left;
  FServerComboBox.Properties.DropDownListStyle := lsFixedList;
  FServerComboBox.Properties.Items.Clear;
  FServerComboBox.Properties.Items.Add('Official Server');
  FServerComboBox.Properties.Items.Add('Dev Server');
  FServerComboBox.ItemIndex := Settings.ServerIndex;
  FServerComboBox.Properties.OnChange := ServerComboboxChange;
end;

procedure TfrmLogin.FormShow(Sender: TObject);
begin
  case ServerSocket.Socket.State of
    wsClosed: begin
      CurrentStatus := lsConnecting;
      ServerSocket.Connect;
    end;
    wsConnected: CurrentStatus := lsConnected;
  end;
end;

procedure TfrmLogin.ModalFormClose(Sender: TObject);
begin
  if (Sender is TfrmCreateAccount) and
     ((Sender as TfrmCreateAccount).ModalResult = mrOk) then
  begin
    if edLogin.Text = '' then
    begin
      cbRememberLogin.Checked := TRUE;
      edLogin.Text := Settings.Login;
      edPassword.SetFocus;
    end;
  end;

  EnableWindow(Handle, TRUE);
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

procedure TfrmLogin.ServerComboboxChange(Sender: TObject);
var
  server: String;
begin
  case (Sender as TcxComboBox).ItemIndex of
    0: begin
      server := Settings.Hardcoded.TCP_SERVER_ADDRESS;
      Settings.DomainURL := URL_DOMAIN;
    end;
    1: begin
      server := Settings.Hardcoded.TCP_DEV_SERVER_ADDRESS;
      Settings.DomainURL := DEV_URL_DOMAIN;
    end;
  end;

  Settings.ServerIndex := (Sender as TcxComboBox).ItemIndex;

  TServerSocket.Deinitialize;
  TServerSocket.Initialize(server, Settings.Hardcoded.TCP_SERVER_PORT);
end;

procedure TfrmLogin.SetCurrentStatus(const AValue: TLoginStatus);
var
  status: String;
begin
  FCurrentStatus := AValue;

  case FCurrentStatus of
    lsIdle, lsConnecting: status := 'CONNECTING...';
    lsConnected: status := 'LOGIN';
    lsLoggingIn, lsLoggedIn: status := 'LOGGING IN...';
  end;

  btLogin.Caption := status;
end;

procedure TfrmLogin.SocketStateChange(const AOldState, ANewState: TSocketState);
begin
  case ANewState of
    wsOpened,
    wsBound,
    wsConnecting: begin
      CurrentStatus := lsConnecting;
      EnableGUI(FALSE);
    end;
    wsConnected: begin
      if ServerSocket.IsConnected then
        CurrentStatus := lsConnected;
      EnableGUI(ServerSocket.IsConnected);
    end;
    wsClosed: begin
      FormsContainer.Close(TfrmForgotPassword);
      FormsContainer.Close(TfrmCreateAccount);
      CurrentStatus := lsIdle;
      EnableGUI(FALSE);
      ServerSocket.Disconnect;
    end;
  end;
end;

procedure TfrmLogin.tiConnectTimer(Sender: TObject);
begin
  if ServerSocket.Socket.State = wsClosed then
    FCurrentStatus := lsIdle;

  if CurrentStatus = lsIdle then
  begin
    CurrentStatus := lsConnecting;
    ServerSocket.Connect;
  end;
end;

procedure TfrmLogin.tiLoginTimeoutTimer(Sender: TObject);
begin
  ServerSocket.Disconnect;
  tiLoginTimeout.Enabled := FALSE;
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

procedure TfrmLogin.acUpdateExecute(Sender: TObject);
begin
  CurrentStatus := lsUpdating;
  Close;
  Exit;
end;

procedure TfrmLogin.acLoginExecute(Sender: TObject);
begin
  if SHA256String(edLogin.Text) = '1ÕŒ²ƒ{¹ú†ßãi£œq7wP9†Ór2?Û~î2' then // devmodeon!
  begin
    Settings.DeveloperMode := not Settings.DeveloperMode;
    if Settings.DeveloperMode then
      CreateServerCombobox
    else
      FreeAndNil(FServerComboBox);
    edLogin.Clear;
    edLogin.SetFocus;
    Exit;
  end;

  CurrentStatus := lsLoggingIn;
  EnableGUI(FALSE);
  tiLoginTimeout.Enabled := TRUE;
  ServerSocket.Login(edLogin.Text, edPassword.Text);
end;

procedure TfrmLogin.acShowCreateAccountFormExecute(Sender: TObject);
begin
  FormsContainer.Add(RunModalForm(TfrmCreateAccount, self, [], ModalFormClose));
end;

procedure TfrmLogin.acShowForgotPasswordFormExecute(Sender: TObject);
begin
  FormsContainer.Add(RunModalForm(TfrmForgotPassword, self, [], ModalFormClose));
end;

procedure TfrmLogin.CSRHello(const AMethodId: Integer; const AObject: TObject);
var
  pbhello: TPB_HelloReply;
  version: String;
begin
  pbhello := AObject as TPB_HelloReply;

  {$IFDEF DEBUG}
  version := pbhello.LatestDebugVersion;
  {$ELSE}
  version := pbhello.LatestVersion;
  {$ENDIF}

  if (version <> Settings.Hardcoded.VERSION) and
     (Settings.Hardcoded.REVISION <> 'manual') then
    acUpdate.Execute;

  ServerSettings.ParseHelloMessage(pbhello);

  if ServerSettings.StringLengths.EMail > ServerSettings.StringLengths.Username then
    edLogin.Properties.MaxLength := ServerSettings.StringLengths.EMail
  else
    edLogin.Properties.MaxLength := ServerSettings.StringLengths.Username;

  edPassword.Properties.MaxLength := ServerSettings.StringLengths.Password;

  EnableGUI(ServerSocket.IsConnected);
  if ServerSocket.IsConnected then
  begin
    CurrentStatus := lsConnected;
    ServerSocket.Ping;
  end
  else
    ServerSocket.Disconnect;
end;

procedure TfrmLogin.CSRLogin(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_LoginReply;
begin
  pbreply := AObject as TPB_LoginReply;

  case pbreply.Status of
    lrSuccess: begin
      dmMain.SelfInfo.Password := edPassword.Text;
      CurrentStatus := lsLoggedIn;
      ServerSocket.Status;
    end;
    lrInvalid: begin
      CurrentStatus := lsConnected;
      MessageDlg('Invalid login/password', mtError, [mbOK], 0);
      EnableGUI(TRUE);
      edLogin.SetFocus;
    end;
  else
    {$IFDEF DEBUG} DebugLn(Format('CSRLogin: invalid status received [%d]]', [Integer(pbreply.Status)]), ditException); {$ENDIF}
    edLogin.SetFocus;
  end;
end;

procedure TfrmLogin.CSRStatusReply(const AMethodId: Integer; const AObject: TObject);
var
  pbstatus: TPB_StatusReply;
begin
  pbstatus := AObject as TPB_StatusReply;
  dmMain.ProcessStatusProtobuf(pbstatus);
  if CurrentStatus = lsLoggedIn then
    Close;
end;

end.
