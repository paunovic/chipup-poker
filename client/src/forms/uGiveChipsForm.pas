unit uGiveChipsForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  cxTextEdit, cxLabel, cxMaskEdit, cxSpinEdit, Vcl.Menus, Vcl.StdCtrls, cxButtons, Vcl.ActnList, uClubInfo,
  uPlayerInfo, uIFormParams, uMessageItem, dxsChipUpDark, dxsChipUpDarkTabs, dxsChipUpRedButton;

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
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    FClub  : TClubInfo;
    FPlayer: TPlayerInfo;

    procedure CSRTransferChipsOk(const AMessage: TMessageItem);

  protected
    procedure WndProc(var AMessage: TMessage); override;

  public
    procedure SetParams(const AParams: array of pointer);
  end;


implementation

{$R *.dfm}

uses
  uSocketClient, uServerCodes, uMainDataModule, uCommon, uMessageContainer, uServerMessageCallback;


procedure TfrmGiveChips.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);
end;

procedure TfrmGiveChips.FormShow(Sender: TObject);
begin
  MessageContainer.AddMessageHandler(Handle);
end;

procedure TfrmGiveChips.WndProc(var AMessage: TMessage);
var
  msg: TMessageItem;
begin
  inherited;

  if MessageContainer.IsNewMessage(AMessage, msg) then
  begin
    case msg.MessageType of
      mtServerResponse: ProcessServerMessage(msg,
                          [
                            TServerMessageCallback.Create(srTransferChipsOk, CSRTransferChipsOk)
                          ]
                        );
    end;

    msg.IncReadCount;
  end;
end;

procedure TfrmGiveChips.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: acCancel.Execute;
    VK_RETURN: if seChipAmount.Focused then
                 acOK.Execute;
  end;
end;


procedure TfrmGiveChips.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Ord(Key) of
    VK_ESCAPE: begin
      acCancel.Execute;
      Key := #0;
    end;
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
  if (seChipAmount.Value <= 0) or (seChipAmount.Value > dmMain.SelfInfo.Balance) then
  begin
    MessageDlg('Invalid chip amount', mtError, [mbOK], 0);
    seChipAmount.SetFocus;
    Exit;
  end;

  SocketClient.TransferChips(FPlayer.Id, seChipAmount.Value * 100);
end;

procedure TfrmGiveChips.CSRTransferChipsOk(const AMessage: TMessageItem);
begin
  MessageDlg('Chips successfully transferred', mtInformation, [mbOK], 0);
  ModalResult := mrOk;
end;

end.

