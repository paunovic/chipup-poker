unit Poker.Forms.CreateAccount;

interface

uses
  Winapi.Windows, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxContainer,
  cxLabel, cxButtons, cxCheckBox, cxTextEdit, Vcl.ActnList, Poker.Interfaces.ModalForm,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxEdit, dxSkinsCore,
  ChipUpPokerDarkSkin, Vcl.Menus, Vcl.StdCtrls;

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
  Poker.Settings, Poker.Server.Socket, Poker.Server.Validators, Poker.Protobufs.Enum.ServerCodes, Poker.Types,
  Poker.DataModule, Poker.Server.MessageCallbacks, Poker.Protobufs.Objects.RegisterReply, Poker.Server.MessageContainer,
  Poker.Server.Settings, Poker.Common.FormsContainer, Poker.Common.Misc, Poker.Common.ModalDialogs;


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
    ModalDialogs.ShowWarning(error);
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
  if not TTypes.TryCast<TPB_RegisterReply>(AObject, pbreply) then
    Exit;

  case pbreply.Status of
   regSuccess: begin
      ModalDialogs.ShowInformation('Account successfully created. Please check your inbox for confirmation e-mail');
      if Settings.LoginUsername = '' then
        Settings.LoginUsername := edEMail.Text;
      ModalResult := mrOk;
      Close;
   end;
   regDuplicateEmail: begin
     ModalDialogs.ShowWarning('E-mail address already exists');
     edEmail.SetFocus;
   end;
   regDupUsername: begin
     ModalDialogs.ShowWarning('Username already exists');
     edUsername.SetFocus;
   end;
   regInvalidEmail: begin
     ModalDialogs.ShowWarning('Invalid E-mail address');
     edEmail.SetFocus;
   end;
   regInvalidName: begin
     ModalDialogs.ShowWarning('Invalid username');
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
