unit PokerClient.Forms.GiveChips;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  cxTextEdit, cxLabel, cxMaskEdit, cxSpinEdit, Vcl.StdCtrls, cxButtons, Vcl.ActnList, PokerClient.Objects.ClubInfo,
  PokerClient.Objects.PlayerInfo, PokerClient.Interfaces.FormParams,  dxsChipUpDark, dxsChipUpDarkTabs, dxsChipUpRedButton, PokerClient.Interfaces.ModalForm,
  Vcl.Menus;

type
  TfrmGiveChips = class(TForm, IFormParams, IModalForm)
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
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure acCancelExecute(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FCallbacksId: Integer;
    FClub: TClubInfo;
    FPlayer: TPlayerInfo;
    FCloseCallback: TNotifyEvent;

    procedure CSRTransferChipsOk(const AMethodId: Integer; const AObject: TObject);

  protected
  public
    procedure SetParams(const AParams: array of pointer);
    procedure SetCloseCallback(const ACallback: TNotifyEvent);
  end;


implementation

{$R *.dfm}

uses
  PokerClient.Server.Socket, PokerClient.Protobufs.Enum.ServerCodes, PokerClient.DataModule, PokerClient.Common.Misc, PokerClient.Server.MessageCallbacks, PokerClient.Server.MessageContainer, PokerClient.Common.FormsContainer;



procedure TfrmGiveChips.FormCreate(Sender: TObject);
begin
  FCallbacksId := MessageContainer.AddCallbacks([
                      TServerMessageCallback.Create(srTransferChipsOk, CSRTransferChipsOk)
                  ]);
end;

procedure TfrmGiveChips.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.Remove(self);
end;

procedure TfrmGiveChips.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;

  if Assigned(FCloseCallback) then
    FCloseCallback(self);
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

procedure TfrmGiveChips.SetCloseCallback(const ACallback: TNotifyEvent);
begin
  FCloseCallback := ACallback;
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
  Close;
end;

procedure TfrmGiveChips.acOKExecute(Sender: TObject);
begin
  if (seChipAmount.Value <= 0) or (seChipAmount.Value > dmMain.SelfInfo.Balance) then
  begin
    MessageDlg('Invalid chip amount', mtError, [mbOK], 0);
    seChipAmount.SetFocus;
    Exit;
  end;

  ServerSocket.TransferChips(FPlayer.Id, seChipAmount.Value * 100);
end;

procedure TfrmGiveChips.CSRTransferChipsOk(const AMethodId: Integer; const AObject: TObject);
begin
  MessageDlg('Chips successfully transferred', mtInformation, [mbOK], 0);
  ModalResult := mrOk;
  Close;
end;

end.

