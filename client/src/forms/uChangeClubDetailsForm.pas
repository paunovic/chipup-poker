unit uChangeClubDetailsForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinDevExpressStyle, Vcl.StdCtrls, cxRadioGroup, cxLabel, cxTextEdit, Vcl.Menus, cxButtons, uClubInfo, Vcl.ActnList, uIFormParams;

type
  TfrmChangeClubDetails = class(TForm, IFormParams)
    lbsClubType: TcxLabel;
    rbPrivate: TcxRadioButton;
    rbPublic: TcxRadioButton;
    lbsClubName: TcxLabel;
    edClubName: TcxTextEdit;
    lbsInvitationCode: TcxLabel;
    edInvitationCode: TcxTextEdit;
    acChangeClubDetails: TActionList;
    acOK: TAction;
    lbInfo: TcxLabel;
    btOK: TcxButton;
    btCancel: TcxButton;
    acCancel: TAction;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure acOKExecute(Sender: TObject);
    procedure acCancelExecute(Sender: TObject);
  private
    FClub: TClubInfo;

    procedure TCClubDetailsChangeOk(const AData: TObject);
    procedure TCClubDetailsChangeClubnameExists(const AData: TObject);
    procedure TCClubDetailsChangeNoGold(const AData: TObject);
  protected
    procedure WndProc(var AMessage: TMessage); override;
  public
    procedure SetParams(const AParams: array of pointer);
  end;


implementation

{$R *.dfm}

uses
  uMainDataModule, uServerCodes, uCommon, uValidators, uSocketClient, uMessageContainer;


procedure TfrmChangeClubDetails.FormCreate(Sender: TObject);
begin
  dmMain.MakeTokenCostMessage(lbInfo, 'Changing club details', dmMain.ServerSettings.TokenPrices.ClubChangeDetails);
end;

procedure TfrmChangeClubDetails.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);
end;

procedure TfrmChangeClubDetails.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: acCancel.Execute;
    VK_RETURN: if not edInvitationCode.Focused then
                 SelectNext(ActiveControl, TRUE, TRUE);
  end;
end;

procedure TfrmChangeClubDetails.FormShow(Sender: TObject);
begin
  MessageContainer.AddMessageHandler(Handle);
end;

procedure TfrmChangeClubDetails.SetParams(const AParams: array of pointer);
begin
  FClub := AParams[0];

  edClubName.Text := FClub.Name;
  edInvitationCode.Text := FClub.InvCode;
  rbPrivate.Checked := FClub.IsPrivate;
  rbPublic.Checked := not rbPrivate.Checked;
end;

procedure TfrmChangeClubDetails.WndProc(var AMessage: TMessage);
begin
  inherited;
                  {
  if SocketClient.IsServerResponseMessage(AMessage) then
    SocketClient.ParseWndMessage(AMessage,
      [
        TWndCallback.Create(SR_CLUB_DETAILS_CHANGE_OK, TCClubDetailsChangeOk),
        TWndCallback.Create(SR_CLUB_DETAILS_CLUBNAME_EXISTS, TCClubDetailsChangeClubnameExists),
        TWndCallback.Create(SR_CLUB_DETAILS_CHANGE_NO_GOLD, TCClubDetailsChangeNoGold)
      ]
    );             }
end;

procedure TfrmChangeClubDetails.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmChangeClubDetails.acOKExecute(Sender: TObject);
var
  error: String;
begin
  if not ValidateClubName(edClubName.Text, error) then
    edClubName.SetFocus
  else
    if not ValidateClubCode(edInvitationCode.Text, error) then
      edInvitationCode.SetFocus
    else
      if not ValidatePrivateClubCode(rbPrivate.Checked, edInvitationCode.Text, error) then
        edInvitationCode.SetFocus;

  if error <> '' then
  begin
    MessageDlg(error, mtError, [mbOK], 0);
    Exit;
  end;

  acOK.Enabled := FALSE;
  SocketClient.ChangeClubDetails(FClub.Id, edClubName.Text, edInvitationCode.Text, rbPrivate.Checked);
end;

procedure TfrmChangeClubDetails.TCClubDetailsChangeClubnameExists(const AData: TObject);
begin
  MessageDlg('Club name already exists', mtError, [mbOk], 0);
  edClubName.SetFocus;
  acOK.Enabled := TRUE;
end;

procedure TfrmChangeClubDetails.TCClubDetailsChangeNoGold(const AData: TObject);
begin
  MessageDlg('You don''t have enough tokens to change club details. You can get some at our site!', mtWarning, [mbYes], 0);
  edClubName.SetFocus;
  acOK.Enabled := TRUE;
end;

procedure TfrmChangeClubDetails.TCClubDetailsChangeOk(const AData: TObject);
begin
  ModalResult := mrOk;
end;

end.
