unit Poker.Forms.CreateGame;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxContainer, Vcl.ActnList,
  cxButtons, cxLabel, cxTextEdit, cxDropDownEdit, cxSpinEdit, Poker.Interfaces.FormParams, Poker.Clubs.Club, Poker.Games.Game,
  Poker.Interfaces.ModalForm, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxEdit, dxSkinsCore, ChipUpPokerDarkSkin,
  Vcl.Menus, cxMaskEdit, Vcl.StdCtrls, Poker.Types;

type
  TfrmCreateGame = class(TForm, IFormParams, IModalForm)
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
    FClubId: TMongoId;
    FCloseCallback: TNotifyEvent;

    procedure CSRCreateGameOk(const AMethodId: Integer; const AObject: TObject);
  public
    procedure SetParams(const AParams: array of pointer);
    procedure SetCloseCallback(const ACallback: TNotifyEvent);
  end;

implementation

{$R *.dfm}

uses
  Poker.Server.Socket, Poker.Protobufs.Enum.ServerCodes, Poker.Common.Misc, Poker.Server.MessageCallbacks, Poker.Server.Validators,
  Poker.Protobufs.Objects.Game, Poker.Server.MessageContainer, Poker.Common.FormsContainer;



procedure TfrmCreateGame.FormCreate(Sender: TObject);
begin
  FCallbacksId := MessageContainer.AddCallbacks([
                      TServerMessageCallback.Create(srCreateGameOk, CSRCreateGameOk)
                  ]);
end;

procedure TfrmCreateGame.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.Remove(self);
end;

procedure TfrmCreateGame.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;

  if Assigned(FCloseCallback) then
    FCloseCallback(self);
end;

procedure TfrmCreateGame.FormKeyPress(Sender: TObject; var Key: Char);
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

procedure TfrmCreateGame.SetCloseCallback(const ACallback: TNotifyEvent);
begin
  FCloseCallback := ACallback;
end;

procedure TfrmCreateGame.SetParams(const AParams: array of pointer);
begin
  FClubId := AParams[0];
end;

procedure TfrmCreateGame.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
  Close;
end;

procedure TfrmCreateGame.acOKExecute(Sender: TObject);
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
          ServerSocket.CreateGame(FClubId, edGameName.Text, TGameType(cbGameType.ItemIndex), TGameLimit(cbLimit.ItemIndex), TGameBlinds(cbBlinds.ItemIndex), seBuyinMin.Value, seBuyinMax.Value, StrToInt(cbSeats.Properties.Items[cbSeats.ItemIndex]));
        end;

  if err <> '' then
    ShowWarningDialog(err);
end;

procedure TfrmCreateGame.cbGameTypePropertiesChange(Sender: TObject);
begin
  cbLimit.Enabled := cbGameType.ItemIndex <> Integer(gtRotationNLHPLO);
end;

procedure TfrmCreateGame.CSRCreateGameOk(const AMethodId: Integer; const AObject: TObject);
begin
  ModalResult := mrOk;
  Close;
end;

end.
