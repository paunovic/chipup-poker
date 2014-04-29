unit Poker.Forms.ChangePassword;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  cxTextEdit, cxLabel, Vcl.StdCtrls, cxButtons, Vcl.ActnList, Vcl.Menus, ChipUpPokerDarkSkin;

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
    procedure acCancelExecute(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
  private
    FCallbacksId: Integer;

    procedure CSRChangePasswordOk(const AMethodId: Integer; const AObject: TObject);
  protected
  public
  end;

implementation

{$R *.dfm}

uses
  Poker.DataModule, Poker.Server.Validators, Poker.Server.Socket, Poker.Protobufs.Enum.ServerCodes, Poker.Common.Misc, Poker.Server.MessageCallbacks, Poker.Server.MessageContainer, Poker.Server.Settings, Poker.Common.FormsContainer;


procedure TfrmChangePassword.FormCreate(Sender: TObject);
begin
  FCallbacksId := MessageContainer.AddCallbacks([
                      TServerMessageCallback.Create(srChangePasswordOk, CSRChangePasswordOk)
                   ]);

  edNewPassword.Properties.MaxLength := ServerSettings.MaxStringLengths.Password;
  edCurrentPassword.Properties.MaxLength := ServerSettings.MaxStringLengths.Password;
  edConfirmPassword.Properties.MaxLength := ServerSettings.MaxStringLengths.Password;
end;

procedure TfrmChangePassword.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.Remove(self);
end;

procedure TfrmChangePassword.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
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
  ServerSocket.ChangePassword(edNewPassword.Text);
end;

procedure TfrmChangePassword.CSRChangePasswordOk(const AMethodId: Integer; const AObject: TObject);
begin
  MessageDlg('Password successfully changed', mtInformation, [mbOK], 0);
  dmMain.SelfInfo.Password := edNewPassword.Text;
  Close;
end;

procedure TfrmChangePassword.acCancelExecute(Sender: TObject);
begin
  Close;
end;



end.
