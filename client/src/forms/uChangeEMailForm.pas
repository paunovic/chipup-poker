unit uChangeEMailForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  cxLabel, Vcl.Menus, Vcl.StdCtrls, cxButtons, cxTextEdit, Vcl.ActnList, uMessageItem, dxSkinDarkRoom;

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
    procedure FormCreate(Sender: TObject);
    procedure edNewMailPropertiesChange(Sender: TObject);
    procedure acOKExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    procedure CSRChangeMail(const AMessage: TMessageItem);
  protected
    procedure WndProc(var AMessage: TMessage); override;
  public
  end;

implementation

{$R *.dfm}

uses
  uMainDataModule, uValidators, uSocketClient, uServerCodes, uCommon, uMessageContainer, uServerMessageCallback, uPB_ChangeMailReply;


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
var
  msg: TMessageItem;
begin
  inherited;

  if MessageContainer.IsNewMessage(AMessage, msg) then
  begin
    case msg.MessageType of
      mtServerResponse: ProcessServerMessage(msg,
                          [
                            TServerMessageCallback.Create(srChangeMailReply, CSRChangeMail)
                          ]
                        );
    end;

    msg.IncReadCount;
  end;
end;


procedure TfrmChangeEMail.edNewMailPropertiesChange(Sender: TObject);
var
  err: String;
begin
  acOK.Enabled := (ValidateEMail(edNewMail.Text, err)) and (edNewMail.Text <> dmMain.SelfInfo.EMail);
end;

procedure TfrmChangeEMail.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Ord(Key) of
    VK_ESCAPE: begin
      acCancel.Execute;
      Key := #0;
    end;
    VK_RETURN: begin
      if edNewMail.Focused then
        acOK.Execute;
      Key := #0;
    end;
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

procedure TfrmChangeEMail.CSRChangeMail(const AMessage: TMessageItem);
var
  pbreply: TPB_ChangeMailReply;
begin
  pbreply := AMessage.Object_ as TPB_ChangeMailReply;

  case pbreply.Status of
    cmSuccess: begin
      MessageDlg('E-mail address successfully changed. Please check your inbox for confirmation link.', mtInformation, [mbOK], 0);
      ModalResult := mrOk;
    end;
    cmDuplicateMail: begin
      MessageDlg('E-mail address is already in use', mtError, [mbOK], 0);
      edNewMail.SetFocus;
      acOK.Enabled := TRUE;
    end;
  end;
end;

end.
