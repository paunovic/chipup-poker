unit Poker.Forms.ChangeEMail;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  cxContainer, cxLabel,
  cxButtons, cxTextEdit, Vcl.ActnList, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxEdit, dxSkinsCore,
  ChipUpPokerDarkSkin, Vcl.Menus, Vcl.StdCtrls;

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
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
  private
    FCallbacksId: Integer;

    procedure CSRChangeMail(const AMethodId: Integer; const AObject: TObject);
  protected
  public
  end;

implementation

{$R *.dfm}

uses
  Poker.DataModule, Poker.Server.Validators, Poker.Server.Socket, Poker.Protobufs.Enum.ServerCodes, Poker.Server.MessageCallbacks, Poker.Protobufs.Objects.ChangeMailReply, Poker.Server.MessageContainer,
  Poker.Server.Settings, Poker.Common.FormsContainer;

procedure TfrmChangeEMail.FormCreate(Sender: TObject);
begin
  FCallbacksId := MessageContainer.AddCallbacks([
                       TServerMessageCallback.Create(srChangeMailReply, CSRChangeMail)
                   ]);

  lbInfo.Caption := Format('Upon changing your e-mail address, you will receive an e-mail containing confirmation link. ' +
                           'You must click on confirmation link in order to complete e-mail change process. ' +
                           'Until your new e-mail address has been validated, you can only log into your account using your username. ' +
                           'Confirmation link will expire in %d hours.', [Round(ServerSettings.EmailConfirmationExpiration / 3600)]);

  edCurrentMail.Text := dmMain.SelfInfo.EMail;
  edNewMail.Properties.MaxLength := ServerSettings.MaxStringLengths.EMail;
end;

procedure TfrmChangeEMail.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.Remove(self);
end;

procedure TfrmChangeEMail.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
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
  Close;
end;

procedure TfrmChangeEMail.acOKExecute(Sender: TObject);
begin
  ServerSocket.ChangeEMail(edNewMail.Text);
  acOK.Enabled := FALSE;
end;

procedure TfrmChangeEMail.CSRChangeMail(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_ChangeMailReply;
begin
  pbreply := AObject as TPB_ChangeMailReply;

  case pbreply.Status of
    cmSuccess: begin
      MessageDlg('E-mail address successfully changed. Please check your inbox for confirmation link.', mtInformation, [mbOK], 0);
      Close;
    end;
    cmDuplicateMail: begin
      MessageDlg('E-mail address is already in use', mtError, [mbOK], 0);
      edNewMail.SetFocus;
      acOK.Enabled := TRUE;
    end;
    cmInvalidEmail: begin
      MessageDlg('Invalid E-mail address', mtError, [mbOK], 0);
      edNewMail.SetFocus;
      acOK.Enabled := TRUE;
    end;
  end;
end;

end.
