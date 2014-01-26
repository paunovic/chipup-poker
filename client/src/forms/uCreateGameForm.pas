unit uCreateGameForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  Vcl.Menus, Vcl.ActnList, Vcl.StdCtrls, cxButtons, cxRadioGroup, cxLabel, cxTextEdit, cxMaskEdit, cxDropDownEdit,
  Vcl.Samples.Spin, cxSpinEdit, uIFormParams, uClubInfo, uMessageItem, dxSkinDarkRoom;

type
  TfrmCreateGame = class(TForm, IFormParams)
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
    procedure acOKExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acCancelExecute(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    FClub: TClubInfo;

    procedure CSRCreateGameOk(const AMessage: TMessageItem);

  protected
    procedure WndProc(var AMessage: TMessage); override;
  public
    procedure SetParams(const AParams: array of pointer);
  end;

implementation

{$R *.dfm}

uses
  uSocketClient, uServerCodes, uCommon, uMessageContainer, uServerMessageCallback, uValidators;


procedure TfrmCreateGame.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);
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

procedure TfrmCreateGame.FormShow(Sender: TObject);
begin
  MessageContainer.AddMessageHandler(Handle);
end;

procedure TfrmCreateGame.SetParams(const AParams: array of pointer);
begin
  FClub := AParams[0];
end;

procedure TfrmCreateGame.WndProc(var AMessage: TMessage);
var
  msg: TMessageItem;
begin
  inherited;

  if MessageContainer.IsNewMessage(AMessage, msg) then
  begin
    case msg.MessageType of
      mtServerResponse: ProcessServerMessage(msg,
                          [
                            TServerMessageCallback.Create(srCreateGameOk, CSRCreateGameOk)
                          ]
                        );
    end;

    msg.IncReadCount;
  end;
end;

procedure TfrmCreateGame.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmCreateGame.acOKExecute(Sender: TObject);
var
  sb, bb: Integer;
  err   : String;
begin
  if not GetBlinds(cbBlinds.Text, sb, bb) then
    Exit;

  if ValidateGameName(edGameName.Text, err) then
  begin
    acOK.Enabled := FALSE;
    SocketClient.CreateGame(FClub.Id, edGameName.Text, cbGameType.ItemIndex, cbLimit.ItemIndex, sb, bb, StrToInt(cbSeats.Properties.Items[cbSeats.ItemIndex]));
  end;

  if err <> '' then
    MessageDlg(err, mtError, [mbOK], 0);
end;

procedure TfrmCreateGame.CSRCreateGameOk(const AMessage: TMessageItem);
begin
  ModalResult := mrOk;
end;


end.
