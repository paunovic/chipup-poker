unit uChangeClubDetailsForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  Vcl.StdCtrls, cxRadioGroup, cxLabel, cxTextEdit, Vcl.Menus, cxButtons, uClubInfo, Vcl.ActnList, uIFormParams,
  uMessageItem, dxsChipUpDark;

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
    btOK: TcxButton;
    btCancel: TcxButton;
    acCancel: TAction;
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acOKExecute(Sender: TObject);
    procedure acCancelExecute(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    FClub: TClubInfo;

    procedure CSRClubDetailsChange(const AMessage: TMessageItem);
  protected
    procedure WndProc(var AMessage: TMessage); override;
  public
    procedure SetParams(const AParams: array of pointer);
  end;


implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} uDebugForm, {$ENDIF}
  uMainDataModule, uServerCodes, uCommon, uValidators, uSocketClient, uMessageContainer, uServerMessageCallback, uPB_ClubCommandReply;


procedure TfrmChangeClubDetails.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);
end;

procedure TfrmChangeClubDetails.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Ord(Key) of
    VK_ESCAPE: begin
      acCancel.Execute;
      Key := #0;
    end;
    VK_RETURN: begin
      if not edInvitationCode.Focused then
        SelectNext(ActiveControl, TRUE, TRUE);
      Key := #0;
    end;
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
var
  msg: TMessageItem;
begin
  inherited;

  if MessageContainer.IsNewMessage(AMessage, msg) then
  begin
    case msg.MessageType of
      mtServerResponse: ProcessServerMessage(msg,
                          [
                            TServerMessageCallback.Create(srChangeClubDetailsReply, CSRClubDetailsChange)
                          ]
                        );
    end;

    msg.IncReadCount;
  end;
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

procedure TfrmChangeClubDetails.CSRClubDetailsChange(const AMessage: TMessageItem);
var
  pbreply: TPB_ClubCommandReply;
begin
  pbreply := AMessage.Object_ as TPB_ClubCommandReply;

  case pbreply.Status of
    csSuccess: ModalResult := mrOk;
    csNameExists: begin
      MessageDlg('Club name already exists', mtError, [mbOk], 0);
      edClubName.SetFocus;
    end;
  else
    {$IFDEF DEBUG} DebugLn(Format('CSRClubDetailsChange: invalid status received [%d]]', [Integer(pbreply.Status)]), ditException); {$ENDIF}
  end;

  acOK.Enabled := TRUE;
end;

end.
