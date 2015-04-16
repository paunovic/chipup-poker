unit Poker.Forms.ClubMemberOptions;

interface

uses
  System.SysUtils, System.Variants, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  cxLabel, cxCheckBox, cxSpinEdit, cxButtons, Vcl.ActnList, Poker.Interfaces.FormParams,
  Poker.Interfaces.ModalForm, Poker.Clubs.Club, cxGraphics, cxLookAndFeels, Poker.Types,
  cxLookAndFeelPainters, Vcl.Menus, dxSkinsCore, ChipUpPokerDarkSkin, cxControls,
  cxContainer, cxEdit, cxTextEdit, cxMaskEdit, Vcl.StdCtrls;

type
  TfrmClubMemberOptions = class(TForm, IFormParams, IModalForm)
    btOK: TcxButton;
    btCancel: TcxButton;
    seLimit: TcxSpinEdit;
    cbUnlimited: TcxCheckBox;
    lbsLimit: TcxLabel;
    alClubMemberOptions: TActionList;
    acOK: TAction;
    acCancel: TAction;
    procedure cbUnlimitedPropertiesChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure acCancelExecute(Sender: TObject);
    procedure acOKExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FCallbacksId: Integer;
    FCloseCallback: TNotifyEvent;
    FClubId: TMongoId;
    FPlayerId: TMongoId;

    procedure CSRPlayerLimitOk(const AMethodId: Integer; const AObject: TObject);
  public
    procedure SetParams(const AParams: array of pointer);
    procedure SetCloseCallback(const ACallback: TNotifyEvent);
  end;

implementation

{$R *.dfm}

uses
  Poker.Common.FormsContainer, Poker.Server.Socket, Poker.Server.MessageContainer, Poker.Server.MessageCallbacks, Poker.Common.Misc,
  Poker.Protobufs.Enum.ServerCodes, Poker.DataModule, Poker.Protobufs.Objects.ClubMember, Poker.Common.ModalDialogs;


procedure TfrmClubMemberOptions.FormCreate(Sender: TObject);
begin
  FCallbacksId := MessageContainer.AddCallbacks(self.Name, [
                     TServerMessageCallback.Create(srPlayerLimitOk, CSRPlayerLimitOk)
                  ])
end;

procedure TfrmClubMemberOptions.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.Remove(self);
end;

procedure TfrmClubMemberOptions.SetCloseCallback(const ACallback: TNotifyEvent);
begin
  FCloseCallback := ACallback;
end;

procedure TfrmClubMemberOptions.SetParams(const AParams: array of pointer);
var
  member: TPB_ClubMember;
  club: TClubInfo;
begin
  FClubId := AParams[0];
  FPlayerId := AParams[1];

  if dmMain.SelfInfo.Clubs.GetAndLock(FClubId, club) then
  try
    if club.GetMemberInfo(FPlayerId, member) then
    begin
      cbUnlimited.Checked := member.UnlimitedLimit;
      seLimit.Value := member.BalanceLimit / 100;
    end;
  finally
    dmMain.SelfInfo.Clubs.Unlock;
  end;
end;

procedure TfrmClubMemberOptions.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  if Assigned(FCloseCallback) then
    FCloseCallback(self);
end;


procedure TfrmClubMemberOptions.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
  Close;
end;

procedure TfrmClubMemberOptions.acOKExecute(Sender: TObject);
var
  limit_float: Single;
  limit: UINT32;
  err: String;
begin
  err := '';
  if (not TryStrToFloat(seLimit.Value, limit_float)) or
     (limit_float > seLimit.Properties.MaxValue) then
    err := 'Invalid limit';

  if err <> '' then
  begin
    ModalDialogs.ShowWarning(err);
    Exit;
  end;

  limit := Trunc(limit_float * 100);

  ServerSocket.SetPlayerLimit(FClubId, FPlayerId, limit, cbUnlimited.Checked);
end;

procedure TfrmClubMemberOptions.cbUnlimitedPropertiesChange(Sender: TObject);
begin
  seLimit.Enabled := not cbUnlimited.Checked;
end;

procedure TfrmClubMemberOptions.CSRPlayerLimitOk(const AMethodId: Integer; const AObject: TObject);
begin
  ModalResult := mrOk;
  Close;
end;

end.
