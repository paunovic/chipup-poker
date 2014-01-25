unit uChangePasswordForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  cxTextEdit, cxLabel, Vcl.Menus, Vcl.StdCtrls, cxButtons, Vcl.ActnList, uMessageItem, dxSkinDarkRoom;

type
  TfrmChangePassword = class(TForm)
    lbsCurrentPassword: TcxLabel;
    lbsNewPassword: TcxLabel;
    edNewPassword: TcxTextEdit;
    edCurrentPassword: TcxTextEdit;
    lbsConfirmPassword: TcxLabel;
    edConfirmPassword: TcxTextEdit;
    btOK: TcxButton;
    btCancel: TcxButton;
    alChangePassword: TActionList;
    acOK: TAction;
    acCancel: TAction;
    procedure FormCreate(Sender: TObject);
    procedure acOKExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acCancelExecute(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    procedure CSRChangePasswordOk(const AMessage: TMessageItem);
  protected
    procedure WndProc(var AMessage: TMessage); override;
  public
  end;

implementation

{$R *.dfm}

uses
  uMainDataModule, uValidators, uSocketClient, uServerCodes, uCommon, uMessageContainer, uServerMessageCallback;


procedure TfrmChangePassword.FormCreate(Sender: TObject);
begin
  edNewPassword.Properties.MaxLength := dmMain.ServerSettings.StringLengths.Password;
  edCurrentPassword.Properties.MaxLength := dmMain.ServerSettings.StringLengths.Password;
  edConfirmPassword.Properties.MaxLength := dmMain.ServerSettings.StringLengths.Password;
end;

procedure TfrmChangePassword.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);
end;

procedure TfrmChangePassword.FormShow(Sender: TObject);
begin
  MessageContainer.AddMessageHandler(Handle);
end;

procedure TfrmChangePassword.WndProc(var AMessage: TMessage);
var
  msg: TMessageItem;
begin
  inherited;

  if MessageContainer.IsNewMessage(AMessage, msg) then
  begin
    case msg.MessageType of
      mtServerResponse: ProcessServerMessage(msg,
                          [
                            TServerMessageCallback.Create(srChangePasswordOk, CSRChangePasswordOk)
                          ]
                        );
    end;

    msg.IncReadCount;
  end;
end;

procedure TfrmChangePassword.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Ord(Key) of
    VK_ESCAPE: begin
      acCancel.Execute;
      Key := #0;
    end;
    VK_RETURN: begin
      if edConfirmPassword.Focused then
        acOK.Execute
      else
        SelectNext(ActiveControl, TRUE, TRUE);
      Key := #0;
    end;
  end;
end;

procedure TfrmChangePassword.acOKExecute(Sender: TObject);
var
  error: String;
begin
  if edCurrentPassword.Text <> dmMain.SelfInfo.Password then
  begin
    error := 'Invalid current password';
    edCurrentPassword.SetFocus;
  end
  else
    if not ValidatePassword(edNewPassword.Text, error) then
      edNewPassword.SetFocus
    else
      if edNewPassword.Text <> edConfirmPassword.Text then
      begin
        error := 'Passwords mismatch';
        edNewPassword.SetFocus;
      end;

  if error <> '' then
  begin
    MessageDlg(error, mtError, [mbOK], 0);
    Exit;
  end;

  acOK.Enabled := FALSE;
  SocketClient.ChangePassword(edNewPassword.Text);
end;

procedure TfrmChangePassword.CSRChangePasswordOk(const AMessage: TMessageItem);
begin
  MessageDlg('Password successfully changed', mtInformation, [mbOK], 0);
  dmMain.SelfInfo.Password := edNewPassword.Text;
  ModalResult := mrOk;
end;

procedure TfrmChangePassword.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;



end.
