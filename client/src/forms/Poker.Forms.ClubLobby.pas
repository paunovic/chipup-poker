unit Poker.Forms.ClubLobby;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Poker.Interfaces.FormParams, Poker.Objects.ClubInfo, cxControls,
  cxEdit, cxLabel, cxButtons,
  cxPC, cxGroupBox, Vcl.ActnList, cxCustomData,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridCustomView, cxGrid, Poker.Objects.PlayerInfo, dxBevel,
  cxImage, Vcl.ExtCtrls, Vcl.Menus, cxStyles,
  cxData, cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, dxSkinsCore, ChipUpPokerDarkSkin, dxSkinscxPCPainter,
  cxPCdxBarPopupMenu, cxFilter, cxDataStorage, cxBlobEdit, cxTextEdit, cxSpinEdit, cxCheckBox, cxCalendar, cxTimeEdit, cxClasses,
  Vcl.StdCtrls, dxGDIPlusClasses;

type
  TfrmClubLobby = class(TForm, IFormParams)
    lbsHeader: TcxLabel;
    lbsSubheader: TcxLabel;
    btClubHome: TcxButton;
    btTables: TcxButton;
    pcTabs: TcxPageControl;
    tsClubHome: TcxTabSheet;
    tsTables: TcxTabSheet;
    gbClubSettings: TcxGroupBox;
    btCloseClub: TcxButton;
    gbPlayers: TcxGroupBox;
    gridPlayersList: TcxGrid;
    gridPlayersListTable: TcxGridTableView;
    gridPlayersListId: TcxGridColumn;
    gridPlayersListName: TcxGridColumn;
    gridPlayersListLevel: TcxGridLevel;
    btGiveOwnership: TcxButton;
    btRemovePlayerFromClub: TcxButton;
    alManageClubs: TActionList;
    acRemovePlayer: TAction;
    acGiveOwnership: TAction;
    acShowClubChangeDetailsForm: TAction;
    acCloseClub: TAction;
    acShowCreateGameForm: TAction;
    acCloseTable: TAction;
    btChangeClubDetails: TcxButton;
    gridPlayersListStatus: TcxGridColumn;
    Bevel1: TdxBevel;
    btSuspendUnsuspend: TcxButton;
    gbTables: TcxGroupBox;
    gridGames: TcxGrid;
    gridGamesTable: TcxGridTableView;
    gridGamesId: TcxGridColumn;
    gridGamesName: TcxGridColumn;
    gridGamesType: TcxGridColumn;
    gridGamesBlinds: TcxGridColumn;
    gridGamesSeats: TcxGridColumn;
    gridGamesLevel: TcxGridLevel;
    btNewGame: TcxButton;
    btCloseTable: TcxButton;
    btEditGame: TcxButton;
    acSuspendPlayer: TAction;
    acReinstatePlayer: TAction;
    btLeaveClub: TcxButton;
    acLeaveClub: TAction;
    imgHeader: TcxImage;
    btPrijatnaPunina: TcxButton;
    gridGamesBuyinLimits: TcxGridColumn;
    tiUpdateClubDetails: TTimer;
    acUpdateClubDetails: TAction;
    gridGamesTableStatus: TcxGridColumn;
    btStats: TcxButton;
    tsStats: TcxTabSheet;
    gridTables: TcxGrid;
    gridTablesTable: TcxGridTableView;
    gridTablesLevel: TcxGridLevel;
    gridTablesEnabled: TcxGridColumn;
    gridTablesName: TcxGridColumn;
    gridTablesTableId: TcxGridColumn;
    gridTablesStatus: TcxGridColumn;
    pmTablesStats: TPopupMenu;
    UnselectAll1: TMenuItem;
    acTablesStatsUnselectAll: TAction;
    gridTablesDate: TcxGridColumn;
    StatsStyleRepo: TcxStyleRepository;
    styleBalancePositive: TcxStyle;
    styleBalanceNegative: TcxStyle;
    styleTableActive: TcxStyle;
    gridTablesStatusInt: TcxGridColumn;
    styleTableClosing: TcxStyle;
    styleTableClosed: TcxStyle;
    styleTableRowSelected: TcxStyle;
    acTablesStatsSelectAll: TAction;
    SelectAll1: TMenuItem;
    gridTablesHands: TcxGridColumn;
    paPlayerStats: TPanel;
    gridStats: TcxGrid;
    gridStatsTable: TcxGridTableView;
    gridStatsTablePlayerId: TcxGridColumn;
    gridStatsTablePlayerName: TcxGridColumn;
    gridStatsTableBalance: TcxGridColumn;
    gridStatsTableBuyins: TcxGridColumn;
    gridStatsTableCashouts: TcxGridColumn;
    gridStatsTableRake: TcxGridColumn;
    gridStatsTableChipsInPlay: TcxGridColumn;
    gridStatsTableTimePlayed: TcxGridColumn;
    gridStatsLevel: TcxGridLevel;
    gridTotalStats: TcxGrid;
    gridTotalStatsTable: TcxGridTableView;
    gridTotalStatsPlayers: TcxGridColumn;
    gridTotalStatsBalance: TcxGridColumn;
    gridTotalStatsBuyins: TcxGridColumn;
    gridTotalStatsCashouts: TcxGridColumn;
    gridTotalStatsRake: TcxGridColumn;
    gridTotalStatsChipsInPlay: TcxGridColumn;
    gridTotalStatsTimePlayed: TcxGridColumn;
    gridTotalStatsLevel: TcxGridLevel;
    gridTotalStatsDummy: TcxGridColumn;
    gridPlayersListLimit: TcxGridColumn;
    gridPlayersListBalance: TcxGridColumn;
    btResetBalance: TcxButton;
    acResetBalance: TAction;
    btSetLimit: TcxButton;
    acSetLimit: TAction;
    procedure btClubHomeClick(Sender: TObject);
    procedure btTablesClick(Sender: TObject);
    procedure acCloseClubExecute(Sender: TObject);
    procedure gridPlayersListTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
    procedure acGiveOwnershipExecute(Sender: TObject);
    procedure acRemovePlayerExecute(Sender: TObject);
    procedure acShowClubChangeDetailsFormExecute(Sender: TObject);
    procedure gridGamesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
    procedure acShowCreateGameFormExecute(Sender: TObject);
    procedure acCloseTableExecute(Sender: TObject);
    procedure acShowEditGameFormExecute(Sender: TObject);
    procedure acSuspendPlayerExecute(Sender: TObject);
    procedure acReinstatePlayerExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure acLeaveClubExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tiUpdateClubDetailsTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btStatsClick(Sender: TObject);
    procedure gridTablesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;  ANewItemRecordFocusingChanged: Boolean);
    procedure gridStatsTableBuyinsGetCellHint(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      ACellViewInfo: TcxGridTableDataCellViewInfo; const AMousePos: TPoint; var AHintText: TCaption; var AIsHintMultiLine: Boolean;
      var AHintTextRect: TRect);
    procedure acTablesStatsUnselectAllExecute(Sender: TObject);
    procedure gridTablesEnabledPropertiesChange(Sender: TObject);
    procedure gridStatsTableBalanceStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
    procedure gridTablesStatusStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
    procedure gridTablesTableStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
    procedure gridTablesTableDblClick(Sender: TObject);
    procedure acTablesStatsSelectAllExecute(Sender: TObject);
    procedure gridStatsTableColumnSizeChanged(Sender: TcxGridTableView; AColumn: TcxGridColumn);
    procedure acResetBalanceExecute(Sender: TObject);
    procedure acSetLimitExecute(Sender: TObject);
  private
    FCallbacksId: Integer;
    FClubId: Integer;
    FSelectedPlayerId: TBytes;
    FSelectedGameId: TBytes;
    FSelectedStatsTableId: TBytes;

    procedure ConfigureGUI(const AUpdateLists: Boolean = TRUE);

    procedure UpdatePlayerlist;
    procedure UpdateGamesList;
    procedure UpdateTablesStatsList;
    procedure UpdatePlayersStatsList;

    procedure ModalFormClose(ASender: TObject);

    procedure CSRStatus(const AMethodId: Integer; const AObject: TObject);
    procedure CSRLeaveClub(const AMethodId: Integer; const AObject: TObject);
    procedure CSRClubDetailsChange(const AMethodId: Integer; const AObject: TObject);
    procedure CSRKickPlayer(const AMethodId: Integer; const AObject: TObject);
    procedure CSRGetUsers(const AMethodId: Integer; const AObject: TObject);
    procedure CSRETransferChipsOk(const AMethodId: Integer; const AObject: TObject);
    procedure CSEUserChange(const AMethodId: Integer; const AObject: TObject);
    procedure CSRPlayerLimitOk(const AMethodId: Integer; const AObject: TObject);
    procedure CSROwnerGiveawayNotOwner(const AMethodId: Integer; const AObject: TObject);
    procedure CSROwnerGiveawayInvalidPlayerId(const AMethodId: Integer; const AObject: TObject);
    procedure CSROwnerGiveawayInvalidClubId(const AMethodId: Integer; const AObject: TObject);
    procedure CSREGameOperation(const AMethodId: Integer; const AObject: TObject);
    procedure CSREClubOperation(const AMethodId: Integer; const AObject: TObject);
    procedure CSRTableStatsReply(const AMethodId: Integer; const AObject: TObject);
    procedure CSETableStatus(const AMethodId: Integer; const AObject: TObject);
    procedure CSRResetPlayerBalanceOk(const AMethodId: Integer; const AObject: TObject);

  protected
    procedure CreateParams(var AParams: TCreateParams); override;

  public
    procedure SetParams(const AParams: array of pointer);

    property ClubId: Integer read FClubId;
  end;


implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  System.Generics.Collections,
  Poker.Common.Misc, Poker.Server.Socket, Poker.DataModule, Poker.Forms.ChangeClubDetails,
  Poker.Server.MessageCallbacks, Poker.Protobufs.Enum.ServerCodes, Poker.Server.MessageContainer, Poker.Objects.GameInfo,
  Poker.Forms.CreateEditGame, Poker.Protobufs.Objects.Club, Poker.Protobufs.Objects.Game, Poker.Protobufs.Objects.ClubCommandReply,
  Poker.Common.FormsContainer, Poker.Forms.CloseTable, Poker.Stats.Table, Poker.Stats.Player, System.DateUtils,
  Poker.Protobufs.Objects.TableStatsReplies, Poker.Forms.CloseClubConfirmation, Poker.Forms.ClubMemberOptions,
  Poker.Protobufs.Objects.PlayerLimitParams;


procedure TfrmClubLobby.FormCreate(Sender: TObject);
begin
  FCallbacksId := MessageContainer.AddCallbacks([
                      TServerMessageCallback.Create(srStatus, CSRStatus),
                      TServerMessageCallback.Create(srLeaveClubReply, CSRLeaveClub),
                      TServerMessageCallback.Create(srChangeClubDetailsReply, CSRClubDetailsChange),
                      TServerMessageCallback.Create(srKickPlayerReply, CSRKickPlayer),
                      TServerMessageCallback.Create(srGetPlayers, CSRGetUsers),
                      TServerMessageCallback.Create(srOwnershipGiveAwayNotOwner, CSROwnerGiveawayNotOwner),
                      TServerMessageCallback.Create(srOwnershipGiveawayInvalidPlayerId, CSROwnerGiveawayInvalidPlayerId),
                      TServerMessageCallback.Create(srOwnershipGiveAwayInvalidClubId, CSROwnerGiveawayInvalidClubId),
                      TServerMessageCallback.Create(srOwnershipGiveAwayOk, CSREClubOperation),
                      TServerMessageCallback.Create(srSuspendPlayerOk, CSREClubOperation),
                      TServerMessageCallback.Create(srReinstatePlayerOk, CSREClubOperation),
                      TServerMessageCallback.Create(seClubChange, CSREClubOperation),
                      TServerMessageCallback.Create(seClubDeleted, CSREClubOperation),
                      TServerMessageCallback.Create(seGameDelete, CSREGameOperation),
                      TServerMessageCallback.Create(seGameChange, CSREGameOperation),
                      TServerMessageCallback.Create(seGameCreate, CSREGameOperation),
                      TServerMessageCallback.Create(srEditGameOk, CSREGameOperation),
                      TServerMessageCallback.Create(srCreateGameOk, CSREGameOperation),
                      TServerMessageCallback.Create(srClubDisbandOk, CSREClubOperation),
                      TServerMessageCallback.Create(srTransferChipsOk, CSRETransferChipsOk),
                      TServerMessageCallback.Create(seTransferChips, CSRETransferChipsOk),
                      TServerMessageCallback.Create(srDeleteGameOk, CSREGameOperation),
                      TServerMessageCallback.Create(seUserChange, CSEUserChange),
                      TServerMessageCallback.Create(srTableStatsReply, CSRTableStatsReply),
                      TServerMessageCallback.Create(seTableStatus, CSETableStatus),
                      TServerMessageCallback.Create(srPlayerLimitOk, CSRPlayerLimitOk),
                      TServerMessageCallback.Create(srResetPlayerBalanceOk, CSRResetPlayerBalanceOk)

                  ]);

  // following block fixes Delphi IDE bug that shifts components by several pixels up occassionally
  btGiveOwnership.Top := gbPlayers.Height - btGiveOwnership.Height - 13;
  btRemovePlayerFromClub.Top := btGiveOwnership.Top;
  btSuspendUnsuspend.Top := btGiveOwnership.Top;
  btResetBalance.Top := btGiveOwnership.Top;
  btSetLimit.Top := btGiveOwnership.Top;
  btNewGame.Top := gbTables.Height - btNewGame.Height - 13;
  btEditGame.Top := btNewGame.Top;
  btCloseTable.Top := btNewGame.Top;
end;

procedure TfrmClubLobby.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.Remove(self);

  OutputDebugString('CLUB LOBBY DESTROY');
end;

procedure TfrmClubLobby.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if tiUpdateClubDetails.Enabled then
  begin
    tiUpdateClubDetails.Enabled := FALSE;
    acUpdateClubDetails.Execute;
  end;

  Action := caFree;
end;

procedure TfrmClubLobby.SetParams(const AParams: array of pointer);
begin
  FClubId := PInteger(AParams[0])^;

  btClubHome.Click;
  ConfigureGUI;
end;

procedure TfrmClubLobby.ConfigureGUI(const AUpdateLists: Boolean = TRUE);
var
  club: TClubInfo;
  player: TPlayerInfo;
  manager: String;
  admin_visible: Boolean;
  member: TClubMemberInfo;
begin
  if dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
  begin
    Caption := Format('%s lobby', [club.Name]);

    lbsHeader.Caption := club.Name;

    manager := '';
    if Players.FindPlayerById(club.OwnerId, player) then
      manager := player.Nick;

    lbsSubheader.Caption := Format('Manager: %s           Members: %d           Club ID: %d', [manager, club.Members.Count, club.Id]);

    admin_visible := CompareBytes(club.OwnerId, dmMain.SelfInfo.Id);

    if not club.GetMemberInfo(FSelectedPlayerId, member) then
      member := nil;

    gridPlayersListLimit.Visible := admin_visible;
    gridPlayersListBalance.Visible := admin_visible;
    btChangeClubDetails.Visible := admin_visible;
    acShowClubChangeDetailsForm.Enabled := admin_visible;
    acUpdateClubDetails.Enabled := admin_visible;
    btCloseClub.Visible := admin_visible;
    acCloseClub.Enabled := admin_visible;
    btResetBalance.Visible := admin_visible;
    btSetLimit.Visible := admin_visible;
    acResetBalance.Enabled := (admin_visible) and (Assigned(member));
    acSetLimit.Enabled := (admin_visible) and (Assigned(member));
    btGiveOwnership.Visible := admin_visible;
    acGiveOwnership.Enabled := (admin_visible) and (Assigned(member)) and (not CompareBytes(club.OwnerId, FSelectedPlayerId));
    btRemovePlayerFromClub.Visible := admin_visible;
    acRemovePlayer.Enabled := acGiveOwnership.Enabled;
    btSuspendUnsuspend.Visible := admin_visible;
    if btSuspendUnsuspend.Visible then
    begin
      acSuspendPlayer.Enabled := (Assigned(member)) and (not member.Suspended) and (not CompareBytes(member.MongoId, club.OwnerId));
      acReinstatePlayer.Enabled := (Assigned(member)) and (member.Suspended) and (not CompareBytes(member.MongoId, club.OwnerId));
      if acReinstatePlayer.Enabled then
        btSuspendUnsuspend.Action := acReinstatePlayer
      else
        btSuspendUnsuspend.Action := acSuspendPlayer;
    end;
    btNewGame.Visible := admin_visible;
    acShowCreateGameForm.Enabled := admin_visible;
    btCloseTable.Visible := admin_visible;
    acCloseTable.Enabled := (admin_visible) and (Length(FSelectedGameId) > 0);
//    btEditGame.Visible := admin_visible;
//    acShowEditGameForm.Enabled := (admin_visible) and (Length(FSelectedGameId) > 0);
    Bevel1.Visible := admin_visible;
    btLeaveClub.Visible := not admin_visible;
    acLeaveClub.Enabled := not admin_visible;
    if admin_visible then
    begin
      gridPlayersList.Align := alTop;
      gridGames.Align := alTop;

      gridPlayersList.Height := btSuspendUnsuspend.Top - 5;
      gridGames.Height := btNewGame.Top - 5;
    end
    else
    begin
      gridPlayersList.Align := alClient;
      gridGames.Align := alClient;
    end;

    btStats.Enabled := admin_visible;

    if AUpdateLists then
    begin
      UpdatePlayerlist;
      UpdateGamesList;
      if btStats.Enabled then
      begin
        UpdateTablesStatsList;
        UpdatePlayersStatsList;
      end;
    end;
  end;
end;

procedure TfrmClubLobby.CreateParams(var AParams: TCreateParams);
begin
  inherited;

  AParams.ExStyle := AParams.ExStyle or WS_EX_APPWINDOW;
  AParams.WndParent := 0;
end;

procedure TfrmClubLobby.btTablesClick(Sender: TObject);
begin
  pcTabs.ActivePage := tsTables;
end;

procedure TfrmClubLobby.btClubHomeClick(Sender: TObject);
begin
  pcTabs.ActivePage := tsClubHome;
end;

procedure TfrmClubLobby.btStatsClick(Sender: TObject);
begin
  pcTabs.ACtivePage := tsStats;
end;

procedure TfrmClubLobby.gridGamesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex       : Integer;
  club           : TClubInfo;
  game           : TGameInfo;
  close_table_act: Boolean;
begin
  if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
    SetLength(FSelectedGameId, 0)
  else
  begin
    recIndex := gridGamesTable.DataController.GetFocusedRecordIndex;
    if recIndex = -1 then
      SetLength(FSelectedGameId, 0)
    else
      FSelectedGameId := gridGamesTable.DataController.GetValue(recIndex, gridGamesId.Index);
  end;

  close_table_act := (Length(FSelectedGameId) > 0) and (CompareBytes(club.OwnerId, dmMain.SelfInfo.Id)) and
                     (club.Games.FindGame(FSelectedGameId, game)) and (game.State in [gsActive, gsEmpty]);

  acCloseTable.Enabled := close_table_act;
//  acShowEditGameForm.Enabled := actions_enabled;
end;

procedure TfrmClubLobby.gridPlayersListTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex: Integer;
  club: TClubInfo;
begin
  if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
    SetLength(FSelectedPlayerId, 0)
  else
  begin
    recIndex := gridPlayersListTable.DataController.GetFocusedRecordIndex;
    if recIndex = -1 then
      SetLength(FSelectedPlayerId, 0)
    else
      FSelectedPlayerId := gridPlayersListTable.DataController.GetValue(recIndex, gridPlayersListId.Index);
  end;

  ConfigureGUI(FALSE);
end;

procedure TfrmClubLobby.gridStatsTableBalanceStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
var
  value: Variant;
begin
  value := ARecord.Values[AItem.Index];
  if value > 0 then
    AStyle := styleBalancePositive
  else
    if value < 0 then
      AStyle := styleBalanceNegative;
end;

procedure TfrmClubLobby.gridStatsTableBuyinsGetCellHint(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  ACellViewInfo: TcxGridTableDataCellViewInfo; const AMousePos: TPoint; var AHintText: TCaption; var AIsHintMultiLine: Boolean;
  var AHintTextRect: TRect);
var
  C1: Integer;
  tablestats: TTableStats;
  player: TPlayerStats;
  playerid: TBytes;
  arr: TArray<UINT32>;
begin
  AHintText := '';

  if not TablesStats.Find(FSelectedStatsTableId, tablestats) then
    Exit;

  playerid := ARecord.Values[gridStatsTablePlayerId.Index];

  for player in tablestats.Players do
    if CompareBytes(player.UserId, playerid) then
    begin
      if ACellViewInfo.Item.Index = gridStatsTableBuyins.Index then
        arr := player.Buyins
      else
        if ACellViewInfo.Item.Index = gridStatsTableCashouts.Index then
          arr := player.Cashouts
        else
          Break;

      if Length(arr) <= 1 then
        Break;

      for C1 := Low(arr) to High(arr) do
      begin
        AHintText := AHintText + FloatToStr(arr[C1] / 100);
        if C1 < High(arr) then
          AHintText := AHintText + #10;
      end;
      AIsHintMultiLine := TRUE;
      Break;
    end;
end;

procedure TfrmClubLobby.gridStatsTableColumnSizeChanged(Sender: TcxGridTableView; AColumn: TcxGridColumn);
begin
  gridTotalStatsPlayers.Width := gridStatsTablePlayerName.Width;
  gridTotalStatsBalance.Width := gridStatsTableBalance.Width;
  gridTotalStatsBuyins.Width := gridStatsTableBuyins.Width;
  gridTotalStatsCashouts.Width := gridStatsTableCashouts.Width;
  gridTotalStatsRake.Width := gridStatsTableRake.Width;
  gridTotalStatsChipsInPlay.Width := gridStatsTableChipsInPlay.Width;
  gridTotalStatsTimePlayed.Width := gridStatsTableTimePlayed.Width;

  gridTotalStatsDummy.Visible := gridStatsTable.Site.VScrollBarVisible;
end;

procedure TfrmClubLobby.gridTablesEnabledPropertiesChange(Sender: TObject);
begin
  UpdatePlayersStatsList;
end;

procedure TfrmClubLobby.gridTablesStatusStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
var
  value: Variant;
begin
  value := ARecord.Values[gridTablesStatusInt.Index];
  if VarIsNull(value) then
    Exit;

  case value of
    Integer(gsEmpty): AStyle := styleTableActive;
    Integer(gsActive): AStyle := styleTableActive;
    Integer(gsClosing): AStyle := styleTableClosing;
    Integer(gsClosed): AStyle := styleTableClosed;
  end;
end;

procedure TfrmClubLobby.gridTablesTableDblClick(Sender: TObject);
var
  c: TcxDataController;
  value: Boolean;
begin
  c := gridTablesTable.DataController;
  c.BeginFullUpdate;
  try
    value := FALSE;
    if c.GetValue(c.FocusedRecordIndex, gridTablesEnabled.Index) = TRUE then
      value := TRUE;
    c.SetValue(c.FocusedRecordIndex, gridTablesEnabled.Index, not value);
    UpdatePlayersStatsList;
  finally
    c.EndFullUpdate;
  end;
end;

procedure TfrmClubLobby.gridTablesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex: Integer;
  club: TClubInfo;
begin
  if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
    SetLength(FSelectedStatsTableId, 0)
  else
  begin
    recIndex := gridTablesTable.DataController.GetFocusedRecordIndex;
    if recIndex = -1 then
      SetLength(FSelectedStatsTableId, 0)
    else
      FSelectedStatsTableId := gridTablesTable.DataController.GetValue(recIndex, gridTablesTableId.Index);
  end;

  UpdatePlayersStatsList;
end;

procedure TfrmClubLobby.gridTablesTableStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
begin
  if ARecord.Values[gridTablesEnabled.Index] = TRUE then
    AStyle := styleTableRowSelected;
end;

procedure TfrmClubLobby.ModalFormClose(ASender: TObject);
begin
  if ASender is TfrmCloseClubConfirmation then
  begin
    if (ASender as TfrmCloseClubConfirmation).ModalResult = mrOk then
      ServerSocket.DisbandClub(FClubId);
  end;

  EnableWindow(Handle, TRUE);
end;

procedure TfrmClubLobby.UpdatePlayerlist;
var
  club: TClubInfo;
  query_players: TArray<TBytes>;

  procedure AddPlayerToGrid(const ARowIndex: Integer; AMember: TClubMemberInfo);
  var
    player: TPlayerInfo;
    status: String;
  begin
    gridPlayersListTable.DataController.SetValue(ARowIndex, gridPlayersListId.Index, AMember.MongoId);
    if Players.FindPlayerById(AMember.MongoId, player) then
      gridPlayersListTable.DataController.SetValue(ARowIndex, gridPlayersListName.Index, player.Nick)
    else
    begin
      gridPlayersListTable.DataController.SetValue(ARowIndex, gridPlayersListName.Index, 'Unknown');
      SetLength(query_players, Length(query_players) + 1);
      query_players[Length(query_players) - 1] := AMember.MongoId;
    end;

    gridPlayersListTable.DataController.SetValue(ARowIndex, gridPlayersListBalance.Index, AMember.ClubBalance / 100);

    if AMember.UnlimitedLimit then
      status := 'Unlimited'
    else
      status := '-' + ChipsToStr(AMember.BalanceLimit);
    gridPlayersListTable.DataController.SetValue(ARowIndex, gridPlayersListLimit.Index, status);

    if CompareBytes(AMember.MongoId, club.OwnerId) then
      status := 'Manager'
    else
      if AMember.Suspended then
        status := 'Suspended'
      else
        status := 'Member';
    gridPlayersListTable.DataController.SetValue(ARowIndex, gridPlayersListStatus.Index, status);
  end;

var
  C1: Integer;
begin
  gridPlayersListTable.DataController.BeginFullUpdate;
  try
    gridPlayersListTable.DataController.SetRecordCount(0);

    if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
    begin
      gridPlayersListTable.DataController.SetRecordCount(0);
      Exit;
    end;

    SetLength(query_players, 0);
    gridPlayersListTable.DataController.SetRecordCount(club.Members.Count);
    for C1 := 0 to club.Members.Count - 1 do
      AddPlayerToGrid(C1, club.Members[C1]);

    if Length(query_players) > 0 then
      ServerSocket.GetUserInfos(query_players);
  finally
    gridPlayersListTable.DataController.EndFullUpdate;
  end;
  gridPlayersListTable.DataController.Refresh;
end;

procedure TfrmClubLobby.UpdateTablesStatsList;
var
  game: TGameInfo;
  club: TClubInfo;
  c: TcxGridDataController;
  recidx: Integer;
  tablestats: TTableStats;
  tmp: String;
begin
  c := gridTablesTable.DataController;
  c.BeginFullUpdate;
  try
    c.SetRecordCount(0);

    if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
      Exit;

    for tablestats in TablesStats do
      if CompareBytes(tablestats.ClubId, club.MongoId) then
      begin
        if club.Games.FindGame(tablestats.GameId, game) then
          tmp := game.Name
        else
          tmp := 'UNKNOWN';

        recidx := c.AppendRecord;
        c.SetValue(recidx, gridTablesTableId.Index, tablestats.GameId);
        c.SetValue(recidx, gridTablesHands.Index, tablestats.Hands);
        c.SetValue(recidx, gridTablesName.Index, tmp);

        if Assigned(game) then
        begin
          c.SetValue(recidx, gridTablesStatus.Index, game.StateAsStr);
          c.SetValue(recidx, gridTablesDate.Index, TTimeZone.Local.ToLocalTime(MongoIdToDateTime(game.MongoId)));
          c.SetValue(recidx, gridTablesStatusInt.Index, Integer(game.State));
        end;
      end;
  finally
    c.EndFullUpdate;
  end;
  c.Refresh;
end;

procedure TfrmClubLobby.UpdatePlayersStatsList;
var
  club: TClubInfo;
  c: TcxGridDataController;
  recidx: Integer;
  tablestats: TTableStats;
  playerstats: TPlayerStats;
  playerstats_new: TPlayerStats;
  player: TPlayerInfo;
  tmp: String;
  datetim: TDateTime;
  selectedids: TList<TBytes>;
  tablestatslist: TObjectList<TTableStats>;
  finalstats: TObjectList<TPlayerStats>;
  selectedid: TBytes;
  C1: Integer;
  found: Boolean;
  total_balance, total_buyins, total_cashouts, total_rake, total_chipsinplay, total_timeplayed: Int64;
begin
  finalstats := TObjectList<TPlayerStats>.Create;
  try
    c := gridStatsTable.DataController;
    c.BeginFullUpdate;
    try
      c.SetRecordCount(0);

      if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
        Exit;

      selectedids := TList<TBytes>.Create;
      try
        for C1 := 0 to gridTablesTable.DataController.RecordCount - 1 do
          if gridTablesTable.DataController.GetValue(C1, gridTablesEnabled.Index) = TRUE then
            selectedids.Add(gridTablesTable.DataController.GetValue(C1, gridTablesTableId.Index));

        tablestatslist := TObjectList<TTableStats>.Create(FALSE);
        try
          if selectedids.Count = 0 then
          begin
            if TablesStats.Find(FSelectedStatsTableId, tablestats) then
              tablestatslist.Add(tablestats);
          end
          else
            for selectedid in selectedids do
              if TablesStats.Find(selectedid, tablestats) then
                tablestatslist.Add(tablestats);

          for tablestats in tablestatslist do
            for playerstats in tablestats.Players do
            begin
              found := FALSE;
              for C1 := 0 to finalstats.Count - 1 do
                if CompareBytes(finalstats[C1].UserId, playerstats.UserId) then
                begin
                  finalstats[C1].Merge(playerstats);
                  found := TRUE;
                  Break;
                end;

              if not found then
              begin
                playerstats_new := TPlayerStats.Create;
                playerstats_new.Assign(playerstats);
                finalstats.Add(playerstats_new);
              end;
            end;

          for playerstats in finalstats do
          begin
            recidx := c.AppendRecord;

            if Players.FindPlayerById(playerstats.UserId, player) then
              tmp := player.Nick
            else
              tmp := 'Unknown';
            c.SetValue(recidx, gridStatsTablePlayerName.Index, tmp);

            c.SetValue(recidx, gridStatsTablePlayerId.Index, playerstats.UserId);
            c.SetValue(recidx, gridStatsTableBalance.Index, playerstats.Balance / 100);
            c.SetValue(recidx, gridStatsTableBuyins.Index, playerstats.BuyinsTotal / 100);
            c.SetValue(recidx, gridStatsTableCashouts.Index, playerstats.CashoutsTotal / 100);
            c.SetValue(recidx, gridStatsTableRake.Index, playerstats.RakeContrib / 100);
            c.SetValue(recidx, gridStatsTableChipsInPlay.Index, playerstats.ChipsInPlay / 100);
            datetim := SecondsToTime(playerstats.SecondsPlayed);
            ReplaceDate(datetim, Date);
            c.SetValue(recidx, gridStatsTableTimePlayed.Index, datetim);
          end;
        finally
          tablestatslist.Free;
        end;
      finally
        selectedids.Free;
      end;
    finally
      c.EndFullUpdate;
    end;
    c.Refresh;

    total_balance := 0;
    total_buyins := 0;
    total_cashouts := 0;
    total_rake := 0;
    total_chipsinplay := 0;
    total_timeplayed := 0;

    for playerstats in finalstats do
    begin
      Inc(total_balance, playerstats.Balance);
      Inc(total_buyins, playerstats.BuyinsTotal);
      Inc(total_cashouts, playerstats.CashoutsTotal);
      Inc(total_rake, playerstats.RakeContrib);
      Inc(total_chipsinplay, playerstats.ChipsInPlay);
      Inc(total_timeplayed, playerstats.SecondsPlayed);
    end;

    c := gridTotalStatsTable.DataController;
    c.BeginFullUpdate;
    try
      c.SetRecordCount(1);
      c.SetValue(0, gridTotalStatsPlayers.Index, finalstats.Count);
      c.SetValue(0, gridTotalStatsBalance.Index, total_balance / 100);
      c.SetValue(0, gridTotalStatsBuyins.Index, total_buyins / 100);
      c.SetValue(0, gridTotalStatsCashouts.Index, total_cashouts / 100);
      c.SetValue(0, gridTotalStatsRake.Index, total_rake / 100);
      c.SetValue(0, gridTotalStatsChipsInPlay.Index, total_chipsinplay / 100);

      datetim := SecondsToTime(total_timeplayed);
      ReplaceDate(datetim, Date);
      c.SetValue(0, gridTotalStatsTimePlayed.Index, datetim);
    finally
      c.EndFullUpdate;
    end;
    c.Refresh;
  finally
    finalstats.Free;
  end;
end;

procedure TfrmClubLobby.UpdateGamesList;
var
  C1    : Integer;
  game  : TGameInfo;
  club  : TClubInfo;
  c     : TcxGridDataController;
  recidx: Integer;
begin
  c := gridGamesTable.DataController;
  c.BeginFullUpdate;
  try
    c.SetRecordCount(0);

    if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
      Exit;

    for C1 := 0 to club.Games.Count - 1 do
    begin
      game := club.Games[C1];

      if game.State = gsClosed then
        Continue;

      recidx := c.AppendRecord;

      c.SetValue(recidx, gridGamesId.Index, game.MongoId);
      c.SetValue(recidx, gridGamesName.Index, game.Name);
      c.SetValue(recidx, gridGamesType.Index, game.AsString(TRUE));
      c.SetValue(recidx, gridGamesBlinds.Index, Format('%d/%d', [Trunc(game.SmallBlind / 100), Trunc(game.BigBlind / 100)]));
      c.SetValue(recidx, gridGamesBuyinLimits.Index, Format('%d-%d', [game.MinBuyin, game.MaxBuyin]));
      c.SetValue(recidx, gridGamesSeats.Index, game.Seats);
      c.SetValue(recidx, gridGamesTableStatus.Index, game.StateAsStr);
    end;
  finally
    c.EndFullUpdate;
  end;
  c.Refresh;
end;

procedure TfrmClubLobby.tiUpdateClubDetailsTimer(Sender: TObject);
begin
  acUpdateClubDetails.Execute;
  tiUpdateClubDetails.Enabled := FALSE;
end;


procedure TfrmClubLobby.acCloseClubExecute(Sender: TObject);
var
  club: TClubInfo;
  game: TGameInfo;
begin
  if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
    Exit;

  for game in club.Games do
    if game.State <> gsClosed then
    begin
      MessageDlg('There are active tables in the club. Before closing the club, please close all active tables first', mtError, [mbOK], 0);
      Exit;
    end;

  FormsContainer.Add(RunModalForm(TfrmCloseClubConfirmation, self, [club], ModalFormClose));
end;

procedure TfrmClubLobby.acGiveOwnershipExecute(Sender: TObject);
var
  club  : TClubInfo;
  player: TPlayerInfo;
begin
  if (not dmMain.SelfInfo.Clubs.FindClub(FClubId, club)) or
     (not Players.FindPlayerById(FSelectedPlayerId, player)) then
    Exit;

  if MessageDlg(Format('Are you sure you want to give club ownership to %s?', [player.Nick]), mtConfirmation, mbYesNo, 0) = mrYes then
    ServerSocket.GiveOwnership(club.Id, player.Id);
end;

procedure TfrmClubLobby.acLeaveClubExecute(Sender: TObject);
begin
  if MessageDlg('Are you sure you want to leave this club?', mtConfirmation, mbYesNo, 0) = mrYes then
    ServerSocket.LeaveClub(FClubId);
end;

procedure TfrmClubLobby.acRemovePlayerExecute(Sender: TObject);
var
  club  : TClubInfo;
  player: TPlayerInfo;
begin
  if (not dmMain.SelfInfo.Clubs.FindClub(FClubId, club)) or
     (not Players.FindPlayerById(FSelectedPlayerId, player)) then
    Exit;

  if MessageDlg(Format('Are you sure you want to remove %s from the club?', [player.Nick]), mtConfirmation, mbYesNo, 0) = mrYes then
    ServerSocket.KickPlayer(club.Id, player.Id);
end;

procedure TfrmClubLobby.acResetBalanceExecute(Sender: TObject);
var
  club: TclubInfo;
  player: TPlayerInfo;
begin
  if (not dmMain.SelfInfo.Clubs.FindClub(FClubId, club)) or
     (not Players.FindPlayerById(FSelectedPlayerId, player)) then
    Exit;

  if MessageDlg(Format('Reset balance for player %s?', [player.Nick]), mtConfirmation, mbYesNo, 0) = mrYes then
    ServerSocket.ResetPlayerBalance(club.MongoId, player.Id);
end;

procedure TfrmClubLobby.acSetLimitExecute(Sender: TObject);
var
  club: TClubInfo;
  member: TClubMemberInfo;
begin
  if (not dmMain.SelfInfo.Clubs.FindClub(FClubId, club)) or
     (not club.GetMemberInfo(FSelectedPlayerId, member)) then
    Exit;

  FormsContainer.Add(RunModalForm(TfrmClubMemberOptions, self, [club, FSelectedPlayerId], ModalFormClose));
end;

procedure TfrmClubLobby.acShowClubChangeDetailsFormExecute(Sender: TObject);
var
  club: TClubInfo;
begin
  if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
    Exit;

  FormsContainer.Add(RunModalForm(TfrmChangeClubDetails, self, [club], ModalFormClose));
end;

procedure TfrmClubLobby.acShowCreateGameFormExecute(Sender: TObject);
var
  club: TClubInfo;
  pint: Integer;
begin
  if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
    Exit;

  pint := 0;
  FormsContainer.Add(RunModalForm(TfrmCreateEditGame, self, [@pint, club], ModalFormClose));
end;

procedure TfrmClubLobby.acShowEditGameFormExecute(Sender: TObject);
var
  club: TClubInfo;
  game: TGameInfo;
  pint: Integer;
begin
  if (not dmMain.SelfInfo.Clubs.FindClub(FClubId, club)) or
     (not club.Games.FindGame(FSelectedGameId, game)) then
    Exit;

  pint := 1;
  FormsContainer.Add(RunModalForm(TfrmCreateEditGame, self, [@pint, game], ModalFormClose));
end;

procedure TfrmClubLobby.acSuspendPlayerExecute(Sender: TObject);
var
  club: TClubInfo;
begin
  if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
    Exit;

  ServerSocket.ChangePlayerSuspendState(club.MongoId, FSelectedPlayerId, TRUE);
end;

procedure TfrmClubLobby.acTablesStatsSelectAllExecute(Sender: TObject);
var
  C1: Integer;
begin
  gridTablesTable.DataController.BeginFullUpdate;
  try
    for C1 := 0 to gridTablesTable.DataController.RecordCount - 1 do
      gridTablesTable.DataController.SetValue(C1, gridTablesEnabled.Index, TRUE);
    UpdatePlayersStatsList;
  finally
    gridTablesTable.DataController.EndFullUpdate;
  end;
  gridTablesTable.DataController.Refresh;
end;

procedure TfrmClubLobby.acTablesStatsUnselectAllExecute(Sender: TObject);
var
  C1: Integer;
begin
  gridTablesTable.DataController.BeginFullUpdate;
  try
    for C1 := 0 to gridTablesTable.DataController.RecordCount - 1 do
      gridTablesTable.DataController.SetValue(C1, gridTablesEnabled.Index, FALSE);
    UpdatePlayersStatsList;
  finally
    gridTablesTable.DataController.EndFullUpdate;
  end;
  gridTablesTable.DataController.Refresh;
end;

procedure TfrmClubLobby.acReinstatePlayerExecute(Sender: TObject);
var
  club: TClubInfo;
begin
  if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
    Exit;

  ServerSocket.ChangePlayerSuspendState(club.MongoId, FSelectedPlayerId, FALSE);
end;

procedure TfrmClubLobby.acCloseTableExecute(Sender: TObject);
var
  club: TClubInfo;
  game: TGameInfo;
begin
  if (dmMain.SelfInfo.Clubs.FindClub(FClubId, club)) and
     (club.Games.FindGame(FSelectedGameId, game)) then
    FormsContainer.Add(RunModalForm(TfrmCloseTable, self, [game], ModalFormClose));
end;

procedure TfrmClubLobby.CSRStatus(const AMethodId: Integer; const AObject: TObject);
begin
  ConfigureGUI;
end;

procedure TfrmClubLobby.CSRTableStatsReply(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_TableStatsReplies;
  C1: Integer;
  club: TClubInfo;
begin
  pbreply := AObject as TPB_TableStatsReplies;

  if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
    Exit;

  for C1 := 0 to pbreply.Reply.Count - 1 do
    if CompareBytes(club.Mongoid, pbreply.Reply[C1].Clubid) then
    begin
      ConfigureGUI;
      Exit;
    end;
end;

procedure TfrmClubLobby.CSRETransferChipsOk(const AMethodId: Integer; const AObject: TObject);
begin
  ConfigureGUI;
end;

procedure TfrmClubLobby.CSETableStatus(const AMethodId: Integer; const AObject: TObject);
begin
  ConfigureGUI;
end;

procedure TfrmClubLobby.CSEUserChange(const AMethodId: Integer; const AObject: TObject);
begin
  ConfigureGUI;
end;

procedure TfrmClubLobby.CSRClubDetailsChange(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_ClubCommandReply;
begin
  pbreply := AObject as TPB_ClubCommandReply;
  if pbreply.Club.Seq <> FClubId then
    Exit;

  case pbreply.Status of
    csSuccess: ConfigureGUI;
    csNameExists: ;
  else
    {$IFDEF DEBUG} DebugLn(Format('CSRLeaveClub: invalid status received [%d]]', [Integer(pbreply.Status)]), ditException); {$ENDIF}
  end;
end;

procedure TfrmClubLobby.CSRLeaveClub(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_ClubCommandReply;
begin
  pbreply := AObject as TPB_ClubCommandReply;
  if pbreply.Club.Seq <> FClubId then
    Exit;

  case pbreply.Status of
    csSuccess: Close;
    csInvalidClubId: ;
  else
    {$IFDEF DEBUG} DebugLn(Format('CSRLeaveClub: invalid status received [%d]]', [Integer(pbreply.Status)]), ditException); {$ENDIF}
  end;
end;

procedure TfrmClubLobby.CSRKickPlayer(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_ClubCommandReply;
begin
  pbreply := AObject as TPB_ClubCommandReply;
  if pbreply.Club.Seq <> FClubId then
    Exit;

  case pbreply.Status of
    csSuccess: ConfigureGUI;
    csInvalidClubId: MessageDlg('Invalid club ID', mtError, [mbOk], 0);
  else
    {$IFDEF DEBUG} DebugLn(Format('CSRKickPlayer: invalid status received [%d]]', [Integer(pbreply.Status)]), ditException); {$ENDIF}
  end;
end;

procedure TfrmClubLobby.CSROwnerGiveawayInvalidClubId(const AMethodId: Integer; const AObject: TObject);
var
  pbclub: TPB_Club;
begin
  pbclub := AObject as TPB_Club;
  if FClubId <> pbclub.Seq then
    Exit;

  MessageDlg('Invalid club ID', mtError, [mbOk], 0);
end;

procedure TfrmClubLobby.CSROwnerGiveawayInvalidPlayerId(const AMethodId: Integer; const AObject: TObject);
var
  pbclub: TPB_Club;
begin
  pbclub := AObject as TPB_Club;
  if FClubId <> pbclub.Seq then
    Exit;

  MessageDlg('Invalid player ID', mtError, [mbOk], 0);
end;

procedure TfrmClubLobby.CSROwnerGiveawayNotOwner(const AMethodId: Integer; const AObject: TObject);
var
  pbclub: TPB_Club;
begin
  pbclub := AObject as TPB_Club;
  if FClubId <> pbclub.Seq then
    Exit;

  MessageDlg('You are not manager of this club', mtError, [mbOk], 0);
end;

procedure TfrmClubLobby.CSRPlayerLimitOk(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_PlayerLimitParams;
  club: TClubInfo;
begin
  pbreply := AObject as TPB_PlayerLimitParams;

  if (not dmMain.SelfInfo.Clubs.FindClub(FClubId, club)) or
     (not CompareBytes(club.MongoId, pbreply.Clubid)) then
    Exit;

  club.UpdateMember(pbreply.Userid, pbreply.Limit, pbreply.Unlimited);

  ConfigureGUI;
end;

procedure TfrmClubLobby.CSRResetPlayerBalanceOk(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_PlayerLimitParams;
  club: TClubInfo;
begin
  pbreply := AObject as TPB_PlayerLimitParams;

  if (not dmMain.SelfInfo.Clubs.FindClub(FClubId, club)) or
     (not CompareBytes(club.MongoId, pbreply.Clubid)) then
    Exit;

  club.ResetMemberBalance(pbreply.Userid);

  ConfigureGUI;
end;

procedure TfrmClubLobby.CSREClubOperation(const AMethodId: Integer; const AObject: TObject);
var
  pbclub: TPB_Club;
  club: TClubInfo;
begin
  pbclub := AObject as TPB_Club;
  if FClubId <> pbclub.Seq then
    Exit;

  if dmMain.SelfInfo.Clubs.FindClub(pbclub.Seq, club) then
    ConfigureGUI
  else // current club is disbanded? close form
    Close;
end;

procedure TfrmClubLobby.CSREGameOperation(const AMethodId: Integer; const AObject: TObject);
var
  pbgame: TPB_Game;
begin
  pbgame := AObject as TPB_Game;

  if pbgame.Clubseq = FClubId then
    ConfigureGUI;
end;

procedure TfrmClubLobby.CSRGetUsers(const AMethodId: Integer; const AObject: TObject);
begin
  ConfigureGUI;
end;

end.
