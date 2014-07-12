unit Poker.Forms.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.ActnList, Vcl.Menus, cxCustomData, cxEdit, cxGridCustomTableView, cxGridTableView, cxGridLevel, cxGrid, cxLabel,
  cxButtons, OverbyteIcsWSocket, Poker.Clubs.Club, Poker.Forms.Login, Poker.Games.Game, cxImage, Vcl.ActnMan,
  Poker.Protobufs.Objects.Club, ChipUpPokerDarkSkin, cxPC, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer,
  dxSkinsCore, dxSkinscxPCPainter, cxPCdxBarPopupMenu, cxStyles, cxFilter, cxData, cxDataStorage, cxSpinEdit, cxTextEdit, cxBlobEdit,
  Vcl.PlatformDefaultStyleActnCtrls, Vcl.StdCtrls, cxClasses, cxGridCustomView, dxGDIPlusClasses, Vcl.ToolWin, Vcl.ActnCtrls, Vcl.ActnMenus,
  Vcl.ActnColorMaps, Vcl.StdStyleActnCtrls, Vcl.AppEvnts;

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
    acShowTournamentLayout: TAction;
    acShowHomeGamesLayout: TAction;
    imgCashier: TcxImage;
    acOpenCashier: TAction;
    imgHeader: TcxImage;
    paMain: TPanel;
    btTournaments: TcxButton;
    btHomeGames: TcxButton;
    acResendVerificationMail: TAction;
    btFiller1: TcxButton;
    pcTabs: TcxPageControl;
    tsHomeGames: TcxTabSheet;
    tsTournaments: TcxTabSheet;
    gridPublicClubs: TcxGrid;
    gridPublicClubsTable: TcxGridTableView;
    gridClubsId: TcxGridColumn;
    gridClubsName: TcxGridColumn;
    gridPublicClubsLevel: TcxGridLevel;
    btPrivateClubs: TcxButton;
    btPublicClubs: TcxButton;
    gridGames: TcxGrid;
    gridGamesTable: TcxGridTableView;
    gridGamesId: TcxGridColumn;
    gridGamesName: TcxGridColumn;
    gridGamesType: TcxGridColumn;
    gridGamesBlinds: TcxGridColumn;
    gridGamesBuyinLimits: TcxGridColumn;
    gridGamesPlayers: TcxGridColumn;
    gridGamesStatus: TcxGridColumn;
    gridGamesLevel: TcxGridLevel;
    btOpenClubLobby: TcxButton;
    btOpenTable: TcxButton;
    btCreateClub: TcxButton;
    btJoinClub: TcxButton;
    btTournamentsHeader: TcxButton;
    lbsTournamentsComingSoon: TcxLabel;
    acShowContactUsForm: TAction;
    acTermsAndConditions: TAction;
    acShowAboutForm: TAction;
    acSoundsOnOff: TAction;
    gridPrivateClubs: TcxGrid;
    gridPrivateClubsTable: TcxGridTableView;
    gridJoinedClubsId: TcxGridColumn;
    gridJoinedClubsClubName: TcxGridColumn;
    gridJoinedClubsStatus: TcxGridColumn;
    gridPrivateClubsLevel: TcxGridLevel;
    acFoldChecks: TAction;
    acHandHistory: TAction;
    acAnimationsEnabled: TAction;
    acSettings: TAction;
    ActionMainMenuBar: TActionMainMenuBar;
    acDisconnect: TAction;
    ApplicationEvents: TApplicationEvents;
    tiRefreshForm: TTimer;
    procedure acLogoutExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acShowCreateClubFormExecute(Sender: TObject);
    procedure acShowJoinClubFormExecute(Sender: TObject);
    procedure gridPrivateClubsTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
    procedure acShowChangeEMailFormExecute(Sender: TObject);
    procedure acShowChangePasswordFormExecute(Sender: TObject);
    procedure acShowChangeAvatarFormExecute(Sender: TObject);
    procedure gridPrivateClubsTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
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
    procedure gridPublicClubsTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
    procedure FormResize(Sender: TObject);
    procedure gridPublicClubsEnter(Sender: TObject);
    procedure gridPrivateClubsEnter(Sender: TObject);
    procedure gridPublicClubsTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure pcTabsChange(Sender: TObject);
    procedure acShowContactUsFormExecute(Sender: TObject);
    procedure acTermsAndConditionsExecute(Sender: TObject);
    procedure acSoundsOnOffExecute(Sender: TObject);
    procedure acShowAboutFormExecute(Sender: TObject);
    procedure acFoldChecksExecute(Sender: TObject);
    procedure acHandHistoryExecute(Sender: TObject);
    procedure acAnimationsEnabledExecute(Sender: TObject);
    procedure acSettingsExecute(Sender: TObject);
    procedure acDisconnectExecute(Sender: TObject);
    procedure ActionMainMenuBarGetControlClass(Sender: TCustomActionBar; AnItem: TActionClient; var ControlClass: TCustomActionControlClass);
    procedure ApplicationEventsDeactivate(Sender: TObject);
    procedure tiRefreshFormTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FSelectedClub: Integer;
    FSelectedGame: TBytes;
    FCallbacksId: Integer;
    FShuttingDown: Boolean;
    FActionMainMenuBarFont: TFont;

    procedure ModalFormClose(ASender: TObject);

    procedure DoLogout;
    procedure UpdateClublist;
    procedure UpdatePublicClublist;
    procedure UpdateGamelist;

    procedure ShowTournamentLayout(const AShow: Boolean);

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
    procedure CSRTableStats(const AMethodId: Integer; const AObject: TObject);
    procedure CSRHandHistoryMsg(const AMethodId: Integer; const AObject: TObject);

    procedure AvatarChanged(Sender: TObject);

    function ConfirmToCloseTablesAppClose: Boolean;
    function ConfirmToCloseTablesLogout: Boolean;
    function ProcessClubObject(const AClub: TPB_Club; const AMethodId: Integer): TClubInfo;

    procedure SocketStateChange(const AOldState, ANewState: TSocketState);
    procedure ConfigureGUI;

    function GetSelectedGame(var AGame: TGameInfo): Boolean;
    function GetSelectedClub(var AClub: TClubInfo): Boolean;
  protected
    procedure DoCreate; override;
    procedure WMQueryEndSession(var AMessage: TWMQueryEndSession); message WM_QUERYENDSESSION;
    procedure WMEndSession(var AMessage: TWMEndSession); message WM_ENDSESSION;
    procedure WMSettingChange(var AMessage: TWMSettingChange); message WM_SETTINGCHANGE;
  public
    procedure LoginStatus(const AValue: TLoginStatus);
    procedure ShowLoginForm;
  end;


var
  frmChipUpMain: TfrmChipUpMain;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  System.Generics.Collections,
  Poker.Server.Socket.Commands, Poker.Protobufs.Enum.ServerCodes, Poker.Common.Misc, Poker.DataModule, Poker.Forms.CreateClub, Poker.Forms.JoinClub,
  Poker.Server.MessageContainer, Poker.Players.PlayerList, Poker.Forms.ChangeEMail, Poker.Forms.ChangePassword, Poker.Forms.ChangeAvatar,
  Poker.Protobufs.Objects.ClubCommandReply, Poker.Protobufs.Objects.User, Poker.Protobufs.Objects.StatusReply, Poker.Server.MessageCallbacks,
  Poker.Protobufs.Objects.Game, Poker.Protobufs.Objects.TableStatus, Poker.Tables.Table, Poker.DirectX.Timer, Poker.Protobufs.Objects.GetUserParams,
  Poker.Common.FormsContainer, Poker.Protobufs.Objects.TransferChipsParams, Poker.Forms.Updater, Poker.Forms.ClubLobby,
  Poker.Protobufs.Objects.UserChangeParams, Poker.Settings, Poker.Protobufs.Objects.TableStatsReplies, Poker.Tables.StatsList,
  Poker.Protobufs.Objects.TableStatsReply, Poker.Forms.ContactUs, Poker.Forms.Reconnect, Poker.Avatars.Avatar, Poker.Forms.About,
  Poker.Protobufs.Objects.ChatEvent, Poker.Forms.SystemTrayPopup, Poker.Protobufs.Objects.ClubMember, Poker.Protobufs.Objects.ClubStatsReply,
  Poker.Protobufs.Objects.ClubHandHistoryReply, Poker.HandHistory.Core, Poker.Forms.HandHistory, Poker.Forms.Settings,
  Poker.ActionMainMenuBarStyle, Poker.Protobufs.Objects.UpdateFileInfo, Poker.Clubs.Member, Poker.Players.Player, Poker.Avatars.AvatarList,
  Poker.Tables.Stats, Poker.Tables.TableList, Poker.Tables.Renderer;


procedure TfrmChipUpMain.DoCreate;
begin
  inherited;

  ShowLoginForm;
end;

procedure TfrmChipUpMain.FormCreate(Sender: TObject);
begin
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
                      TServerMessageCallback.Create(srTableStatsReply, CSRTableStats),
                      TServerMessageCallback.Create(srHandHistoryMsg, CSRHandHistoryMsg)
                  ], TRUE);

  LoadImageFromResource(imgCashier, 'CashierNormal');

  ActionManager.Style := ActionMainMenuBarStyle;
  ActionMainMenuBar.ColorMap.Assign(ActionMainMenuBarColorMap);

  FActionMainMenuBarFont := TFont.Create;
  FActionMainMenuBarFont.Assign(ActionMainMenuBar.Font);

  btHomeGames.Font.Name := 'Sintony Bold';
  btHomeGames.Font.Style := [];
  btHomeGames.Font.Size := 8;

  btJoinClub.Font.Assign(btHomeGames.Font);
  btTournaments.Font.Assign(btHomeGames.Font);
  btOpenClubLobby.Font.Assign(btHomeGames.Font);
  btCreateClub.Font.Assign(btHomeGames.Font);
  btJoinClub.Font.Assign(btHomeGames.Font);

  pcTabs.ActivePage := tsHomeGames;
  FCallbacksId := -1;

  Avatars.OnAvatarChanged := AvatarChanged;

  EnableWindow(Handle, TRUE);
end;

procedure TfrmChipUpMain.FormDestroy(Sender: TObject);
begin
  FormsContainer.CloseAllForms;
  Tables.Lock;
  try
    Tables.Clear;
  finally
    Tables.Unlock;
  end;
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FActionMainMenuBarFont.Free;
end;

procedure TfrmChipUpMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmChipUpMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := (not dmMain.IsLoggedIn) or
              (FShuttingDown) or
              (ConfirmToCloseTablesAppClose);

  if (CanClose) and
     (dmMain.IsLoggedIn) then
    ServerSocket.Logout;
end;

procedure TfrmChipUpMain.FormDeactivate(Sender: TObject);
begin
  LoadImageFromResource(imgCashier, 'CashierNormal');
end;

procedure TfrmChipUpMain.FormResize(Sender: TObject);
begin
  btPublicClubs.Width := (tsHomeGames.Width - btPublicClubs.Left - 3 - 11) div 2; // 3 = middle gap, 11 = right border
  btPrivateClubs.Left := btPublicClubs.Left + btPublicClubs.Width + 3;
  btPrivateClubs.Width := btPublicClubs.Width;
  gridPublicClubs.Left := btPublicClubs.Left;
  gridPublicClubs.Width := btPublicClubs.Width;
  gridPrivateClubs.Left := btPrivateClubs.Left;
  gridPrivateClubs.Width := btPrivateClubs.Width;
  gridGames.Width := btPrivateClubs.Left + btPrivateClubs.Width - btPublicClubs.Left;
  btTournamentsHeader.Left := btPublicClubs.Left;
  btTournamentsHeader.Width := btPublicClubs.Width + 3 + btPrivateClubs.Width;
end;

procedure TfrmChipUpMain.FormShow(Sender: TObject);
begin
  tiRefreshForm.Enabled := TRUE;
end;

procedure TfrmChipUpMain.DoLogout;
begin
  FormsContainer.CloseAllForms;
  Tables.ClearWithoutNotification;
  gridPublicClubsTable.DataController.SetRecordCount(0);
  gridPrivateClubsTable.DataController.SetRecordCount(0);
  gridGamesTable.DataController.SetRecordCount(0);
  dmMain.SelfInfo.Flush;
  Players.Clear;
  TablesStats.Clear;
  HandHistory.Clear;
  {$IFDEF DEBUG} RefreshDebugForm([dfiUser]); {$ENDIF}
end;

procedure TfrmChipUpMain.ShowLoginForm;
begin
  Application.ShowMainForm := FALSE;
  DoLogout;
  Hide;
  FormsContainer.RunForm(TfrmChipUpLogin, self, [], FALSE);
end;

procedure TfrmChipUpMain.ShowTournamentLayout(const AShow: Boolean);
begin
  btCreateClub.Visible := not AShow;
  btJoinClub.Visible := not AShow;
  gridPrivateClubs.Visible := not AShow;
  gridPublicClubs.Visible := not AShow;
  btPrivateClubs.Visible := not AShow;
  btOpenTable.Visible := not AShow;
  btPublicClubs.Visible := not AShow;
  gridGames.Visible := not AShow;
  btOpenClubLobby.Visible := not AShow;
end;

procedure TfrmChipUpMain.SocketStateChange(const AOldState, ANewState: TSocketState);
var
  form: TForm;
begin
  case ANewState of
    wsClosed: begin // handle disconnection here (try to reconnect)
      // dont reconnect if login form is active
      if FormsContainer.Find(TfrmChipUpLogin, form) then
        Exit;

      // check if reconnect form already exists, if it does, don't recreate it!
      if not FormsContainer.Contains(TfrmReconnect) then
      begin
        // save form states and disable them
        FormsContainer.SaveState;
        FormsContainer.DisableAll;

        // disable all tables
        Tables.DisableAll;

        // disable main form (its not in forms container)
        EnableWindow(Handle, FALSE);

        // open reconection form
        (FormsContainer.RunForm(TfrmReconnect, self, [], FALSE) as TfrmReconnect).SetCloseCallback(ModalFormClose);
      end;
    end;
  end;

  {$IFDEF DEBUG} RefreshDebugForm([dfiServer, dfiSocketState]); {$ENDIF}
end;

procedure TfrmChipUpMain.tiRefreshFormTimer(Sender: TObject);
begin
  gridGames.Refresh;
end;

function TfrmChipUpMain.GetSelectedClub(var AClub: TClubInfo): Boolean;
begin
  result := dmMain.SelfInfo.Clubs.FindClubBySeq(FSelectedClub, AClub);
end;

function TfrmChipUpMain.GetSelectedGame(var AGame: TGameInfo): Boolean;
var
  club: TClubInfo;
begin
  result := (GetSelectedClub(club)) and
            (club.Games.TryGetValue(FSelectedGame, AGame));
end;

procedure TfrmChipUpMain.acAnimationsEnabledExecute(Sender: TObject);
begin
  Settings.Animations := not Settings.Animations;
  acAnimationsEnabled.Checked := Settings.Animations;
  DXTimer.AnimationsEnabled := Settings.Animations;
  Settings.Save;
end;

procedure TfrmChipUpMain.acDisconnectExecute(Sender: TObject);
begin
  ServerSocket.Disconnect;
end;

procedure TfrmChipUpMain.acFoldChecksExecute(Sender: TObject);
begin
  Settings.FoldChecks := not Settings.FoldChecks;
  acFoldChecks.Checked := Settings.FoldChecks;
  Settings.Save;
end;

procedure TfrmChipUpMain.acHandHistoryExecute(Sender: TObject);
begin
  FormsContainer.RunForm(TfrmHandHistory, self, [nil, nil], FALSE);
end;

procedure TfrmChipUpMain.acLogoutExecute(Sender: TObject);
begin
  if not ConfirmToCloseTablesLogout then
    Exit;

  ServerSocket.Logout;
end;

procedure TfrmChipUpMain.acOpenCashierExecute(Sender: TObject);
begin
  dmMain.OpenCashierLink;
end;

procedure TfrmChipUpMain.acOpenClubLobbyExecute(Sender: TObject);
var
  club: TClubInfo;
  form: TForm;
begin
  if not dmMain.CheckAuthed then
    Exit;

  if not dmMain.SelfInfo.Clubs.FindClubBySeq(FSelectedClub, club) then
    Exit;

  for form in FormsContainer.Items do
    if (form is TfrmClubLobby) and
       ((form as TfrmClubLobby).ClubId = FSelectedClub) then
    begin
      form.SetFocus;
      Exit;
    end;

  FormsContainer.RunForm(TfrmClubLobby, self, [@FSelectedClub], TRUE);
end;

procedure TfrmChipUpMain.acResendVerificationMailExecute(Sender: TObject);
begin
  ServerSocket.ResendVerificationMail;
  MessageDlg(Format('Verification mail sent to %s. Please check your inbox.', [dmMain.SelfInfo.EMail]), mtInformation, [mbOK], 0);
end;

procedure TfrmChipUpMain.acSettingsExecute(Sender: TObject);
begin
  FormsContainer.RunForm(TfrmSettings, self, [], FALSE);
end;

procedure TfrmChipUpMain.acShowAboutFormExecute(Sender: TObject);
begin
  FormsContainer.RunForm(TfrmAbout, self, [], FALSE);
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

procedure TfrmChipUpMain.acShowContactUsFormExecute(Sender: TObject);
begin
  FormsContainer.RunForm(TfrmContactUs, self, [], FALSE);
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
  table: TTable;
  member: TClubMemberInfo;
begin
  if not dmMain.CheckAuthed then
    Exit;

  if (not GetSelectedClub(club)) or (not GetSelectedGame(game)) then
    Exit;

  member := nil;
  if (club.IsPrivate) and (not club.GetMemberInfo(dmMain.SelfInfo.Id, member)) then
    Exit;

  if (Assigned(member)) and
     (member.Suspended) then
    MessageDlg('You are currently suspended in this club, and cannot join any tables. Please contact club owner to resolve this issue.', mtWarning, [mbOK], 0)
  else
    if Tables.FindTable(game.MongoId, ttLiveGame, table) then
      table.BringToFront
    else
      Tables.AddTable(game.MongoId, FALSE, TRUE);
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

  acResendVerificationMail.Visible := not dmMain.SelfInfo.Authed;

  acSoundsOnOff.Checked := Settings.Sounds;
  acFoldChecks.Checked := Settings.FoldChecks;
  acAnimationsEnabled.Checked := Settings.Animations;

  ActionManager.ActionBars[0].Items[3].Visible := Settings.DeveloperMode;

  UpdateClublist;
  UpdateGamelist;
  UpdatePublicClublist;
end;

function TfrmChipUpMain.ConfirmToCloseTablesAppClose: Boolean;
begin
  result := TRUE;
  if Tables.SittingCount > 0 then
    result := MessageDlg('Closing the application will automatically leave all the tables you are currently playing on. Proceed?', mtWarning, mbYesNo, 0) = mrYes;
end;

function TfrmChipUpMain.ConfirmToCloseTablesLogout: Boolean;
begin
  result := TRUE;
  if Tables.SittingCount > 0 then
    result := MessageDlg('Upon logout you will automatically leave all the tables you are currently playing on. Proceed?', mtWarning, mbYesNo, 0) = mrYes;
end;

procedure TfrmChipUpMain.UpdateClublist;
var
  club: TClubInfo;
  status: String;
  rcount: Integer;
  c: TcxDataController;
  member: TClubMemberInfo;
begin
  c := gridPrivateClubsTable.DataController;
  c.BeginFullUpdate;
  try
    rcount := 0;
    for club in dmMain.SelfInfo.Clubs.Values do
      if club.IsPrivate then
      begin
        Inc(rcount);
        if rcount > c.RecordCount then
          c.SetRecordCount(rcount);

        c.SetValue(rcount - 1, gridJoinedClubsId.Index, club.Id);
        c.SetValue(rcount - 1, gridJoinedClubsClubName.Index, club.Name);

        if CompareBytes(dmMain.SelfInfo.Id, club.OwnerId) then
          status := 'Manager'
        else
          if club.GetMemberInfo(dmMain.SelfInfo.id, member) then
          begin
            if member.Suspended then
              status := 'Suspended'
            else
              status := 'Member';
          end
          else
            status := 'Unknown';
        c.SetValue(rcount - 1, gridJoinedClubsStatus.Index, status);
      end;
    c.SetRecordCount(rcount);
  finally
    c.EndFullUpdate;
  end;
  c.Refresh;
end;

procedure TfrmChipUpMain.UpdateGamelist;
var
  game: TGameInfo;
  c: TcxGridDataController;
  club: TClubInfo;
  rcount: Integer;
begin
  c := gridGamesTable.DataController;
  c.BeginFullUpdate;
  try
    rcount := 0;
    if GetSelectedClub(club) then
      for game in club.Games.Values do
      begin
        if game.State = gsClosed then
          Continue;

        Inc(rcount);
        if rcount > c.RecordCount then
          c.SetRecordCount(rcount);

        c.SetValue(rcount - 1, gridGamesId.Index, game.MongoId);
        c.SetValue(rcount - 1, gridGamesName.Index, game.Name);
        c.SetValue(rcount - 1, gridGamesType.Index, game.AsString(TRUE));
        c.SetValue(rcount - 1, gridGamesBlinds.Index, Format('%d/%d', [Trunc(game.SmallBlind / 100), Trunc(game.BigBlind / 100)]));
        c.SetValue(rcount - 1, gridGamesBuyinLimits.Index, Format('%d-%d', [game.MinBuyin, game.MaxBuyin]));
        c.SetValue(rcount - 1, gridGamesPlayers.Index, Format('%d/%d', [game.Sitting, game.Seats]));
        c.SetValue(rcount - 1, gridGamesStatus.Index, game.StateAsStr);
      end;
    c.SetRecordCount(rcount);
  finally
    c.EndFullUpdate;
  end;
  c.Refresh;
end;

procedure TfrmChipUpMain.UpdatePublicClublist;
var
  rcount: Integer;
  club: TClubInfo;
  c: TcxGridDataController;
begin
  c := gridPublicClubsTable.DataController;

  c.BeginFullUpdate;
  try
    rcount := 0;
    for club in dmMain.SelfInfo.Clubs.Values do
      if not club.IsPrivate then
      begin
        Inc(rcount);
        if rcount > c.RecordCount then
          c.SetRecordCount(rcount);
        c.SetValue(rcount - 1, gridClubsId.Index, club.Id);
        c.SetValue(rcount - 1, gridClubsName.Index, club.Name);
      end;
    c.SetRecordCount(rcount);
  finally
    c.EndFullUpdate;
  end;
  c.Refresh;
end;

procedure TfrmChipUpMain.WMEndSession(var AMessage: TWMEndSession);
begin
  FShuttingDown := AMessage.EndSession;

  inherited;
end;

procedure TfrmChipUpMain.WMQueryEndSession(var AMessage: TWMQueryEndSession);
begin
  FShuttingDown := TRUE;

  inherited;
end;

procedure TfrmChipUpMain.WMSettingChange(var AMessage: TWMSettingChange);
begin
  inherited;

  // this reassigns font/colormap to ActionMainMenuBar
  // bug info: http://stackoverflow.com/questions/9577540/tactionmainmenubar-and-tactiontoolbar-lose-settings
  ActionMainMenuBar.Font.Assign(FActionMainMenuBarFont);
  ActionMainMenuBar.ColorMap.Assign(ActionMainMenuBarColorMap);
end;

procedure TfrmChipUpMain.gridPrivateClubsEnter(Sender: TObject);
begin
  gridPublicClubsTable.DataController.FocusedRecordIndex := -1;
end;

procedure TfrmChipUpMain.gridPublicClubsEnter(Sender: TObject);
begin
  gridPrivateClubsTable.DataController.FocusedRecordIndex := -1;
end;

procedure TfrmChipUpMain.gridPrivateClubsTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  acOpenClubLobby.Execute;
end;

procedure TfrmChipUpMain.gridPublicClubsTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  acOpenClubLobby.Execute;
end;

procedure TfrmChipUpMain.gridPublicClubsTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex: Integer;
  club_id: Integer;
  club: TClubInfo;
begin
  recIndex := gridPublicClubsTable.DataController.GetFocusedRecordIndex;
  if recIndex = -1 then
    FSelectedClub := -1
  else
  begin
    club_id := gridPublicClubsTable.DataController.GetValue(recIndex, gridClubsId.Index);
    if not dmMain.SelfInfo.Clubs.FindClubBySeq(club_id, club) then
      FSelectedClub := -1
    else
    begin
      FSelectedClub := club_id;
      SetLength(FSelectedGame, 0);
      gridGamesTable.DataController.FocusedRecordIndex := -1;
    end;
  end;

  acOpenClubLobby.Enabled := (dmMain.SelfInfo.Clubs.FindClubBySeq(FSelectedClub, club)) and
                             (CompareBytes(club.OwnerId, dmMain.SelfInfo.Id));

  UpdateGamelist;
end;

procedure TfrmChipUpMain.gridGamesTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  acShowGameTableForm.Execute;
end;

procedure TfrmChipUpMain.gridPrivateClubsTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex: Integer;
  club_id: Int64;
  club: TClubInfo;
begin
  recIndex := gridPrivateClubsTable.DataController.GetFocusedRecordIndex;
  if recIndex = -1 then
    FSelectedClub := -1
  else
  begin
    club_id := gridPrivateClubsTable.DataController.GetValue(recIndex, gridJoinedClubsId.Index);
    if not dmMain.SelfInfo.Clubs.FindClubBySeq(club_id, club) then
      FSelectedClub := -1
    else
    begin
      FSelectedClub := club_id;
      SetLength(FSelectedGame, 0);
      gridGamesTable.DataController.FocusedRecordIndex := -1;
    end;
  end;

  acOpenClubLobby.Enabled := dmMain.SelfInfo.Clubs.FindClubBySeq(FSelectedClub, club);

  UpdateGamelist;
end;

procedure TfrmChipUpMain.gridGamesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex: Integer;
  game_id: TBytes;
  game: TGameInfo;
  club: TClubInfo;
begin
  recIndex := gridGamesTable.DataController.GetFocusedRecordIndex;
  if (recIndex = -1) or
     (not GetSelectedClub(club)) then
    SetLength(FSelectedGame, 0)
  else
  begin
    game_id := gridGamesTable.DataController.GetValue(recIndex, gridGamesId.Index);
    if not club.Games.TryGetValue(game_id, game) then
      SetLength(FSelectedGame, 0)
    else
      FSelectedGame := game_id;
  end;

  acShowGameTableForm.Enabled := Length(FSelectedGame) > 0;
end;

procedure TfrmChipUpMain.imgCashierMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    if PtInCircle(X, Y, imgCashier.Width div 2, imgCashier.Height div 2, 42) then
      LoadImageFromResource(imgCashier, 'CashierPressed');
  end;
end;

procedure TfrmChipUpMain.imgCashierMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    if PtInCircle(X, Y, imgCashier.Width div 2, imgCashier.Height div 2, 42) then
      dmMain.OpenCashierLink;
    LoadImageFromResource(imgCashier, 'CashierNormal');
  end;
end;

procedure TfrmChipUpMain.LoginStatus(const AValue: TLoginStatus);
begin
  case AValue of
    lsLoggedIn: begin
      FSelectedClub := -1;
      SetLength(FSelectedGame, 0);
      ConfigureGUI;
      Show;
      dmMain.ProcessReconnectedTables;
    end;

    lsUpdating: (FormsContainer.RunForm(TfrmUpdater, self, [], FALSE) as TfrmUpdater).SetCloseCallback(ModalFormClose);
  else
    Close;
  end;
end;

procedure TfrmChipUpMain.ModalFormClose(ASender: TObject);
begin
  if ASender is TfrmReconnect then
    case (ASender as TfrmReconnect).CurrentStatus of
      rsLoggedIn: ConfigureGUI;
    else
      FormsContainer.Items.Extract(ASender as TForm);
      ShowLoginForm;
    end;

  if ASender is TfrmUpdater then
    if (ASender as TfrmUpdater).RequiresReboot then
      PostMessage(frmChipUpMain.Handle, WM_QUIT, 0, 0)
    else
      ShowLoginForm;

  EnableWindow(Handle, TRUE);
end;

procedure TfrmChipUpMain.pcTabsChange(Sender: TObject);
begin
  if pcTabs.ActivePage = tsHomeGames then
    ShowTournamentLayout(FALSE);
  if pcTabs.ActivePage = tsTournaments then
    ShowTournamentLayout(TRUE);
end;

procedure TfrmChipUpMain.CSRLeaveClub(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_ClubCommandReply;
begin
  pbreply := AObject as TPB_ClubCommandReply;

  case pbreply.Status of
    csSuccess: begin
      ProcessClubObject(pbreply.Club, AMethodId);
      ConfigureGUI;
    end;
  end;
end;

function TfrmChipUpMain.ProcessClubObject(const AClub: TPB_Club; const AMethodId: Integer): TClubInfo;
var
  club: TClubInfo;
  player: TPlayerInfo;
  query_users: TArray<TBytes>;
  empty_array: TBytes;
  member: TClubMemberInfo;
  memberpb: TPB_ClubMember;
begin
  if AMethodId <> Integer(srClubDisbandOk) then
  begin
    club := dmMain.SelfInfo.Clubs.AddClub(AClub);
    SetLength(query_users, 0);
    SetLength(empty_array, 0);

    if not Players.TryGetValue(AClub.Owner, player) then
    begin
      SetLength(query_users, 1);
      query_users[0] := AClub.Owner;
      Players.AddPlayer(AClub.Owner, 'Retrieving...', '', 0, empty_array);
    end;

    for memberpb in AClub.Members do
      if (not Players.TryGetValue(memberpb.MongoId, player)) or
         (player.Nick = '') or
         (Length(player.AvatarId) = 0) then
      begin
        SetLength(query_users, Length(query_users) + 1);
        query_users[Length(query_users) - 1] := memberpb.MongoId;
        Players.AddPlayer(memberpb.MongoId, 'Retrieving...', '', 0, empty_array);
      end;

    if Length(query_users) > 0 then
      ServerSocket.GetUserInfos(query_users);

    // we got kicked.. or club got deleted
    if (not club.GetMemberInfo(dmMain.SelfInfo.Id, member)) and
       (club.IsPrivate) then
    begin
      Tables.CloseTablesForClub(club.MongoId);
      dmMain.SelfInfo.Clubs.Remove(club.MongoId);
      club := nil;
    end;
  end
  else
  begin
    Tables.CloseTablesForClub(AClub.MongoId);
    dmMain.SelfInfo.Clubs.Remove(AClub.MongoId);
    club := nil;
  end;

  result := club;
end;

procedure TfrmChipUpMain.CSRClubCommand(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_ClubCommandReply;
  club: TClubInfo;
begin
  pbreply := AObject as TPB_ClubCommandReply;

  case pbreply.Status of
    csSuccess: begin
      club := ProcessClubObject(pbreply.Club, AMethodId);

      if (AMethodId in [Integer(srJoinClubReply), Integer(srChangeClubDetailsReply)]) and
         (Assigned(club)) then
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

  ProcessClubObject(pbclub, AMethodId);

  ConfigureGUI;
end;

procedure TfrmChipUpMain.CSRGetUsers(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_GetUserParams;
  user: TPB_User;
begin
  pbreply := AObject as TPB_GetUserParams;

  for user in pbreply.Users do
    Players.AddPlayer(user);
end;

procedure TfrmChipUpMain.CSRETransferChipsOk(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_TransferChipsParams;
  player_info: TPlayerInfo;
begin
  pbreply := AObject as TPB_TransferChipsParams;

  if AMethodId = Integer(seTransferChips) then
  begin
    dmMain.SelfInfo.Balance := dmMain.SelfInfo.Balance + pbreply.ChipAmount;
    if Players.TryGetValue(pbreply.PlayerMongoId, player_info) then
      player_info.Balance := player_info.Balance - pbreply.ChipAmount;
  end
  else
  begin
    dmMain.SelfInfo.Balance := dmMain.SelfInfo.Balance - pbreply.ChipAmount;
    if Players.TryGetValue(pbreply.PlayerMongoId, player_info) then
      player_info.Balance := player_info.Balance + pbreply.ChipAmount;
  end;
  dmMain.UpdateSelfInfoInPlayers;
end;

procedure TfrmChipUpMain.acShowHomeGamesLayoutExecute(Sender: TObject);
begin
  pcTabs.ActivePage := tsHomeGames;
end;

procedure TfrmChipUpMain.acShowTournamentLayoutExecute(Sender: TObject);
begin
  pcTabs.ActivePage := tsTournaments;
end;

procedure TfrmChipUpMain.acSoundsOnOffExecute(Sender: TObject);
begin
  Settings.Sounds := not Settings.Sounds;
  acSoundsOnOff.Checked := Settings.Sounds;
  Settings.Save;
end;

procedure TfrmChipUpMain.acTermsAndConditionsExecute(Sender: TObject);
begin
  dmMain.OpenTACLink;
end;

procedure TfrmChipUpMain.ActionMainMenuBarGetControlClass(Sender: TCustomActionBar; AnItem: TActionClient; var ControlClass: TCustomActionControlClass);
begin
  // this reassigns colormap to ActionMainMenuBar
  // bug info: http://stackoverflow.com/questions/9577540/tactionmainmenubar-and-tactiontoolbar-lose-settings
  ActionMainMenuBar.ColorMap.Assign(ActionMainMenuBarColorMap);
end;

procedure TfrmChipUpMain.ApplicationEventsDeactivate(Sender: TObject);
begin
  FormsContainer.Close(TfrmAbout);
end;

procedure TfrmChipUpMain.AvatarChanged(Sender: TObject);
var
  table: TTable;
begin
  Tables.Lock;
  try
    for table in Tables.Values do
      table.RenderSync;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmChipUpMain.CSESecondaryLoginDetected(const AMethodId: Integer; const AObject: TObject);
begin
  ShowLoginForm;
end;

procedure TfrmChipUpMain.CSEUserChange(const AMethodId: Integer; const AObject: TObject);
var
  pbusers: TPB_UserChangeParams;
  pbuser: TPB_user;
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

  dmMain.UpdateSelfInfoInPlayers;

  ConfigureGUI;
end;

procedure TfrmChipUpMain.CSEChatEvent(const AMethodId: Integer; const AObject: TObject);
var
  chatEvent: TPB_ChatEvent;
begin
  chatEvent := AObject as TPB_ChatEvent;
  if chatEvent.Event = ceServerMessage then
    TfrmSystemTrayPopup.ShowPopup(chatEvent.Msg.Msg);
end;

procedure TfrmChipUpMain.CSEClubDeleted(const AMethodId: Integer; const AObject: TObject);
var
  pbclub: TPB_Club;
begin
  pbclub := AObject as TPB_Club;

  Tables.CloseTablesForClub(pbclub.MongoId);
  dmMain.SelfInfo.Clubs.Remove(pbclub.MongoId);

  ConfigureGUI;
end;

procedure TfrmChipUpMain.CSREGameDelete(const AMethodId: Integer; const AObject: TObject);
var
  pbgame: TPB_Game;
  club: TClubInfo;
  game: TGameInfo;
  table: TTable;
begin
  pbgame := AObject as TPB_Game;

  if (dmMain.SelfInfo.Clubs.FindClubBySeq(pbgame.Clubseq, club)) and
     (club.Games.TryGetValue(pbgame.MongoId, game)) then
  begin
    if Tables.FindTable(game.MongoId, ttLiveGame, table) then
      Tables.Remove(table.InternalId);
    club.Games.AddGame(pbgame);
  end;

  ConfigureGUI;
end;

procedure TfrmChipUpMain.CSREGameOperation(const AMethodId: Integer; const AObject: TObject);
var
  pbgame: TPB_Game;
  club: TClubInfo;
  game: TGameInfo;
begin
  pbgame := AObject as TPB_Game;

  if dmMain.SelfInfo.Clubs.FindClubBySeq(pbgame.Clubseq, club) then
  begin
    game := club.Games.AddGame(pbgame);

    if (Assigned(game)) and
       (AMethodId = Integer(srCreateGameOk)) then
      Tables.AddTable(game.MongoId, FALSE, TRUE);
  end;

  ConfigureGUI;
end;

procedure TfrmChipUpMain.CSRTableStatus(const AMethodId: Integer; const AObject: TObject);
var
  pbtstatus: TPB_TableStatus;
  table: TTable;
  game: TGameInfo;
begin
  pbtstatus := AObject as TPB_TableStatus;
  if Tables.FindTable(pbtstatus.TableMongoId, ttLiveGame, table) then
  begin
    Tables.Lock;
    try
      if table.GetObjectCopy(game) then
      try
        game.UpdateFromTableStatus(pbtstatus);
        if not table.Form.Visible then
          table.BringToFront;

        ConfigureGUI;
      finally
        game.Free;
      end;
    finally
      Tables.Unlock;
    end;
  end;
end;

procedure TfrmChipUpMain.CSRTableStats(const AMethodId: Integer; const AObject: TObject);
var
  pb: TPB_TableStatsReplies;
  tablepb: TPB_TableStatsReply;
  tablestats: TTableStats;
  player: TPB_User;
  playerinfo: TPlayerInfo;
  club: TClubInfo;
  query_users: TArray<TBytes>;
  empty_array: TBytes;
  clubstats: TPB_ClubStatsReply;
begin
  pb := AObject as TPB_TableStatsReplies;

  SetLength(empty_array, 0);
  SetLength(query_users, 0);
  for player in pb.Players do
    if Players.TryGetValue(player.MongoId, playerinfo) then
      playerinfo.Nick := player.Displayname
    else
    begin
      SetLength(query_users, Length(query_users) + 1);
      query_users[Length(query_users) - 1] := player.MongoId;
      Players.AddPlayer(player.MongoId, 'Retrieving...', '', 0, empty_array);
    end;

  if Length(query_users) <> 0 then
    ServerSocket.GetUserInfos(query_users);

  for clubstats in pb.ClubStats do
    if dmMain.SelfInfo.Clubs.TryGetValue(clubstats.Clubid, club) then
      club.UpdateFromClubStats(clubstats);

  for tablepb in pb.Reply do
    if TablesStats.TryGetValue(tablepb.Gameid, tablestats) then
      tablestats.Assign(tablepb)
    else
    begin
      tablestats := TTableStats.Create;
      tablestats.Assign(tablepb);
      TablesStats.Add(tablestats.GameId, tablestats);
    end;
end;

procedure TfrmChipUpMain.CSRHandHistoryMsg(const AMethodId: Integer; const AObject: TObject);
var
  pb: TPB_ClubHandHistoryReply;
begin
  pb := AObject as TPB_ClubHandHistoryReply;
  HandHistory.Add(pb);
end;

end.
