unit uCreateClubForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, dxSkinsCore, dxSkinDevExpressStyle, cxLookAndFeels, dxSkinsForm, cxGraphics, cxControls,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel, cxTextEdit, Vcl.StdCtrls, cxRadioGroup, Vcl.Menus, cxButtons, Vcl.ActnList,
  uMessageItem;

type
  TfrmCreateClub = class(TForm)
    edClubName: TcxTextEdit;
    lbsClubName: TcxLabel;
    edClubCode: TcxTextEdit;
    lbsInvCode: TcxLabel;
    lbsClubType: TcxLabel;
    rbPrivate: TcxRadioButton;
    rbPublic: TcxRadioButton;
    alCreateClub: TActionList;
    acOK: TAction;
    lbInfo: TcxLabel;
    btOK: TcxButton;
    btCancel: TcxButton;
    acCancel: TAction;
    procedure acOKExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure acCancelExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure TCCreateClubOk(const AMessage: TMessageItem);
    procedure TCCreateClubNameExists(const AMessage: TMessageItem);
    procedure TCCreateClubInvalidName(const AMessage: TMessageItem);
    procedure TCCreateClubInvalidCode(const AMessage: TMessageItem);
    procedure TCCreateClubNoGold(const AMessage: TMessageItem);

  protected
    procedure WndProc(var AMessage: TMessage); override;
  public
  end;

implementation

{$R *.dfm}

uses
  uSocketClient, uCommon, uServerCodes, uValidators, uMainDataModule, uMessageContainer,
  uServerMessageCallback;


procedure TfrmCreateClub.FormCreate(Sender: TObject);
begin
  dmMain.MakeTokenCostMessage(lbInfo, 'Club creation', dmMain.ServerSettings.TokenPrices.ClubCreation);

  edClubName.Properties.MaxLength := dmMain.ServerSettings.StringLengths.ClubName;
  edClubCode.Properties.MaxLength := dmMain.ServerSettings.StringLengths.ClubInvCode;
end;

procedure TfrmCreateClub.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);
end;

procedure TfrmCreateClub.FormShow(Sender: TObject);
begin
  MessageContainer.AddMessageHandler(Handle);
end;

procedure TfrmCreateClub.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: acCancel.Execute;
    VK_RETURN: if not edClubCode.Focused then
                 SelectNext(ActiveControl, TRUE, TRUE);
  end;
end;

procedure TfrmCreateClub.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmCreateClub.acOKExecute(Sender: TObject);
var
  error: String;
begin
  if not ValidateClubName(edClubName.Text, error) then
    edClubName.SetFocus
  else
    if not ValidateClubCode(edClubCode.Text, error) then
      edClubCode.SetFocus
    else
      if not ValidatePrivateClubCode(rbPrivate.Checked, edClubCode.Text, error) then
        edClubCode.SetFocus;

  if error <> '' then
  begin
    MessageDlg(error, mtError, [mbOK], 0);
    Exit;
  end;

  acOK.Enabled := FALSE;
  SocketClient.CreateClub(edClubName.Text, edClubCode.Text, rbPrivate.Checked);
end;

procedure TfrmCreateClub.WndProc(var AMessage: TMessage);
var
  msg: TMessageItem;
begin
  inherited;

  if MessageContainer.IsNewMessage(AMessage, msg) then
  begin
    case msg.MessageType of
      mtServerResponse: ProcessServerMessage(msg,
                           [
                             TServerMessageCallback.Create(SR_CREATECLUB_OK, TCCreateClubOk),
                             TServerMessageCallback.Create(SR_CREATECLUB_NAME_EXISTS, TCCreateClubNameExists),
                             TServerMessageCallback.Create(SR_CREATECLUB_INVALID_NAME, TCCreateClubInvalidName),
                             TServerMessageCallback.Create(SR_CREATECLUB_INVALID_CODE, TCCreateClubInvalidCode),
                             TServerMessageCallback.Create(SR_CREATECLUB_NO_TOKENS, TCCreateClubNoGold)
                           ]
                         );
    end;

    msg.IncReadCount;
  end;
end;

procedure TfrmCreateClub.TCCreateClubInvalidCode(const AMessage: TMessageItem);
begin
  MessageDlg('Invalid club code', mtError, [mbOK], 0);
  edClubCode.SetFocus;
  acOK.Enabled := TRUE;
end;

procedure TfrmCreateClub.TCCreateClubInvalidName(const AMessage: TMessageItem);
begin
  MessageDlg('Invalid club name', mtError, [mbOK], 0);
  edClubName.SetFocus;
  acOK.Enabled := TRUE;
end;

procedure TfrmCreateClub.TCCreateClubNoGold(const AMessage: TMessageItem);
begin
  MessageDlg('You don''t have enough tokens to create new club. You can get some at our site!', mtWarning, [mbOK], 0);
  acOK.Enabled := TRUE;
end;

procedure TfrmCreateClub.TCCreateClubNameExists(const AMessage: TMessageItem);
begin
  MessageDlg('Club name already exists', mtError, [mbOK], 0);
  edClubName.SetFocus;
  acOK.Enabled := TRUE;
end;

procedure TfrmCreateClub.TCCreateClubOk(const AMessage: TMessageItem);
begin
  MessageDlg('Club created successfully!', mtInformation, [mbOK], 0);
  ModalResult := mrOk;
end;

end.
