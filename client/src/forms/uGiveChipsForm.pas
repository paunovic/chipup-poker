unit uGiveChipsForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinDevExpressStyle, cxTextEdit, cxLabel, cxMaskEdit, cxSpinEdit, Vcl.Menus, Vcl.StdCtrls, cxButtons, Vcl.ActnList, uClubInfo,
  uPlayerInfo, uIFormParams;

type
  TfrmGiveChips = class(TForm, IFormParams)
    lbsClubName: TcxLabel;
    edClubName: TcxTextEdit;
    lbsPlayerName: TcxLabel;
    edPlayerName: TcxTextEdit;
    lbsChipsAmount: TcxLabel;
    seChipAmount: TcxSpinEdit;
    alChipTransfer: TActionList;
    acOK: TAction;
    btOK: TcxButton;
    btCancel: TcxButton;
    acCancel: TAction;
    procedure acOKExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure acCancelExecute(Sender: TObject);
  private
    FClub  : TClubInfo;
    FPlayer: TPlayerInfo;

    procedure TCClubTransferChipsOk(const AData: TObject);
    procedure TCClubTransferChipsInvalidAmount(const AData: TObject);

  protected
    procedure WndProc(var AMessage: TMessage); override;

  public
    procedure SetParams(const AParams: array of pointer);
  end;


implementation

{$R *.dfm}

uses
  uSocketClient, uServerCodes, uMainDataModule, uCommon, uMessageContainer;


procedure TfrmGiveChips.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);
end;

procedure TfrmGiveChips.FormShow(Sender: TObject);
begin
  MessageContainer.AddMessageHandler(Handle);
end;

procedure TfrmGiveChips.WndProc(var AMessage: TMessage);
begin
  inherited;
                  {
  if SocketClient.IsServerResponseMessage(AMessage) then
    SocketClient.ParseWndMessage(AMessage,
      [
        TWndCallback.Create(SR_CLUB_TRANFER_CHIPS_OK, TCClubTransferChipsOk),
        TWndCallback.Create(SR_CLUB_TRANFER_CHIPS_INVALID_AMOUNT, TCClubTransferChipsInvalidAmount)
      ]
    );             }
end;

procedure TfrmGiveChips.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: acCancel.Execute;
  end;
end;


procedure TfrmGiveChips.SetParams(const AParams: array of pointer);
begin
  FClub := AParams[0];
  FPlayer := AParams[1];

  edClubName.Text := FClub.Name;
  edPlayerName.Text := FPlayer.Nick;
end;

procedure TfrmGiveChips.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmGiveChips.acOKExecute(Sender: TObject);
begin
  SocketClient.TransferChips(FClub.Id, FPlayer.Id, seChipAmount.Value);
end;

procedure TfrmGiveChips.TCClubTransferChipsInvalidAmount(const AData: TObject);
begin
  MessageDlg('Invalid chip amount to transfer', mtError, [mbOK], 0);
  seChipAmount.SetFocus;
end;

procedure TfrmGiveChips.TCClubTransferChipsOk(const AData: TObject);
begin
  MessageDlg('Chips successfully transferred', mtInformation, [mbOK], 0);
  ModalResult := mrOk;
end;

end.

