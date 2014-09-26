unit Poker.Forms.ForgotPassword;

interface

uses
  Winapi.Windows, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ActnList,
  cxButtons, cxLabel, cxTextEdit, Poker.Interfaces.ModalForm, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer,
  cxEdit, dxSkinsCore, ChipUpPokerDarkSkin, Vcl.Menus, Vcl.StdCtrls;

type
  TfrmForgotPassword = class(TForm, IModalForm)
    alForgotPassword: TActionList;
    acOK: TAction;
    acCancel: TAction;
    edEMail: TcxTextEdit;
    lbsEMail: TcxLabel;
    lbsInfo: TcxLabel;
    btOK: TcxButton;
    btCancel: TcxButton;
    procedure acOKExecute(Sender: TObject);
    procedure acCancelExecute(Sender: TObject);
    procedure edEmailChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
  private
    FCloseCallback: TNotifyEvent;
  public
    procedure SetCloseCallback(const ACallback: TNotifyEvent);
  end;

implementation

{$R *.dfm}

uses
  Poker.Server.Socket, Poker.Server.Validators, Poker.Server.Settings, Poker.Common.FormsContainer;


procedure TfrmForgotPassword.FormCreate(Sender: TObject);
begin
  edEMail.Properties.MaxLength := ServerSettings.MaxStringLengths.Password;
end;

procedure TfrmForgotPassword.FormDestroy(Sender: TObject);
begin
  FormsContainer.Remove(self);
end;

procedure TfrmForgotPassword.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  if Assigned(FCloseCallback) then
    FCloseCallback(self);
end;


procedure TfrmForgotPassword.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Ord(Key) of
    VK_RETURN: begin
      acOK.Execute;
      Key := #0;
    end;
    VK_ESCAPE: begin
      acCancel.Execute;
      Key := #0;
    end;
  end;
end;

procedure TfrmForgotPassword.SetCloseCallback(const ACallback: TNotifyEvent);
begin
  FCloseCallback := ACallback;
end;

procedure TfrmForgotPassword.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
  Close;
end;

procedure TfrmForgotPassword.acOKExecute(Sender: TObject);
begin
  acOK.Enabled := FALSE;
  ServerSocket.ForgotPassword(edEmail.Text);
  MessageDlg('You should soon receive password reset instructions in your inbox.', mtInformation, [mbOK], 0);
  ModalResult := mrOk;
  Close;
end;

procedure TfrmForgotPassword.edEmailChange(Sender: TObject);
var
  error: String;
begin
  acOK.Enabled := ValidateEMail(edEmail.Text, error);
end;

end.
