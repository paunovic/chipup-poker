unit Poker.Forms.CreateAccount;

interface

uses
  Winapi.Windows, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  cxContainer, cxLabel, cxButtons, cxCheckBox, cxTextEdit, Vcl.ActnList,
   Poker.Interfaces.ModalForm, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxEdit, dxSkinsCore, ChipUpPokerDarkSkin,
  Vcl.Menus, Vcl.StdCtrls;

type
  TfrmCreateAccount = class(TForm, IModalForm)
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
    lbsTAC: TcxLabel;
    procedure acSignUpExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lbsTACClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FCallbacksId: Integer;
    FCloseCallback: TNotifyEvent;

    function ValidateForm: Boolean;

    procedure CSRRegisterReply(const AMethodId: Integer; const AObject: TObject);
  protected
  public
    procedure SetCloseCallback(const ACallback: TNotifyEvent);
  end;

implementation

{$R *.dfm}

uses
  Poker.Settings, Poker.Server.Socket.Commands, Poker.Server.Validators, Poker.Protobufs.Enum.ServerCodes,
  Poker.DataModule, Poker.Server.MessageCallbacks, Poker.Protobufs.Objects.RegisterReply, Poker.Server.MessageContainer,
  Poker.Server.Settings, Poker.Common.FormsContainer;


procedure TfrmCreateAccount.FormCreate(Sender: TObject);
begin
  FCallbacksId := MessageContainer.AddCallbacks([
                      TServerMessageCallback.Create(srRegisterReply, CSRRegisterReply)
                  ]);

  edEMail.Properties.MaxLength := ServerSettings.MaxStringLengths.EMail;
  edPassword.Properties.MaxLength := ServerSettings.MaxStringLengths.Password;
  edConfirmPassword.Properties.MaxLength := ServerSettings.MaxStringLengths.Password;
  edUsername.Properties.MaxLength := ServerSettings.MaxStringLengths.Username;

  edPassword.Properties.PasswordChar := Chr($25CF);
  edConfirmPassword.Properties.PasswordChar := Chr($25CF);
end;

procedure TfrmCreateAccount.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.Remove(self);
end;

procedure TfrmCreateAccount.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  if Assigned(FCloseCallback) then
    FCloseCallback(self);
end;


procedure TfrmCreateAccount.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Ord(Key) of
    VK_ESCAPE: begin
      ModalResult := mrCancel;
      Close;
      Key := #0;
    end;
    VK_RETURN: begin
      if not edUsername.Focused then
        SelectNext(ActiveControl, TRUE, TRUE);
      Key := #0;
    end;
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
    if not ValidateUserPassword(edPassword.Text, error) then
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
  ServerSocket.CreateAccount(edUsername.Text, edPassword.Text, edEmail.Text);
end;

procedure TfrmCreateAccount.CSRRegisterReply(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_RegisterReply;
begin
  pbreply := AObject as TPB_RegisterReply;

  case pbreply.Status of
   regSuccess: begin
      MessageDlg('Account successfully created. Please check your inbox for confirmation e-mail', mtInformation, [mbOK], 0);
      if Settings.Login = '' then
        Settings.Login := edEMail.Text;
      ModalResult := mrOk;
      Close;
   end;
   regDuplicateEmail: begin
     MessageDlg('E-mail address already exists', mtError, [mbOK], 0);
     edEmail.SetFocus;
   end;
   regDupUsername: begin
     MessageDlg('Username already exists', mtError, [mbOK], 0);
     edUsername.SetFocus;
   end;
   regInvalidEmail: begin
     MessageDlg('Invalid E-mail address', mtError, [mbOK], 0);
     edEmail.SetFocus;
   end;
   regInvalidName: begin
     MessageDlg('Invalid username', mtError, [mbOK], 0);
     edUsername.SetFocus;
   end;
  end;

  acSignUp.Enabled := TRUE;
end;

procedure TfrmCreateAccount.lbsTACClick(Sender: TObject);
begin
  dmMain.OpenTACLink;
end;

procedure TfrmCreateAccount.SetCloseCallback(const ACallback: TNotifyEvent);
begin
  FCloseCallback := ACallback;
end;

end.
