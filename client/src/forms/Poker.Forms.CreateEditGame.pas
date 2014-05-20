unit Poker.Forms.CreateEditGame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  Vcl.ActnList, Vcl.StdCtrls, cxButtons, cxRadioGroup, cxLabel, cxTextEdit, cxMaskEdit, cxDropDownEdit,
  cxSpinEdit, Poker.Interfaces.FormParams, Poker.Objects.ClubInfo, Poker.Objects.GameInfo, Poker.Interfaces.ModalForm,
  Vcl.Menus, ChipUpPokerDarkSkin;

type
  TfrmCreateEditGame = class(TForm, IFormParams, IModalForm)
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
    procedure FormDestroy(Sender: TObject);
    procedure acCancelExecute(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbGameTypePropertiesChange(Sender: TObject);
  private
    FCallbacksId: Integer;
    FFormType: Integer;
    FClub: TClubInfo;
    FGame: TGameInfo;
    FCloseCallback: TNotifyEvent;

    procedure CSRCreateGameOk(const AMethodId: Integer; const AObject: TObject);
    procedure CSREditGameOk(const AMethodId: Integer; const AObject: TObject);

  protected
  public
    procedure SetParams(const AParams: array of pointer);
    procedure SetCloseCallback(const ACallback: TNotifyEvent);

  end;

implementation

{$R *.dfm}

uses
  Poker.Server.Socket, Poker.Protobufs.Enum.ServerCodes, Poker.Common.Misc, Poker.Server.MessageCallbacks, Poker.Server.Validators,
  Poker.Protobufs.Objects.Game, Poker.Server.MessageContainer, Poker.Common.FormsContainer;



procedure TfrmCreateEditGame.FormCreate(Sender: TObject);
begin
  FCallbacksId := MessageContainer.AddCallbacks([
                      TServerMessageCallback.Create(srCreateGameOk, CSRCreateGameOk),
                      TServerMessageCallback.Create(srEditGameOk, CSREditGameOk)
                  ]);
end;

procedure TfrmCreateEditGame.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.Remove(self);
end;

procedure TfrmCreateEditGame.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;

  if Assigned(FCloseCallback) then
    FCloseCallback(self);
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

procedure TfrmCreateEditGame.SetCloseCallback(const ACallback: TNotifyEvent);
begin
  FCloseCallback := ACallback;
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

procedure TfrmCreateEditGame.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
  Close;
end;

procedure TfrmCreateEditGame.acOKExecute(Sender: TObject);
var
  sb, bb: Integer;
  err: String;
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
            0: ServerSocket.CreateGame(FClub.Id, edGameName.Text, TGameType(cbGameType.ItemIndex), TGameLimit(cbLimit.ItemIndex), TGameBlinds(cbBlinds.ItemIndex), seBuyinMin.Value, seBuyinMax.Value, StrToInt(cbSeats.Properties.Items[cbSeats.ItemIndex]));
//            1: ServerSocket.EditGame(FGame.MongoId, edGameName.Text, TGameType(cbGameType.ItemIndex), TGameLimit(cbLimit.ItemIndex), TGameBlinds(cbBlinds.ItemIndex), seBuyinMin.Value, seBuyinMax.Value, StrToInt(cbSeats.Properties.Items[cbSeats.ItemIndex]));
          else
            Assert(FALSE, 'Invalid FFormType');
          end;
        end;

  if err <> '' then
    MessageDlg(err, mtError, [mbOK], 0);
end;

procedure TfrmCreateEditGame.cbGameTypePropertiesChange(Sender: TObject);
begin
  cbLimit.Enabled := cbGameType.ItemIndex <> Integer(gtRotationNLHPLO);
end;

procedure TfrmCreateEditGame.CSRCreateGameOk(const AMethodId: Integer; const AObject: TObject);
begin
  ModalResult := mrOk;
  Close;
end;

procedure TfrmCreateEditGame.CSREditGameOk(const AMethodId: Integer; const AObject: TObject);
begin
  ModalResult := mrOk;
  Close;
end;

end.
