unit Poker.Forms.Login;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Dialogs, Vcl.Controls, Vcl.Forms, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, cxGraphics, dxSkinsForm,
  Vcl.ExtCtrls, Vcl.ActnList, cxLabel, cxTextEdit, Vcl.StdCtrls, cxButtons, cxCheckBox,
  OverbyteIcsWSocket,  cxImage, dxGDIPlusClasses, cxMaskEdit, cxDropDownEdit,
  ChipUPPokerDarkSkin, System.Generics.Collections, Poker.Common.AlphaBlendThread,
  Vcl.Menus, Vcl.ToolWin, Vcl.ActnMan, Vcl.ActnCtrls, Vcl.ActnMenus,
  System.Actions;

type
  TLoginStatus = (lsIdle, lsConnecting, lsConnected, lsHelloing, lsHelloOk, lsLoggingIn, lsLoggedIn, lsUpdating);

  TfrmChipUPLogin = class(TForm)
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
    tiLoginTimeout: TTimer;
    acUpdate: TAction;
    imgBackground: TImage;
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
    FPopupMenu: TPopupMenu;
    FAlphaBlendThread: TAlphaBlendThread;

    procedure ApplySettings;
    procedure SaveSettings;

    procedure ModalFormClose(Sender: TObject);

    procedure CreateServerCombobox;
    procedure CreatePopupMenu;

    procedure CSRLogin(const AMethodId: Integer; const AObject: TObject);
    procedure CSRHello(const AMethodId: Integer; const AObject: TObject);

    procedure EnterDeveloperMode;
    procedure LeaveDeveloperMode;

    procedure SocketStateChange(const AOldState, ANewState: TSocketState);

    procedure ServerComboboxChange(Sender: TObject);

    procedure EnableGUI(const AEnable: Boolean);
    procedure SetCurrentStatus(const AValue: TLoginStatus);
    procedure AlphaBlendThreadNotify(Sender: TObject);

    procedure HelloServer;
  protected
    procedure CreateParams(var AParams: TCreateParams); override;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  public
    property CurrentStatus: TLoginStatus read FCurrentStatus write SetCurrentStatus;
  end;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Poker.Forms.CreateAccount, Poker.Forms.ForgotPassword, Poker.Settings, Poker.Server.Socket, Poker.Server.MessageContainer,
  Poker.Server.Settings, Poker.Protobufs.Enum.ServerCodes, Poker.Common.Misc, Poker.DataModule, Poker.Protobufs.Objects.HelloReply,
  Poker.Protobufs.Objects.LoginReply, Poker.Server.MessageCallbacks, Poker.Forms.Main, Poker.Common.FormsContainer,
  Poker.HardcodedSettings, Poker.Common.Encryption, Poker.Protobufs.Objects.UpdateFileInfo, Poker.Common.CommandLineParams,
  Poker.Tables.Resources, Poker.DirectX.Core, Poker.Types, Poker.Common.ModalDialogs, Poker.SoftExceptions,
  Poker.Server.Validators, Soap.EncdDecd;


procedure TfrmChipUPLogin.FormCreate(Sender: TObject);
begin
  AlphaBlendValue := 0;

  FCallbacksId := MessageContainer.AddCallbacks(self.Name, [
                     TSocketStateChangeCallback.Create(SocketStateChange),
                     TServerMessageCallback.Create(srHello, CSRHello),
                     TServerMessageCallback.Create(srLoginReply, CSRLogin)
                  ]);

  Caption := Format('Welcome to %s', [Settings.Hardcoded.PROJECT_CAPTION]);

  CurrentStatus := lsIdle;
  edPassword.Properties.PasswordChar := Chr($25CF);
  ApplySettings;

  if Settings.DeveloperMode then
    EnterDeveloperMode;

  tiLoginTimeout.Interval := Settings.Hardcoded.SERVER_CONNECT_TIMEOUT * 1000;

  EnableGUI(FCurrentStatus = lsHelloOk);

end;

procedure TfrmChipUPLogin.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  SaveSettings;

  TAlphaBlendThread.FreeAlpaBlendThread(FAlphaBlendThread);
end;

procedure TfrmChipUPLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  FormsContainer.Remove(TfrmChipUPLogin);
  frmChipUPMain.LoginStatus(FCurrentStatus);
end;

procedure TfrmChipUPLogin.CreateParams(var AParams: TCreateParams);
begin
  inherited;
  AParams.ExStyle := AParams.ExStyle or WS_EX_APPWINDOW;
end;

procedure TfrmChipUPLogin.CreateServerCombobox;
var
  C1: Integer;
begin
  FServerComboBox := TcxComboBox.Create(self);
  FServerComboBox.Parent := self;
  FServerComboBox.Style.LookAndFeel.SkinName := edLogin.Style.LookAndFeel.SkinName;
  FServerComboBox.Width := btLogin.Width;
  FServerComboBox.Top := btLogin.Top + btLogin.Height + 4;
  FServerComboBox.Left := btLogin.Left;
  FServerComboBox.Properties.DropDownListStyle := lsFixedList;
  FServerComboBox.Properties.Items.Clear;
  for C1 := Low(Settings.Hardcoded.SERVER_LIST) to High(Settings.Hardcoded.SERVER_LIST) do
    FServerComboBox.Properties.Items.Add(Settings.Hardcoded.SERVER_LIST[C1].Address);
  FServerComboBox.ItemIndex := Settings.ServerIndex;
  FServerComboBox.Properties.OnChange := ServerComboboxChange;
end;

procedure TfrmChipUPLogin.CreatePopupMenu;
var
  C1: Integer;
  mi: TMenuItem;
begin
  FPopupMenu := TPopupMenu.Create(self);

  for C1 := 0 to frmChipUPMain.ActionManager.ActionCount - 1 do
    if frmChipUPMain.ActionManager.Actions[C1].Category = 'Dev' then
    begin
      mi := TMenuItem.Create(FPopupMenu);
      mi.Action := frmChipUPMain.ActionManager.Actions[C1];
      FPopupMenu.Items.Add(mi);
    end;

  imgBackground.PopupMenu := FPopupMenu;
end;

procedure TfrmChipUPLogin.FormShow(Sender: TObject);
begin
  if DXCore.Device.IsAtFault then
    ModalDialogs.ShowError('Failed to initialize DirectX.'#10 +
      'Please check that your graphic drivers are up-to-date and that your system meets the minimum requirements.');

  case ServerSocket.Socket.State of
    wsClosed: begin
      CurrentStatus := lsConnecting;
      dmMain.ServerSocketConnect;
    end;
    wsConnected: CurrentStatus := lsConnected;
  end;

  TAlphaBlendThread.CreateAlphaBlendThread(FAlphaBlendThread, AlphaBlendValue, 255, 0.1, 0.15, AlphaBlendThreadNotify);
end;

procedure TfrmChipUPLogin.HelloServer;
var
  files: TObjectList<TPB_UpdateFileInfo>;
begin
  CurrentStatus := lsHelloing;

  files := TObjectList<TPB_UpdateFileInfo>.Create(FALSE);
  try
    dmMain.GetUpdateFilesList(files);
    {$IFDEF DEBUG}
    ServerSocket.Hello(TRUE, files);
    {$ELSE}
    ServerSocket.Hello(FALSE, files);
    {$ENDIF};
  finally
    files.Free;
  end;
end;

procedure TfrmChipUPLogin.ModalFormClose(Sender: TObject);
begin
  if (Sender is TfrmCreateAccount) and
     ((Sender as TfrmCreateAccount).ModalResult = mrOk) then
  begin
    if edLogin.Text = '' then
    begin
      cbRememberLogin.Checked := TRUE;
      edLogin.Text := Settings.LoginUsername;
      edPassword.SetFocus;
    end;
  end;

  EnableWindow(Handle, TRUE);
end;

procedure TfrmChipUPLogin.ApplySettings;
begin
  cbRememberLogin.Checked := Settings.RememberLogin;
  cbRememberPassword.Checked := Settings.RememberPassword;

  if Settings.RememberLogin then
    edLogin.Text := Settings.LoginUsername;

  if Settings.RememberPassword then
    edPassword.Text := Settings.LoginPassword;
end;

procedure TfrmChipUPLogin.SaveSettings;
begin
  Settings.RememberLogin := cbRememberLogin.Checked;
  Settings.RememberPassword := cbRememberPassword.Checked;

  if Settings.RememberLogin then
    Settings.LoginUsername := edLogin.Text
  else
    Settings.LoginUsername := '';

  if Settings.RememberPassword then
    Settings.LoginPassword := edPassword.Text
  else
    Settings.LoginPassword := '';
end;

procedure TfrmChipUPLogin.ServerComboboxChange(Sender: TObject);
var
  item_index: Integer;
begin
  item_index := (Sender as TcxComboBox).ItemIndex;
  Settings.ServerIndex := item_index;
  ServerSocket.Disconnect;
end;

procedure TfrmChipUPLogin.SetCurrentStatus(const AValue: TLoginStatus);
var
  status: String;
begin
  FCurrentStatus := AValue;

  case FCurrentStatus of
    lsIdle, lsConnecting, lsConnected, lsHelloing: status := 'CONNECTING...';
    lsHelloOk: status := 'LOGIN';
    lsLoggingIn, lsLoggedIn: status := 'LOGGING IN...';
  end;

  btLogin.Caption := status;
end;

procedure TfrmChipUPLogin.SocketStateChange(const AOldState, ANewState: TSocketState);
begin
  case ANewState of
    wsOpened,
    wsBound,
    wsConnecting: begin
      tiConnect.Interval := 1000;
      CurrentStatus := lsConnecting;
      EnableGUI(FALSE);
    end;
    wsConnected: begin
      CurrentStatus := lsConnected;
      tiConnect.Interval := 100;
    end;
    wsClosed: begin
      tiConnect.Interval := 1000;
      FormsContainer.Close(TfrmForgotPassword);
      FormsContainer.Close(TfrmCreateAccount);
      CurrentStatus := lsIdle;
      EnableGUI(FALSE);
      if Assigned(ServerSocket) then
        ServerSocket.Disconnect;
    end;
  end;
end;

procedure TfrmChipUPLogin.tiConnectTimer(Sender: TObject);
begin
  if ServerSocket.Socket.State = wsClosed then
    FCurrentStatus := lsIdle;

  if CurrentStatus = lsIdle then
  begin
    CurrentStatus := lsConnecting;
    dmMain.ServerSocketConnect;
  end;

  if (ServerSocket.IsConnected) and
     (CurrentStatus = lsConnected) then
  begin
    HelloServer;
    tiConnect.Interval := 1000;
  end;
end;

procedure TfrmChipUPLogin.tiLoginTimeoutTimer(Sender: TObject);
begin
  ServerSocket.Disconnect;
  tiLoginTimeout.Enabled := FALSE;
end;

procedure TfrmChipUPLogin.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 0;
end;

procedure TfrmChipUPLogin.EnableGUI(const AEnable: Boolean);
begin
  acLogin.Enabled := (AEnable) and (not DXCore.Device.IsAtFault);
  acShowCreateAccountForm.Enabled := AEnable;
  acShowForgotPasswordForm.Enabled := AEnable;
end;

procedure TfrmChipUPLogin.EnterDeveloperMode;
begin
  CreateServerCombobox;
  CreatePopupMenu;
end;

procedure TfrmChipUPLogin.LeaveDeveloperMode;
begin
  FreeAndNil(FServerComboBox);
  imgBackground.PopupMenu := nil;
  FreeAndNil(FPopupMenu);
end;

procedure TfrmChipUPLogin.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Ord(Key) of
    VK_RETURN: begin
      acLogin.Execute;
      Key := #0;
    end;
  end;
end;

procedure TfrmChipUPLogin.acUpdateExecute(Sender: TObject);
begin
  CurrentStatus := lsUpdating;
  Close;
end;

procedure TfrmChipUPLogin.acLoginExecute(Sender: TObject);
var
  err: String;
begin
  if RawByteStringToHex(SHA256String(edLogin.Text)) = '04B2A4A01EE2039D98F01342553E1E34877457A85A6F5213D56F86878A0CC06A' then // devmodeon!
  begin
    Settings.DeveloperMode := not Settings.DeveloperMode;
    if Settings.DeveloperMode then
      EnterDeveloperMode
    else
      LeaveDeveloperMode;
    edLogin.Clear;
    edLogin.SetFocus;
    Exit;
  end;

  if (ValidateUsername(edLogin.Text, err)) or
     (ValidateEMail(edLogin.Text, err)) then
  begin
    if ValidateUserPassword(edPassword.Text, err) then
    begin
      CurrentStatus := lsLoggingIn;
      EnableGUI(FALSE);
      tiLoginTimeout.Enabled := TRUE;
      ServerSocket.Login(edLogin.Text, edPassword.Text)
    end
    else
    begin
      ModalDialogs.ShowWarning(err);
      edPassword.SetFocus;
    end;
  end
  else
  begin
    ModalDialogs.ShowWarning('Invalid username/E-Mail address');
    edLogin.SetFocus;
  end;
end;

procedure TfrmChipUPLogin.acShowCreateAccountFormExecute(Sender: TObject);
begin
  FormsContainer.Add(RunModalForm(TfrmCreateAccount, self, [], ModalFormClose));
end;

procedure TfrmChipUPLogin.acShowForgotPasswordFormExecute(Sender: TObject);
begin
  FormsContainer.Add(RunModalForm(TfrmForgotPassword, self, [], ModalFormClose));
end;

procedure TfrmChipUPLogin.CSRHello(const AMethodId: Integer; const AObject: TObject);
var
  pbhello: TPB_HelloReply;
begin
  if not TTypes.TryCast<TPB_HelloReply>(AObject, pbhello) then
    Exit;

  if pbhello.UpdateFiles.Count > 0 then
  begin
    if TCommandLineParams.NoUpdateFlag then
    begin
      {$IFDEF DEBUG} DebugLn('Ignoring update (-noupdate parameter found)', ditApplication); {$ENDIF}
    end
    else
    begin
      dmMain.StoreUpdateFiles(pbhello.UpdateFiles);
      acUpdate.Execute;
    end;
  end;

  ServerSettings.ParseHelloMessage(pbhello);
  if ServerSettings.MaxStringLengths.EMail > ServerSettings.MaxStringLengths.Username then
    edLogin.Properties.MaxLength := ServerSettings.MaxStringLengths.EMail
  else
    edLogin.Properties.MaxLength := ServerSettings.MaxStringLengths.Username;
  edPassword.Properties.MaxLength := ServerSettings.MaxStringLengths.Password;

  if ServerSocket.IsConnected then
  begin
    CurrentStatus := lsHelloOk;
    EnableGUI(TRUE);
    ServerSocket.Ping;
  end
  else
    ServerSocket.Disconnect;
end;

procedure TfrmChipUPLogin.CSRLogin(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_LoginReply;
begin
  if not TTypes.TryCast<TPB_LoginReply>(AObject, pbreply) then
    Exit;

  tiLoginTimeout.Enabled := FALSE;

  case pbreply.LoginStatus of
    lrSuccess: begin
      if not Assigned(TableResources) then
        TTableResources.Initialize(DXCore.Canvas);
      dmMain.SelfInfo.Password := edPassword.Text;
      dmMain.ProcessLoginReply(pbreply);
      CurrentStatus := lsLoggedIn;
      TAlphaBlendThread.CreateAlphaBlendThread(FAlphaBlendThread, AlphaBlendValue, 0, 0, 0.1, AlphaBlendThreadNotify);
    end;
    lrInvalid: begin
      ModalDialogs.ShowWarning('Invalid login/password');
      CurrentStatus := lsHelloOk;
      EnableGUI(TRUE);
      edLogin.SetFocus;
    end;
  else
    SoftException(Format('CSRLogin: invalid status received [%d]]', [Integer(pbreply.LoginStatus)]));
    edLogin.SetFocus;
  end;
end;

procedure TfrmChipUPLogin.AlphaBlendThreadNotify(Sender: TObject);
var
  abthread: TAlphaBlendThread;
begin
  abthread := Sender as TAlphaBlendThread;
  AlphaBlendValue := abthread.CurrentValue;
  if not Visible then
    Show;

  if abthread.Done then
  begin
    if AlphaBlendValue = 0 then
      Close;
    dmMain.RefreshSkinControllerDelayed;
  end;
end;


end.

