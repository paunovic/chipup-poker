unit Poker.Forms.ClubLobby;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Poker.Interfaces.FormParams,
  Poker.Clubs.Club, cxControls, cxEdit, cxLabel, cxButtons, cxPC, cxGroupBox, Vcl.ActnList, cxCustomData, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridCustomView, cxGrid, Poker.Players.PlayerList, dxBevel, cxImage, Vcl.ExtCtrls,
  Vcl.Menus, cxStyles, cxData, cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, dxSkinsCore, ChipUpPokerDarkSkin,
  dxSkinscxPCPainter, cxPCdxBarPopupMenu, cxFilter, cxDataStorage, cxBlobEdit, cxTextEdit, cxSpinEdit, cxCheckBox, cxCalendar, cxTimeEdit,
  cxClasses, Vcl.StdCtrls, dxGDIPlusClasses, Poker.Types;

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
    acSuspendPlayer: TAction;
    acReinstatePlayer: TAction;
    btLeaveClub: TcxButton;
    acLeaveClub: TAction;
    imgHeader: TcxImage;
    btPrijatnaPunina: TcxButton;
    gridGamesBuyinLimits: TcxGridColumn;
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
    styleCheckedRow: TcxStyle;
    styleSelectedRow: TcxStyle;
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
    procedure acSuspendPlayerExecute(Sender: TObject);
    procedure acReinstatePlayerExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure acLeaveClubExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure btStatsClick(Sender: TObject);
    procedure gridTablesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;  ANewItemRecordFocusingChanged: Boolean);
    procedure gridStatsTableBuyinsGetCellHint(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord; ACellViewInfo: TcxGridTableDataCellViewInfo;
      const AMousePos: TPoint; var AHintText: TCaption; var AIsHintMultiLine: Boolean; var AHintTextRect: TRect);
    procedure acTablesStatsUnselectAllExecute(Sender: TObject);
    procedure gridTablesEnabledPropertiesChange(Sender: TObject);
    procedure gridStatsTableBalanceStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
    procedure gridTablesStatusStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
    procedure gridTablesTableDblClick(Sender: TObject);
    procedure acTablesStatsSelectAllExecute(Sender: TObject);
    procedure gridStatsTableColumnSizeChanged(Sender: TcxGridTableView; AColumn: TcxGridColumn);
    procedure acResetBalanceExecute(Sender: TObject);
    procedure acSetLimitExecute(Sender: TObject);
    procedure gridTablesTableStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
  private
    FCallbacksId: Integer;
    FClubId: TMongoId;
    FSelectedPlayerId: TMongoId;
    FSelectedGameId: TMongoId;
    FSelectedStatsTableId: TMongoId;
    {$IFDEF DEBUG} FDebugId: Integer; {$ENDIF}

    procedure ConfigureGUI(const AUpdateLists: Boolean = TRUE);

    procedure UpdatePlayerlist;
    procedure UpdateGamesList;
    procedure UpdateTablesStatsList;
    procedure UpdatePlayersStatsList;

    procedure ModalFormClose(ASender: TObject);

    procedure CSRLeaveClub(const AMethodId: Integer; const AObject: TObject);
    procedure CSRClubDetailsChange(const AMethodId: Integer; const AObject: TObject);
    procedure CSRKickPlayer(const AMethodId: Integer; const AObject: TObject);
    procedure CSRGetUsers(const AMethodId: Integer; const AObject: TObject);
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

    property ClubId: TMongoId read FClubId;
  end;


implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  System.Generics.Collections, Poker.Common.Misc, Poker.Server.Socket, Poker.DataModule, Poker.Forms.ChangeClubDetails,
  Poker.Server.MessageCallbacks, Poker.Protobufs.Enum.ServerCodes, Poker.Server.MessageContainer, Poker.Games.Game,
  Poker.Forms.CreateGame, Poker.Protobufs.Objects.Club, Poker.Protobufs.Objects.Game, Poker.Protobufs.Objects.ClubCommandReply,
  Poker.Common.FormsContainer, Poker.Forms.CloseTable, Poker.Tables.StatsList, System.DateUtils, Poker.Protobufs.Objects.TableStatsReplies,
  Poker.Forms.CloseClubConfirmation, Poker.Forms.ClubMemberOptions, Poker.Protobufs.Objects.PlayerLimitParams, Poker.Clubs.Member,
  Poker.Players.Player, Poker.Protobufs.Objects.TablePlayerStats, Poker.Helpers.PB_TablePlayerStats, Poker.Protobufs.Objects.Base,
  Poker.Protobufs.Objects.TableStatsReply;


procedure TfrmClubLobby.FormCreate(Sender: TObject);
begin
  FCallbacksId := MessageContainer.AddCallbacks([
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
                      TServerMessageCallback.Create(srCreateGameOk, CSREGameOperation),
                      TServerMessageCallback.Create(srClubDisbandOk, CSREClubOperation),
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
  btCloseTable.Top := btNewGame.Top;
end;

procedure TfrmClubLobby.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.Remove(self);

  {$IFDEF DEBUG} UnregisterDebugObject(FDebugId); {$ENDIF}
end;

procedure TfrmClubLobby.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmClubLobby.SetParams(const AParams: array of pointer);
begin
  PtrToMongoId(AParams[0], FClubId);

  btClubHome.Click;
  ConfigureGUI;

  {$IFDEF DEBUG} FDebugId := RegisterDebugObject(Format('%s [%s]', [Name, Caption])); {$ENDIF}
end;

procedure TfrmClubLobby.ConfigureGUI(const AUpdateLists: Boolean = TRUE);
var
  club: TClubInfo;
  player: TPlayerInfo;
  manager: String;
  admin_visible: Boolean;
  member: TClubMemberInfo;
begin
  if dmMain.SelfInfo.Clubs.GetAndLock(FClubId, club) then
  try
    Caption := Format('%s lobby', [club.Name]);

    lbsHeader.Caption := club.Name;

    manager := '';
    if Players.TryGetValue(club.OwnerId, player) then
      manager := player.Nick;

    lbsSubheader.Caption := Format('Manager: %s           Members: %d           Club ID: %d', [manager, club.Members.Count, club.Id]);

    admin_visible := CompareMongoId(club.OwnerId, dmMain.SelfInfo.MongoId);

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
    acGiveOwnership.Enabled := (admin_visible) and (Assigned(member)) and (not CompareMongoId(club.OwnerId, FSelectedPlayerId));
    btRemovePlayerFromClub.Visible := admin_visible;
    acRemovePlayer.Enabled := acGiveOwnership.Enabled;
    btSuspendUnsuspend.Visible := admin_visible;
    if btSuspendUnsuspend.Visible then
    begin
      acSuspendPlayer.Enabled := (Assigned(member)) and (not member.Suspended) and (not CompareMongoId(member.MongoId, club.OwnerId));
      acReinstatePlayer.Enabled := (Assigned(member)) and (member.Suspended) and (not CompareMongoId(member.MongoId, club.OwnerId));
      if acReinstatePlayer.Enabled then
        btSuspendUnsuspend.Action := acReinstatePlayer
      else
        btSuspendUnsuspend.Action := acSuspendPlayer;
    end;
    btNewGame.Visible := admin_visible;
    acShowCreateGameForm.Enabled := admin_visible;
    btCloseTable.Visible := admin_visible;
    acCloseTable.Enabled := (admin_visible) and (not CompareMongoId(FSelectedGameId, EMPTY_MONGO_ID));
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
  finally
    dmMain.SelfInfo.Clubs.Unlock;
  end;

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
  recIndex: Integer;
  club: TClubInfo;
  game: TGameInfo;
  close_table_act: Boolean;
begin
  close_table_act := FALSE;
  FSelectedGameId := EMPTY_MONGO_ID;
  if dmMain.SelfInfo.Clubs.GetAndLock(FClubId, club) then
  try
    recIndex := gridGamesTable.DataController.GetFocusedRecordIndex;
    if recIndex > -1 then
      VariantToMongoId(gridGamesTable.DataController.GetValue(recIndex, gridGamesId.Index), FSelectedGameId);

    close_table_act := (not CompareMongoId(FSelectedGameId, EMPTY_MONGO_ID)) and
                       (CompareMongoId(club.OwnerId, dmMain.SelfInfo.MongoId)) and
                       (club.Games.TryGetValue(FSelectedGameId, game)) and (game.State in [gsActive, gsEmpty]);

  finally
    dmMain.SelfInfo.Clubs.Unlock;
  end;

  acCloseTable.Enabled := close_table_act;
end;

procedure TfrmClubLobby.gridPlayersListTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex: Integer;
begin
  recIndex := gridPlayersListTable.DataController.GetFocusedRecordIndex;
  if recIndex > -1 then
    VariantToMongoId(gridPlayersListTable.DataController.GetValue(recIndex, gridPlayersListId.Index), FSelectedPlayerId)
  else
    FSelectedPlayerId := EMPTY_MONGO_ID;

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
  tablestats: TPB_TableStatsReply;
  player: TPB_TablePlayerStats;
  playerid: TMongoId;
  list: TList<UINT32>;
begin
  AHintText := '';

  if not TablesStats.TryGetValue(FSelectedStatsTableId, tablestats) then
    Exit;

  VariantToMongoId(ARecord.Values[gridStatsTablePlayerId.Index], playerid);

  list := nil;
  for player in tablestats.Playerstats do
    if CompareMongoId(player.UserId, playerid) then
    begin
      if ACellViewInfo.Item.Index = gridStatsTableBuyins.Index then
        list := player.Buyins
      else
        if ACellViewInfo.Item.Index = gridStatsTableCashouts.Index then
          list := player.Cashouts
        else
          Break;

      if (not Assigned(list)) or
         (list.Count < 2) then
        Break;

      for C1 := 0 to list.Count - 1 do
      begin
        AHintText := AHintText + FloatToStr(list[C1] / 100);
        if C1 < list.Count - 1 then
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
begin
  recIndex := gridTablesTable.DataController.GetFocusedRecordIndex;
  if recIndex = -1 then
    FSelectedStatsTableId := EMPTY_MONGO_ID
  else
    VariantToMongoId(gridTablesTable.DataController.GetValue(recIndex, gridTablesTableId.Index), FSelectedStatsTableId);

  UpdatePlayersStatsList;
end;

procedure TfrmClubLobby.gridTablesTableStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
begin
  if ARecord.Values[gridTablesEnabled.Index] = TRUE then
    AStyle := styleCheckedRow
  else
    if Sender.DataController.FocusedRowIndex = ARecord.Index then
      AStyle := styleSelectedRow;
end;

procedure TfrmClubLobby.ModalFormClose(ASender: TObject);
begin
  if ASender is TfrmCloseClubConfirmation then
  begin
    if (ASender as TfrmCloseClubConfirmation).ModalResult = mrOk then
    begin
      ServerSocket.DisbandClub(FClubId);
    end;
  end;

  EnableWindow(Handle, TRUE);
end;

procedure TfrmClubLobby.UpdatePlayerlist;
var
  club: TClubInfo;
  query_players: TArray<TMongoId>;

  procedure AddPlayerToGrid(const ARowIndex: Integer; AMember: TClubMemberInfo);
  var
    player: TPlayerInfo;
    status: String;
  begin
    gridPlayersListTable.DataController.SetValue(ARowIndex, gridPlayersListId.Index, MongoIdToVariant(AMember.MongoId));
    if Players.TryGetValue(AMember.MongoId, player) then
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

    if CompareMongoId(AMember.MongoId, club.OwnerId) then
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
  rec_count: Integer;
begin
  gridPlayersListTable.DataController.BeginFullUpdate;
  try
    SetLength(query_players, 0);
    rec_count := 0;
    if dmMain.SelfInfo.Clubs.GetAndLock(FClubId, club) then
    try
      rec_count := club.Members.Count;
      gridPlayersListTable.DataController.SetRecordCount(rec_count);
      for C1 := 0 to club.Members.Count - 1 do
        AddPlayerToGrid(C1, club.Members[C1]);
    finally
      dmMain.SelfInfo.Clubs.Unlock;
    end;

    gridPlayersListTable.DataController.SetRecordCount(rec_count);
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
  tablestats: TPB_TableStatsReply;
  tmp: String;
  rec_count: Integer;
  current_mongoid: TMongoId;
begin
  c := gridTablesTable.DataController;
  c.BeginFullUpdate;
  try
    rec_count := 0;
    if dmMain.SelfInfo.Clubs.GetAndLock(FClubId, club) then
    try
      for tablestats in TablesStats.Values do
        if CompareMongoId(tablestats.ClubId, club.MongoId) then
        begin
          Inc(rec_count);
          if rec_count > c.RecordCount then
          begin
            recidx := c.AppendRecord;
            current_mongoid := EMPTY_MONGO_ID;
          end
          else
          begin
            recidx := rec_count - 1;
            VariantToMongoId(c.GetValue(recidx, gridTablesTableId.Index), current_mongoid);
          end;

          if club.Games.TryGetValue(tablestats.GameId, game) then
            tmp := game.Name
          else
            tmp := 'UNKNOWN';

          if not CompareMongoId(current_mongoid, tablestats.GameId) then
            c.SetValue(recidx, gridTablesEnabled.Index, FALSE);

          c.SetValue(recidx, gridTablesTableId.Index, MongoIdToVariant(tablestats.GameId));
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
      dmMain.SelfInfo.Clubs.Unlock;
    end;
    c.SetRecordCount(rec_count);
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
  tablestats: TPB_TableStatsReply;
  playerstats: TPB_TablePlayerStats;
  player: TPlayerInfo;
  tmp: String;
  datetim: TDateTime;
  selectedids: TList<TMongoId>;
  tablestatslist: TPB_TableStatsReplyList;
  finalstats: TPB_TablePlayerStatsList;
  selectedid: TMongoId;
  C1: Integer;
  found: Boolean;
  total_balance, total_buyins, total_cashouts, total_rake, total_chipsinplay: Int64;
  rec_count: Integer;
begin
  finalstats := TPB_TablePlayerStatsList.Create;
  try
    c := gridStatsTable.DataController;
    c.BeginFullUpdate;
    try
      rec_count := 0;
      if dmMain.SelfInfo.Clubs.GetAndLock(FClubId, club) then
      try
        selectedids := TList<TMongoId>.Create;
        try
          for C1 := 0 to gridTablesTable.DataController.RecordCount - 1 do
            if gridTablesTable.DataController.GetValue(C1, gridTablesEnabled.Index) = TRUE then
            begin
              VariantToMongoId(gridTablesTable.DataController.GetValue(C1, gridTablesTableId.Index), selectedid);
              selectedids.Add(selectedid);
            end;

          tablestatslist := TPB_TableStatsReplyList.Create(FALSE);
          try
            if selectedids.Count = 0 then
            begin
              if TablesStats.TryGetValue(FSelectedStatsTableId, tablestats) then
                tablestatslist.Add(tablestats);
            end
            else
              for selectedid in selectedids do
                if TablesStats.TryGetValue(selectedid, tablestats) then
                  tablestatslist.Add(tablestats);

            for tablestats in tablestatslist do
              for playerstats in tablestats.Playerstats do
              begin
                found := FALSE;
                for C1 := 0 to finalstats.Count - 1 do
                  if CompareMongoId(finalstats[C1].UserId, playerstats.UserId) then
                  begin
                    finalstats[C1].Merge(playerstats);
                    Break;
                  end;

                if not found then
                  finalstats.Add(TPB_TablePlayerStats.Create(playerstats, TRUE));
              end;

            for playerstats in finalstats do
            begin
              Inc(rec_count);
              if rec_count > c.RecordCount then
                recidx := c.AppendRecord
              else
                recidx := rec_count - 1;

              if Players.TryGetValue(playerstats.UserId, player) then
                tmp := player.Nick
              else
                tmp := 'Unknown';
              c.SetValue(recidx, gridStatsTablePlayerName.Index, tmp);
              c.SetValue(recidx, gridStatsTablePlayerId.Index, MongoIdToVariant(playerstats.UserId));
              c.SetValue(recidx, gridStatsTableBalance.Index, playerstats.Balance / 100);
              c.SetValue(recidx, gridStatsTableBuyins.Index, playerstats.GetBuyinsTotal / 100);
              c.SetValue(recidx, gridStatsTableCashouts.Index, playerstats.GetCashoutsTotal / 100);
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
        dmMain.SelfInfo.Clubs.Unlock;
      end;
      c.SetRecordCount(rec_count);
    finally
      c.EndFullUpdate;
    end;
    c.Refresh;

    total_balance := 0;
    total_buyins := 0;
    total_cashouts := 0;
    total_rake := 0;
    total_chipsinplay := 0;

    for playerstats in finalstats do
    begin
      Inc(total_balance, playerstats.Balance);
      Inc(total_buyins, playerstats.GetBuyinsTotal);
      Inc(total_cashouts, playerstats.GetCashoutsTotal);
      Inc(total_rake, playerstats.RakeContrib);
      Inc(total_chipsinplay, playerstats.ChipsInPlay);
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
      c.SetValue(0, gridTotalStatsTimePlayed.Index, 'N/A');
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
  game: TGameInfo;
  club: TClubInfo;
  c: TcxGridDataController;
  recidx: Integer;
begin
  c := gridGamesTable.DataController;
  c.BeginFullUpdate;
  try
    c.SetRecordCount(0);

    if dmMain.SelfInfo.Clubs.GetAndLock(FClubId, club) then
    try
      for game in club.Games.Values do
      begin
        if game.State = gsClosed then
          Continue;

        recidx := c.AppendRecord;

        c.SetValue(recidx, gridGamesId.Index, MongoIdToVariant(game.MongoId));
        c.SetValue(recidx, gridGamesName.Index, game.Name);
        c.SetValue(recidx, gridGamesType.Index, game.AsString(TRUE));
        c.SetValue(recidx, gridGamesBlinds.Index, Format('%d/%d', [Trunc(game.SmallBlind / 100), Trunc(game.BigBlind / 100)]));
        c.SetValue(recidx, gridGamesBuyinLimits.Index, Format('%d-%d', [game.MinBuyin, game.MaxBuyin]));
        c.SetValue(recidx, gridGamesSeats.Index, game.Seats);
        c.SetValue(recidx, gridGamesTableStatus.Index, game.StateAsStr);
      end;
    finally
      dmMain.SelfInfo.Clubs.Unlock;
    end;
  finally
    c.EndFullUpdate;
  end;
  c.Refresh;
end;

procedure TfrmClubLobby.acCloseClubExecute(Sender: TObject);
var
  club: TClubInfo;
  game: TGameInfo;
  err: String;
begin
  err := '';
  if dmMain.SelfInfo.Clubs.GetAndLock(FClubId, club) then
  try
    for game in club.Games.Values do
      if game.State <> gsClosed then
      begin
        err := 'There are active tables in the club. Before closing the club, please close all active tables first';
        Break;
      end;

    if err = '' then
      FormsContainer.Add(RunModalForm(TfrmCloseClubConfirmation, self, [@club.MongoId[0]], ModalFormClose));
  finally
    dmMain.SelfInfo.Clubs.Unlock;
  end;

  if err <> '' then
    MessageDlg(err, mtWarning, [mbOK], 0);
end;

procedure TfrmClubLobby.acGiveOwnershipExecute(Sender: TObject);
var
  player: TPlayerInfo;
begin
  if not Players.TryGetValue(FSelectedPlayerId, player) then
    Exit;

  if MessageDlg(Format('Are you sure you want to give club ownership to %s?', [player.Nick]), mtConfirmation, mbYesNo, 0) = mrYes then
  begin
    if Players.TryGetValue(FSelectedPlayerId, player) then
      ServerSocket.GiveOwnership(FClubId, player.MongoId);
  end;
end;

procedure TfrmClubLobby.acLeaveClubExecute(Sender: TObject);
begin
  if MessageDlg('Are you sure you want to leave this club?', mtConfirmation, mbYesNo, 0) = mrYes then
    ServerSocket.LeaveClub(FClubId);
end;

procedure TfrmClubLobby.acRemovePlayerExecute(Sender: TObject);
var
  player: TPlayerInfo;
begin
  if not Players.TryGetValue(FSelectedPlayerId, player) then
    Exit;

  if MessageDlg(Format('Are you sure you want to remove %s from the club?', [player.Nick]), mtConfirmation, mbYesNo, 0) = mrYes then
  begin
    if Players.TryGetValue(FSelectedPlayerId, player) then
      ServerSocket.KickPlayer(FClubId, player.MongoId);
  end;
end;

procedure TfrmClubLobby.acResetBalanceExecute(Sender: TObject);
var
  club: TClubInfo;
  player: TPlayerInfo;
begin
  if not Players.TryGetValue(FSelectedPlayerId, player) then
    Exit;

  if MessageDlg(Format('Reset balance for player %s?', [player.Nick]), mtConfirmation, mbYesNo, 0) = mrYes then
  begin
    if dmMain.SelfInfo.Clubs.GetAndLock(FClubId, club) then
    try
      if Players.TryGetValue(FSelectedPlayerId, player) then
        ServerSocket.ResetPlayerBalance(club.MongoId, player.MongoId);
    finally
      dmMain.SelfInfo.Clubs.Unlock;;
    end;
  end;
end;

procedure TfrmClubLobby.acSetLimitExecute(Sender: TObject);
begin
  FormsContainer.Add(RunModalForm(TfrmClubMemberOptions, self, [@FClubId[0], @FSelectedPlayerId[0]], ModalFormClose));
end;

procedure TfrmClubLobby.acShowClubChangeDetailsFormExecute(Sender: TObject);
var
  club: TClubInfo;
begin
  if not dmMain.SelfInfo.Clubs.GetAndLock(FClubId, club) then
    Exit;
  dmMain.SelfInfo.Clubs.Unlock;

  FormsContainer.Add(RunModalForm(TfrmChangeClubDetails, self, [@FClubId[0]], ModalFormClose));
end;

procedure TfrmClubLobby.acShowCreateGameFormExecute(Sender: TObject);
begin
  FormsContainer.Add(RunModalForm(TfrmCreateGame, self, [@FClubId[0]], ModalFormClose));
end;

procedure TfrmClubLobby.acSuspendPlayerExecute(Sender: TObject);
var
  club: TClubInfo;
begin
  if not dmMain.SelfInfo.Clubs.GetAndLock(FClubId, club) then
    Exit;
  dmMain.SelfInfo.Clubs.Unlock;

  ServerSocket.ChangePlayerSuspendState(FClubId, FSelectedPlayerId, TRUE);
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
  if not dmMain.SelfInfo.Clubs.GetAndLock(FClubId, club) then
    Exit;
  dmMain.SelfInfo.Clubs.Unlock;

  ServerSocket.ChangePlayerSuspendState(FClubId, FSelectedPlayerId, FALSE);
end;

procedure TfrmClubLobby.acCloseTableExecute(Sender: TObject);
begin
  FormsContainer.Add(RunModalForm(TfrmCloseTable, self, [@FSelectedGameId[0]], ModalFormClose));
end;

procedure TfrmClubLobby.CSRTableStatsReply(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_TableStatsReplies;
  C1: Integer;
begin
  if not TProtobufBaseObject.ObjectToProto(AObject, TPB_TableStatsReplies, pointer(pbreply)) then
    Exit;

  for C1 := 0 to pbreply.Reply.Count - 1 do
    if CompareMongoId(FClubId, pbreply.Reply[C1].Clubid) then
    begin
      ConfigureGUI;
      Exit;
    end;
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
  if not TProtobufBaseObject.ObjectToProto(AObject, TPB_ClubCommandReply, pointer(pbreply)) then
    Exit;
  if not CompareMongoId(pbreply.Club.MongoId, FClubId) then
    Exit;

  case pbreply.Status of
    csSuccess: ConfigureGUI;
    csNameExists: ;
  else
    {$IFDEF DEBUG} DebugLn(FDebugId, Format('CSRLeaveClub: invalid status received [%d]]', [Integer(pbreply.Status)]), ditException); {$ENDIF}
  end;
end;

procedure TfrmClubLobby.CSRLeaveClub(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_ClubCommandReply;
begin
  if not TProtobufBaseObject.ObjectToProto(AObject, TPB_ClubCommandReply, pointer(pbreply)) then
    Exit;
  if not CompareMongoId(pbreply.Club.MongoId, FClubId) then
    Exit;

  case pbreply.Status of
    csSuccess: Close;
    csInvalidClubId: ;
  else
    {$IFDEF DEBUG} DebugLn(FDebugId, Format('CSRLeaveClub: invalid status received [%d]]', [Integer(pbreply.Status)]), ditException); {$ENDIF}
  end;
end;

procedure TfrmClubLobby.CSRKickPlayer(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_ClubCommandReply;
begin
  if not TProtobufBaseObject.ObjectToProto(AObject, TPB_ClubCommandReply, pointer(pbreply)) then
    Exit;
  if not CompareMongoId(pbreply.Club.MongoId, FClubId) then
    Exit;

  case pbreply.Status of
    csSuccess: ConfigureGUI;
    csInvalidClubId: MessageDlg('Invalid club ID', mtError, [mbOk], 0);
  else
    {$IFDEF DEBUG} DebugLn(FDebugId, Format('CSRKickPlayer: invalid status received [%d]]', [Integer(pbreply.Status)]), ditException); {$ENDIF}
  end;
end;

procedure TfrmClubLobby.CSROwnerGiveawayInvalidClubId(const AMethodId: Integer; const AObject: TObject);
var
  pbclub: TPB_Club;
begin
  if not TProtobufBaseObject.ObjectToProto(AObject, TPB_Club, pointer(pbclub)) then
    Exit;
  if not CompareMongoId(pbclub.MongoId, FClubId) then
    Exit;

  MessageDlg('Invalid club ID', mtError, [mbOk], 0);
end;

procedure TfrmClubLobby.CSROwnerGiveawayInvalidPlayerId(const AMethodId: Integer; const AObject: TObject);
var
  pbclub: TPB_Club;
begin
  if not TProtobufBaseObject.ObjectToProto(AObject, TPB_Club, pointer(pbclub)) then
    Exit;
  if not CompareMongoId(pbclub.MongoId, FClubId) then
    Exit;

  MessageDlg('Invalid player ID', mtError, [mbOk], 0);
end;

procedure TfrmClubLobby.CSROwnerGiveawayNotOwner(const AMethodId: Integer; const AObject: TObject);
var
  pbclub: TPB_Club;
begin
  if not TProtobufBaseObject.ObjectToProto(AObject, TPB_Club, pointer(pbclub)) then
    Exit;
  if not CompareMongoId(pbclub.MongoId, FClubId) then
    Exit;

  MessageDlg('You are not manager of this club', mtError, [mbOk], 0);
end;

procedure TfrmClubLobby.CSRPlayerLimitOk(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_PlayerLimitParams;
  club: TClubInfo;
begin
  if not TProtobufBaseObject.ObjectToProto(AObject, TPB_PlayerLimitParams, pointer(pbreply)) then
    Exit;
  if not CompareMongoId(FClubId, pbreply.Clubid) then
    Exit;

  if dmMain.SelfInfo.Clubs.GetAndLock(FClubId, club) then
  try
    club.UpdateMember(pbreply.Userid, pbreply.Limit, pbreply.Unlimited);
  finally
    dmMain.SelfInfo.Clubs.Unlock;
  end;

  ConfigureGUI;
end;

procedure TfrmClubLobby.CSRResetPlayerBalanceOk(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_PlayerLimitParams;
  club: TClubInfo;
begin
  if not TProtobufBaseObject.ObjectToProto(AObject, TPB_PlayerLimitParams, pointer(pbreply)) then
    Exit;
  if not CompareMongoId(FClubId, pbreply.Clubid) then
    Exit;

  if dmMain.SelfInfo.Clubs.GetAndLock(FClubId, club) then
  try
    club.ResetMemberBalance(pbreply.Userid);
  finally
    dmMain.SelfInfo.Clubs.Unlock;
  end;

  ConfigureGUI;
end;

procedure TfrmClubLobby.CSREClubOperation(const AMethodId: Integer; const AObject: TObject);
var
  pbclub: TPB_Club;
  contains_key: Boolean;
begin
  if not TProtobufBaseObject.ObjectToProto(AObject, TPB_Club, pointer(pbclub)) then
    Exit;
  if not CompareMongoId(pbclub.MongoId, FClubId) then
    Exit;

  dmMain.SelfInfo.Clubs.Lock;
  try
    contains_key := dmMain.SelfInfo.Clubs.ContainsKey(FClubId);
  finally
    dmMain.SelfInfo.Clubs.Unlock;
  end;

  if contains_key then
    ConfigureGUI
  else // current club is disbanded? close form
    Close;
end;

procedure TfrmClubLobby.CSREGameOperation(const AMethodId: Integer; const AObject: TObject);
var
  pbgame: TPB_Game;
  club: TClubInfo;
  config_gui: Boolean;
  game: TGameInfo;
begin
  if not TProtobufBaseObject.ObjectToProto(AObject, TPB_Game, pointer(pbgame)) then
    Exit;

  config_gui := FALSE;
  if dmMain.SelfInfo.Clubs.GetAndLockByGame(pbgame.MongoId, club, game) then
  try
    config_gui := CompareMongoId(FClubId, club.MongoId);
  finally
    dmMain.SelfInfo.Clubs.Unlock;
  end;

  if config_gui then
    ConfigureGUI;
end;

procedure TfrmClubLobby.CSRGetUsers(const AMethodId: Integer; const AObject: TObject);
begin
  ConfigureGUI;
end;

end.
