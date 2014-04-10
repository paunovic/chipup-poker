unit Poker.Forms.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.ActnList, Vcl.StdCtrls, Vcl.Menus, Vcl.AppEvnts, dxSkinsCore, cxLookAndFeels, dxSkinsForm, cxGraphics, cxControls,
  cxLookAndFeelPainters, dxSkinscxPCPainter, cxCustomData, cxDataStorage, cxEdit, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxClasses, cxGridLevel, cxGrid, cxTextEdit, cxSpinEdit, cxContainer, cxLabel, cxButtons, OverbyteIcsWSocket, Poker.Objects.ClubInfo,
  cxMaskEdit, cxDropDownEdit, Poker.Forms.Login, Poker.Objects.GameInfo, cxBlobEdit, cxImage, dxsChipUpDark, Vcl.ActnMan, Vcl.ActnMenus,
  Vcl.PlatformDefaultStyleActnCtrls, dxsChipUpDarkTabs, dxsChipUpRedButton, cxStyles, cxFilter, cxData, Poker.Protobufs.Objects.Club,
  dxGDIPlusClasses;

type
  TfrmChipUpMain = class(TForm)
    ActionManager: TActionManager;
    acLogout: TAction;
    acShowChangeEMailForm: TAction;
    acShowChangePasswordForm: TAction;
    acShowChangeAvatarForm: TAction;
    acShowCreateClubForm: TAction;
    acShowJoinClubForm: TAction;
    acShowGameTableForm: TAction;
    acOpenClubLobby: TAction;
    MainMenu: TMainMenu;
    Account1: TMenuItem;
    ChangeEmailAddress1: TMenuItem;
    ChangePassword1: TMenuItem;
    ChangeAvatar1: TMenuItem;
    N1: TMenuItem;
    Logout1: TMenuItem;
    acShowTournamentLayout: TAction;
    acShowHomeGamesLayout: TAction;
    imgCashier: TcxImage;
    acOpenCashier: TAction;
    imgHeader: TcxImage;
    paMain: TPanel;
    gridTournaments: TcxGrid;
    gridTournamentsTable: TcxGridTableView;
    cxGridColumn2: TcxGridColumn;
    gridTournamentsTableColumn4: TcxGridColumn;
    gridTournamentsTableColumn3: TcxGridColumn;
    gridTournamentsTableColumn1: TcxGridColumn;
    gridTournamentsTableColumn2: TcxGridColumn;
    cxGridColumn3: TcxGridColumn;
    gridTournamentsLevel: TcxGridLevel;
    btOpenClubLobby: TcxButton;
    gridGames: TcxGrid;
    gridGamesTable: TcxGridTableView;
    gridGamesId: TcxGridColumn;
    gridGamesName: TcxGridColumn;
    gridGamesType: TcxGridColumn;
    gridGamesBlinds: TcxGridColumn;
    gridGamesPlayers: TcxGridColumn;
    gridGamesStatus: TcxGridColumn;
    gridGamesLevel: TcxGridLevel;
    gridJoinedClubs: TcxGrid;
    gridJoinedClubsTable: TcxGridTableView;
    gridJoinedClubsId: TcxGridColumn;
    gridJoinedClubsClubName: TcxGridColumn;
    gridJoinedClubsStatus: TcxGridColumn;
    gridJoinedClubsLevel: TcxGridLevel;
    btTournaments: TcxButton;
    btHomeGames: TcxButton;
    btPrijatnaPunina: TcxButton;
    btOpenTournamentLobby: TcxButton;
    btCreateClub: TcxButton;
    btJoinClub: TcxButton;
    gridGamesBuyinLimits: TcxGridColumn;
    Resendverificationmail1: TMenuItem;
    N2: TMenuItem;
    acResendVerificationMail: TAction;
    gridClubs: TcxGrid;
    gridClubsTable: TcxGridTableView;
    gridClubsId: TcxGridColumn;
    gridClubsName: TcxGridColumn;
    gridClubsPlayers: TcxGridColumn;
    gridClubsLevel: TcxGridLevel;
    btJoinPublicClub: TcxButton;
    acJoinSelectedPublicClub: TAction;
    tiPublicClubRefresh: TTimer;
    btPublicClubs: TcxButton;
    procedure acLogoutExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acShowCreateClubFormExecute(Sender: TObject);
    procedure acShowJoinClubFormExecute(Sender: TObject);
    procedure gridJoinedClubsTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
    procedure acShowChangeEMailFormExecute(Sender: TObject);
    procedure acShowChangePasswordFormExecute(Sender: TObject);
    procedure acShowChangeAvatarFormExecute(Sender: TObject);
    procedure gridJoinedClubsTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure gridGamesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
    procedure gridGamesTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure acShowGameTableFormExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure acOpenClubLobbyExecute(Sender: TObject);
    procedure acShowHomeGamesLayoutExecute(Sender: TObject);
    procedure acShowTournamentLayoutExecute(Sender: TObject);
    procedure imgCashierMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure acOpenCashierExecute(Sender: TObject);
    procedure imgCashierMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure acResendVerificationMailExecute(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure acJoinSelectedPublicClubExecute(Sender: TObject);
    procedure gridClubsTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
  private
    FSelectedClub: Integer;
    FSelectedGame: TBytes;
    FCallbacksId: Integer;
    FSelectedPublicClubId: Integer;

    procedure ShowLoginForm;

    procedure DoLogout;
    procedure UpdateClublist;
    procedure UpdatePublicClublist;
    procedure UpdateGamelist;

    procedure CSRLeaveClub(const AMethodId: Integer; const AObject: TObject);
    procedure CSRClubCommand(const AMethodId: Integer; const AObject: TObject);
    procedure CSRStatus(const AMethodId: Integer; const AObject: TObject);
    procedure CSRGetUsers(const AMethodId: Integer; const AObject: TObject);
    procedure CSRETransferChipsOk(const AMethodId: Integer; const AObject: TObject);

    procedure CSRLogout(const AMethodId: Integer; const AObject: TObject);
    procedure CSESecondaryLoginDetected(const AMethodId: Integer; const AObject: TObject);
    procedure CSEChatEvent(const AMethodId: Integer; const AObject: TObject);
    procedure CSEAccountConfirmed(const AMethodId: Integer; const AObject: TObject);
    procedure CSEClubDeleted(const AMethodId: Integer; const AObject: TObject);
    procedure CSREClubOperation(const AMethodId: Integer; const AObject: TObject);
    procedure CSREGameOperation(const AMethodId: Integer; const AObject: TObject);
    procedure CSREGameDelete(const AMethodId: Integer; const AObject: TObject);
    procedure CSRTableStatus(const AMethodId: Integer; const AObject: TObject);
    procedure CSEUserChange(const AMethodId: Integer; const AObject: TObject);
    procedure CSRListClubs(const AMethodId: Integer; const AObject: TObject);
    procedure CSRTableStats(const AMethodId: Integer; const AObject: TObject);

    function ConfirmToCloseTables: Boolean;
    function ProcessClubObject(const AClub: TPB_Club): TClubInfo;

    procedure SocketStateChange(const AOldState, ANewState: TSocketState);

    procedure ConfigureGUI;

    function GetSelectedGame(var AGame: TGameInfo): Boolean;
    function GetSelectedClub(var AClub: TClubInfo): Boolean;
  protected
    procedure DoCreate; override;

  public
    procedure LoginStatus(const AValue: TLoginStatus);
  end;


var
  frmChipUpMain: TfrmChipUpMain;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  System.Generics.Collections, Poker.Protobufs.Objects.GameQuery, SynDBSQLite3,
  Poker.Server.Socket, Poker.Protobufs.Enum.ServerCodes, Poker.Common.Misc, Poker.DataModule, Poker.Forms.CreateClub, Poker.Forms.JoinClub,
  Poker.Server.MessageContainer, Poker.Objects.PlayerInfo, Poker.Forms.ChangeEMail, Poker.Forms.ChangePassword, Poker.Forms.ChangeAvatar,
  Poker.Protobufs.Objects.ClubCommandReply, Poker.Protobufs.Objects.User, Poker.Protobufs.Objects.StatusReply,
  Poker.Server.MessageCallbacks, Poker.Protobufs.Objects.Game, Poker.Protobufs.Objects.TableStatus, Poker.Protobufs.Objects.ListClubsReply,
  Poker.Table.Tables, Poker.Protobufs.Objects.GetUserParams, Poker.Common.FormsContainer, Poker.Protobufs.Objects.TransferChipsParams,
  Poker.Forms.Updater, Poker.Forms.ClubLobby, Poker.Protobufs.Objects.UserChangeParams, Poker.Database.Core, Poker.Settings,
  Poker.Protobufs.Objects.TableStatsReplies, Poker.Stats.Table, Poker.Protobufs.Objects.TableStatsReply;


procedure TfrmChipUpMain.DoCreate;
begin
  inherited;

  ShowLoginForm;
end;

procedure TfrmChipUpMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmChipUpMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ConfirmToCloseTables;
  if CanClose then
    Tables.ClearWithoutNotification;
end;

procedure TfrmChipUpMain.FormCreate(Sender: TObject);
begin
  LoadImageFromResource(imgCashier, 'CashierNormal');

  btHomeGames.Font.Name := 'Sintony Bold';
  btHomeGames.Font.Style := [];
  btHomeGames.Font.Size := 8;

  btJoinClub.Font.Assign(btHomeGames.Font);
  btTournaments.Font.Assign(btHomeGames.Font);
  btOpenClubLobby.Font.Assign(btHomeGames.Font);
  btOpenTournamentLobby.Font.Assign(btHomeGames.Font);
  btCreateClub.Font.Assign(btHomeGames.Font);
  btJoinClub.Font.Assign(btHomeGames.Font);

  EnableWindow(Handle, TRUE);
end;

procedure TfrmChipUpMain.FormDeactivate(Sender: TObject);
begin
  LoadImageFromResource(imgCashier, 'CashierNormal');
end;

procedure TfrmChipUpMain.FormDestroy(Sender: TObject);
begin
  FormsContainer.CloseAllForms;
  MessageContainer.RemoveCallbacks(FCallbacksId);
end;

procedure TfrmChipUpMain.DoLogout;
begin
  FormsContainer.CloseAllForms;
  gridJoinedClubsTable.DataController.SetRecordCount(0);
  gridGamesTable.DataController.SetRecordCount(0);
  dmMain.SelfInfo.Flush;
  Players.Clear;
  Tables.ClearWithoutNotification;
  tiPublicClubRefresh.Enabled := FALSE;
end;

procedure TfrmChipUpMain.ShowLoginForm;
begin
  Application.ShowMainForm := FALSE;
  DoLogout;
  Hide;
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.RunForm(TfrmLogin, self, [], FALSE);
end;

procedure TfrmChipUpMain.SocketStateChange(const AOldState, ANewState: TSocketState);
begin
  case ANewState of
    wsClosed: begin
      ServerSocket.Disconnect;
      ShowLoginForm;
    end;
  end;
end;

function TfrmChipUpMain.GetSelectedClub(var AClub: TClubInfo): Boolean;
begin
  result := dmMain.SelfInfo.Clubs.FindClub(FSelectedClub, AClub);
end;

function TfrmChipUpMain.GetSelectedGame(var AGame: TGameInfo): Boolean;
var
  club: TClubInfo;
begin
  result := (GetSelectedClub(club)) and (club.Games.FindGame(FSelectedGame, AGame));
end;

procedure TfrmChipUpMain.acJoinSelectedPublicClubExecute(Sender: TObject);
var
  club: TClubInfo;
begin
  if not dmMain.CheckAuthed then
    Exit;

  if dmMain.PublicClubs.FindClub(FSelectedPublicClubId, club) then
  begin
    if club.IsPrivate then
      FormsContainer.RunForm(TfrmJoinClub, self, [@FSelectedPublicClubId], FALSE)
    else
      ServerSocket.JoinClub(FSelectedPublicClubId, '');
  end;
end;

procedure TfrmChipUpMain.acLogoutExecute(Sender: TObject);
begin
  if not ConfirmToCloseTables then
    Exit;

  ServerSocket.Logout;
end;

procedure TfrmChipUpMain.acOpenCashierExecute(Sender: TObject);
begin
  dmMain.OpenCashierLink;
end;

procedure TfrmChipUpMain.acOpenClubLobbyExecute(Sender: TObject);
var
  club : TClubInfo;
  form : TForm;
  found: Boolean;
begin
  if not dmMain.CheckAuthed then
    Exit;

  if not dmMain.SelfInfo.Clubs.FindClub(FSelectedClub, club) then
    Exit;

  found := FALSE;
  for form in FormsContainer.Items do
    if (form is TfrmClubLobby) and
       ((form as TfrmClubLobby).ClubId = FSelectedClub) then
    begin
      form.SetFocus;
      found := TRUE;
      Break;
    end;

  if not found then
    FormsContainer.RunForm(TfrmClubLobby, self, [@FSelectedClub], TRUE);
end;

procedure TfrmChipUpMain.acResendVerificationMailExecute(Sender: TObject);
begin
  ServerSocket.ResendVerificationMail;
  MessageDlg(Format('Verification mail sent to %s. Please check your inbox.', [dmMain.SelfInfo.EMail]), mtInformation, [mbOK], 0);
end;

procedure TfrmChipUpMain.acShowChangeAvatarFormExecute(Sender: TObject);
begin
  FormsContainer.RunForm(TfrmChangeAvatar, self, [], FALSE);
end;

procedure TfrmChipUpMain.acShowChangeEMailFormExecute(Sender: TObject);
begin
  FormsContainer.RunForm(TfrmChangeEMail, self, [], FALSE);
end;

procedure TfrmChipUpMain.acShowChangePasswordFormExecute(Sender: TObject);
begin
  FormsContainer.RunForm(TfrmChangePassword, self, [], FALSE);
end;

procedure TfrmChipUpMain.acShowCreateClubFormExecute(Sender: TObject);
begin
  if not dmMain.CheckAuthed then
    Exit;

  FormsContainer.RunForm(TfrmCreateClub, self, [], FALSE);
end;

procedure TfrmChipUpMain.acShowGameTableFormExecute(Sender: TObject);
var
  game: TGameInfo;
  club: TClubInfo;
begin
  if not dmMain.CheckAuthed then
    Exit;

  if (not GetSelectedClub(club)) or (not GetSelectedGame(game)) then
    Exit;

  if club.IsSuspendedPlayer(dmMain.SelfInfo.Id) then
    MessageDlg('You are currently suspended in this club, and cannot join any tables. Please contact club owner to resolve this issue.', mtWarning, [mbOK], 0)
  else
    Tables.AddTable(club, game);
end;

procedure TfrmChipUpMain.acShowJoinClubFormExecute(Sender: TObject);
begin
  if not dmMain.CheckAuthed then
    Exit;

  FormsContainer.RunForm(TfrmJoinClub, self, [], FALSE);
end;

procedure TfrmChipUpMain.ConfigureGUI;
var
  cpt: String;
begin
  cpt := Format('ChipUP Poker - %s', [dmMain.SelfInfo.Nick]);
  if not dmMain.SelfInfo.Authed then
    cpt := cpt + ' (account verification pending)';
  if cpt <> Caption then
    Caption := cpt;

  Resendverificationmail1.Visible := not dmMain.SelfInfo.Authed;

  acOpenClubLobby.Enabled := FSelectedClub <> -1;
  UpdateClublist;
  UpdateGamelist;
  UpdatePublicClublist;
end;

function TfrmChipUpMain.ConfirmToCloseTables: Boolean;
begin
  result := TRUE;
  if Tables.SittingCount > 0 then
    result := MessageDlg('If you close the application, you will automatically leave the tables you are currently playing on. Proceed?', mtWarning, mbYesNo, 0) = mrYes;
end;

procedure TfrmChipUpMain.UpdateClublist;
var
  C1    : Integer;
  club  : TClubInfo;
  status: String;
begin
  gridJoinedClubsTable.DataController.BeginFullUpdate;
  try
    gridJoinedClubsTable.DataController.SetRecordCount(dmMain.SelfInfo.Clubs.Count);
    for C1 := 0 to dmMain.SelfInfo.Clubs.Count - 1 do
    begin
      club := dmMain.SelfInfo.Clubs[C1];

      gridJoinedClubsTable.DataController.SetValue(C1, gridJoinedClubsId.Index, club.Id);
      gridJoinedClubsTable.DataController.SetValue(C1, gridJoinedClubsClubName.Index, club.Name);

      if CompareBytes(dmMain.SelfInfo.Id, club.OwnerId) then
        status := 'Owner'
      else
        status := 'Player';
      gridJoinedClubsTable.DataController.SetValue(C1, gridJoinedClubsStatus.Index, status);
    end;
  finally
    gridJoinedClubsTable.DataController.EndFullUpdate;
  end;
  gridJoinedClubsTable.DataController.Refresh;
end;

procedure TfrmChipUpMain.UpdateGamelist;
var
  C1    : Integer;
  game  : TGameInfo;
  c     : TcxGridDataController;
  club  : TClubInfo;
  recidx: Integer;
begin
  c := gridGamesTable.DataController;
  c.BeginFullUpdate;
  try
    c.SetRecordCount(0);
    if not GetSelectedClub(club) then
      Exit;

    for C1 := 0 to club.Games.Count - 1 do
    begin
      game := club.Games[C1];

      if game.State = gsClosed then
        Continue;

      recidx := c.AppendRecord;

      c.SetValue(recidx, gridGamesId.Index, game.MongoId);
      c.SetValue(recidx, gridGamesName.Index, game.Name);
      c.SetValue(recidx, gridGamesType.Index, game.GameTypeStrFull);
      c.SetValue(recidx, gridGamesBlinds.Index, Format('%d/%d', [Trunc(game.SmallBlind / 100), Trunc(game.BigBlind / 100)]));
      c.SetValue(recidx, gridGamesBuyinLimits.Index, Format('%d-%d', [game.MinBuyin, game.MaxBuyin]));
      c.SetValue(recidx, gridGamesPlayers.Index, Format('%d/%d', [game.Sitting, game.Seats]));
      c.SetValue(recidx, gridGamesStatus.Index, game.StateAsStr);
    end;
  finally
    c.EndFullUpdate;
  end;
  c.Refresh;
end;

procedure TfrmChipUpMain.UpdatePublicClublist;
var
  rcount: Integer;
  club  : TClubInfo;
  c     : TcxGridDataController;
begin
  c := gridClubsTable.DataController;

  c.BeginFullUpdate;
  try
    rcount := 0;
    c.SetRecordCount(0);

    for club in dmMain.PublicClubs do
    begin
      Inc(rcount);
      c.SetRecordCount(rcount);
      c.SetValue(rcount - 1, gridClubsId.Index, club.Id);
      c.SetValue(rcount - 1, gridClubsName.Index, club.Name);
      c.SetValue(rcount - 1, gridClubsPlayers.Index, Length(club.Players));
    end;
  finally
    c.EndFullUpdate;
  end;
  c.Refresh;
end;

procedure TfrmChipUpMain.gridJoinedClubsTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  acOpenClubLobby.Execute;
end;

procedure TfrmChipUpMain.gridClubsTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex: Integer;
begin
  recIndex := gridClubsTable.DataController.GetFocusedRecordIndex;
  if recIndex = -1 then
    FSelectedPublicClubId := -1
  else
    FSelectedPublicClubId := gridClubsTable.DataController.GetValue(recIndex, gridClubsId.Index);

  acJoinSelectedPublicClub.Enabled := FSelectedPublicClubId <> -1;
end;

procedure TfrmChipUpMain.gridGamesTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  acShowGameTableForm.Execute;
end;

procedure TfrmChipUpMain.gridJoinedClubsTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex: Integer;
  club_id : Int64;
begin
  recIndex := gridJoinedClubsTable.DataController.GetFocusedRecordIndex;
  if recIndex = -1 then
  begin
    FSelectedClub := -1;
    Exit;
  end;

  club_id := gridJoinedClubsTable.DataController.GetValue(recIndex, gridJoinedClubsId.Index);
  if dmMain.SelfInfo.Clubs.IndexOf(club_id) = -1 then
    FSelectedClub := -1
  else
  begin
    FSelectedClub := club_id;
    SetLength(FSelectedGame, 0);
    gridGamesTable.DataController.FocusedRecordIndex := -1;
  end;

  acOpenClubLobby.Enabled := FSelectedClub <> -1;
  UpdateGamelist;
end;

procedure TfrmChipUpMain.gridGamesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex: Integer;
  game_id : TBytes;
  club    : TClubInfo;
begin
  recIndex := gridGamesTable.DataController.GetFocusedRecordIndex;
  if (recIndex = -1) or
     (not GetSelectedClub(club)) then
  begin
    SetLength(FSelectedGame, 0);
    Exit;
  end;

  game_id := gridGamesTable.DataController.GetValue(recIndex, gridGamesId.Index);
  if club.Games.IndexOf(game_id) = -1 then
  begin
    SetLength(FSelectedGame, 0);
    Exit;
  end
  else
    FSelectedGame := game_id;
end;

procedure TfrmChipUpMain.imgCashierMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    if IsPointInsideCircle(X, Y, imgCashier.Width div 2, imgCashier.Height div 2, 42) then
      LoadImageFromResource(imgCashier, 'CashierPressed');
  end;
end;

procedure TfrmChipUpMain.imgCashierMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    if IsPointInsideCircle(X, Y, imgCashier.Width div 2, imgCashier.Height div 2, 42) then
      dmMain.OpenCashierLink;
    LoadImageFromResource(imgCashier, 'CashierNormal');
  end;
end;

procedure TfrmChipUpMain.LoginStatus(const AValue: TLoginStatus);
begin
  case AValue of
    lsLoggedIn: begin
      FCallbacksId := MessageContainer.AddCallbacks([
                          TSocketStateChangeCallback.Create(SocketStateChange),
                          TServerMessageCallback.Create(srStatus, CSRStatus),
                          TServerMessageCallback.Create(srLeaveClubReply, CSRLeaveClub),
                          TServerMessageCallback.Create(srChangeClubDetailsReply, CSRClubCommand),
                          TServerMessageCallback.Create(srCreateClubReply, CSRClubCommand),
                          TServerMessageCallback.Create(srJoinClubReply, CSRClubCommand),
                          TServerMessageCallback.Create(srKickPlayerReply, CSRClubCommand),
                          TServerMessageCallback.Create(srGetPlayers, CSRGetUsers),
                          TServerMessageCallback.Create(srLogout, CSRLogout),
                          TServerMessageCallback.Create(srEditGameOk, CSREGameOperation),
                          TServerMessageCallback.Create(srCreateGameOk, CSREGameOperation),
                          TServerMessageCallback.Create(srClubDisbandOk, CSREClubOperation),
                          TServerMessageCallback.Create(seSecondaryLoginDetected, CSESecondaryLoginDetected),
                          TServerMessageCallback.Create(seChat, CSEChatEvent),
                          TServerMessageCallback.Create(seAccountConfirmed, CSEAccountConfirmed),
                          TServerMessageCallback.Create(seClubChange, CSREClubOperation),
                          TServerMessageCallback.Create(srSuspendPlayerOk, CSREClubOperation),
                          TServerMessageCallback.Create(srReinstatePlayerOk, CSREClubOperation),
                          TServerMessageCallback.Create(srOwnershipGiveAwayOk, CSREClubOperation),
                          TServerMessageCallback.Create(srTransferChipsOk, CSRETransferChipsOk),
                          TServerMessageCallback.Create(seTransferChips, CSRETransferChipsOk),
                          TServerMessageCallback.Create(seClubDeleted, CSEClubDeleted),
                          TServerMessageCallback.Create(seGameChange, CSREGameOperation),
                          TServerMessageCallback.Create(seGameCreate, CSREGameOperation),
                          TServerMessageCallback.Create(seGameDelete, CSREGameDelete),
                          TServerMessageCallback.Create(seTableStatus, CSRTableStatus),
                          TServerMessageCallback.Create(srTableStandUpOk, CSRTableStatus),
                          TServerMessageCallback.Create(srTableSitOk, CSRTableStatus),
                          TServerMessageCallback.Create(seUserChange, CSEUserChange),
                          TServerMessageCallback.Create(srListClubs, CSRListClubs),
                          TServerMessageCallback.Create(srTableStatsReply, CSRTableStats)
                      ]);

      FSelectedClub := -1;
      FSelectedPublicClubId := -1;
      SetLength(FSelectedGame, 0);
      tiPublicClubRefresh.Enabled := TRUE;
      ServerSocket.QueryTableStats([]); // empty array - query all table stats
      ConfigureGUI;
      Show;
    end;

    lsUpdating: FormsContainer.RunForm(TfrmUpdater, self, [], FALSE);
  else
    Close;
  end;
end;

procedure TfrmChipUpMain.CSRLeaveClub(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_ClubCommandReply;
begin
  pbreply := AObject as TPB_ClubCommandReply;

  case pbreply.Status of
    csSuccess: begin
      ProcessClubObject(pbreply.Club);
      ConfigureGUI;
    end;
  end;
end;

procedure TfrmChipUpMain.CSRListClubs(const AMethodId: Integer; const AObject: TObject);
begin

end;

function TfrmChipUpMain.ProcessClubObject(const AClub: TPB_Club): TClubInfo;
var
  C1         : Integer;
  club       : TClubInfo;
  player     : TPlayerInfo;
  query_users: TArray<TBytes>;
  empty_array: TBytes;
begin
  club := dmMain.SelfInfo.Clubs.AddClub(AClub);

  SetLength(query_users, 0);
  if not Players.FindPlayerById(AClub.Owner, player) then
  begin
    SetLength(query_users, 1);
    query_users[0] := AClub.Owner;
  end;
  for C1 := 0 to Length(AClub.Members) - 1 do
    if not Players.FindPlayerById(AClub.Members[C1], player) then
    begin
      SetLength(query_users, Length(query_users) + 1);
      query_users[Length(query_users) - 1] := AClub.Members[C1];
    end;
  if Length(query_users) > 0 then
  begin
    SetLength(empty_array, 0);
    for C1 := 0 to Length(query_users) - 1 do
      Players.AddPlayer(query_users[C1], 'Unknown', '', 0, empty_array);

    ServerSocket.GetUserInfos(query_users);
  end;

  if not club.IsPlayerInTheClub(dmMain.SelfInfo.Id) then
  begin
    if not club.IsPrivate then
    begin
      dmMain.PublicClubs.Add(club);
      dmMain.SelfInfo.Clubs.Extract(club);
    end
    else
    begin
      dmMain.SelfInfo.Clubs.Remove(club);
      club := nil;
    end;
  end
  else
  begin
    C1 := dmMain.PublicClubs.IndexOf(club.Id);
    if C1 <> -1 then
      dmMain.PublicClubs.Delete(C1);
  end;

  result := club;
end;

procedure TfrmChipUpMain.CSRClubCommand(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_ClubCommandReply;
  club   : TClubInfo;
begin
  pbreply := AObject as TPB_ClubCommandReply;

  case pbreply.Status of
    csSuccess: begin
      club := ProcessClubObject(pbreply.Club);
      if Assigned(club) then
        club.Games.UpdateFromProtobufObjects(pbreply.Games);
       ConfigureGUI;
    end;
  end;
end;

procedure TfrmChipUpMain.CSREClubOperation(const AMethodId: Integer; const AObject: TObject);
var
  pbclub: TPB_Club;
begin
  pbclub := AObject as TPB_Club;

  ProcessClubObject(pbclub);

  ConfigureGUI;
end;

procedure TfrmChipUpMain.CSRGetUsers(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_GetUserParams;
  user   : TPB_User;
begin
  pbreply := AObject as TPB_GetUserParams;

  for user in pbreply.Users do
    Players.AddPlayer(user);
end;

procedure TfrmChipUpMain.CSRETransferChipsOk(const AMethodId: Integer; const AObject: TObject);
var
  pbreply    : TPB_TransferChipsParams;
  player_info: TPlayerInfo;
begin
  pbreply := AObject as TPB_TransferChipsParams;

  if AMethodId = Integer(seTransferChips) then
  begin
    dmMain.SelfInfo.Balance := dmMain.SelfInfo.Balance + pbreply.ChipAmount;

    if Players.FindPlayerById(dmMain.SelfInfo.Id, player_info) then
      player_info.Balance := player_info.Balance + pbreply.ChipAmount;

    if Players.FindPlayerById(pbreply.PlayerMongoId, player_info) then
      player_info.Balance := player_info.Balance - pbreply.ChipAmount;
  end
  else
  begin
    dmMain.SelfInfo.Balance := dmMain.SelfInfo.Balance - pbreply.ChipAmount;

    if Players.FindPlayerById(dmMain.SelfInfo.Id, player_info) then
      player_info.Balance := player_info.Balance - pbreply.ChipAmount;

    if Players.FindPlayerById(pbreply.PlayerMongoId, player_info) then
      player_info.Balance := player_info.Balance + pbreply.ChipAmount;
  end;
end;

procedure TfrmChipUpMain.acShowHomeGamesLayoutExecute(Sender: TObject);
begin
  btCreateClub.Show;
  btJoinClub.Show;
  btOpenTournamentLobby.Hide;
  btJoinPublicClub.Show;
  gridClubs.Show;
  btPublicClubs.Show;
  gridTournaments.Hide;
  gridJoinedClubs.Show;
  gridGames.Show;
  btOpenClubLobby.Show;
end;

procedure TfrmChipUpMain.acShowTournamentLayoutExecute(Sender: TObject);
begin
  btCreateClub.Hide;
  btJoinClub.Hide;
  btOpenTournamentLobby.Show;
  btJoinPublicClub.Hide;
  btPublicClubs.Hide;
  gridClubs.Hide;
  gridTournaments.Show;
  gridJoinedClubs.Hide;
  gridGames.Hide;
  btOpenClubLobby.Hide;
end;

procedure TfrmChipUpMain.CSESecondaryLoginDetected(const AMethodId: Integer; const AObject: TObject);
begin
  ShowLoginForm;
end;

procedure TfrmChipUpMain.CSEUserChange(const AMethodId: Integer; const AObject: TObject);
var
  pbusers: TPB_UserChangeParams;
  pbuser : TPB_user;
begin
  pbusers := AObject as TPB_UserChangeParams;

  for pbuser in pbusers.Users do
    Players.AddPlayer(pbuser);
end;

procedure TfrmChipUpMain.CSRStatus(const AMethodId: Integer; const AObject: TObject);
var
  pbstatus: TPB_StatusReply;
begin
  pbstatus := AObject as TPB_StatusReply;
  dmMain.ProcessStatusProtobuf(pbstatus);
  ConfigureGUI;
end;

procedure TfrmChipUpMain.CSRLogout(const AMethodId: Integer; const AObject: TObject);
begin
  ShowLoginForm;
end;

procedure TfrmChipUpMain.CSEAccountConfirmed(const AMethodId: Integer; const AObject: TObject);
var
  pbuser: TPB_User;
begin
  pbuser := AObject as TPB_User;

  dmMain.SelfInfo.Id := pbuser.MongoId;
  dmMain.SelfInfo.Balance := pbuser.Chips;
  dmMain.SelfInfo.EMail := pbuser.Email;
  dmMain.SelfInfo.Nick := pbuser.Displayname;
  dmMain.SelfInfo.AvatarId := pbuser.Avatar;
  dmMain.SelfInfo.Authed := pbuser.Authed;

  ConfigureGUI;
end;

procedure TfrmChipUpMain.CSEChatEvent(const AMethodId: Integer; const AObject: TObject);
//var
//  chatEvent: TPB_ChatEvent;
begin
//  chatEvent := AObject as TPB_ChatEvent;
end;

procedure TfrmChipUpMain.CSEClubDeleted(const AMethodId: Integer; const AObject: TObject);
var
  pbclub: TPB_Club;
  index : Integer;
begin
  pbclub := AObject as TPB_Club;

  index := dmMain.SelfInfo.Clubs.IndexOf(pbclub.Seq);
  if index = -1 then
    Exit;

  dmMain.SelfInfo.Clubs.Delete(index);

  ConfigureGUI;
end;

procedure TfrmChipUpMain.CSREGameDelete(const AMethodId: Integer; const AObject: TObject);
var
  pbgame: TPB_Game;
  club  : TClubInfo;
  game  : TGameInfo;
  C1    : Integer;
begin
  pbgame := AObject as TPB_Game;

  if (dmMain.SelfInfo.Clubs.FindClub(pbgame.Clubseq, club)) and
     (club.Games.FindGame(pbgame.MongoId, game)) then
  begin
    for C1 := 0 to Tables.Count - 1 do
      if Tables[C1].Game = game then
      begin
        Tables.Delete(C1);
        Break;
      end;

    club.Games.AddGame(pbgame);
  end;

  ConfigureGUI;
end;

procedure TfrmChipUpMain.CSREGameOperation(const AMethodId: Integer; const AObject: TObject);
var
  pbgame: TPB_Game;
  club  : TClubInfo;
  game  : TGameInfo;
begin
  pbgame := AObject as TPB_Game;

  if dmMain.SelfInfo.Clubs.FindClub(pbgame.Clubseq, club) then
  begin
    game := club.Games.AddGame(pbgame);

    if (Assigned(game)) and
       (AMethodId = Integer(srCreateGameOk)) then
      Tables.AddTable(club, game);
  end;

  ConfigureGUI;
end;

procedure TfrmChipUpMain.CSRTableStatus(const AMethodId: Integer; const AObject: TObject);
var
  pbtstatus: TPB_TableStatus;
  table    : TTable;
begin
  pbtstatus := AObject as TPB_TableStatus;

  if not Tables.FindTable(pbtstatus.TableMongoId, table) then
    Exit;

  table.Game.UpdateFromTableStatus(pbtstatus);

  ConfigureGUI;
end;

procedure TfrmChipUpMain.CSRTableStats(const AMethodId: Integer; const AObject: TObject);
var
  pb: TPB_TableStatsReplies;
  tablepb: TPB_TableStatsReply;
  tablestats: TTableStats;
  player: TPB_User;
  playerinfo: TPlayerInfo;
begin
  pb := AObject as TPB_TableStatsReplies;

  for player in pb.Players do
    if Players.FindPlayerById(player.MongoId, playerinfo) then
      playerinfo.Nick := player.Displayname
    else
      Players.AddPlayer(player);

  for tablepb in pb.Reply do
    if TablesStats.Find(tablepb.Gameid, tablestats) then
      tablestats.Assign(tablepb)
    else
    begin
      tablestats := TTableStats.Create;
      tablestats.Assign(tablepb);
      TablesStats.Add(tablestats);
    end;
end;


end.
