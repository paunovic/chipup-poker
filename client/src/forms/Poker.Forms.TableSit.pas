unit Poker.Forms.TableSit;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxButtons, cxTextEdit,
  cxSpinEdit, cxLabel, Vcl.ActnList, Poker.Interfaces.FormParams, Poker.Table.Tables, Poker.Objects.TableStatus,
  Poker.Interfaces.ModalForm, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  ChipUpPokerDarkSkin, Vcl.Menus, Vcl.StdCtrls, cxMaskEdit;

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
    FTable: TTable;
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

    function GetMaxBuyin: UINT32;
  protected
  public
    procedure SetParams(const AParams: array of pointer);
    procedure SetCloseCallback(const ACallback: TNotifyEvent);
  end;

implementation

{$R *.dfm}

uses
  Poker.Common.Misc, Poker.Server.Socket, Poker.Protobufs.Enum.ServerCodes, Poker.Server.MessageCallbacks, Poker.DataModule,
  Poker.Server.MessageContainer, Poker.Common.FormsContainer, Poker.Protobufs.Objects.TableStatus, Poker.Protobufs.Objects.BuyinError,
  Poker.Protobufs.Objects.Game, Poker.Objects.SeatInfo;


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
                      TServerMessageCallback.Create(srClubBalanceReached, CSRClubBalanceReached)
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
begin
  if (FTable.SeatIndex <> -1) and
     (FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info)) then
    seat_chips := seat_info.Chips
  else
    seat_chips := 0;

  if seat_chips > FTable.Game.MaxBuyin * FTable.Game.BigBlind then
    result := 0
  else
  begin
    result := FTable.Game.MaxBuyin * FTable.Game.BigBlind - seat_chips;
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
begin
  FTable := AParams[0];
  FTableStatus := AParams[1];
  FSeatIndex := PInteger(AParams[2])^;

  lbvTableName.Caption := Format('%s (%s/%s %s)', [FTable.Game.Name, ChipsToStr(FTable.Game.SmallBlind), ChipsToStr(FTable.Game.BigBlind), FTable.Game.AsString(FALSE)]);
  lbsTableBuyins.Caption := Format('(min buy-in %s, max buyin %s)', [ChipsToStr(FTable.Game.MinBuyin * FTable.Game.BigBlind),
      ChipsToStr(FTable.Game.MaxBuyin * FTable.Game.BigBlind)]);
  lbvAvailableBalance.Caption := Format('%s', [ChipsToStr(dmMain.AvailableBalance)]);
  if FTable.SeatIndex <> -1 then
    FBuyinPhrase := 'add-on'
  else
    FBuyinPhrase := 'buy-in';

  lbsMaxBuyin.Caption := Format('Your maximum %s:', [FBuyinPhrase]);
  lbvMaxBuyin.Caption := Format('%s', [ChipsToStr(GetMaxBuyin)]);

  default_buyin := FTable.Game.BigBlind * 50;
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
begin
  SetBuyin(FTable.Game.MinBuyin * FTable.Game.BigBlind);
end;

procedure TfrmTableSit.acOKExecute(Sender: TObject);
var
  err: String;
  seat_info: TSeatInfo;
  buyin: Single;
begin
  if not TryStrToFloat(seBuyin.Text, buyin) then
  begin
    err := 'Invalid buyin';
    seBuyin.SelectAll;
  end;

  if err = '' then
  begin
    if FTable.SeatIndex = -1 then
    begin
      if FTable.Game.State = gsClosed then
        err := 'Table is closed';

      if err = '' then
        ServerSocket.TableSit(FTable.Game.MongoId, FSeatIndex, Round(seBuyin.Value * 100))
      else
        seBuyin.SelectAll;
    end
    else
    begin
      if not FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info) then
        err := 'Invalid seat index';

      if err = '' then
        ServerSocket.TableAddOn(FTable.Game.MongoId, Round(buyin * 100));
    end;

    acOK.Enabled := FALSE
  end
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

  MessageDlg('You can''t add-on over maximum table buy-in limit', mtWarning, [mbOK], 0);
  acOK.Enabled := TRUE;
end;

procedure TfrmTableSit.CSRClubBalanceReached(const AMethodId: Integer; const AObject: TObject);
var
  pbstatus: TPB_TableStatus;
begin
  pbstatus := AObject as TPB_TableStatus;
  if not CompareBytes(FTable.Game.MongoId, pbstatus.TableMongoId) then
    Exit;

  MessageDlg('You reached your balance limit for this club', mtWarning, [mbOK], 0);
  acOK.Enabled := TRUE;
end;


procedure TfrmTableSit.CSRTableBuyinLessThanCashout(const AMethodId: Integer; const AObject: TObject);
var
  pbbuyinerr: TPB_BuyinError;
begin
  pbbuyinerr := AObject as TPB_BuyinError;
  if not CompareBytes(FTable.Game.MongoId, pbbuyinerr.GameId) then
    Exit;

  if pbbuyinerr.LastCashout > FTable.Game.MaxBuyin * FTable.Game.BigBlind then
    MessageDlg(Format('You must buyin with equal amount of chips as your last cashout (%s)', [ChipsToStr(pbbuyinerr.LastCashout)]), mtWarning, [mbOK], 0)
  else
    MessageDlg(Format('You must buyin with equal or more chips than your last cashout (%s)', [ChipsToStr(pbbuyinerr.LastCashout)]), mtWarning, [mbOK], 0);

  acOK.Enabled := TRUE;
end;

procedure TfrmTableSit.CSRTableInvalidBuyin(const AMethodId: Integer; const AObject: TObject);
var
  pbbuyinerr: TPB_BuyinError;
begin
  pbbuyinerr := AObject as TPB_BuyinError;
  if not CompareBytes(FTable.Game.MongoId, pbbuyinerr.GameId) then
    Exit;

  MessageDlg('Invalid buy-in amount', mtWarning, [mbOK], 0);

  acOK.Enabled := TRUE;
end;

end.
