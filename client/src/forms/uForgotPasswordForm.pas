unit uForgotPasswordForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.StdCtrls, Vcl.ActnList, cxGraphics, cxLookAndFeels, cxLookAndFeelPainters,
  Vcl.Menus, dxSkinsCore, cxButtons, cxControls, cxContainer, cxEdit, cxLabel, cxTextEdit, dxSkinsForm, dxsChipUpDark, dxsChipUpDarkTabs;

type
  TfrmForgotPassword = class(TForm)
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
