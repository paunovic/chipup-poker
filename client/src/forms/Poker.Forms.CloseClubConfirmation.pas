unit Poker.Forms.CloseClubConfirmation;

interface

uses
  Winapi.Windows, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Poker.Interfaces.FormParams, Poker.Interfaces.ModalForm,
  Poker.Clubs.Club, Vcl.ActnList, cxButtons, cxTextEdit, cxLabel, cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, Vcl.Menus,
  dxSkinsCore, ChipUpPokerDarkSkin, cxControls, cxContainer, cxEdit, Vcl.StdCtrls, System.SysUtils, Poker.Types;

type
  TfrmCloseClubConfirmation = class(TForm, IFormParams, IModalForm)
    btConfirm: TcxButton;
    btCancel: TcxButton;
    alCloseClub: TActionList;
    acCancel: TAction;
    acConfirm: TAction;
    lbsWarning1: TcxLabel;
    lbsWarning2: TcxLabel;
    edPassword: TcxTextEdit;
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure acCancelExecute(Sender: TObject);
    procedure acConfirmExecute(Sender: TObject);
    procedure edPasswordKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure edPasswordPropertiesChange(Sender: TObject);
  private
    FClubId: TMongoId;
    FCloseCallback: TNotifyEvent;
  protected
  public
    procedure SetParams(const AParams: array of pointer);
    procedure SetCloseCallback(const ACallback: TNotifyEvent);
  end;

implementation

{$R *.dfm}

uses
  Poker.Common.FormsContainer, Poker.Server.Settings, Poker.Server.Validators, Poker.DataModule;

{ TfrmCloseClubConfirmation }


procedure TfrmCloseClubConfirmation.FormDestroy(Sender: TObject);
begin
  FormsContainer.Remove(self);
end;

procedure TfrmCloseClubConfirmation.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  if Assigned(FCloseCallback) then
    FCloseCallback(self);
end;

procedure TfrmCloseClubConfirmation.FormCreate(Sender: TObject);
begin
  edPassword.Properties.MaxLength := ServerSettings.MaxStringLengths.Password;
end;

procedure TfrmCloseClubConfirmation.SetCloseCallback(const ACallback: TNotifyEvent);
begin
  FCloseCallback := ACallback;
end;

procedure TfrmCloseClubConfirmation.SetParams(const AParams: array of pointer);
begin
  FClubId := AParams[0];
end;

procedure TfrmCloseClubConfirmation.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = vk_RETURN then
    acConfirm.Execute;
end;

procedure TfrmCloseClubConfirmation.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrClose;
  Close;
end;

procedure TfrmCloseClubConfirmation.acConfirmExecute(Sender: TObject);
var
  club: TClubInfo;
  clubpass: String;
begin
  clubpass := '';
  if dmMain.SelfInfo.Clubs.GetAndLock(FClubId, club) then
  try
    clubpass := club.Password;
  finally
    dmMain.SelfInfo.Clubs.Unlock;
  end;

  if edPassword.Text = clubpass then
  begin
    ModalResult := mrOk;
    Close;
  end
  else
  begin
    MessageDlg('Incorrect password', mtError, [mbOK], 0);
    edPassword.SelectAll;
  end;
end;

procedure TfrmCloseClubConfirmation.edPasswordKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = vk_RETURN then
    acConfirm.Execute;
end;

procedure TfrmCloseClubConfirmation.edPasswordPropertiesChange(Sender: TObject);
var
  err: String;
begin
  acConfirm.Enabled := ValidateClubPassword(edPassword.Text, err);
end;

end.
