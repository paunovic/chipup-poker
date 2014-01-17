unit uJoinClubForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  Vcl.Menus, Vcl.StdCtrls, cxButtons, cxLabel, cxTextEdit, Vcl.ActnList, dxSkinsForm, cxMaskEdit, cxSpinEdit,
  uIFormParams, uMessageItem, dxSkinDarkRoom;

type
  TfrmJoinClub = class(TForm, IFormParams)
    lbsClubID: TcxLabel;
    edClubCode: TcxTextEdit;
    lbsInvCode: TcxLabel;
    alJoinClub: TActionList;
    acOk: TAction;
    edClubID: TcxSpinEdit;
    btOK: TcxButton;
    btCancel: TcxButton;
    acCancel: TAction;
    procedure acOkExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edClubIDPropertiesChange(Sender: TObject);
    procedure acCancelExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure TCJoinClubOk(const AMessage: TMessageItem);
    procedure TCJoinClubInvalidId(const AMessage: TMessageItem);
    procedure TCJoinClubInvalidCode(const AMessage: TMessageItem);
    procedure TCJoinClubAlreadyMember(const AMessage: TMessageItem);
  protected
    procedure WndProc(var AMessage: TMessage); override;
  public
    procedure SetParams(const AParams: array of pointer);
  end;

implementation

{$R *.dfm}

uses
  uSocketClient, uCommon, uServerCodes, uMainDataModule, uMessageContainer, uServerMessageCallback;


procedure TfrmJoinClub.edClubIDPropertiesChange(Sender: TObject);
begin
  if edClubID.Value > edClubID.Properties.MaxValue then
    edClubID.Value := edClubID.Properties.MaxValue;
end;

procedure TfrmJoinClub.FormCreate(Sender: TObject);
begin
  edClubCode.Properties.MaxLength := dmMain.ServerSettings.StringLengths.ClubInvCode;
end;

procedure TfrmJoinClub.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);
end;

procedure TfrmJoinClub.FormShow(Sender: TObject);
begin
  MessageContainer.AddMessageHandler(Handle);
end;

procedure TfrmJoinClub.SetParams(const AParams: array of pointer);
begin
  edClubCode.TabOrder := 0;
  edClubID.TabOrder := 1;
  edClubID.Text := IntToStr(PInt64(AParams[0])^);
end;

procedure TfrmJoinClub.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: acCancel.Execute;
    VK_RETURN: if not edClubCode.Focused then
                 SelectNext(ActiveControl, TRUE, TRUE)
               else
                 acOk.Execute;
  end;
end;

procedure TfrmJoinClub.WndProc(var AMessage: TMessage);
var
  msg: TMessageItem;
begin
  inherited;

  if MessageContainer.IsNewMessage(AMessage, msg) then
  begin
    case msg.MessageType of
      mtServerResponse: ProcessServerMessage(msg,
                           [
                             TServerMessageCallback.Create(SR_JOINCLUB_OK , TCJoinClubOk),
                             TServerMessageCallback.Create(SR_JOINCLUB_INVALID_ID, TCJoinClubInvalidId),
                             TServerMessageCallback.Create(SR_JOINCLUB_INVALID_CODE, TCJoinClubInvalidCode),
                             TServerMessageCallback.Create(SR_JOINCLUB_ALREADY_MEMBER, TCJoinClubAlreadyMember)
                           ]
                         );
    end;

    msg.IncReadCount;
  end;
end;

procedure TfrmJoinClub.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmJoinClub.acOkExecute(Sender: TObject);
begin
  acOK.Enabled := FALSE;
  SocketClient.JoinClub(edClubID.Value, edClubCode.Text);
end;

procedure TfrmJoinClub.TCJoinClubAlreadyMember(const AMessage: TMessageItem);
begin
  MessageDlg('You are already member of this club', mtInformation, [mbOK], 0);
  edClubID.SetFocus;
  acOK.Enabled := TRUE;
end;

procedure TfrmJoinClub.TCJoinClubInvalidCode(const AMessage: TMessageItem);
begin
  MessageDlg('Invalid club code', mtError, [mbOK], 0);
  edClubCode.SetFocus;
  acOK.Enabled := TRUE;
end;

procedure TfrmJoinClub.TCJoinClubInvalidId(const AMessage: TMessageItem);
begin
  MessageDlg('Invalid club ID', mtError, [mbOK], 0);
  edClubID.SetFocus;
  acOK.Enabled := TRUE;
end;

procedure TfrmJoinClub.TCJoinClubOk(const AMessage: TMessageItem);
begin
  MessageDlg('Successfully joined', mtInformation, [mbOK], 0);
  ModalResult := mrOk;
end;


end.
