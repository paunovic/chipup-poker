unit uTableSitForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  Vcl.Menus, Vcl.StdCtrls, cxButtons, cxTextEdit, cxMaskEdit, cxSpinEdit, cxLabel, Vcl.ActnList, uIFormParams,
  uMessageItem, dxsChipUpDark, dxsChipUpDarkTabs, dxsChipUpRedButton, uTables, uTableStatus;

type
  TfrmTableSit = class(TForm, IFormParams)
    lbsBuyinAmount: TcxLabel;
    seBuyin: TcxSpinEdit;
    btOK: TcxButton;
    btCancel: TcxButton;
    alTableSit: TActionList;
    acOK: TAction;
    acCancel: TAction;
    lbsInfo: TcxLabel;
    btMin: TcxButton;
    btMax: TcxButton;
    acMin: TAction;
    acMax: TAction;
    procedure acCancelExecute(Sender: TObject);
    procedure acOKExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure seBuyinPropertiesChange(Sender: TObject);
    procedure acMinExecute(Sender: TObject);
    procedure acMaxExecute(Sender: TObject);
  private
    FTable      : TTable;
    FTableStatus: TTableStatus;
    FSeatIndex  : Integer;

    procedure SetBuyin(const ABuyin: Double);
    procedure CSRTableSitOk(const AMessage: TMessageItem);
    procedure CSRTableSitSeatTaken(const AMessage: TMessageItem);
    procedure CSRTableSitNoChips(const AMessage: TMessageItem);
    procedure CSRTableAddonOk(const AMessage: TMessageItem);
    procedure CSRTableAddonOverLimit(const AMessage: TMessageItem);
  protected
    procedure WndProc(var AMessage: TMessage); override;
  public
    procedure SetParams(const AParams: array of pointer);
  end;

var
  frmTableSit: TfrmTableSit;

implementation

{$R *.dfm}

uses
  uSocketClient, uMessageContainer, uServerCodes, uServerMessageCallback, uMainDataModule;


procedure TfrmTableSit.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);
end;

procedure TfrmTableSit.FormShow(Sender: TObject);
begin
  MessageContainer.AddMessageHandler(Handle);

  seBuyin.Properties.OnChange(Sender);
end;

procedure TfrmTableSit.seBuyinPropertiesChange(Sender: TObject);
var
  val: Double;
begin
  acOK.Enabled := (seBuyin.Value > 0) and (TryStrToFloat(seBuyin.Text, val));
end;

procedure TfrmTableSit.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Ord(Key) of
    VK_RETURN: begin
      acOK.Execute;
      Key := #0;
    end;
    VK_ESCAPE: begin
      acCancel.Execute;
      Key := #0;
    end;
  end;
end;

procedure TfrmTableSit.SetBuyin(const ABuyin: Double);
var
  buyin: Double;
begin
  buyin := ABuyin;
  if buyin > dmMain.SelfInfo.Balance then
    buyin := dmMain.SelfInfo.Balance;
  seBuyin.Value := Trunc(buyin / 100);
end;

procedure TfrmTableSit.SetParams(const AParams: array of pointer);
var
  buyin: Double;
begin
  FTable := AParams[0];
  FTableStatus := AParams[1];
  FSeatIndex := PInteger(AParams[2])^;

  lbsInfo.Caption := Format('%s (%d/%d) %s'#10#10'Min buy-in: %d'#10'Max buy-in: %d'#10#10'Your balance: %.2f',
    [
      FTable.Game.Name, Trunc(FTable.Game.SmallBlind / 100), Trunc(FTable.Game.BigBlind / 100), FTable.Game.GameTypeStrFull,
      Trunc((FTable.Game.MinBuyin * FTable.Game.BigBlind) / 100), Trunc((FTable.Game.MaxBuyin * FTable.Game.BigBlind) / 100),
      dmMain.SelfInfo.Balance / 100
    ]);

  buyin := FTable.Game.MinBuyin * FTable.Game.BigBlind;
  buyin := buyin + (FTable.Game.MaxBuyin * FTable.Game.BigBlind - FTable.Game.MinBuyin * FTable.Game.BigBlind) * 0.75;
  buyin := Trunc((buyin / 10) * 10);
  SetBuyin(buyin);
end;

procedure TfrmTableSit.WndProc(var AMessage: TMessage);
var
  msg: TMessageItem;
begin
  inherited;

  if MessageContainer.IsNewMessage(AMessage, msg) then
  begin
    case msg.MessageType of
      mtServerResponse: ProcessServerMessage(msg,
                          [
                            TServerMessageCallback.Create(srTableSitOk, CSRTableSitOk),
                            TServerMessageCallback.Create(srTableSitSeatTaken, CSRTableSitSeatTaken),
                            TServerMessageCallback.Create(srTableSitNoChips, CSRTableSitNoChips),
                            TServerMessageCallback.Create(srTableAddonOk, CSRTableAddonOk),
                            TServerMessageCallback.Create(srTableAddonOverLimit, CSRTableAddonOverLimit)
                          ]
                        );
    end;

    MessageContainer.RemoveMessageReader(AMessage.WParam, Handle);
  end;
end;

procedure TfrmTableSit.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmTableSit.acMaxExecute(Sender: TObject);
begin
  SetBuyin(FTable.Game.MaxBuyin * FTable.Game.BigBlind);
end;

procedure TfrmTableSit.acMinExecute(Sender: TObject);
begin
  SetBuyin(FTable.Game.MinBuyin * FTable.Game.BigBlind);
end;

procedure TfrmTableSit.acOKExecute(Sender: TObject);
var
  err      : String;
  seat_info: TSeatInfo;
begin
  if FTable.SeatIndex = -1 then
  begin
    if seBuyin.Value * 100 > FTable.Game.MaxBuyin * FTable.Game.BigBlind then
      err := Format('Maximum buy-in for this table is %d', [(FTable.Game.MaxBuyin * FTable.Game.BigBlind) div 100])
    else
      if seBuyin.Value * 100 < FTable.Game.MinBuyin * FTable.Game.BigBlind then
        err := Format('Minimum buy-in for this table is %d', [(FTable.Game.MinBuyin * FTable.Game.BigBlind) div 100]);

    if err = '' then
      SocketClient.TableSit(FTable.Game.MongoId, FSeatIndex, Trunc(seBuyin.Value * 100));
  end
  else
  begin
    if not FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info) then
      err := 'Invalid seat index'
    else
      if seBuyin.Value * 100 > FTable.Game.MaxBuyin * FTable.Game.BigBlind - seat_info.Chips  then
        err := Format('Maximum buy-in for this table is %d', [(FTable.Game.MaxBuyin * FTable.Game.BigBlind) div 100]);

    if err = '' then
      SocketClient.TableAddOn(FTable.Game.MongoId, Trunc(seBuyin.Value * 100));
  end;

  if err = '' then
    acOK.Enabled := FALSE
  else
    MessageDlg(err, mtError, [mbOK], 0);
end;

procedure TfrmTableSit.CSRTableSitNoChips(const AMessage: TMessageItem);
begin
  MessageDlg('Insufficient chips', mtWarning, [mbOK], 0);
  acOK.Enabled := TRUE;
end;

procedure TfrmTableSit.CSRTableSitOk(const AMessage: TMessageItem);
begin
  ModalResult := mrOk;
end;

procedure TfrmTableSit.CSRTableSitSeatTaken(const AMessage: TMessageItem);
begin
  MessageDlg('Seat is already taken. Please choose another seat', mtWarning, [mbOK], 0);
  ModalResult := mrClose;
end;

procedure TfrmTableSit.CSRTableAddonOk(const AMessage: TMessageItem);
begin
  ModalResult := mrOk;
end;

procedure TfrmTableSit.CSRTableAddonOverLimit(const AMessage: TMessageItem);
begin
  MessageDlg('You can''t addon over maximum table buy-in limit', mtWarning, [mbOK], 0);
  acOK.Enabled := TRUE;
end;


end.
