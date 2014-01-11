unit uChangeEMailForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinDevExpressStyle, cxLabel, Vcl.Menus, Vcl.StdCtrls, cxButtons, cxTextEdit, Vcl.ActnList;

type
  TfrmChangeEMail = class(TForm)
    lbInfo: TcxLabel;
    lbsCurrentMail: TcxLabel;
    edCurrentMail: TcxTextEdit;
    lbsNewMail: TcxLabel;
    edNewMail: TcxTextEdit;
    btOK: TcxButton;
    btCancel: TcxButton;
    alChangeEMailAddress: TActionList;
    acOK: TAction;
    acCancel: TAction;
    procedure acCancelExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure edNewMailPropertiesChange(Sender: TObject);
    procedure acOKExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure TCChangeMailOk(const AData: TObject);
    procedure TCChangeMailInvalidMail(const AData: TObject);
    procedure TCChangeMailDuplicateMail(const AData: TObject);
  protected
    procedure WndProc(var AMessage: TMessage); override;
  public
  end;

implementation

{$R *.dfm}

uses
  uMainDataModule, uValidators, uSocketClient, uServerCodes, uCommon, uMessageContainer;


procedure TfrmChangeEMail.FormCreate(Sender: TObject);
begin
  lbInfo.Caption := Format('Upon changing your e-mail address, you will receive an e-mail containing confirmation link. ' +
                           'You must click on confirmation link in order to complete e-mail change process. ' +
                           'Until your new e-mail address has been validated, you can only log into your account using your username. ' +
                           'Confirmation link will expire in %d hours.', [Round(dmMain.ServerSettings.EmailConfirmationExpiration / 3600)]);

  edCurrentMail.Text := dmMain.SelfInfo.EMail;
  edNewMail.Properties.MaxLength := dmMain.ServerSettings.StringLengths.EMail;
end;

procedure TfrmChangeEMail.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);
end;


procedure TfrmChangeEMail.FormShow(Sender: TObject);
begin
  MessageContainer.AddMessageHandler(Handle);
end;

procedure TfrmChangeEMail.WndProc(var AMessage: TMessage);
begin
  inherited;
                  {
  if SocketClient.IsServerResponseMessage(AMessage) then
    SocketClient.ParseWndMessage(AMessage,
      [
        TWndCallback.Create(SR_CHANGE_MAIL_OK, TCChangeMailOk),
        TWndCallback.Create(SR_CHANGE_MAIL_INVALID_MAIL, TCChangeMailInvalidMail),
        TWndCallback.Create(SR_CHANGE_MAIL_DUPLICATE_MAIL, TCChangeMailDuplicateMail)
      ]
    );             }
end;


procedure TfrmChangeEMail.edNewMailPropertiesChange(Sender: TObject);
var
  err: String;
begin
  acOK.Enabled := (ValidateEMail(edNewMail.Text, err)) and (edNewMail.Text <> dmMain.SelfInfo.EMail);
end;

procedure TfrmChangeEMail.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: acCancel.Execute;
    VK_RETURN: if edNewMail.Focused then
                 acOK.Execute;
  end;
end;
procedure TfrmChangeEMail.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmChangeEMail.acOKExecute(Sender: TObject);
begin
  SocketClient.ChangeEMail(edNewMail.Text);
  acOK.Enabled := FALSE;
end;

procedure TfrmChangeEMail.TCChangeMailDuplicateMail(const AData: TObject);
begin
  MessageDlg('E-mail address is already in use', mtError, [mbOK], 0);
  edNewMail.SetFocus;
  acOK.Enabled := TRUE;
end;

procedure TfrmChangeEMail.TCChangeMailInvalidMail(const AData: TObject);
begin
  MessageDlg('Invalid E-mail address', mtError, [mbOK], 0);
  edNewMail.SetFocus;
  acOK.Enabled := TRUE;
end;

procedure TfrmChangeEMail.TCChangeMailOk(const AData: TObject);
begin
  MessageDlg('E-mail address successfully changed. Please check your inbox for confirmation link.', mtInformation, [mbOK], 0);
  ModalResult := mrOk;
end;






end.
