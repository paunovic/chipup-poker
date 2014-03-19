unit Poker.Forms.ChangeClubDetails;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, Vcl.StdCtrls, cxRadioGroup, cxLabel,
  cxTextEdit, cxButtons, Poker.Objects.ClubInfo, Vcl.ActnList, Poker.Interfaces.FormParams, dxsChipUpDark,
  dxsChipUpDarkTabs, dxsChipUpRedButton, Poker.Interfaces.ModalForm, Vcl.Menus;

type
  TfrmChangeClubDetails = class(TForm, IFormParams, IModalForm)
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
    procedure acOKExecute(Sender: TObject);
    procedure acCancelExecute(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
  private
    FCallbacksId: Integer;
    FClub: TClubInfo;
    FCloseCallback: TNotifyEvent;

    procedure CSRClubDetailsChange(const AMethodId: Integer; const AObject: TObject);
  protected
  public
    procedure SetParams(const AParams: array of pointer);
    procedure SetCloseCallback(const ACallback: TNotifyEvent);
  end;


implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Poker.Protobufs.Enum.ServerCodes, Poker.Common.Misc, Poker.Server.Validators, Poker.Server.Socket, Poker.Server.MessageCallbacks, Poker.Protobufs.Objects.ClubCommandReply, Poker.Server.MessageContainer,
  Poker.Common.FormsContainer;


procedure TfrmChangeClubDetails.FormCreate(Sender: TObject);
begin
  FCallbacksId := MessageContainer.AddCallbacks([
                     TServerMessageCallback.Create(srChangeClubDetailsReply, CSRClubDetailsChange)
                  ])
end;

procedure TfrmChangeClubDetails.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.Remove(self);
end;

procedure TfrmChangeClubDetails.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  if Assigned(FCloseCallback) then
    FCloseCallback(self);
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

procedure TfrmChangeClubDetails.SetCloseCallback(const ACallback: TNotifyEvent);
begin
  FCloseCallback := ACallback;
end;

procedure TfrmChangeClubDetails.SetParams(const AParams: array of pointer);
begin
  FClub := AParams[0];

  edClubName.Text := FClub.Name;
  edInvitationCode.Text := FClub.InvCode;
  rbPrivate.Checked := FClub.IsPrivate;
  rbPublic.Checked := not rbPrivate.Checked;
end;

procedure TfrmChangeClubDetails.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
  Close;
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
  ServerSocket.ChangeClubDetails(FClub.Id, edClubName.Text, edInvitationCode.Text, rbPrivate.Checked, FClub.Rake);
end;

procedure TfrmChangeClubDetails.CSRClubDetailsChange(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_ClubCommandReply;
begin
  pbreply := AObject as TPB_ClubCommandReply;

  case pbreply.Status of
    csSuccess: begin
      ModalResult := mrOk;
      Close;
    end;
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
