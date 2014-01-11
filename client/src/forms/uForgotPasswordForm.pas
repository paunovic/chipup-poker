unit uForgotPasswordForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.StdCtrls, Vcl.ActnList, cxGraphics, cxLookAndFeels, cxLookAndFeelPainters,
  Vcl.Menus, dxSkinsCore, dxSkinDevExpressStyle, cxButtons, cxControls, cxContainer, cxEdit, cxLabel, cxTextEdit, dxSkinsForm;

type
  TfrmForgotPassword = class(TForm)
    alForgotPassword: TActionList;
    acOK: TAction;
    acCancel: TAction;
    btOk: TcxButton;
    btCancel: TcxButton;
    edEMail: TcxTextEdit;
    lbsEMail: TcxLabel;
    cxLabel1: TcxLabel;
    procedure acOKExecute(Sender: TObject);
    procedure acCancelExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edEmailChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
  public
  end;

implementation

{$R *.dfm}

uses
  uSocketClient, uValidators, uMainDataModule;

procedure TfrmForgotPassword.FormCreate(Sender: TObject);
begin
  edEMail.Properties.MaxLength := dmMain.ServerSettings.StringLengths.Password;
end;

procedure TfrmForgotPassword.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_RETURN: acOK.Execute;
    VK_ESCAPE: acCancel.Execute;
  end;
end;

procedure TfrmForgotPassword.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmForgotPassword.acOKExecute(Sender: TObject);
begin
  acOK.Enabled := FALSE;
  SocketClient.ForgotPassword(edEmail.Text);
  MessageDlg('You should soon receive password reset instructions in your inbox', mtInformation, [mbOK], 0);
  ModalResult := mrOk;
end;

procedure TfrmForgotPassword.edEmailChange(Sender: TObject);
var
  error: String;
begin
  acOK.Enabled := ValidateEMail(edEmail.Text, error);
end;

end.
