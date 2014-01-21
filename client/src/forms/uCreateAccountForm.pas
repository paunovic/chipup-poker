unit uCreateAccountForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, dxSkinsCore, Vcl.Menus, cxLabel, cxButtons, cxCheckBox, cxTextEdit, Vcl.ActnList, Vcl.ExtCtrls,
  dxSkinsForm, uMessageItem, dxSkinDarkRoom;

type
  TfrmCreateAccount = class(TForm)
    alCreateAccount: TActionList;
    acSignUp: TAction;
    edEMail: TcxTextEdit;
    edPassword: TcxTextEdit;
    edConfirmPassword: TcxTextEdit;
    edUsername: TcxTextEdit;
    cb18Years: TcxCheckBox;
    cbTOS: TcxCheckBox;
    btSignUp: TcxButton;
    lbsEMail: TcxLabel;
    lbsPassword: TcxLabel;
    lbsConfirmPassword: TcxLabel;
    lbsUsername: TcxLabel;
    lbTOS: TcxLabel;
    procedure acSignUpExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure lbTOSClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    function ValidateForm: Boolean;

    procedure TCRegisterOk(const AMessage: TMessageItem);
    procedure TCRegisterDuplicateMail(const AMessage: TMessageItem);
    procedure TCRegisterDuplicateUser(const AMessage: TMessageItem);
    procedure TCRegisterInvalidMail(const AMessage: TMessageItem);
  protected
    procedure WndProc(var AMessage: TMessage); override;
  public
  end;

implementation

{$R *.dfm}

uses
  uSettings, uCommon, uSocketClient, uValidators, uServerCodes, uMainDataModule, uMessageContainer, uServerMessageCallback;


procedure TfrmCreateAccount.FormCreate(Sender: TObject);
begin
  edEMail.Properties.MaxLength := dmMain.ServerSettings.StringLengths.EMail;
  edPassword.Properties.MaxLength := dmMain.ServerSettings.StringLengths.Password;
  edConfirmPassword.Properties.MaxLength := dmMain.ServerSettings.StringLengths.Password;
  edUsername.Properties.MaxLength := dmMain.ServerSettings.StringLengths.Username;

  edPassword.Properties.PasswordChar := Chr($25CF);
  edConfirmPassword.Properties.PasswordChar := Chr($25CF);
end;

procedure TfrmCreateAccount.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);
end;

procedure TfrmCreateAccount.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: ModalResult := mrCancel;
    VK_RETURN: if not edUsername.Focused then
                 SelectNext(ActiveControl, TRUE, TRUE);
  end;
end;

procedure TfrmCreateAccount.FormShow(Sender: TObject);
begin
  MessageContainer.AddMessageHandler(Handle);
end;

procedure TfrmCreateAccount.WndProc(var AMessage: TMessage);
var
  msg: TMessageItem;
begin
  inherited;

  if MessageContainer.IsNewMessage(AMessage, msg) then
  begin
    case msg.MessageType of
      mtServerResponse: ProcessServerMessage(msg,
                          [
                            TServerMessageCallback.Create(SR_REGISTER_OK, TCRegisterOk),
                            TServerMessageCallback.Create(SR_REGISTER_DUPLICATE_MAIL, TCRegisterDuplicateMail),
                            TServerMessageCallback.Create(SR_REGISTER_DUPLICATE_USERNAME, TCRegisterDuplicateUser),
                            TServerMessageCallback.Create(SR_REGISTER_INVALID_MAIL, TCRegisterInvalidMail)
                          ]
                        );
    end;

    msg.IncReadCount;
  end;
end;

function TfrmCreateAccount.ValidateForm: Boolean;
var
  error: String;
begin
  error := '';
  if not ValidateEMail(edEmail.Text, error) then
    edEmail.SetFocus
  else
    if not ValidatePassword(edPassword.Text, error) then
      edPassword.SetFocus
    else
      if edPassword.Text <> edConfirmPassword.Text then
      begin
        error := 'Password mismatch';
        edPassword.SetFocus;
      end
      else
        if not ValidateUsername(edUsername.Text, error) then
          edUsername.SetFocus
        else
          if not cb18Years.Checked then
            error := 'Plase confirm that you are at least 18 years of age'
          else
            if not cbTOS.Checked then
              error := 'Please agree to Terms and Conditions';

  result := error = '';
  if not result then
    MessageDlg(error, mtError, [mbOK], 0);
end;

procedure TfrmCreateAccount.acSignUpExecute(Sender: TObject);
begin
  if not ValidateForm then
    Exit;

  acSignUp.Enabled := FALSE;
  SocketClient.CreateAccount(edUsername.Text, edPassword.Text, edEmail.Text);
end;

procedure TfrmCreateAccount.TCRegisterOk(const AMessage: TMessageItem);
begin
  MessageDlg('Account successfully created. Please check your inbox for confirmation e-mail', mtInformation, [mbOK], 0);

  if Settings.Login = '' then
    Settings.Login := edEMail.Text;

  ModalResult := mrOk;
end;

procedure TfrmCreateAccount.TCRegisterDuplicateMail(const AMessage: TMessageItem);
begin
  MessageDlg('E-mail address already exists', mtError, [mbOK], 0);
  edEmail.SetFocus;
  acSignUp.Enabled := TRUE;
end;

procedure TfrmCreateAccount.TCRegisterDuplicateUser(const AMessage: TMessageItem);
begin
  MessageDlg('Username already exists', mtError, [mbOK], 0);
  edUsername.SetFocus;
  acSignUp.Enabled := TRUE;
end;

procedure TfrmCreateAccount.TCRegisterInvalidMail(const AMessage: TMessageItem);
begin
  MessageDlg('Invalid E-mail address', mtError, [mbOK], 0);
  edEmail.SetFocus;
  acSignUp.Enabled := TRUE;
end;

procedure TfrmCreateAccount.lbTOSClick(Sender: TObject);
begin
  dmMain.OpenTOSLink;
end;


end.
