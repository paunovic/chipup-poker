unit uManageClubsForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles, dxSkinsCore,
  dxSkinDevExpressStyle, dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, cxTextEdit, cxSpinEdit,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxClasses, cxGridCustomView, cxGrid, Vcl.Menus, Vcl.StdCtrls, cxButtons, cxContainer,
  cxLabel, cxRadioGroup, cxGroupBox, dxSkinsForm, uClubInfo, Vcl.ActnList, cxMaskEdit, uPlayerInfo, uGameInfo, uMessageItem;

type
  TfrmManageClubs = class(TForm)
    gbPlayers: TcxGroupBox;
    gridPlayersList: TcxGrid;
    gridPlayersListTable: TcxGridTableView;
    gridPlayersListName: TcxGridColumn;
    gridPlayersListBalance: TcxGridColumn;
    gridPlayersListId: TcxGridColumn;
    gridPlayersListLevel: TcxGridLevel;
    btGiveOwnership: TcxButton;
    btRemovePlayerFromClub: TcxButton;
    alManageClubs: TActionList;
    acKickPlayer: TAction;
    acGiveOwnership: TAction;
    acShowClubChangeDetailsForm: TAction;
    gbClubs: TcxGroupBox;
    gridClubs: TcxGrid;
    gridClubsTable: TcxGridTableView;
    gridClubsId: TcxGridColumn;
    gridClubsClubName: TcxGridColumn;
    gridClubsType: TcxGridColumn;
    gridClubsLevel: TcxGridLevel;
    btChangeClubType: TcxButton;
    btDisbandClub: TcxButton;
    acDisbandClub: TAction;
    btGiveChips: TcxButton;
    acGiveChips: TAction;
    gridClubsBalance: TcxGridColumn;
    gbGames: TcxGroupBox;
    gridGames: TcxGrid;
    gridGamesTable: TcxGridTableView;
    gridGamesName: TcxGridColumn;
    gridGamesType: TcxGridColumn;
    gridGamesLevel: TcxGridLevel;
    btNewGame: TcxButton;
    acShowCreateGameForm: TAction;
    btDeleteGame: TcxButton;
    acDeleteGame: TAction;
    gridGamesId: TcxGridColumn;
    btEditGame: TcxButton;
    acShowEditGameForm: TAction;
    gridGamesBlinds: TcxGridColumn;
    gridGamesSeats: TcxGridColumn;
    procedure FormCreate(Sender: TObject);
    procedure gridClubsTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    procedure acKickPlayerExecute(Sender: TObject);
    procedure gridPlayersListTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord,
      AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure acGiveOwnershipExecute(Sender: TObject);
    procedure acShowClubChangeDetailsFormExecute(Sender: TObject);
    procedure acDisbandClubExecute(Sender: TObject);
    procedure acGiveChipsExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure acShowCreateGameFormExecute(Sender: TObject);
    procedure gridGamesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    procedure acDeleteGameExecute(Sender: TObject);
    procedure acShowEditGameFormExecute(Sender: TObject);
  private
    FSelectedClub  : TClubInfo;
    FSelectedPlayer: TPlayerInfo;
    FSelectedGame  : TGameInfo;

    procedure UpdateClublist;
    procedure UpdateClubPlayerlist;
    procedure UpdateClubGamesList;
    procedure ShowClubInfo;

    procedure TCStatusReply(const AMessage: TMessageItem);
    procedure TCKickPlayerOk(const AMessage: TMessageItem);
    procedure TCKickPlayerInvalidClubId(const AMessage: TMessageItem);
    procedure TCKickPlayerInvalidPlayerId(const AMessage: TMessageItem);
    procedure TCOwnerGiveawayOk(const AMessage: TMessageItem);
    procedure TCOwnerGiveawayNotOwner(const AMessage: TMessageItem);
    procedure TCOwnerGiveawayInvalidPlayerId(const AMessage: TMessageItem);
    procedure TCOwnerGiveawayInvalidClubId(const AMessage: TMessageItem);
    procedure TCClubDisbandOk(const AMessage: TMessageItem);
    procedure TCDeleteGameOk(const AMessage: TMessageItem);
  protected
    procedure WndProc(var AMessage: TMessage); override;
  public
  end;


implementation

{$R *.dfm}

uses
  uMainDataModule, uSocketClient, uCommon, uServerCodes, uChangeClubDetailsForm, uGiveChipsForm, uCreateGameForm, uEditGameForm,
  uPB_StatusReply, uMessageContainer, uServerMessageCallback;

procedure TfrmManageClubs.FormCreate(Sender: TObject);
begin
  FSelectedClub := nil;
  FSelectedPlayer := nil;
  FSelectedGame := nil;
  UpdateClublist;
  ShowClubInfo;
end;

procedure TfrmManageClubs.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);
end;

procedure TfrmManageClubs.FormShow(Sender: TObject);
begin
  MessageContainer.AddMessageHandler(Handle);
end;

procedure TfrmManageClubs.WndProc(var AMessage: TMessage);
var
  msg: TMessageItem;
begin
  inherited;

  if MessageContainer.IsNewMessage(AMessage, msg) then
  begin
    case msg.MessageType of
      mtServerResponse: ProcessServerMessage(msg,
                          [
                            TServerMessageCallback.Create(SR_STATUS, TCStatusReply),
                            TServerMessageCallback.Create(SR_KICKPLAYER_OK, TCKickPlayerOk),
                            TServerMessageCallback.Create(SR_KICKPLAYER_INVALID_CLUB_ID, TCKickPlayerInvalidClubId),
                            TServerMessageCallback.Create(SR_KICKPLAYER_INVALID_PLAYER_ID, TCKickPlayerInvalidPlayerId),
                            TServerMessageCallback.Create(SR_OWNERSHIP_GIVEAWAY_NOT_OWNER, TCOwnerGiveawayNotOwner),
                            TServerMessageCallback.Create(SR_OWNERSHIP_GIVEAWAY_INVALID_PLAYER_ID, TCOwnerGiveawayInvalidPlayerId),
                            TServerMessageCallback.Create(SR_OWNERSHIP_GIVEAWAY_INVALID_CLUB_ID, TCOwnerGiveawayInvalidClubId),
                            TServerMessageCallback.Create(SR_OWNERSHIP_GIVEAWAY_OK, TCOwnerGiveawayOk),
                            TServerMessageCallback.Create(SR_CLUB_DISBAND_OK, TCClubDisbandOk),
                            TServerMessageCallback.Create(SR_DELETE_GAME_OK, TCDeleteGameOk)
                          ]
                        );
    end;

    msg.IncReadCount;
  end;
end;

procedure TfrmManageClubs.UpdateClublist;
var
  C1   : Integer;
  ctype: String;
  index: Integer;
begin
  gridClubsTable.DataController.BeginFullUpdate;
  try
    gridClubsTable.DataController.SetRecordCount(0);
    for C1 := 0 to dmMain.SelfInfo.Clubs.Count - 1 do
      if dmMain.SelfInfo.Clubs[C1].OwnerId = dmMain.SelfInfo.Id then
      begin
        gridClubsTable.DataController.SetRecordCount(gridClubsTable.DataController.RecordCount + 1);
        index := gridClubsTable.DataController.RecordCount - 1;

        gridClubsTable.DataController.SetValue(index, gridClubsId.Index, dmMain.SelfInfo.Clubs[C1].Id);
        gridClubsTable.DataController.SetValue(index, gridClubsClubName.Index, dmMain.SelfInfo.Clubs[C1].Name);
        if dmMain.SelfInfo.Clubs[C1].IsPrivate then
          ctype := 'Private'
        else
          ctype := 'Public';
        gridClubsTable.DataController.SetValue(index, gridClubsType.Index, ctype);
        gridClubsTable.DataController.SetValue(index, gridClubsBalance.Index, dmMain.SelfInfo.Clubs[C1].Balance);
      end;
  finally
    gridClubsTable.DataController.EndFullUpdate;
  end;
end;

procedure TfrmManageClubs.gridClubsTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord,
  AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex: Integer;
  club_id : Int64;
begin
  recIndex := gridClubsTable.DataController.GetFocusedRecordIndex;
  if recIndex = -1 then
    FSelectedClub := nil
  else
  begin
    club_id := gridClubsTable.DataController.GetValue(recIndex, gridClubsId.Index);
    if not dmMain.SelfInfo.Clubs.FindClub(club_id, FSelectedClub) then
      FSelectedClub := nil;
  end;

  ShowClubInfo;
end;

procedure TfrmManageClubs.gridGamesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord,
  AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex: Integer;
  game_id : String;
begin
  recIndex := gridGamesTable.DataController.GetFocusedRecordIndex;
  if (recIndex = -1) or (not Assigned(FSelectedClub)) then
    FSelectedGame := nil
  else
  begin
    game_id := gridGamesTable.DataController.GetValue(recIndex, gridGamesId.Index);
    if not FSelectedClub.Games.FindGame(game_id, FSelectedGame) then
      FSelectedGame := nil;
  end;

  acDeleteGame.Enabled := Assigned(FSelectedGame);
  acShowEditGameForm.Enabled := Assigned(FSelectedGame);
end;

procedure TfrmManageClubs.gridPlayersListTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord,
  AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex      : Integer;
  player_id     : String;
  action_enabled: Boolean;
begin
  if not Assigned(FSelectedClub) then
    Exit;

  recIndex := gridPlayersListTable.DataController.GetFocusedRecordIndex;
  if recIndex = -1 then
    FSelectedPlayer := nil
  else
  begin
    player_id := gridPlayersListTable.DataController.GetValue(recIndex, gridPlayersListId.Index);
    if not dmMain.Players.FindPlayerById(player_id, FSelectedPlayer) then
      FSelectedPlayer := nil;
  end;

  action_enabled := (Assigned(FSelectedClub)) and (Assigned(FSelectedPlayer)) and
                    (FSelectedClub.OwnerId = dmMain.SelfInfo.Id) and (FSelectedClub.OwnerId <> FSelectedPlayer.Id);
  acKickPlayer.Enabled := action_enabled;
  acGiveOwnership.Enabled := action_enabled;
  acGiveChips.Enabled := action_enabled;
end;

procedure TfrmManageClubs.ShowClubInfo;
begin
  acShowClubChangeDetailsForm.Enabled := Assigned(FSelectedClub);
  acDisbandClub.Enabled := Assigned(FSelectedClub);
  acShowCreateGameForm.Enabled := Assigned(FSelectedClub);

  UpdateClubPlayerlist;
  UpdateClubGamesList;
end;

procedure TfrmManageClubs.UpdateClubPlayerlist;
var
  C1    : Integer;
  player: TPlayerInfo;
begin
  gridPlayersListTable.DataController.BeginFullUpdate;
  try
    gridPlayersListTable.DataController.SetRecordCount(0);

    if not Assigned(FSelectedClub) then
    begin
      gridPlayersListTable.DataController.SetRecordCount(0);
      Exit;
    end;

    gridPlayersListTable.DataController.SetRecordCount(FSelectedClub.Players.Count);
    for C1 := 0 to FSelectedClub.Players.Count - 1 do
    begin
      if not dmMain.Players.FindPlayerById(FSelectedClub.Players[C1], player) then
        Continue;

      gridPlayersListTable.DataController.SetValue(C1, gridPlayersListName.Index, player.Nick);
      gridPlayersListTable.DataController.SetValue(C1, gridPlayersListBalance.Index, player.Balance);
      gridPlayersListTable.DataController.SetValue(C1, gridPlayersListId.Index, player.Id);
    end;
  finally
    gridPlayersListTable.DataController.EndFullUpdate;
  end;
end;

procedure TfrmManageClubs.UpdateClubGamesList;
var
  C1       : Integer;
  game     : TGameInfo;
  game_type: String;
begin
  gridGamesTable.DataController.BeginFullUpdate;
  try
    gridGamesTable.DataController.SetRecordCount(0);

    if not Assigned(FSelectedClub) then
    begin
      gridGamesTable.DataController.SetRecordCount(0);
      Exit;
    end;

    gridGamesTable.DataController.SetRecordCount(FSelectedClub.Games.Count);
    for C1 := 0 to FSelectedClub.Games.Count - 1 do
    begin
      game := FSelectedClub.Games[C1];

      gridGamesTable.DataController.SetValue(C1, gridGamesId.Index, game.MongoId);
      gridGamesTable.DataController.SetValue(C1, gridGamesName.Index, game.Name);
      case game.Limit of
        glNoLimit: game_type := 'NL';
        glLimit: game_type := 'FL';
        glPotLimit: game_type := 'PL';
      end;

      case game.GameType of
        gtHoldem: game_type := game_type + ' Hold''em';
        gtOmaha: game_type := game_type + ' Omaha';
      else
        game_type := game_type + ' Unknown';
      end;
      gridGamesTable.DataController.SetValue(C1, gridGamesType.Index, game_type);
      gridGamesTable.DataController.SetValue(C1, gridGamesBlinds.Index, Format('%d/%d', [game.SmallBlind, game.BigBlind]));
      gridGamesTable.DataController.SetValue(C1, gridGamesSeats.Index, game.Seats);
    end;
  finally
    gridGamesTable.DataController.EndFullUpdate;
  end;
end;

procedure TfrmManageClubs.acDeleteGameExecute(Sender: TObject);
begin
  SocketClient.DeleteGame(FSelectedGame.MongoId);
end;

procedure TfrmManageClubs.acDisbandClubExecute(Sender: TObject);
begin
  if MessageDlg('Are you sure you want to disband the club?', mtConfirmation, mbYesNo, 0) = mrYes then
    SocketClient.DisbandClub(FSelectedClub.Id);
end;

procedure TfrmManageClubs.acGiveChipsExecute(Sender: TObject);
begin
  if RunModalForm(TfrmGiveChips, self, [FSelectedClub, FSelectedPlayer]) = mrOk then
    SocketClient.Status;
end;

procedure TfrmManageClubs.acGiveOwnershipExecute(Sender: TObject);
begin
  if (not Assigned(FSelectedClub)) or (not Assigned(FSelectedPlayer)) then
    Exit;

  if MessageDlg(Format('Are you sure you want to give club ownership to %s?', [FSelectedPlayer.Nick]), mtConfirmation, mbYesNo, 0) = mrYes then
    SocketClient.GiveOwnership(FSelectedClub.Id, FSelectedPlayer.Id);
end;

procedure TfrmManageClubs.acKickPlayerExecute(Sender: TObject);
begin
  if (not Assigned(FSelectedClub)) or (not Assigned(FSelectedPlayer)) then
    Exit;

  if MessageDlg(Format('Are you sure you want to remove %s from the club?', [FSelectedPlayer.Nick]), mtConfirmation, mbYesNo, 0) = mrYes then
    SocketClient.KickPlayer(FSelectedClub.Id, FSelectedPlayer.Id);
end;

procedure TfrmManageClubs.acShowClubChangeDetailsFormExecute(Sender: TObject);
begin
  if RunModalForm(TfrmChangeClubDetails, self, [FSelectedClub]) = mrOk then
    SocketClient.Status;
end;

procedure TfrmManageClubs.acShowCreateGameFormExecute(Sender: TObject);
begin
  if RunModalForm(TfrmCreateGame, self, [FSelectedClub]) = mrOk then
    SocketClient.Status;
end;

procedure TfrmManageClubs.acShowEditGameFormExecute(Sender: TObject);
begin
  if RunModalForm(TfrmEditGame, self, [FSelectedGame]) = mrOk then
    SocketClient.Status;
end;

procedure TfrmManageClubs.TCStatusReply(const AMessage: TMessageItem);
var
  pbstatus: TPB_StatusReply;
begin
  pbstatus := AMessage.Object_ as TPB_StatusReply;

  dmMain.SelfInfo.ParseStatus(pbstatus);
  dmMain.Players.ParseStatus(pbstatus);
  UpdateClublist;
  UpdateClubPlayerlist;
  UpdateClubGamesList;
end;

procedure TfrmManageClubs.TCKickPlayerInvalidClubId(const AMessage: TMessageItem);
begin
  MessageDlg('Invalid club ID', mtError, [mbOk], 0);
end;

procedure TfrmManageClubs.TCKickPlayerInvalidPlayerId(const AMessage: TMessageItem);
begin
  MessageDlg('Invalid player ID', mtError, [mbOk], 0);
end;

procedure TfrmManageClubs.TCKickPlayerOk(const AMessage: TMessageItem);
begin
  SocketClient.Status;
end;

procedure TfrmManageClubs.TCOwnerGiveawayInvalidClubId(const AMessage: TMessageItem);
begin
  MessageDlg('Invalid club ID', mtError, [mbOk], 0);
end;

procedure TfrmManageClubs.TCOwnerGiveawayInvalidPlayerId(const AMessage: TMessageItem);
begin
  MessageDlg('Invalid player ID', mtError, [mbOk], 0);
end;

procedure TfrmManageClubs.TCOwnerGiveawayNotOwner(const AMessage: TMessageItem);
begin
  MessageDlg('You are not owner of this club', mtError, [mbOk], 0);
end;

procedure TfrmManageClubs.TCOwnerGiveawayOk(const AMessage: TMessageItem);
begin
  SocketClient.Status;
end;

procedure TfrmManageClubs.TCClubDisbandOk(const AMessage: TMessageItem);
begin
  SocketClient.Status;
end;

procedure TfrmManageClubs.TCDeleteGameOk(const AMessage: TMessageItem);
begin
  SocketClient.Status;
end;

end.

