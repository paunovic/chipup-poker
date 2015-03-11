unit Poker.Forms.ChangeClubDetails;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, cxContainer, cxLabel, cxTextEdit, cxButtons, Poker.Clubs.Club,
  Vcl.ActnList, Poker.Interfaces.FormParams, Poker.Interfaces.ModalForm, cxSpinEdit,
  cxCheckBox, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxEdit,
  dxSkinsCore, ChipUpPokerDarkSkin, Vcl.Menus, cxMaskEdit, Vcl.StdCtrls, Poker.Types,
  cxDropDownEdit;

type
  TfrmChangeClubDetails = class(TForm, IFormParams, IModalForm)
    lbsClubName: TcxLabel;
    edClubName: TcxTextEdit;
    lbsInvitationCode: TcxLabel;
    edInvitationCode: TcxTextEdit;
    acChangeClubDetails: TActionList;
    acOK: TAction;
    btOK: TcxButton;
    btCancel: TcxButton;
    acCancel: TAction;
    cbDefaultPlayerLimit: TcxCheckBox;
    seLimit: TcxSpinEdit;
    seRake: TcxSpinEdit;
    lbsClubRake: TcxLabel;
    lbsResetBuyinLimits: TcxLabel;
    cbResetBuyinLimits: TcxComboBox;
    lbsResetBuyinMinutes: TcxLabel;
    lbsMaxRakePerHand: TcxLabel;
    seMaxRakePerHand: TcxSpinEdit;
    procedure acOKExecute(Sender: TObject);
    procedure acCancelExecute(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure cbDefaultPlayerLimitPropertiesChange(Sender: TObject);
  private
    FCallbacksId: Integer;
    FClubId: TMongoId;
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
  Poker.Protobufs.Enum.ServerCodes, Poker.Common.Misc, Poker.Server.Validators, Poker.Server.Socket, Poker.Server.MessageCallbacks,
  Poker.Protobufs.Objects.ClubCommandReply, Poker.Server.MessageContainer, Poker.Common.FormsContainer, Poker.DataModule, Poker.Common.ModalDialogs,
  Poker.SoftExceptions;


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
var
  club: TClubInfo;
begin
  FClubId := AParams[0];
  if dmMain.SelfInfo.Clubs.GetAndLock(FClubId, club) then
  try
    edClubName.Text := club.Name;
    edInvitationCode.Text := club.Password;
    seRake.Value := club.Rake;
    seMaxRakePerHand.Value := club.MaxRakePerHand;
    seLimit.Value := club.DefaultBalanceLimit / 100;
    cbDefaultPlayerLimit.Checked := not club.UnlimitedDefaultBalance;
    cbResetBuyinLimits.Text := IntToStr(club.BuyinReset);
  finally
    dmMain.SelfInfo.Clubs.Unlock;
  end;
end;

procedure TfrmChangeClubDetails.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
  Close;
end;

procedure TfrmChangeClubDetails.acOKExecute(Sender: TObject);
var
  error: String;
  rake: Integer;
  limit: Single;
  limituint: UINT32;
begin
  if not ValidateClubName(edClubName.Text, error) then
    edClubName.SetFocus
  else
    if not ValidateClubPassword(edInvitationCode.Text, error) then
      edInvitationCode.SetFocus
    else
      if (not TryStrToInt(StringReplace(seRake.Text, '%', '', [rfReplaceAll]), rake)) or
         (rake < Round(seRake.Properties.MinValue)) or (rake > Round(seRake.Properties.MaxValue)) then
      begin
        error := 'Invalid rake';
        seRake.SetFocus;
      end
      else
        if (not TryStrToFloat(seLimit.Text, limit)) or
           (limit < 1) then
        begin
          error := 'Invalid player limit';
          seLimit.SetFocus;
        end;

  if error <> '' then
  begin
    ModalDialogs.ShowWarning(error);
    Exit;
  end;

  limituint := Trunc(limit * 100);

  acOK.Enabled := FALSE;
  ServerSocket.ChangeClubDetails(FClubId, edClubName.Text, edInvitationCode.Text, rake,
      limituint, seMaxRakePerHand.Value, not cbDefaultPlayerLimit.Checked, StrToInt(cbResetBuyinLimits.Text));
end;

procedure TfrmChangeClubDetails.cbDefaultPlayerLimitPropertiesChange(Sender: TObject);
begin
  seLimit.Enabled := cbDefaultPlayerLimit.Checked;
end;

procedure TfrmChangeClubDetails.CSRClubDetailsChange(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_ClubCommandReply;
begin
  if not TTypes.TryCast<TPB_ClubCommandReply>(AObject, pbreply) then
    Exit;
  if pbreply.Club.MongoId <> FClubId then
    Exit;

  case pbreply.Status of
    csSuccess: begin
      ModalResult := mrOk;
      Close;
    end;
    csNameExists: begin
      ModalDialogs.ShowWarning('Club name already exists');
      edClubName.SetFocus;
    end;
  else
    SoftException(Format('CSRClubDetailsChange: invalid status received [%d]]', [Integer(pbreply.Status)]));
  end;

  acOK.Enabled := TRUE;
end;

end.
