unit PokerClient.Forms.TableSit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  Vcl.StdCtrls, cxButtons, cxTextEdit, cxMaskEdit, cxSpinEdit, cxLabel, Vcl.ActnList, PokerClient.Interfaces.FormParams,
   dxsChipUpDark, dxsChipUpDarkTabs, dxsChipUpRedButton, PokerClient.Table.Tables, PokerClient.Table.Status, PokerClient.Interfaces.ModalForm,
  Vcl.Menus;

type
  TfrmTableSit = class(TForm, IFormParams, IModalForm)
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
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FCallbacksId  : Integer;
    FTable        : TTable;
    FTableStatus  : TTableStatus;
    FSeatIndex    : Integer;
    FCloseCallback: TNotifyEvent;

    procedure SetBuyin(const ABuyin: Double);
    procedure CSRTableSitOk(const AMethodId: Integer; const AObject: TObject);
    procedure CSRTableSitSeatTaken(const AMethodId: Integer; const AObject: TObject);
    procedure CSRTableSitNoChips(const AMethodId: Integer; const AObject: TObject);
    procedure CSRTableAddonOk(const AMethodId: Integer; const AObject: TObject);
    procedure CSRTableAddonOverLimit(const AMethodId: Integer; const AObject: TObject);
  protected
  public
    procedure SetParams(const AParams: array of pointer);
    procedure SetCloseCallback(const ACallback: TNotifyEvent);
  end;

var
  frmTableSit: TfrmTableSit;

implementation

{$R *.dfm}

uses
  PokerClient.Common.Misc, PokerClient.Server.Socket, PokerClient.Protobufs.Enum.ServerCodes, PokerClient.Server.MessageCallbacks, PokerClient.DataModule, PokerClient.Server.MessageContainer, PokerClient.Common.FormsContainer, PokerClient.Protobufs.Objects.TableStatus;


procedure TfrmTableSit.FormCreate(Sender: TObject);
begin
  FCallbacksId := MessageContainer.AddCallbacks([
                      TServerMessageCallback.Create(srTableSitOk, CSRTableSitOk),
                      TServerMessageCallback.Create(srTableSitSeatTaken, CSRTableSitSeatTaken),
                      TServerMessageCallback.Create(srTableSitNoChips, CSRTableSitNoChips),
                      TServerMessageCallback.Create(srTableAddonOk, CSRTableAddonOk),
                      TServerMessageCallback.Create(srTableAddonOverLimit, CSRTableAddonOverLimit)
                  ]);
end;

procedure TfrmTableSit.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.Remove(self);
end;

procedure TfrmTableSit.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;

  if Assigned(FCloseCallback) then
    FCloseCallback(self);
end;

procedure TfrmTableSit.FormShow(Sender: TObject);
begin
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

procedure TfrmTableSit.SetCloseCallback(const ACallback: TNotifyEvent);
begin
  FCloseCallback := ACallback;
end;

procedure TfrmTableSit.SetParams(const AParams: array of pointer);
var
  buyin: Double;
begin
  FTable := AParams[0];
  FTableStatus := AParams[1];
  FSeatIndex := PInteger(AParams[2])^;

  lbsInfo.Caption := Format('%s (%d/%d) %s'#10#10'Min buy-in: %d'#10'Max buy-in: %d'#10#10'Your available balance: %.2f',
    [
      FTable.Game.Name, Trunc(FTable.Game.SmallBlind / 100), Trunc(FTable.Game.BigBlind / 100), FTable.Game.GameTypeStrFull,
      Trunc((FTable.Game.MinBuyin * FTable.Game.BigBlind) / 100), Trunc((FTable.Game.MaxBuyin * FTable.Game.BigBlind) / 100),
      dmMain.SelfInfo.Balance / 100 {FIXME: AVAIL BALANCE}
    ]);

  buyin := FTable.Game.MinBuyin * FTable.Game.BigBlind;
  buyin := buyin + (FTable.Game.MaxBuyin * FTable.Game.BigBlind - FTable.Game.MinBuyin * FTable.Game.BigBlind) * 0.75;
  buyin := Trunc((buyin / 10) * 10);
  SetBuyin(buyin);
end;

procedure TfrmTableSit.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
  Close;
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
      ServerSocket.TableSit(FTable.Game.MongoId, FSeatIndex, Trunc(seBuyin.Value * 100));
  end
  else
  begin
    if not FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info) then
      err := 'Invalid seat index'
    else
      if seBuyin.Value * 100 > FTable.Game.MaxBuyin * FTable.Game.BigBlind - seat_info.Chips  then
        err := Format('Maximum buy-in for this table is %d', [(FTable.Game.MaxBuyin * FTable.Game.BigBlind) div 100]);

    if err = '' then
      ServerSocket.TableAddOn(FTable.Game.MongoId, Trunc(seBuyin.Value * 100));
  end;

  if err = '' then
    acOK.Enabled := FALSE
  else
    MessageDlg(err, mtError, [mbOK], 0);
end;

procedure TfrmTableSit.CSRTableSitNoChips(const AMethodId: Integer; const AObject: TObject);
var
  pbstatus: TPB_TableStatus;
begin
  pbstatus := AObject as TPB_TableStatus;
  if not CompareBytes(FTable.Game.MongoId, pbstatus.TableMongoId) then
    Exit;

  MessageDlg('Insufficient chips', mtWarning, [mbOK], 0);
  acOK.Enabled := TRUE;
end;

procedure TfrmTableSit.CSRTableSitOk(const AMethodId: Integer; const AObject: TObject);
var
  pbstatus: TPB_TableStatus;
begin
  pbstatus := AObject as TPB_TableStatus;
  if not CompareBytes(FTable.Game.MongoId, pbstatus.TableMongoId) then
    Exit;

  ModalResult := mrOk;
  Close;
end;

procedure TfrmTableSit.CSRTableSitSeatTaken(const AMethodId: Integer; const AObject: TObject);
var
  pbstatus: TPB_TableStatus;
begin
  pbstatus := AObject as TPB_TableStatus;
  if not CompareBytes(FTable.Game.MongoId, pbstatus.TableMongoId) then
    Exit;

  MessageDlg('Seat is already taken. Please choose another seat', mtWarning, [mbOK], 0);
  ModalResult := mrClose;
  Close;
end;

procedure TfrmTableSit.CSRTableAddonOk(const AMethodId: Integer; const AObject: TObject);
var
  pbstatus: TPB_TableStatus;
begin
  pbstatus := AObject as TPB_TableStatus;
  if not CompareBytes(FTable.Game.MongoId, pbstatus.TableMongoId) then
    Exit;

  ModalResult := mrOk;
  Close;
end;

procedure TfrmTableSit.CSRTableAddonOverLimit(const AMethodId: Integer; const AObject: TObject);
var
  pbstatus: TPB_TableStatus;
begin
  pbstatus := AObject as TPB_TableStatus;
  if not CompareBytes(FTable.Game.MongoId, pbstatus.TableMongoId) then
    Exit;

  MessageDlg('You can''t addon over maximum table buy-in limit', mtWarning, [mbOK], 0);
  acOK.Enabled := TRUE;
end;


end.
