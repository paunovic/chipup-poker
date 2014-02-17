unit uEditGameForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  Vcl.Menus, Vcl.ActnList, Vcl.StdCtrls, cxButtons, cxRadioGroup, cxLabel, cxTextEdit, cxMaskEdit, cxDropDownEdit,
  Vcl.Samples.Spin, cxSpinEdit, uGameInfo, uIFormParams, uMessageItem, dxsChipUpDark, dxsChipUpDarkTabs, dxsChipUpRedButton;

type
  TfrmEditGame = class(TForm, IFormParams)
    edGameName: TcxTextEdit;
    lbsGameName: TcxLabel;
    btOK: TcxButton;
    btCancel: TcxButton;
    alEditGame: TActionList;
    acOK: TAction;
    acCancel: TAction;
    lbsSeats: TcxLabel;
    cbSeats: TcxComboBox;
    lbsGameType: TcxLabel;
    cbGameType: TcxComboBox;
    lbsBlinds: TcxLabel;
    cbLimit: TcxComboBox;
    lbsLimit: TcxLabel;
    cbBlinds: TcxComboBox;
    procedure acOKExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acCancelExecute(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    FGame: TGameInfo;

    procedure CSREditGameOk(const AMessage: TMessageItem);
  protected
    procedure WndProc(var AMessage: TMessage); override;
  public
    procedure SetParams(const AParams: array of pointer);
  end;


implementation

{$R *.dfm}

uses
  uSocketClient, uServerCodes, uCommon, uMessageContainer, uServerMessageCallback, uPB_Game, uMainDataModule, uClubInfo;


procedure TfrmEditGame.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);
end;

procedure TfrmEditGame.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Ord(Key) of
    VK_ESCAPE: begin
      acCancel.Execute;
      Key := #0;
    end;
  end;
end;

procedure TfrmEditGame.FormShow(Sender: TObject);
begin
  MessageContainer.AddMessageHandler(Handle);
end;

procedure TfrmEditGame.SetParams(const AParams: array of pointer);
var
  cb_index, C1: Integer;
  blstr       : String;
begin
  FGame := AParams[0];

  edGameName.Text := FGame.Name;
  cbGameType.ItemIndex := Integer(FGame.GameType);
  cbLimit.ItemIndex := Integer(FGame.Limit);

  blstr := Format('%d/%d', [FGame.SmallBlind, FGame.BigBlind]);
  for C1 := 0 to cbBlinds.Properties.Items.Count - 1 do
    if cbBlinds.Properties.Items[C1] = blstr then
    begin
      cbBlinds.ItemIndex := C1;
      Break;
    end;

  cb_index := 0;
  for C1 := 0 to cbSeats.Properties.Items.Count - 1 do
    if cbSeats.Properties.Items[C1] = IntToStr(FGame.Seats) then
    begin
      cb_index := C1;
      Break;
    end;
  cbSeats.ItemIndex := cb_index;
end;

procedure TfrmEditGame.WndProc(var AMessage: TMessage);
var
  msg: TMessageItem;
begin
  inherited;

  if MessageContainer.IsNewMessage(AMessage, msg) then
  begin
    case msg.MessageType of
      mtServerResponse: ProcessServerMessage(msg,
                          [
                            TServerMessageCallback.Create(srEditGameOk, CSREditGameOk)
                          ]
                        );
    end;

    MessageContainer.RemoveMessageReader(AMessage.WParam, Handle);
  end;
end;


procedure TfrmEditGame.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmEditGame.acOKExecute(Sender: TObject);
var
  sb, bb: Integer;
begin
  if not GetBlinds(cbBlinds.Text, sb, bb) then
    Exit;

  acOK.Enabled := FALSE;
  SocketClient.EditGame(FGame.MongoId, edGameName.Text, cbGameType.ItemIndex, cbLimit.ItemIndex, sb * 100, bb * 100, StrToInt(cbSeats.Properties.Items[cbSeats.ItemIndex]));
end;

procedure TfrmEditGame.CSREditGameOk(const AMessage: TMessageItem);
begin
  ModalResult := mrOk;
end;


end.
