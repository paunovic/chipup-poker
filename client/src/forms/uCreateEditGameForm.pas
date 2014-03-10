unit uCreateEditGameForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  Vcl.Menus, Vcl.ActnList, Vcl.StdCtrls, cxButtons, cxRadioGroup, cxLabel, cxTextEdit, cxMaskEdit, cxDropDownEdit,
  Vcl.Samples.Spin, cxSpinEdit, uIFormParams, uClubInfo, uMessageItem, dxsChipUpDark, dxsChipUpDarkTabs, dxsChipUpRedButton, uGameInfo;

type
  TfrmCreateEditGame = class(TForm, IFormParams)
    edGameName: TcxTextEdit;
    lbsGameName: TcxLabel;
    lbsGameType: TcxLabel;
    btOK: TcxButton;
    btCancel: TcxButton;
    alCreateGame: TActionList;
    acOK: TAction;
    acCancel: TAction;
    cbGameType: TcxComboBox;
    lbsBlinds: TcxLabel;
    lbsSeats: TcxLabel;
    cbSeats: TcxComboBox;
    cbLimit: TcxComboBox;
    lbsLimit: TcxLabel;
    cbBlinds: TcxComboBox;
    lbsBuyinLimit: TcxLabel;
    seBuyinMin: TcxSpinEdit;
    seBuyinMax: TcxSpinEdit;
    lbsBuyinMin: TcxLabel;
    lbsBuyinMax: TcxLabel;
    lbsBuyinBigBlinds: TcxLabel;
    procedure acOKExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acCancelExecute(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    FFormType: Integer;
    FClub: TClubInfo;
    FGame: TGameInfo;

    procedure CSRCreateGameOk(const AMessage: TMessageItem);
    procedure CSREditGameOk(const AMessage: TMessageItem);

  protected
    procedure WndProc(var AMessage: TMessage); override;
  public
    procedure SetParams(const AParams: array of pointer);
  end;

implementation

{$R *.dfm}

uses
  uSocketClient, uServerCodes, uCommon, uServerMessageCallback, uValidators, uPB_Game, uMainDataModule, uMessageContainer;


procedure TfrmCreateEditGame.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);
end;

procedure TfrmCreateEditGame.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Ord(Key) of
    VK_ESCAPE: begin
      acCancel.Execute;
      Key := #0;
    end;
    VK_RETURN: begin
      if not cbSeats.Focused then
        SelectNext(ActiveControl, TRUE, TRUE)
      else
        acOK.Execute;
      Key := #0;
    end;
  end;
end;

procedure TfrmCreateEditGame.FormShow(Sender: TObject);
begin
  MessageContainer.AddMessageHandler(Handle);
end;

procedure TfrmCreateEditGame.SetParams(const AParams: array of pointer);
var
  blstr: String;
  C1   : Integer;
begin
  FFormType := PInteger(AParams[0])^;
  case FFormType of
    0: begin
      Caption := 'Create a Table';
      FClub := AParams[1];
    end;
    1: begin
      Caption := 'Edit Table';
      FGame := AParams[1];

      edGameName.Text := FGame.Name;
      cbGameType.ItemIndex := Integer(FGame.GameType);
      cbLimit.ItemIndex := Integer(FGame.Limit);

      cbBlinds.ItemIndex := 0;
      blstr := Format('%d/%d', [FGame.SmallBlind, FGame.BigBlind]);
      for C1 := 0 to cbBlinds.Properties.Items.Count - 1 do
        if cbBlinds.Properties.Items[C1] = blstr then
        begin
          cbBlinds.ItemIndex := C1;
          Break;
        end;

      seBuyinMin.Value := FGame.MinBuyin;
      seBuyinMax.Value := FGame.MaxBuyin;

      cbSeats.ItemIndex := 0;
      for C1 := 0 to cbSeats.Properties.Items.Count - 1 do
        if cbSeats.Properties.Items[C1] = IntToStr(FGame.Seats) then
        begin
          cbSeats.ItemIndex := C1;
          Break;
        end;
    end;
  end;
end;

procedure TfrmCreateEditGame.WndProc(var AMessage: TMessage);
var
  msg: TMessageItem;
begin
  inherited;

  if MessageContainer.IsNewMessage(AMessage, msg) then
  begin
    case msg.MessageType of
      mtServerResponse: ProcessServerMessage(msg,
                          [
                            TServerMessageCallback.Create(srCreateGameOk, CSRCreateGameOk),
                            TServerMessageCallback.Create(srEditGameOk, CSREditGameOk)
                          ]
                        );
    end;

    MessageContainer.RemoveMessageReader(AMessage.WParam, Handle);
  end;
end;

procedure TfrmCreateEditGame.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmCreateEditGame.acOKExecute(Sender: TObject);
var
  sb, bb: Integer;
  err   : String;
begin
  if not GetBlinds(cbBlinds.Text, sb, bb) then
    Exit;

  if seBuyinMin.Value < 5 then
  begin
    err := 'Minimum lower buy-in must be atleast 5bb';
    seBuyinMin.SetFocus;
  end
  else
    if seBuyinMax.Value < 10 then
    begin
      err := 'Minimum upper buy-in must be atleast 10bb';
      seBuyinMax.SetFocus;
    end
    else
      if seBuyinMin.Value > seBuyinMax.Value then
      begin
        err := 'Invalid buy-in limits';
        seBuyinMin.SetFocus;
      end
      else
        if ValidateGameName(edGameName.Text, err) then
        begin
          acOK.Enabled := FALSE;
          case FFormType of
            0: SocketClient.CreateGame(FClub.Id, edGameName.Text, TGameType(cbGameType.ItemIndex), TGameLimit(cbLimit.ItemIndex), sb * 100, bb * 100, seBuyinMin.Value, seBuyinMax.Value, StrToInt(cbSeats.Properties.Items[cbSeats.ItemIndex]));
            1: SocketClient.EditGame(FGame.MongoId, edGameName.Text, TGameType(cbGameType.ItemIndex), TGameLimit(cbLimit.ItemIndex), sb * 100, bb * 100, seBuyinMin.Value, seBuyinMax.Value, StrToInt(cbSeats.Properties.Items[cbSeats.ItemIndex]));
          else
            Assert(FALSE, 'Invalid FFormType');
          end;
        end;

  if err <> '' then
    MessageDlg(err, mtError, [mbOK], 0);
end;

procedure TfrmCreateEditGame.CSRCreateGameOk(const AMessage: TMessageItem);
begin
  ModalResult := mrOk;
end;

procedure TfrmCreateEditGame.CSREditGameOk(const AMessage: TMessageItem);
begin
  ModalResult := mrOk;
end;

end.
