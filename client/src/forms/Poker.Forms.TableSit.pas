unit Poker.Forms.TableSit;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxButtons, cxTextEdit,
  cxSpinEdit, cxLabel, Vcl.ActnList, Poker.Interfaces.FormParams, Poker.Tables.Table, Poker.Tables.Status,
  Poker.Interfaces.ModalForm, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  ChipUpPokerDarkSkin, Vcl.Menus, Vcl.StdCtrls, cxMaskEdit, Poker.Games.Game;

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
    lbsAvailableBalance: TcxLabel;
    lbvAvailableBalance: TcxLabel;
    lbsMaxBuyin: TcxLabel;
    lbvMaxBuyin: TcxLabel;
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
    FTableStatus: TTableStatus;
    FSeatIndex: Integer;
    FCloseCallback: TNotifyEvent;
    FBuyinPhrase: String;

    procedure SetBuyin(const ABuyin: UINT32);
    procedure CSRTableSitOk(const AMethodId: Integer; const AObject: TObject);
    procedure CSRTableSitSeatTaken(const AMethodId: Integer; const AObject: TObject);
    procedure CSRTableSitNoChips(const AMethodId: Integer; const AObject: TObject);
    procedure CSRTableAddonOk(const AMethodId: Integer; const AObject: TObject);
    procedure CSRTableAddonOverLimit(const AMethodId: Integer; const AObject: TObject);
    procedure CSRTableBuyinLessThanCashout(const AMethodId: Integer; const AObject: TObject);
    procedure CSRTableInvalidBuyin(const AMethodId: Integer; const AObject: TObject);
    procedure CSRClubBalanceReached(const AMethodId: Integer; const AObject: TObject);
    procedure CSRNotSitting(const AMethodId: Integer; const AObject: TObject);

    function GetMaxBuyin: UINT32;
    function GetObjects(out ATable: TTable; out AGame: TGameInfo): Boolean;
  public
    procedure SetParams(const AParams: array of pointer);
    procedure SetCloseCallback(const ACallback: TNotifyEvent);
  end;

implementation

{$R *.dfm}

uses
  Poker.Common.Misc, Poker.Server.Socket.Commands, Poker.Protobufs.Enum.ServerCodes, Poker.Server.MessageCallbacks, Poker.DataModule,
  Poker.Server.MessageContainer, Poker.Common.FormsContainer, Poker.Protobufs.Objects.TableStatus, Poker.Protobufs.Objects.BuyinError,
  Poker.Protobufs.Objects.Game, Poker.Seats.Seat, Poker.Tables.TableList;


procedure TfrmTableSit.FormCreate(Sender: TObject);
begin
  FCallbacksId := MessageContainer.AddCallbacks([
                      TServerMessageCallback.Create(srTableSitOk, CSRTableSitOk),
                      TServerMessageCallback.Create(srTableSitSeatTaken, CSRTableSitSeatTaken),
                      TServerMessageCallback.Create(srTableSitNoChips, CSRTableSitNoChips),
                      TServerMessageCallback.Create(srTableAddonOk, CSRTableAddonOk),
                      TServerMessageCallback.Create(srTableAddonOverLimit, CSRTableAddonOverLimit),
                      TServerMessageCallback.Create(srTableBuyinLessThanCashout, CSRTableBuyinLessThanCashout),
                      TServerMessageCallback.Create(srInvalidTableBuyin, CSRTableInvalidBuyin),
                      TServerMessageCallback.Create(srClubBalanceReached, CSRClubBalanceReached),
                      TServerMessageCallback.Create(srNotSitting, CSRNotSitting)
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

function TfrmTableSit.GetObjects(out ATable: TTable; out AGame: TGameInfo): Boolean;
begin
  result := (Tables.TryGetValue(FInternalId, ATable)) and
            (ATable.GetObjects(AGame));
end;

function TfrmTableSit.GetMaxBuyin: UINT32;
var
  seat_info: TSeatInfo;
  seat_chips: UINT32;
  game: TGameInfo;
  table: TTable;
begin
  if not GetObjects(table, game) then
    Exit(0);

  if (table.SeatIndex <> -1) and
     (FTableStatus.GetSeatInfo(table.SeatIndex, seat_info)) then
    seat_chips := seat_info.Chips
  else
    seat_chips := 0;

  if seat_chips > game.MaxBuyin * game.BigBlind then
    result := 0
  else
  begin
    result := game.MaxBuyin * game.BigBlind - seat_chips;
    if result > dmMain.AvailableBalance then
      result := dmMain.AvailableBalance;
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
  seBuyin.Value := Trunc(buyin / 100);
end;

procedure TfrmTableSit.SetCloseCallback(const ACallback: TNotifyEvent);
begin
  FCloseCallback := ACallback;
end;

procedure TfrmTableSit.SetParams(const AParams: array of pointer);
var
  default_buyin: UINT32;
  game: TGameInfo;
  table: TTable;
begin
  FInternalId := PInteger(AParams[0])^;
  FTableStatus := AParams[1];
  FSeatIndex := PInteger(AParams[2])^;

  if not GetObjects(table, game) then
    Exit;

  lbvTableName.Caption := Format('%s (%s/%s %s)', [game.Name, ChipsToStr(game.SmallBlind), ChipsToStr(game.BigBlind), game.AsString(FALSE)]);
  lbsTableBuyins.Caption := Format('(min buy-in %s, max buyin %s)', [ChipsToStr(game.MinBuyin * game.BigBlind),
      ChipsToStr(game.MaxBuyin * game.BigBlind)]);
  lbvAvailableBalance.Caption := Format('%s', [ChipsToStr(dmMain.AvailableBalance)]);
  if table.SeatIndex <> -1 then
    FBuyinPhrase := 'add-on'
  else
    FBuyinPhrase := 'buy-in';

  lbsMaxBuyin.Caption := Format('Your maximum %s:', [FBuyinPhrase]);
  lbvMaxBuyin.Caption := Format('%s', [ChipsToStr(GetMaxBuyin)]);

  default_buyin := game.BigBlind * 50;
  default_buyin := (default_buyin div 10) * 10;
  SetBuyin(default_buyin);
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
  game: TGameInfo;
  table: TTable;
begin
  if not GetObjects(table, game) then
    Exit;

  SetBuyin(game.MinBuyin * game.BigBlind);
end;

procedure TfrmTableSit.acOKExecute(Sender: TObject);
var
  err: String;
  seat_info: TSeatInfo;
  buyin: Single;
  game: TGameInfo;
  table: TTable;
begin
  if not GetObjects(table, game) then
    Exit;

  if not TryStrToFloat(seBuyin.Text, buyin) then
  begin
    err := 'Invalid buyin';
    seBuyin.SelectAll;
  end;

  if err = '' then
  begin
    if table.SeatIndex = -1 then
    begin
      if game.State = gsClosed then
        err := 'Table is closed';

      if err = '' then
        ServerSocket.TableSit(game.MongoId, FSeatIndex, Round(seBuyin.Value * 100))
      else
        seBuyin.SelectAll;
    end
    else
    begin
      if not FTableStatus.GetSeatInfo(table.SeatIndex, seat_info) then
        err := 'Invalid seat index';

      if err = '' then
        ServerSocket.TableAddOn(game.MongoId, Round(buyin * 100));
    end;

    acOK.Enabled := FALSE
  end
  else
    MessageDlg(err, mtError, [mbOK], 0);
end;

procedure TfrmTableSit.CSRTableSitNoChips(const AMethodId: Integer; const AObject: TObject);
var
  pbstatus: TPB_TableStatus;
  game: TGameInfo;
  table: TTable;
begin
  if not GetObjects(table, game) then
    Exit;

  pbstatus := AObject as TPB_TableStatus;
  if not CompareBytes(game.MongoId, pbstatus.TableMongoId) then
    Exit;

  MessageDlg('Insufficient chips', mtWarning, [mbOK], 0);
  acOK.Enabled := TRUE;
end;

procedure TfrmTableSit.CSRTableSitOk(const AMethodId: Integer; const AObject: TObject);
var
  pbstatus: TPB_TableStatus;
  game: TGameInfo;
  table: TTable;
begin
  if (not Tables.TryGetValue(FInternalId, table)) or
     (not table.GetObjects(game)) then
    Exit;

  pbstatus := AObject as TPB_TableStatus;
  if not CompareBytes(game.MongoId, pbstatus.TableMongoId) then
    Exit;

  ModalResult := mrOk;
  Close;
end;

procedure TfrmTableSit.CSRTableSitSeatTaken(const AMethodId: Integer; const AObject: TObject);
var
  pbstatus: TPB_TableStatus;
  game: TGameInfo;
  table: TTable;
begin
  if not GetObjects(table, game) then
    Exit;

  pbstatus := AObject as TPB_TableStatus;
  if not CompareBytes(game.MongoId, pbstatus.TableMongoId) then
    Exit;

  MessageDlg('Seat is already taken. Please choose another seat', mtWarning, [mbOK], 0);
  ModalResult := mrClose;
  Close;
end;

procedure TfrmTableSit.CSRTableAddonOk(const AMethodId: Integer; const AObject: TObject);
var
  pbstatus: TPB_TableStatus;
  game: TGameInfo;
  table: TTable;
begin
  if not GetObjects(table, game) then
    Exit;

  pbstatus := AObject as TPB_TableStatus;
  if not CompareBytes(game.MongoId, pbstatus.TableMongoId) then
    Exit;

  ModalResult := mrOk;
  Close;
end;

procedure TfrmTableSit.CSRTableAddonOverLimit(const AMethodId: Integer; const AObject: TObject);
var
  pbstatus: TPB_TableStatus;
  game: TGameInfo;
  table: TTable;
begin
  if not GetObjects(table, game) then
    Exit;

  pbstatus := AObject as TPB_TableStatus;
  if not CompareBytes(game.MongoId, pbstatus.TableMongoId) then
    Exit;

  MessageDlg('You can''t add-on over maximum table buy-in limit', mtWarning, [mbOK], 0);
  acOK.Enabled := TRUE;
end;

procedure TfrmTableSit.CSRClubBalanceReached(const AMethodId: Integer; const AObject: TObject);
var
  pbstatus: TPB_TableStatus;
  game: TGameInfo;
  table: TTable;
begin
  if not GetObjects(table, game) then
    Exit;

  pbstatus := AObject as TPB_TableStatus;
  if not CompareBytes(game.MongoId, pbstatus.TableMongoId) then
    Exit;

  MessageDlg('You reached your balance limit for this club', mtWarning, [mbOK], 0);
  acOK.Enabled := TRUE;
end;

procedure TfrmTableSit.CSRNotSitting(const AMethodId: Integer; const AObject: TObject);
var
  pbgame: TPB_Game;
  game: TGameInfo;
  table: TTable;
begin
  if not GetObjects(table, game) then
    Exit;

  pbgame := AObject as TPB_Game;
  if not CompareBytes(game.MongoId, pbgame.MongoId) then
    Exit;

  MessageDlg('You are not sitting', mtWarning, [mbOK], 0);

  ModalResult := mrCancel;
  Close;
end;

procedure TfrmTableSit.CSRTableBuyinLessThanCashout(const AMethodId: Integer; const AObject: TObject);
var
  pbbuyinerr: TPB_BuyinError;
  game: TGameInfo;
  table: TTable;
begin
  if not GetObjects(table, game) then
    Exit;

  pbbuyinerr := AObject as TPB_BuyinError;
  if not CompareBytes(game.MongoId, pbbuyinerr.GameId) then
    Exit;

  if pbbuyinerr.LastCashout > game.MaxBuyin * game.BigBlind then
    MessageDlg(Format('You must buyin with equal amount of chips as your last cashout (%s)', [ChipsToStr(pbbuyinerr.LastCashout)]), mtWarning, [mbOK], 0)
  else
    MessageDlg(Format('You must buyin with equal or more chips than your last cashout (%s)', [ChipsToStr(pbbuyinerr.LastCashout)]), mtWarning, [mbOK], 0);

  acOK.Enabled := TRUE;
end;

procedure TfrmTableSit.CSRTableInvalidBuyin(const AMethodId: Integer; const AObject: TObject);
var
  pbbuyinerr: TPB_BuyinError;
  game: TGameInfo;
  table: TTable;
begin
  if not GetObjects(table, game) then
    Exit;

  pbbuyinerr := AObject as TPB_BuyinError;
  if not CompareBytes(game.MongoId, pbbuyinerr.GameId) then
    Exit;

  MessageDlg('Invalid buy-in amount', mtWarning, [mbOK], 0);

  acOK.Enabled := TRUE;
end;

end.
