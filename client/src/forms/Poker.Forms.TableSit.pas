unit Poker.Forms.TableSit;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxButtons, cxTextEdit,
  cxSpinEdit, cxLabel, Vcl.ActnList, Poker.Interfaces.FormParams, Poker.Tables.Table, Poker.Tables.Status,
  Poker.Interfaces.ModalForm, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  ChipUpPokerDarkSkin, Vcl.Menus, Vcl.StdCtrls, cxMaskEdit, Poker.Games.Game, Winapi.Messages;

type
  TfrmTableSit = class(TForm, IFormParams, IModalForm)
    lbsChipsAmount: TcxLabel;
    seBuyin: TcxSpinEdit;
    btOK: TcxButton;
    btCancel: TcxButton;
    alTableSit: TActionList;
    acOK: TAction;
    acCancel: TAction;
    lbvTableName: TcxLabel;
    btMin: TcxButton;
    btMax: TcxButton;
    acMin: TAction;
    acMax: TAction;
    lbsTableBuyins: TcxLabel;
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
    FCallbacksId: Integer;
    FInternalId: Integer;
    FSeatIndex: Integer;
    FCloseCallback: TNotifyEvent;

    procedure SetBuyin(const ABuyin: UINT32);
    procedure CSRTableSitOk(const AMethodId: Integer; const AObject: TObject);
    procedure CSRTableSitSeatTaken(const AMethodId: Integer; const AObject: TObject);
    procedure CSRTableAddonOk(const AMethodId: Integer; const AObject: TObject);
    procedure CSRTableAddonOverLimit(const AMethodId: Integer; const AObject: TObject);
    procedure CSRTableBuyinLessThanCashout(const AMethodId: Integer; const AObject: TObject);
    procedure CSRTableInvalidBuyin(const AMethodId: Integer; const AObject: TObject);
    procedure CSRClubBalanceReached(const AMethodId: Integer; const AObject: TObject);
    procedure CSRNotSitting(const AMethodId: Integer; const AObject: TObject);
    procedure CSEPlayerClubStatus(const AMethodId: Integer; const AObject: TObject);
    procedure ConfigureGUI;

    function GetMaxBuyin: UINT32;
    function GetMinBuyin: UINT32;
  protected
    procedure WndProc(var AMessage: TMessage); override;
  public
    procedure SetParams(const AParams: array of pointer);
    procedure SetCloseCallback(const ACallback: TNotifyEvent);
  end;

implementation

{$R *.dfm}

uses
  Poker.Common.Misc, Poker.Server.Socket, Poker.Protobufs.Enum.ServerCodes, Poker.Server.MessageCallbacks, Poker.DataModule,
  Poker.Server.MessageContainer, Poker.Common.FormsContainer, Poker.Protobufs.Objects.TableStatus, Poker.Protobufs.Objects.BuyinError,
  Poker.Protobufs.Objects.Game, Poker.Seats.Seat, Poker.Tables.TableList, Poker.Types, Poker.Protobufs.Objects.PlayerClubStatus;


procedure TfrmTableSit.FormCreate(Sender: TObject);
begin
  FCallbacksId := MessageContainer.AddCallbacks([
                      TServerMessageCallback.Create(srTableSitOk, CSRTableSitOk),
                      TServerMessageCallback.Create(srTableSitSeatTaken, CSRTableSitSeatTaken),
                      TServerMessageCallback.Create(srTableAddonOk, CSRTableAddonOk),
                      TServerMessageCallback.Create(srTableAddonOverLimit, CSRTableAddonOverLimit),
                      TServerMessageCallback.Create(srTableBuyinLessThanCashout, CSRTableBuyinLessThanCashout),
                      TServerMessageCallback.Create(srInvalidTableBuyin, CSRTableInvalidBuyin),
                      TServerMessageCallback.Create(srClubBalanceReached, CSRClubBalanceReached),
                      TServerMessageCallback.Create(srNotSitting, CSRNotSitting),
                      TServerMessageCallback.Create(sePlayerClubStatus, CSEPlayerClubStatus)
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

function TfrmTableSit.GetMaxBuyin: UINT32;
var
  seat_info: TSeatInfo;
  seat_chips: UINT32;
  table: TTable;
  pcsproto: TPB_PlayerClubStatus;
begin
  result := 0;
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if dmMain.SelfInfo.TableStatuses.TryGetValue(table.GameId, pcsproto) then
      if pcsproto.has_BuyinMax then
      begin
        result := pcsproto.BuyinMax;
        Exit;
      end;

    if (table.Status.SelfSeatIndex <> -1) and
       (table.Status.GetSeatInfo(table.Status.SelfSeatIndex, seat_info)) then
      seat_chips := seat_info.Chips
    else
      seat_chips := 0;

    if seat_chips > table.Game.BuyinMax then
      result := 0
    else
      result := table.Game.BuyinMax - seat_chips;
  finally
    Tables.Unlock;
  end;
end;

function TfrmTableSit.GetMinBuyin: UINT32;
var
  table: TTable;
  pcsproto: TPB_PlayerClubStatus;
begin
  result := 0;
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if dmMain.SelfInfo.TableStatuses.TryGetValue(table.GameId, pcsproto) then
      if pcsproto.has_BuyinMin then
      begin
        result := pcsproto.BuyinMin;
        Exit;
      end;

    result := table.Game.BuyinMin;
  finally
    Tables.Unlock;
  end;
 end;

procedure TfrmTableSit.seBuyinPropertiesChange(Sender: TObject);
var
  val: Single;
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

procedure TfrmTableSit.SetBuyin(const ABuyin: UINT32);
var
  buyin: UINT32;
begin
  buyin := ABuyin;
  if buyin > GetMaxBuyin then
    buyin := GetMaxBuyin;
  seBuyin.Value := buyin / 100;
end;

procedure TfrmTableSit.SetCloseCallback(const ACallback: TNotifyEvent);
begin
  FCloseCallback := ACallback;
end;

procedure TfrmTableSit.SetParams(const AParams: array of pointer);
var
  table: TTable;
begin
  FInternalId := PInteger(AParams[0])^;
  FSeatIndex := PInteger(AParams[1])^;
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    ServerSocket.TableSitOpen(table.GameId);
  finally
    Tables.Unlock;
  end;
  SetBuyin(GetMaxBuyin);
  ConfigureGUI;
end;

procedure TfrmTableSit.WndProc(var AMessage: TMessage);
begin
  // prevent ALT key from switching between forms
  if (AMessage.Msg = WM_SYSCOMMAND) and
     (AMessage.WParam = SC_KEYMENU) then
    Exit;

  inherited;
end;

procedure TfrmTableSit.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
  Close;
end;

procedure TfrmTableSit.acMaxExecute(Sender: TObject);
begin
  SetBuyin(GetMaxBuyin);
end;

procedure TfrmTableSit.acMinExecute(Sender: TObject);
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    SetBuyin(GetMinBuyin);
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTableSit.acOKExecute(Sender: TObject);
var
  err: String;
  seat_info: TSeatInfo;
  buyin: Single;
  table: TTable;
begin
  err := '';
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if not TryStrToFloat(seBuyin.Text, buyin) then
    begin
      err := 'Invalid buyin';
      seBuyin.SelectAll;
    end;

    if err = '' then
    begin
      if table.Status.SelfSeatIndex = -1 then
      begin
        if table.Game.State = gsClosed then
          err := 'Table is closed';

        if err = '' then
          ServerSocket.TableSit(table.Game.MongoId, FSeatIndex, Round(seBuyin.Value * 100))
        else
          seBuyin.SelectAll;
      end
      else
      begin
        if not table.Status.GetSeatInfo(table.Status.SelfSeatIndex, seat_info) then
          err := 'Invalid seat index';

        if err = '' then
          ServerSocket.TableAddOn(table.Game.MongoId, Round(buyin * 100));
      end;

      acOK.Enabled := FALSE
    end;
  finally
    Tables.Unlock;
  end;

  if err <> '' then
    ShowWarningDialog(err);
end;

procedure TfrmTableSit.CSRTableSitOk(const AMethodId: Integer; const AObject: TObject);
var
  pbstatus: TPB_TableStatus;
  table: TTable;
begin
  if not TTypes.TryCast<TPB_TableStatus>(AObject, pbstatus) then
    Exit;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.Game.MongoId <> pbstatus.TableMongoId then
      Exit;

    ModalResult := mrOk;
    Close;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTableSit.CSRTableSitSeatTaken(const AMethodId: Integer; const AObject: TObject);
var
  pbstatus: TPB_TableStatus;
  table: TTable;
begin
  if not TTypes.TryCast<TPB_TableStatus>(AObject, pbstatus) then
    Exit;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.Game.MongoId <> pbstatus.TableMongoId then
      Exit;
  finally
    Tables.Unlock;
  end;

  ShowWarningDialog('Seat is already taken. Please choose another seat');
  ModalResult := mrClose;
  Close;
end;

procedure TfrmTableSit.CSRTableAddonOk(const AMethodId: Integer; const AObject: TObject);
var
  pbstatus: TPB_TableStatus;
  table: TTable;
begin
  if not TTypes.TryCast<TPB_TableStatus>(AObject, pbstatus) then
    Exit;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.Game.MongoId <> pbstatus.TableMongoId then
      Exit;

    ModalResult := mrOk;
    Close;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTableSit.CSRTableAddonOverLimit(const AMethodId: Integer; const AObject: TObject);
var
  pbstatus: TPB_TableStatus;
  table: TTable;
begin
  if not TTypes.TryCast<TPB_TableStatus>(AObject, pbstatus) then
    Exit;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.game.MongoId <> pbstatus.TableMongoId then
      Exit;
  finally
    Tables.Unlock;
  end;

  ShowWarningDialog('You can''t add-on over maximum table buy-in limit');
  seBuyin.SelectAll;
  acOK.Enabled := TRUE;
end;

procedure TfrmTableSit.ConfigureGUI;
var
  table: TTable;
  min_buyin, max_buyin: UINT32;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    min_buyin := GetMinBuyin;
    max_buyin := GetMaxBuyin;

    lbvTableName.Caption := Format('%s (%s/%s %s)', [table.Game.Gamename, ChipsToStr(table.Game.SmallBlind), ChipsToStr(table.Game.BigBlind), table.Game.AsString(FALSE)]);
    lbsTableBuyins.Caption := Format('(min buy-in %s, max buyin %s)', [ChipsToStr(GetMinBuyin),
        ChipsToStr(max_buyin)]);
{    if table.Status.SelfSeatIndex <> -1 then
      FBuyinPhrase := 'add-on'
    else
      FBuyinPhrase := 'buy-in';}
    if UINT32(seBuyin.Value) * 100 < min_buyin then
      seBuyin.Value := min_buyin / 100;
    if UINT32(seBuyin.Value) * 100 > max_buyin then
      seBuyin.Value := max_buyin / 100;
   finally
    Tables.Unlock;
  end;
end;

procedure TfrmTableSit.CSEPlayerClubStatus(const AMethodId: Integer; const AObject: TObject);
var
  proto: TPB_PlayerClubStatus;
begin
  if not TTypes.TryCast<TPB_PlayerClubStatus>(AObject, proto) then
    Exit;

  ConfigureGUI;
end;

procedure TfrmTableSit.CSRClubBalanceReached(const AMethodId: Integer; const AObject: TObject);
var
  pbstatus: TPB_TableStatus;
  table: TTable;
begin
  if not TTypes.TryCast<TPB_TableStatus>(AObject, pbstatus) then
    Exit;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.game.MongoId <> pbstatus.TableMongoId then
      Exit;
  finally
    Tables.Unlock;
  end;

  ShowWarningDialog('You reached your balance limit for this club');
  seBuyin.SelectAll;
  acOK.Enabled := TRUE;
end;

procedure TfrmTableSit.CSRNotSitting(const AMethodId: Integer; const AObject: TObject);
var
  pbgame: TPB_Game;
  table: TTable;
begin
  if not TTypes.TryCast<TPB_Game>(AObject, pbgame) then
    Exit;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.game.MongoId <> pbgame.MongoId then
      Exit;
  finally
    Tables.Unlock;
  end;

  ShowWarningDialog('You are not sitting');
  ModalResult := mrCancel;
  Close;
end;

procedure TfrmTableSit.CSRTableBuyinLessThanCashout(const AMethodId: Integer; const AObject: TObject);
var
  pbbuyinerr: TPB_BuyinError;
  table: TTable;
  err: String;
begin
  if not TTypes.TryCast<TPB_BuyinError>(AObject, pbbuyinerr) then
    Exit;

  err := '';
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.game.MongoId <> pbbuyinerr.GameId then
      Exit;

    if pbbuyinerr.LastCashout > table.game.BuyinMax then
      err := Format('You must buyin with equal amount of chips as your last cashout (%s)', [ChipsToStr(pbbuyinerr.LastCashout)])
    else
      err := Format('You must buyin with equal or more chips than your last cashout (%s)', [ChipsToStr(pbbuyinerr.LastCashout)]);
  finally
    Tables.Unlock;
  end;

  ShowWarningDialog(err);
  seBuyin.SelectAll;
  acOK.Enabled := TRUE;
end;

procedure TfrmTableSit.CSRTableInvalidBuyin(const AMethodId: Integer; const AObject: TObject);
var
  pbbuyinerr: TPB_BuyinError;
  table: TTable;
begin
  if not TTypes.TryCast<TPB_BuyinError>(AObject, pbbuyinerr) then
    Exit;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.game.MongoId <> pbbuyinerr.GameId then
      Exit;
  finally
    Tables.Unlock;
  end;

  ShowWarningDialog('Invalid buy-in amount');
  seBuyin.SelectAll;
  acOK.Enabled := TRUE;
end;

end.
