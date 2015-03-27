unit Poker.Forms.Main;

interface

{$I defines.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ActnList,
  Vcl.Menus, cxCustomData, cxEdit, cxGridCustomTableView, cxGridTableView, cxGridLevel,
  cxGrid, cxLabel, cxButtons, OverbyteIcsWSocket, Poker.Clubs.Club, Poker.Forms.Login,
  Poker.Games.Game, cxImage, Vcl.ActnMan, ChipUpPokerDarkSkin, cxPC, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, dxSkinsCore,
  dxSkinscxPCPainter, cxPCdxBarPopupMenu, cxStyles, cxFilter, cxData, cxDataStorage,
  cxSpinEdit, cxTextEdit, cxBlobEdit, Vcl.PlatformDefaultStyleActnCtrls, Vcl.StdCtrls,
  cxClasses, cxGridCustomView, dxGDIPlusClasses, Vcl.ToolWin, Vcl.ActnCtrls,
  Vcl.ActnMenus, Vcl.AppEvnts, System.Generics.Collections, Vcl.StdStyleActnCtrls,
  Poker.Types, RVScroll, RichView, RVStyle, cxTimeEdit, cxCalendar, dxBevel;

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
    gridPublicClubsMongoId: TcxGridColumn;
    gridPublicClubsName: TcxGridColumn;
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
    acShowContactUsForm: TAction;
    acTermsAndConditions: TAction;
    acShowAboutForm: TAction;
    acSoundsOnOff: TAction;
    gridPrivateClubs: TcxGrid;
    gridPrivateClubsTable: TcxGridTableView;
    gridHomeClubsId: TcxGridColumn;
    gridHomeClubsName: TcxGridColumn;
    gridHomeClubsStatus: TcxGridColumn;
    gridPrivateClubsLevel: TcxGridLevel;
    acFoldChecks: TAction;
    acHandHistory: TAction;
    acAnimationsEnabled: TAction;
    acSettings: TAction;
    ActionMainMenuBar: TActionMainMenuBar;
    acDisconnect: TAction;
    ApplicationEvents: TApplicationEvents;
    gridHomeClubsMongoId: TcxGridColumn;
    gridTournaments: TcxGrid;
    gridTournamentsTable: TcxGridTableView;
    gridTournamentsId: TcxGridColumn;
    gridTournamentsName: TcxGridColumn;
    gridTournamentsStartTime: TcxGridColumn;
    gridTournamentsStatus: TcxGridColumn;
    gridTournamentsLevel: TcxGridLevel;
    btTournamentLobby: TcxButton;
    RVStyle: TRVStyle;
    acTournamentLobby: TAction;
    gridTournamentsPlayers: TcxGridColumn;
    btTournamentRegister: TcxButton;
    acTournamentRegister: TAction;
    acTournamentUnregister: TAction;
    StyleRepository: TcxStyleRepository;
    styleTournamentOpen: TcxStyle;
    styleTournamentInProgress: TcxStyle;
    styleTournamentCancelled: TcxStyle;
    acTournamentsOpenAll: TAction;
    acTournamentItemOpen: TAction;
    styleTournamentFinished: TcxStyle;
    styleTournamentName: TcxStyle;
    paTournamentInfo: TPanel;
    lbvTournamentName: TcxLabel;
    lbvTournamentInfo: TcxLabel;
    lbvTournamentGameType: TcxLabel;
    lbvTournamentState: TcxLabel;
    lbvTournamentDescription: TcxLabel;
    lbsTournamentDetails: TcxLabel;
    tiTournamentInfoRefresh: TTimer;
    styleTournamentNameRegistered: TcxStyle;
    acConfirmationOnFold: TAction;
    acAlwaysRunItTwice: TAction;
    acLaunchNewInstance: TAction;
    procedure acLogoutExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acShowCreateClubFormExecute(Sender: TObject);
    procedure acShowJoinClubFormExecute(Sender: TObject);
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
    procedure gridTournamentsTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
    procedure acTournamentLobbyExecute(Sender: TObject);
    procedure acTournamentRegisterExecute(Sender: TObject);
    procedure gridTournamentsTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure acTournamentUnregisterExecute(Sender: TObject);
    procedure gridTournamentsStatusStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
    procedure acTournamentItemOpenExecute(Sender: TObject);
    procedure acTournamentsOpenAllExecute(Sender: TObject);
    procedure tiTournamentInfoRefreshTimer(Sender: TObject);
    procedure gridTournamentsNameStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
    procedure acConfirmationOnFoldExecute(Sender: TObject);
    procedure acAlwaysRunItTwiceExecute(Sender: TObject);
    procedure acLaunchNewInstanceExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    const
      RESOURCE_CASHIER_NORMAL = 'CashierNormal';
      RESOURCE_CASHIER_PRESSED = 'CashierPressed';

    var
      FSelectedClub: TMongoId;
      FSelectedGame: TMongoId;
      FSelectedTournament: TMongoId;
      FCallbacksId: Integer;
      FShuttingDown: Boolean;
      FActionMainMenuBarFont: TFont;
      FRegisteredTournamentsMap: TDictionary<Integer, TMongoId>;

    procedure ModalFormClose(ASender: TObject);

    procedure FlushData;
    procedure UpdateClublist;
    procedure UpdatePublicClublist;
    procedure UpdateGamelist;
    procedure UpdateTournamentList;
    procedure UpdateTournamentActions;
    procedure RefreshGrids;
    procedure UpdateMenuActions;
    procedure UpdateFormCaption;
    procedure FillTournamentMenuList;
    procedure UpdateTournamentInfo;
    procedure RefreshAll;

    procedure ShowTournamentLayout(const AShow: Boolean);
    procedure OpenTournamentLobby(const AMongoId: TMongoId);

    procedure CSRLeaveClub(const AMethodId: Integer; const AObject: TObject);
    procedure CSRClubCommand(const AMethodId: Integer; const AObject: TObject);
    procedure CSRGetUsers(const AMethodId: Integer; const AObject: TObject);

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
    procedure CSETournamentList(const AMethodId: Integer; const AObject: TObject);
    procedure CSRTournamentReply(const AMethodId: Integer; const AObject: TObject);
    procedure CSRTournamentDetails(const AMethodId: Integer; const AObject: TObject);
    procedure CSRTournamentOpenTable(const AMethodId: Integer; const AObject: TObject);
    procedure CSETournamentPlayerFinished(const AMethodId: Integer; const AObject: TObject);
    procedure CSETournamentPlayerTransfer(const AMethodId: Integer; const AObject: TObject);
    procedure CSEPlayerTableStatus(const AMethodId: Integer; const AObject: TObject);

    procedure AvatarChanged(Sender: TObject);

    function ConfirmToCloseTablesAppClose: Boolean;
    function ConfirmToCloseTablesLogout: Boolean;

    procedure SocketStateChange(const AOldState, ANewState: TSocketState);

    procedure DoLogout;

    {$IFDEF ENABLE_EXCEPTION_LOGGING}
    procedure ApplicationException(Sender: TObject; E: Exception);
    {$ENDIF}
  protected
    procedure DoCreate; override;
    procedure WMQueryEndSession(var AMessage: TWMQueryEndSession); message WM_QUERYENDSESSION;
    procedure WMEndSession(var AMessage: TWMEndSession); message WM_ENDSESSION;
    procedure WMSettingChange(var AMessage: TWMSettingChange); message WM_SETTINGCHANGE;
    procedure WMWindowPosChanging(var AMessage: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
  public
    procedure LoginStatus(const AValue: TLoginStatus);
    procedure OpenClubTable(const AClubId, ATableId: TMongoId);
  end;

var
  frmChipUpMain: TfrmChipUpMain;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  {$IFDEF ENABLE_EXCEPTION_LOGGING} JclDebug, {$ENDIF}
  Poker.Sounds, Poker.Server.Socket, Poker.Protobufs.Enum.ServerCodes, Poker.Common.Misc,
  Poker.DataModule, Poker.Forms.CreateClub, Poker.Forms.JoinClub, Poker.Server.MessageContainer, Poker.Players.PlayerList, Poker.Forms.ChangeEMail,
  Poker.Forms.ChangePassword, Poker.Forms.ChangeAvatar, Poker.Protobufs.Objects.ClubCommandReply, Poker.Protobufs.Objects.User,
  Poker.Server.MessageCallbacks, Poker.Protobufs.Objects.TableStatus, Poker.Tables.Table, Poker.DirectX.Timer, Poker.Protobufs.Objects.GetUserParams,
  Poker.Common.FormsContainer, Poker.Forms.Updater, Poker.Forms.ClubLobby, Poker.Protobufs.Objects.UserChangeParams, Poker.Settings,
  Poker.Protobufs.Objects.TableStatsReplies, Poker.Tables.StatsList, Poker.Protobufs.Objects.TableStatsReply, Poker.Forms.ContactUs,
  Poker.Forms.Reconnect, Poker.Avatars.Avatar, Poker.Forms.About, Poker.Protobufs.Objects.ChatEvent, Poker.Forms.SystemTrayPopup,
  Poker.Protobufs.Objects.ClubMember, Poker.Protobufs.Objects.ClubStatsReply, Poker.Protobufs.Objects.HandHistoryReply, Poker.HandHistory.Core,
  Poker.Forms.HandHistory, Poker.Forms.Settings, Poker.ActionMainMenuBarStyle, Poker.Protobufs.Objects.UpdateFileInfo,
  Poker.Players.Player, Poker.Avatars.AvatarList, Poker.Tables.TableList, Poker.Tables.Status, Poker.Forms.Subscriptions,
  Poker.Protobufs.Objects.Club, Poker.Protobufs.Objects.Game, Poker.Protobufs.Objects.TournamentList, Poker.Protobufs.Objects.TournamentInfo,
  Poker.Tournaments, Poker.Forms.TournamentLobby, Poker.Protobufs.Objects.TournamentCommandParams, System.DateUtils, Poker.Tournaments.Info,
  Poker.Protobufs.Objects.TournamentTableStart, Poker.Protobufs.Objects.TournamentPlayerFinished, Poker.Protobufs.Objects.TableMessage,
  Poker.Protobufs.Objects.TournamentMember, Poker.Protobufs.Objects.TournamentPlayerTransfer, Poker.Forms.Table, Poker.Forms.TournamentFinishDialog,
  Poker.Protobufs.Objects.PlayerClubStatus, Poker.Common.ModalDialogs, Poker.Common.InstanceController,
  Poker.SoftExceptions;


procedure TfrmChipUpMain.DoCreate;
begin
  inherited;

  DoLogout;
end;

procedure TfrmChipUpMain.FormCreate(Sender: TObject);
begin
  {$IFDEF ENABLE_EXCEPTION_LOGGING}
  Application.OnException := ApplicationException;
  {$ENDIF}

  FRegisteredTournamentsMap := TDictionary<Integer, TMongoId>.Create;

  FCallbacksId := MessageContainer.AddCallbacks([
                      TSocketStateChangeCallback.Create(SocketStateChange),
                      TServerMessageCallback.Create(srLeaveClubReply, CSRLeaveClub),
                      TServerMessageCallback.Create(srGetPlayers, CSRGetUsers),
                      TServerMessageCallback.Create(srLogout, CSRLogout),
                      TServerMessageCallback.Create(seChat, CSEChatEvent),
                      TServerMessageCallback.Create(seAccountConfirmed, CSEAccountConfirmed),
                      TServerMessageCallback.Create(seClubDeleted, CSEClubDeleted),
                      TServerMessageCallback.Create(seGameDelete, CSREGameDelete),
                      TServerMessageCallback.Create(seUserChange, CSEUserChange),
                      TServerMessageCallback.Create(srTableStatsReply, CSRTableStats),
                      TServerMessageCallback.Create(srHandHistoryMsg, CSRHandHistoryMsg),
                      TServerMessageCallback.Create(seTournamentList, CSETournamentList),
                      TServerMessageCallback.Create(srTournamentReply, CSRTournamentReply),
                      TServerMessageCallback.Create(srTournamentDetails, CSRTournamentDetails),
                      TServerMessageCallback.Create(srTournamentOpenTable, CSRTournamentOpenTable),
                      TServerMessageCallback.Create(seTournamentPlayerFinished, CSETournamentPlayerFinished),
                      TServerMessageCallback.Create(seSecondaryLoginDetected, CSESecondaryLoginDetected),
                      TServerMessageCallback.Create(seTournamentPlayerTransfer, CSETournamentPlayerTransfer),
                      TServerMessageCallback.Create(sePlayerClubStatus, CSEPlayerTableStatus),
                      TServerMessageCallback.Create([srChangeClubDetailsReply, srCreateClubReply, srJoinClubReply, srKickPlayerReply], CSRClubCommand),
                      TServerMessageCallback.Create([srCreateGameOk, seGameChange, seGameCreate], CSREGameOperation),
                      TServerMessageCallback.Create([srClubDisbandOk, seClubChange, srSuspendPlayerOk, srReinstatePlayerOk, srOwnershipGiveAwayOk], CSREClubOperation),
                      TServerMessageCallback.Create([seTableStatus, srTableStandUpOk, srTableSitOk, srTournamentOpenTable], CSRTableStatus)
                  ], TRUE);

  Settings.LoadFormSettings(self,
    Screen.Width div 2 - Width div 2, Screen.Height div 2 - Height div 2);

  LoadImageFromResource(imgCashier, RESOURCE_CASHIER_NORMAL);

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

  Avatars.OnAvatarChanged := AvatarChanged;

  EnableWindow(Handle, TRUE);
end;

procedure TfrmChipUpMain.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FlushData;
  FormsContainer.CloseAllForms;
  FActionMainMenuBarFont.Free;
  FRegisteredTournamentsMap.Free;
end;

procedure TfrmChipUpMain.FormActivate(Sender: TObject);
begin
  dmMain.RefreshSkinController;
end;

procedure TfrmChipUpMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Settings.SaveFormSettings(self);

  Action := caFree;
end;

procedure TfrmChipUpMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := (not dmMain.IsLoggedIn) or
              (FShuttingDown) or
              (ConfirmToCloseTablesAppClose);

  if CanClose then
  begin
    if dmMain.IsLoggedIn then
      ServerSocket.Logout;
  end;
end;

procedure TfrmChipUpMain.FormDeactivate(Sender: TObject);
begin
  LoadImageFromResource(imgCashier, RESOURCE_CASHIER_NORMAL);
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
  gridTournaments.Left := btTournamentsHeader.Left;
  paTournamentInfo.Left := gridTournaments.Left + gridTournaments.Width + 3;
  paTournamentInfo.Width := btTournamentsHeader.Width - gridTournaments.Width - 4;
  paTournamentInfo.Height := gridTournaments.Height - 1;

  if WindowState <> wsMaximized then
    Settings.SaveFormSettings(self);
end;


procedure TfrmChipUpMain.FlushData;
begin
  FormsContainer.CloseAllForms;
  Tables.ClearWithoutNotification;
  gridPublicClubsTable.DataController.SetRecordCount(0);
  gridPrivateClubsTable.DataController.SetRecordCount(0);
  gridGamesTable.DataController.SetRecordCount(0);
  gridTournamentsTable.DataController.SetRecordCount(0);
  dmMain.SelfInfo.Flush;
  Players.Clear;
  TablesStats.Clear;
  HandHistory.Clear;
  Tournaments.Clear;
  btHomeGames.Down := TRUE;
  acShowHomeGamesLayout.Execute;
  {$IFDEF DEBUG} RefreshDebugForm([dfiUser]); {$ENDIF}
end;

procedure TfrmChipUpMain.DoLogout;
begin
  Application.ShowMainForm := FALSE;
  ModalDialogs.CloseAll;
  FlushData;
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

  btTournamentsHeader.Visible := AShow;
  gridTournaments.Visible := AShow;
  paTournamentInfo.Visible := AShow;
  btTournamentLobby.Visible := AShow;

  tiTournamentInfoRefresh.Enabled := AShow;
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
end;

procedure TfrmChipUpMain.tiTournamentInfoRefreshTimer(Sender: TObject);
begin
  UpdateTournamentInfo;
end;

procedure TfrmChipUpMain.acAlwaysRunItTwiceExecute(Sender: TObject);
begin
  Settings.AlwaysRunItTwice := not Settings.AlwaysRunItTwice;
  acAlwaysRunItTwice.Checked := Settings.AlwaysRunItTwice;
  Settings.Save;
end;

procedure TfrmChipUpMain.acAnimationsEnabledExecute(Sender: TObject);
begin
  Settings.Animations := not Settings.Animations;
  acAnimationsEnabled.Checked := Settings.Animations;
  DXTimer.AnimationsEnabled := Settings.Animations;
  Settings.Save;
end;

procedure TfrmChipUpMain.acConfirmationOnFoldExecute(Sender: TObject);
begin
  Settings.FoldConfirmation := not Settings.FoldConfirmation;
  acConfirmationOnFold.Checked := Settings.FoldConfirmation;
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

procedure TfrmChipUpMain.acLaunchNewInstanceExecute(Sender: TObject);
begin
  TInstanceController.ReleaseInstance;
  ShellOpen(PChar(ParamStr(0)), nil, PChar(ParamStr(1)));
end;

procedure TfrmChipUpMain.acLogoutExecute(Sender: TObject);
begin
  if not ConfirmToCloseTablesLogout then
    Exit;

  ServerSocket.Logout;
end;

procedure TfrmChipUpMain.acOpenCashierExecute(Sender: TObject);
begin
  FormsContainer.RunForm(TfrmSubscriptions, self, [], FALSE);
end;

procedure TfrmChipUpMain.acOpenClubLobbyExecute(Sender: TObject);
var
  form: TForm;
begin
  if not dmMain.CheckAuthed then
    Exit;

  for form in FormsContainer.Items do
    if (form is TfrmClubLobby) and
       ((form as TfrmClubLobby).ClubId = FSelectedClub) then
    begin
      form.BringToFront;
      Exit;
    end;

  FormsContainer.RunForm(TfrmClubLobby, self, [FSelectedClub.Memory], TRUE);
end;

procedure TfrmChipUpMain.acResendVerificationMailExecute(Sender: TObject);
begin
  ServerSocket.ResendVerificationMail;
  ModalDialogs.ShowInformation(Format('Verification mail sent to %s. Please check your inbox.', [dmMain.SelfInfo.EMail]));
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
begin
  OpenClubTable(FSelectedClub, FSelectedGame);
end;

procedure TfrmChipUpMain.OpenClubTable(const AClubId, ATableId: TMongoId);
var
  game: TGameInfo;
  club: TClubInfo;
  table: TTable;
  member: TPB_ClubMember;
  err: String;
begin
  if not dmMain.CheckAuthed then
    Exit;

  err := '';
  if dmMain.SelfInfo.Clubs.GetAndLock(AClubId, club) then
  try
    if club.Games.TryGetValue(ATableId, game) then
    begin
      member := nil;
      if (club.IsPrivate) and
         (not club.GetMemberInfo(dmMain.SelfInfo.MongoId, member)) then
        Exit;

      if (Assigned(member)) and
         (member.Suspended) then
        err := 'You are currently suspended in this club, and cannot join any tables. Please contact club owner to resolve this issue.'
      else
        if Tables.GetAndLockTable(game.MongoId, ttLive, table) then
        begin
          table.Show;
          Tables.Unlock;
        end
        else
          Tables.AddLiveTable(game.MongoId, FALSE, TRUE);
    end;
  finally
    dmMain.SelfInfo.Clubs.Unlock;
  end;

  if err <> '' then
    ModalDialogs.ShowWarning(err);
end;

procedure TfrmChipUpMain.acShowJoinClubFormExecute(Sender: TObject);
begin
  if not dmMain.CheckAuthed then
    Exit;

  FormsContainer.RunForm(TfrmJoinClub, self, [], FALSE);
end;

procedure TfrmChipUpMain.UpdateFormCaption;
var
  cpt: String;
begin
  cpt := Format('ChipUP Poker - %s', [dmMain.SelfInfo.Displayname]);
  if not dmMain.SelfInfo.Authed then
    cpt := cpt + ' (account verification pending)';
  Caption := cpt;
end;

procedure TfrmChipUpMain.UpdateMenuActions;
begin
  acResendVerificationMail.Visible := not dmMain.SelfInfo.Authed;

  acSoundsOnOff.Checked := Settings.Sounds;
  acFoldChecks.Checked := Settings.FoldChecks;
  acAnimationsEnabled.Checked := Settings.Animations;
  acConfirmationOnFold.Checked := Settings.FoldConfirmation;
  acAlwaysRunItTwice.Checked := Settings.AlwaysRunItTwice;

  ActionManager.ActionBars[0].Items[3].Visible := Settings.DeveloperMode;
end;

procedure TfrmChipUpMain.RefreshAll;
begin
  UpdateFormCaption;
  RefreshGrids;
  UpdateMenuActions;
  UpdateTournamentActions;
  FillTournamentMenuList;
end;

procedure TfrmChipUpMain.RefreshGrids;
begin
  UpdateClublist;
  UpdateGamelist;
  UpdatePublicClublist;
  UpdateTournamentList;
end;

procedure TfrmChipUpMain.FillTournamentMenuList;
var
  tournament: TTournamentInfo;
  aci: TActionClientItem;
  C1: Integer;
  game: TPB_Game;
  table: TTable;
  added: Boolean;
begin
  C1 := 0;
  while C1 < ActionManager.ActionBars[0].Items[1].Items[1].Items.Count - 1 do
    if ActionManager.ActionBars[0].Items[1].Items[1].Items[C1].Tag > 0 then
      ActionManager.ActionBars[0].Items[1].Items[1].Items.Delete(C1)
    else
      Inc(C1);

  FRegisteredTournamentsMap.Clear;
  for C1 := 0 to dmMain.SelfInfo.RegisteredTournaments.Count - 1 do
  begin
    if Tournaments.GetAndLock(dmMain.SelfInfo.RegisteredTournaments[C1], tournament) then
    try
      added := FALSE;
      aci := ActionManager.ActionBars[0].Items[1].Items[1].Items.Insert(0) as TActionClientItem;
      aci.Tag := C1 + 1;
      for game in tournament.Games do
        if Tables.GetAndLockTable(game.MongoId, ttTournament, table) then
        try
          FRegisteredTournamentsMap.Add(C1 + 1, table.GameId);
          added := TRUE;
          Break;
        finally
          Tables.Unlock;
        end;

      if not added then
        FRegisteredTournamentsMap.Add(C1 + 1, tournament.Mongoid);

      aci.Action := TAction.Create(ActionManager);
      aci.Action.OnExecute := acTournamentItemOpenExecute;
      aci.Action.Tag := C1 + 1;
      (aci.Action as TAction).Caption := Format('%s (%s)', [tournament.Name, tournament.StateToStr])
    finally
      Tournaments.Unlock;
    end;
  end;
end;

procedure TfrmChipUpMain.UpdateTournamentActions;
var
  registered: Boolean;
  tournament: TTournamentInfo;
begin
  acTournamentLobby.Enabled := not FSelectedTournament.IsEmpty;

  if not FSelectedTournament.IsEmpty then
  begin
    registered := dmMain.SelfInfo.RegisteredTournaments.Contains(FSelectedTournament);
    if not Tournaments.GetAndLock(FSelectedTournament, tournament) then
    begin
      acTournamentRegister.Enabled := FALSE;
      acTournamentUnregister.Enabled := FALSE;
    end
    else
      try
        acTournamentRegister.Enabled := (not FSelectedTournament.IsEmpty) and (not registered) and (tournament.State = tnsOpen);
        acTournamentUnregister.Enabled := (not FSelectedTournament.IsEmpty) and (registered) and (tournament.State = tnsOpen);
      finally
        Tournaments.Unlock;
      end;
  end
  else
  begin
    acTournamentRegister.Enabled := FALSE;
    acTournamentUnregister.Enabled := FALSE;
  end;

  if acTournamentUnregister.Enabled then
  begin
    btTournamentRegister.Action := acTournamentUnregister;
    btTournamentRegister.Colors.HotText := $001111DF;
    btTournamentRegister.Colors.NormalText := $001111BF;
    btTournamentRegister.Colors.PressedText := $001111BF;
  end
  else
  begin
    btTournamentRegister.Action := acTournamentRegister;
    btTournamentRegister.Colors.HotText := $0000E600;
    btTournamentRegister.Colors.NormalText := $0000BF00;
    btTournamentRegister.Colors.PressedText := $0000BF00;
  end;

  UpdateTournamentInfo;
end;

procedure TfrmChipUpMain.UpdateTournamentInfo;
var
  tournament: TTournamentInfo;
  minutes: Integer;
  minutes_text, players_text: String;
begin
  if not Tournaments.GetAndLock(FSelectedTournament, tournament) then
  begin
    lbvTournamentName.Clear;
    lbvTournamentState.Clear;
    lbvTournamentGameType.Clear;
    lbvTournamentInfo.Clear;
    lbvTournamentDescription.Clear;
  end
  else
    try
      lbvTournamentName.Caption := tournament.Name;

      case tournament.State of
        tnsOpen: begin
          lbvTournamentState.Style.TextColor := styleTournamentOpen.TextColor;
          minutes := MinutesBetween(TTimeZone.Local.ToLocalTime(UnixToDateTime(tournament.StartTime)), Now);
          lbvTournamentState.Caption := Format('Starts in %s', [MinutesToString(minutes)]);
        end;
        tnsStarting, tnsInProgress, tnsOnBreak: begin
          lbvTournamentState.Style.TextColor := styleTournamentInProgress.TextColor;
          minutes := MinutesBetween(Now, TTimeZone.Local.ToLocalTime(UnixToDateTime(tournament.StartTime)));
          if tournament.State = tnsOnBreak then
            lbvTournamentState.Caption := Format('Running (%s, on break)', [MinutesToString(minutes)])
          else
            lbvTournamentState.Caption := Format('Running (%s)', [MinutesToString(minutes)]);
        end;
        tnsCancelled: begin
          lbvTournamentState.Style.TextColor := styleTournamentCancelled.TextColor;
          lbvTournamentState.Caption := tournament.StateToStr;
        end;
        tnsFinished: begin
          lbvTournamentState.Style.TextColor := styleTournamentFinished.TextColor;
          lbvTournamentState.Caption := tournament.StateToStr;
        end;
      end;

      lbvTournamentGameType.Caption := Format('%s, %d-max', [TGameInfo.GameTypeToStr(tournament.GameType, tournament.Limit, FALSE), tournament.SeatsPerTable]);

      if tournament.RegisteredPlayers = 1 then
        players_text := 'player'
      else
        players_text := 'players';

      if tournament.Timeperlevel = 1 then
        minutes_text := 'minute'
      else
        minutes_text := 'minutes';

      lbvTournamentInfo.Caption := Format('%d registered %s'#10'%d starting chips'#10'%d %s per level',
        [tournament.RegisteredPlayers, players_text, tournament.Startingchips, tournament.Timeperlevel, minutes_text]);

      lbvTournamentDescription.Caption := tournament.Description;
    finally
      Tournaments.Unlock;
    end;
end;

function TfrmChipUpMain.ConfirmToCloseTablesAppClose: Boolean;
begin
  result := TRUE;
  if Tables.SittingCount > 0 then
    result := ModalDialogs.ShowConfirmation('Closing the application will automatically leave all the tables you are currently playing on. Proceed?') = mrYes;
end;

function TfrmChipUpMain.ConfirmToCloseTablesLogout: Boolean;
begin
  result := TRUE;
  if Tables.SittingCount > 0 then
    result := ModalDialogs.ShowConfirmation('Upon logout you will automatically leave all the tables you are currently playing on. Proceed?') = mrYes;
end;

procedure TfrmChipUpMain.UpdateClublist;
var
  club: TClubInfo;
  status: String;
  rcount: Integer;
  c: TcxDataController;
  member: TPB_ClubMember;
begin
  c := gridPrivateClubsTable.DataController;
  c.BeginFullUpdate;
  try
    rcount := 0;
    dmMain.SelfInfo.Clubs.Lock;
    try
      for club in dmMain.SelfInfo.Clubs.Values do
        if club.IsPrivate then
        begin
          Inc(rcount);
          if rcount > c.RecordCount then
            c.SetRecordCount(rcount);

          c.SetValue(rcount - 1, gridHomeClubsMongoId.Index, club.MongoId.ToVariant);
          c.SetValue(rcount - 1, gridHomeClubsId.Index, club.Seq);
          c.SetValue(rcount - 1, gridHomeClubsName.Index, club.Name);

          if dmMain.SelfInfo.MongoId = club.Owner then
            status := 'Owner'
          else
            if club.GetMemberInfo(dmMain.SelfInfo.Mongoid, member) then
            begin
              if member.Suspended then
                status := 'Suspended'
              else
                if member.Manager then
                  status := 'Manager'
                else
                  status := 'Member';
            end
            else
              status := 'Unknown';
          c.SetValue(rcount - 1, gridHomeClubsStatus.Index, status);
        end;
    finally
      dmMain.SelfInfo.Clubs.Unlock;
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
    if dmMain.SelfInfo.Clubs.GetAndLock(FSelectedClub, club) then
    try
      for game in club.Games.Values do
      begin
        if game.State = gsClosed then
          Continue;

        Inc(rcount);
        if rcount > c.RecordCount then
          c.SetRecordCount(rcount);

        c.SetValue(rcount - 1, gridGamesId.Index, game.MongoId.ToVariant);
        c.SetValue(rcount - 1, gridGamesName.Index, game.Gamename);
        c.SetValue(rcount - 1, gridGamesType.Index, game.AsString(TRUE));
        c.SetValue(rcount - 1, gridGamesBlinds.Index, Format('%s/%s', [ChipsToStr(game.SmallBlind), ChipsToStr(game.BigBlind)]));
        c.SetValue(rcount - 1, gridGamesBuyinLimits.Index, Format('%s-%s', [ChipsToStr(game.BuyinMin), ChipsToStr(game.BuyinMax)]));
        c.SetValue(rcount - 1, gridGamesPlayers.Index, Format('%d/%d', [game.Sitting, game.Seats]));
        c.SetValue(rcount - 1, gridGamesStatus.Index, game.StateAsStr);
      end;
    finally
      dmMain.SelfInfo.Clubs.Unlock;
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
    dmMain.SelfInfo.Clubs.Lock;
    try
      for club in dmMain.SelfInfo.Clubs.Values do
        if not club.IsPrivate then
        begin
          Inc(rcount);
          if rcount > c.RecordCount then
            c.SetRecordCount(rcount);
          c.SetValue(rcount - 1, gridPublicClubsMongoId.Index, club.MongoId.ToVariant);
          c.SetValue(rcount - 1, gridPublicClubsName.Index, club.Name);
        end;
    finally
      dmMain.SelfInfo.Clubs.Unlock;
    end;
    c.SetRecordCount(rcount);
  finally
    c.EndFullUpdate;
  end;
  c.Refresh;
end;

procedure TfrmChipUpMain.UpdateTournamentList;
var
  c: TcxGridDataController;
  rcount: Integer;
  tournament_info: TPB_TournamentInfo;
  sel_index: Integer;
begin
  c := gridTournamentsTable.DataController;
  c.BeginFullUpdate;
  try
    sel_index := c.FocusedRecordIndex;
    rcount := 0;
    Tournaments.Lock;
    try
      for tournament_info in Tournaments.Values do
      begin
        Inc(rcount);
        if rcount > c.RecordCount then
          c.SetRecordCount(rcount);

        c.SetValue(rcount - 1, gridTournamentsId.Index, tournament_info.MongoId.ToVariant);
        c.SetValue(rcount - 1, gridTournamentsStartTime.Index, TTimeZone.Local.ToLocalTime(UnixToDateTime(tournament_info.StartTime)));
        c.SetValue(rcount - 1, gridTournamentsName.Index, Format('%s', [tournament_info.Name]));
        c.SetValue(rcount - 1, gridTournamentsPlayers.Index, tournament_info.RegisteredPlayers);
        c.SetValue(rcount - 1, gridTournamentsStatus.Index, (tournament_info as TTournamentInfo).StateToStr);
      end;
    finally
      Tournaments.Unlock;
    end;
    c.SetRecordCount(rcount);
    if (sel_index >= 0) and
       (sel_index < c.RecordCount) then
      c.FocusedRecordIndex := sel_index;
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
  AMessage.Result := 1;
  PostQuitMessage(0);
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

procedure TfrmChipUpMain.WMWindowPosChanging(var AMessage: TWMWindowPosChanging);
const
  SWP_STATECHANGED = $8000;
begin
  // save form state if form is about to be maximized
  if ((AMessage.WindowPos^.flags and (SWP_STATECHANGED or SWP_FRAMECHANGED)) <> 0) and
     (AMessage.WindowPos^.x < 0) and
     (AMessage.WindowPos^.y < 0) then
    Settings.SaveFormSettings(self);

  inherited;
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
  club_col_id: Integer;
  club: TClubInfo;
  club_mongoid: TMongoId;
begin
  recIndex := Sender.DataController.GetFocusedRecordIndex;
  if recIndex = -1 then
    FSelectedClub.Clear
  else
  begin
    if Sender = gridPublicClubsTable then
      club_col_id := gridPublicClubsMongoId.Index
    else
      club_col_id := gridHomeClubsMongoId.Index;

    club_mongoid := Sender.DataController.GetValue(recIndex, club_col_id);
    if dmMain.SelfInfo.Clubs.GetAndLock(club_mongoid, club) then
    begin
      FSelectedClub := club.MongoId;
      dmMain.SelfInfo.Clubs.Unlock;
      FSelectedGame.Clear;
      gridGamesTable.DataController.FocusedRecordIndex := -1;
    end
    else
      FSelectedClub.Clear;
  end;

  dmMain.SelfInfo.Clubs.Lock;
  try
    acOpenClubLobby.Enabled := (dmMain.SelfInfo.Clubs.TryGetValue(FSelectedClub, club)) and
                               ((club.IsPrivate) or
                                (club.Owner = dmMain.SelfInfo.MongoId));
  finally
    dmMain.SelfInfo.Clubs.Unlock;
  end;

  UpdateGamelist;
end;

procedure TfrmChipUpMain.gridTournamentsNameStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
var
  mongoid: TMongoId;
begin
  mongoid := ARecord.Values[gridTournamentsId.Index];
  if dmMain.SelfInfo.RegisteredTournaments.Contains(mongoid) then
    AStyle := styleTournamentNameRegistered
  else
    AStyle := styleTournamentName;
end;

procedure TfrmChipUpMain.gridTournamentsStatusStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
var
  mongoid: TMongoId;
  tournament: TTournamentInfo;
begin
  mongoid := ARecord.Values[gridTournamentsId.Index];
  if Tournaments.GetAndLock(mongoid, tournament) then
  try
    case tournament.State of
      tnsOpen: AStyle := styleTournamentOpen;
      tnsInProgress, tnsStarting, tnsOnBreak: AStyle := styleTournamentInProgress;
      tnsCancelled: AStyle := styleTournamentCancelled;
      tnsFinished: AStyle := styleTournamentFinished;
    end;
  finally
    Tournaments.Unlock;
  end;
end;

procedure TfrmChipUpMain.gridTournamentsTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  acTournamentLobby.Execute;
end;

procedure TfrmChipUpMain.gridTournamentsTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex: Integer;
  tournament: TTournamentInfo;
  tournament_id: TMongoId;
begin
  recIndex := Sender.DataController.GetFocusedRecordIndex;
  if recIndex = -1 then
    FSelectedTournament.Clear
  else
  begin
    tournament_id := Sender.DataController.GetValue(recIndex, gridTournamentsId.Index);
    if Tournaments.GetAndLock(tournament_id, tournament) then
    try
      FSelectedTournament := tournament_id;
    finally
      Tournaments.Unlock;
    end;
  end;

  UpdateTournamentActions;
end;

procedure TfrmChipUpMain.gridGamesTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  acShowGameTableForm.Execute;
end;

procedure TfrmChipUpMain.gridGamesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex: Integer;
  game_id: TMongoId;
  game: TGameInfo;
  club: TClubInfo;
begin
  recIndex := gridGamesTable.DataController.GetFocusedRecordIndex;
  dmMain.SelfInfo.Clubs.Lock;
  try
    if (recIndex = -1) or
       (not dmMain.SelfInfo.Clubs.TryGetValue(FSelectedClub, club)) then
      FSelectedGame.Clear
    else
    begin
      game_id := gridGamesTable.DataController.GetValue(recIndex, gridGamesId.Index);
      if not club.Games.TryGetValue(game_id, game) then
        FSelectedGame.Clear
      else
        FSelectedGame := game_id;
    end;
  finally
    dmMain.SelfInfo.Clubs.Unlock;
  end;

  acShowGameTableForm.Enabled := not FSelectedGame.IsEmpty;
end;

procedure TfrmChipUpMain.imgCashierMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    if PtInCircle(X, Y, imgCashier.Width div 2, imgCashier.Height div 2, 42) then
      LoadImageFromResource(imgCashier, RESOURCE_CASHIER_PRESSED);
  end;
end;

procedure TfrmChipUpMain.imgCashierMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    if PtInCircle(X, Y, imgCashier.Width div 2, imgCashier.Height div 2, 42) then
      acOpenCashier.Execute;
    LoadImageFromResource(imgCashier, RESOURCE_CASHIER_NORMAL);
  end;
end;

procedure TfrmChipUpMain.LoginStatus(const AValue: TLoginStatus);
begin
  case AValue of
    lsLoggedIn: begin
      FSelectedClub.Clear;
      FSelectedGame.Clear;
      FSelectedTournament.Clear;
      RefreshAll;
      Show;
      dmMain.ProcessReconnectedTables;
      dmMain.ProcessOpenedTournamentLobbies;
      RefreshAll;
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
      rsLoggedIn: RefreshAll;
    else
      FormsContainer.Items.Extract(ASender as TForm);
      DoLogout;
    end;

  if ASender is TfrmUpdater then
    if (ASender as TfrmUpdater).RequiresReboot then
      PostMessage(frmChipUpMain.Handle, WM_QUIT, 0, 0)
    else
      DoLogout;

  EnableWindow(Handle, TRUE);
end;

procedure TfrmChipUpMain.OpenTournamentLobby(const AMongoId: TMongoId);
var
  form: TForm;
begin
  if not dmMain.CheckAuthed then
    Exit;

  for form in FormsContainer.Items do
    if (form is TfrmTournamentLobby) and
       ((form as TfrmTournamentLobby).TournamentId = AMongoId) then
    begin
      form.SetFocus;
      Exit;
    end;

  FormsContainer.RunForm(TfrmTournamentLobby, self, [AMongoId.Memory], TRUE);
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
  if not TTypes.TryCast<TPB_ClubCommandReply>(AObject, pbreply) then
    Exit;

  case pbreply.Status of
    csSuccess: begin
      dmMain.ProcessClubObject(pbreply.Club, pbreply.Games, AMethodId);
      RefreshAll;
    end;
  end;
end;

procedure TfrmChipUpMain.CSRClubCommand(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_ClubCommandReply;
begin
  if not TTypes.TryCast<TPB_ClubCommandReply>(AObject, pbreply) then
    Exit;

  case pbreply.Status of
    csSuccess: begin
      dmMain.ProcessClubObject(pbreply.Club, pbreply.Games, AMethodId);
      RefreshAll;
    end;
  end;
end;

procedure TfrmChipUpMain.CSREClubOperation(const AMethodId: Integer; const AObject: TObject);
var
  pbclub: TPB_Club;
begin
  if not TTypes.TryCast<TPB_Club>(AObject, pbclub) then
    Exit;

  dmMain.ProcessClubObject(pbclub, nil, AMethodId);
  RefreshAll;
end;

procedure TfrmChipUpMain.CSRGetUsers(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_GetUserParams;
  user: TPB_User;
begin
  if not TTypes.TryCast<TPB_GetUserParams>(AObject, pbreply) then
    Exit;

  for user in pbreply.Users do
    Players.AddPlayer(user);
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
  DoLogout;
end;

procedure TfrmChipUpMain.CSETournamentList(const AMethodId: Integer; const AObject: TObject);
var
  proto: TPB_TournamentList;
begin
  if not TTypes.TryCast<TPB_TournamentList>(AObject, proto) then
    Exit;

  Tournaments.Assign(proto);
  UpdateTournamentList;
end;

procedure TfrmChipUpMain.CSETournamentPlayerFinished(const AMethodId: Integer; const AObject: TObject);
var
  proto: TPB_TournamentPlayerFinished;
  tournament: TTournamentInfo;
  place_str, msg, nsuffix, suffix: String;
  table: TTable;
begin
  if not TTypes.TryCast<TPB_TournamentPlayerFinished>(AObject, proto) then
    Exit;

  if proto.PlayerId <> dmMain.SelfInfo.MongoId then
    Exit;

  msg := '';
  if Tournaments.GetAndLock(proto.TournamentId, tournament) then
  try
    suffix := '!';
    nsuffix := '';
    case proto.Place + 1 of
      1: place_str := 'the first';
      2: place_str := 'the second';
      3: place_str := 'the third';
    else
      nsuffix := 'th';
      if proto.Place + 1 > 20 then
        case (proto.Place + 1) mod 10 of
          1: nsuffix := 'st';
          2: nsuffix := 'nd';
          3: nsuffix := 'rd';
        end;
      place_str := Format('%d%s', [proto.Place + 1, nsuffix]);
      suffix := '.';
    end;

    msg := Format('You have finished the tournament at %s place%s', [place_str, suffix]);
    if (proto.has_Prize) and
       (proto.Prize.Name <> '') then
      msg := msg + #10 + Format('You have won the following prize: %s!', [proto.Prize.Name]) + #10 +
         'We will contact you soon on your E-Mail address about more details for claiming your prize.';
  finally
    Tournaments.Unlock;
  end;

  if msg <> '' then
    TfrmTournamentFinishDialog.Run(self, msg);

  if Tables.GetAndLockTable(proto.TableId, ttTournament, table) then
  try
    Tables.Remove(table.InternalId);
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmChipUpMain.CSETournamentPlayerTransfer(const AMethodId: Integer; const AObject: TObject);
var
  pbtransfer: TPB_TournamentPlayerTransfer;
  table: TTable;
begin
  if not TTypes.TryCast<TPB_TournamentPlayerTransfer>(AObject, pbtransfer) then
    Exit;

  if pbtransfer.UserId = dmMain.SelfInfo.MongoId then
  begin
    if not Tables.GetAndLockTable(pbtransfer.GameSource, ttTournament, table) then
      Tables.AddTournamentTable(pbtransfer.GameDestination, TRUE, FALSE)
    else
      try
        if not Tables.ContainsMongoId(pbtransfer.GameDestination) then
          table.Transfer(pbtransfer)
        else
          Tables.Remove(table.InternalId);
        table.UpdateObjects;
      finally
        Tables.Unlock;
      end;

    if Tables.GetAndLockTable(pbtransfer.GameDestination, ttTournament, table) then
    try
      table.UpdateObjects;
      table.Show;
    finally
      Tables.Unlock;
    end;
  end;
end;

procedure TfrmChipUpMain.CSEUserChange(const AMethodId: Integer; const AObject: TObject);
var
  pbusers: TPB_UserChangeParams;
  pbuser: TPB_User;
begin
  if not TTypes.TryCast<TPB_UserChangeParams>(AObject, pbusers) then
    Exit;

  for pbuser in pbusers.Users do
    Players.AddPlayer(pbuser);
end;

procedure TfrmChipUpMain.CSRLogout(const AMethodId: Integer; const AObject: TObject);
begin
  DoLogout;
end;

procedure TfrmChipUpMain.CSEAccountConfirmed(const AMethodId: Integer; const AObject: TObject);
var
  pbuser: TPB_User;
begin
  if not TTypes.TryCast<TPB_User>(AObject, pbuser) then
    Exit;

  dmMain.SelfInfo.Clear;
  dmMain.SelfInfo.MergeFrom(pbuser);

  dmMain.UpdateSelfInfoInPlayers;

  RefreshAll;
end;

procedure TfrmChipUpMain.CSEChatEvent(const AMethodId: Integer; const AObject: TObject);
var
  pbchatevent: TPB_ChatEvent;
begin
  if not TTypes.TryCast<TPB_ChatEvent>(AObject, pbchatevent) then
    Exit;

  if pbchatevent.Event = ceServerMessage then
    TfrmSystemTrayPopup.ShowPopup(pbchatevent.Msg.Msg);
end;

procedure TfrmChipUpMain.CSEClubDeleted(const AMethodId: Integer; const AObject: TObject);
var
  pbclub: TPB_Club;
begin
  if not TTypes.TryCast<TPB_Club>(AObject, pbclub) then
    Exit;

  Tables.CloseTablesForClub(pbclub.MongoId);
  dmMain.SelfInfo.Clubs.Lock;
  try
    dmMain.SelfInfo.Clubs.Remove(pbclub.MongoId);
  finally
    dmMain.SelfInfo.Clubs.Unlock;
  end;

  Tables.Lock;
  try
    Tables.UpdateClubObject(pbclub.MongoId);
  finally
    Tables.Unlock;
  end;

  RefreshAll;
end;

procedure TfrmChipUpMain.CSEPlayerTableStatus(const AMethodId: Integer; const AObject: TObject);
var
  proto: TPB_PlayerClubStatus;
begin
  if not TTypes.TryCast<TPB_PlayerClubStatus>(AObject, proto) then
    Exit;

  dmMain.SelfInfo.TableStatuses.AddOrSetValue(proto.Tableid, TPB_PlayerClubStatus.Create(proto, TRUE));
end;

procedure TfrmChipUpMain.CSREGameDelete(const AMethodId: Integer; const AObject: TObject);
var
  pbgame: TPB_Game;
  iid: Integer;
  table: TTable;
  club: TClubInfo;
begin
  if not TTypes.TryCast<TPB_Game>(AObject, pbgame) then
    Exit;

  iid := -1;
  if Tables.GetAndLockTable(pbgame.MongoId, ttLive, table) then
  try
    iid := table.InternalId;
  finally
    Tables.Unlock;
  end;
  if iid <> -1 then
    Tables.Remove(iid);

  if dmMain.SelfInfo.Clubs.GetAndLock(pbgame.ClubMongoid, club) then
  try
    club.Games.AddGame(pbgame);
  finally
    dmMain.SelfInfo.Clubs.Unlock;
  end;

  RefreshAll;
end;

procedure TfrmChipUpMain.CSREGameOperation(const AMethodId: Integer; const AObject: TObject);
var
  pbgame: TPB_Game;
  club: TClubInfo;
begin
  if not TTypes.TryCast<TPB_Game>(AObject, pbgame) then
    Exit;

  if dmMain.SelfInfo.Clubs.GetAndLock(pbgame.ClubMongoid, club) then
  try
    club.Games.AddGame(pbgame);
  finally
    dmMain.SelfInfo.Clubs.Unlock;
  end;

  if AMethodId = Integer(srCreateGameOk) then
    Tables.AddLiveTable(pbgame.MongoId, FALSE, TRUE);

  Tables.Lock;
  try
    Tables.UpdateGameObject(pbgame.MongoId);
  finally
    Tables.Unlock;
  end;

  RefreshAll;
end;

procedure TfrmChipUpMain.CSRTableStatus(const AMethodId: Integer; const AObject: TObject);
var
  pbtstatus: TPB_TableStatus;
  club: TClubInfo;
  game: TGameInfo;
begin
  if not TTypes.TryCast<TPB_TableStatus>(AObject, pbtstatus) then
    Exit;

  if dmMain.SelfInfo.Clubs.GetAndLockByGame(pbtstatus.TableMongoId, club, game) then
  try
    game.Sitting := pbtstatus.Seats.Count;
  finally
    dmMain.SelfInfo.Clubs.Unlock;
  end;

  UpdateGamelist;
end;

procedure TfrmChipUpMain.CSRTournamentReply(const AMethodId: Integer; const AObject: TObject);
var
  proto: TPB_TournamentCommandParams;
begin
  if not TTypes.TryCast<TPB_TournamentCommandParams>(AObject, proto) then
    Exit;

  case proto.ReplyStatus of
    tceRegisterOk, tceAlreadyRegistered: begin
      if not dmMain.SelfInfo.RegisteredTournaments.Contains(proto.MongoId) then
        dmMain.SelfInfo.RegisteredTournaments.Add(proto.MongoId);
      UpdateTournamentList;
      UpdateTournamentActions;
    end;
    tceRegisterLimitReached: ModalDialogs.ShowWarning('This tournament is already filled');
    tceRegisterFailed: ModalDialogs.ShowWarning('Tournament registration failed');
    tceUnregisterOk: begin
      dmMain.SelfInfo.RegisteredTournaments.Remove(proto.MongoId);
      UpdateTournamentList;
      UpdateTournamentActions;
    end;
    tceNotOpen: ;
  end;
end;

procedure TfrmChipUpMain.CSRTableStats(const AMethodId: Integer; const AObject: TObject);
var
  pb: TPB_TableStatsReplies;
  tablepb: TPB_TableStatsReply;
  tablestats: TPB_TableStatsReply;
  player: TPB_User;
  playerinfo: TPlayerInfo;
  club: TClubInfo;
  query_users: TArray<TMongoId>;
  empty_avatar_id: TBytes;
  clubstats: TPB_ClubStatsReply;
begin
  if not TTypes.TryCast<TPB_TableStatsReplies>(AObject, pb) then
    Exit;

  SetLength(empty_avatar_id, 0);
  SetLength(query_users, 0);
  for player in pb.Players do
    if Players.TryGetValue(player.MongoId, playerinfo) then
      playerinfo.Displayname := player.Displayname
    else
    begin
      SetLength(query_users, Length(query_users) + 1);
      query_users[Length(query_users) - 1] := player.MongoId;
      Players.AddPlayer(player.MongoId, 'Retrieving...', '', empty_avatar_id);
    end;

  if Length(query_users) <> 0 then
    ServerSocket.GetUserInfos(query_users);

  for clubstats in pb.ClubStats do
  begin
    if dmMain.SelfInfo.Clubs.GetAndLock(clubstats.Clubid, club) then
    try
      club.UpdateFromClubStats(clubstats);
    finally
      dmMain.SelfInfo.Clubs.Unlock;
    end;
  end;

  for tablepb in pb.Reply do
    if TablesStats.TryGetValue(tablepb.Gameid, tablestats) then
    begin
      tablestats.Clear;
      tablestats.MergeFrom(tablepb)
    end
    else
    begin
      tablestats := TPB_TableStatsReply.Create(tablepb);
      TablesStats.Add(tablestats.GameId, tablestats);
    end;
end;

procedure TfrmChipUpMain.CSRHandHistoryMsg(const AMethodId: Integer; const AObject: TObject);
var
  pb: TPB_HandHistoryReply;
begin
  if not TTypes.TryCast<TPB_HandHistoryReply>(AObject, pb) then
    Exit;

  HandHistory.Add(pb);
end;

procedure TfrmChipUpMain.acTournamentItemOpenExecute(Sender: TObject);
var
  action: TAction;
  mongoid: TMongoId;
  tournament: TTournamentInfo;
  game: TPB_Game;
  table: TTable;
begin
  if not (Sender is TAction) then
    Exit;

  action := Sender as TAction;
  if FRegisteredTournamentsMap.TryGetValue(action.Tag, mongoid) then
  begin
    game := nil;
    if (Tournaments.GetAndLockByGame(mongoid, tournament, game)) or
       (Tournaments.GetAndLock(mongoid, tournament)) then
    try
      case tournament.State of
        tnsOpen: ;
        tnsInProgress: begin
          if Assigned(game) then
          begin
            if Tables.GetAndLockTable(game.MongoId, ttTournament, table) then
            try
              table.Show;
            finally
              Tables.Unlock;
            end;
          end
          else
            OpenTournamentLobby(tournament.MongoId);
        end;
      end;
    finally
      Tournaments.Unlock;
    end;
  end;
end;

procedure TfrmChipUpMain.acTournamentLobbyExecute(Sender: TObject);
begin
  OpenTournamentLobby(FSelectedTournament);
end;

procedure TfrmChipUpMain.CSRTournamentDetails(const AMethodId: Integer; const AObject: TObject);
var
  proto: TPB_TournamentInfo;
  member: TPB_TournamentMember;
  self_registered: Boolean;
  tournament: TTournamentInfo;
  pbgame: TPB_Game;
  table: TTable;
begin
  if not TTypes.TryCast<TPB_TournamentInfo>(AObject, proto) then
    Exit;

  Tournaments.Add(proto);

  if Tournaments.GetAndLock(proto.MongoId, tournament) then
  try
    for pbgame in tournament.Games do
      if Tables.GetAndLockTable(pbgame.MongoId, ttTournament, table) then
      try
        table.UpdateObjects;
        if Assigned(table.Form) then
          (table.Form as TfrmTable).ConfigureGUI;
      finally
        Tables.Unlock;
      end;
  finally
    Tournaments.Unlock;
  end;

  self_registered := FALSE;
  for member in proto.Players do
    if member.MongoId = dmMain.SelfInfo.MongoId then
    begin
      self_registered := TRUE;
      Break;
    end;

  if not self_registered then
    dmMain.SelfInfo.RegisteredTournaments.Remove(proto.MongoId)
  else
    if not dmMain.SelfInfo.RegisteredTournaments.Contains(proto.MongoId) then
      dmMain.SelfInfo.RegisteredTournaments.Add(proto.MongoId);

  UpdateTournamentList;
end;

procedure TfrmChipUpMain.CSRTournamentOpenTable(const AMethodId: Integer; const AObject: TObject);
var
  proto: TPB_TournamentTableStart;
  tournament: TTournamentInfo;
  table: TTable;
begin
  if not TTypes.TryCast<TPB_TournamentTableStart>(AObject, proto) then
    Exit;

  if Tournaments.GetAndLock(proto.Game.Tournament, tournament) then
  try
    tournament.AddGame(proto.Game);
  finally
    Tournaments.Unlock;
  end;

  Tables.AddTournamentTable(proto.Game.MongoId, TRUE, FALSE);
  if Tables.GetAndLockTable(proto.Game.MongoId, ttTournament, table) then
  try
    table.SetTableStatus(proto.TableStatus, TRUE);
    table.Show;
  finally
    Tables.Unlock;
  end;

  RefreshAll;
end;

procedure TfrmChipUpMain.acTournamentRegisterExecute(Sender: TObject);
begin
  ServerSocket.TournamentRegister(FSelectedTournament);
  acTournamentRegister.Enabled := FALSE;
end;

procedure TfrmChipUpMain.acTournamentUnregisterExecute(Sender: TObject);
begin
  ServerSocket.TournamentUnregister(FSelectedTournament);
  acTournamentUnregister.Enabled := FALSE;
end;

procedure TfrmChipUpMain.acTournamentsOpenAllExecute(Sender: TObject);
var
  table: TTable;
begin
  Tables.Lock;
  try
    for table in Tables.Values do
      if table.TableType = ttTournament then
        table.Show;
  finally
    Tables.Unlock;
  end;
end;

{$IFDEF ENABLE_EXCEPTION_LOGGING}
procedure TfrmChipUpMain.ApplicationException(Sender: TObject; E: Exception);
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    JclLastExceptStackListToStrings(sl, TRUE, TRUE, TRUE, FALSE);
    sl.SaveToFile('C:\exception.txt');
    SoftException('Hard Exception', sl.Text);
    MessageDlg('Exception happened. C:\exception.txt created', mtError, [mbOK], 0);
  finally
    sl.Free;
  end;
end;
{$ENDIF}


{$IFDEF ENABLE_EXCEPTION_LOGGING}
initialization
  // Enable raw mode (default mode uses stack frames which aren't always generated by the compiler)
  Include(JclStackTrackingOptions, stRawMode);
  // Disable stack tracking in dynamically loaded modules (it makes stack tracking code a bit faster)
  Include(JclStackTrackingOptions, stStaticModuleList);
  // Initialize Exception tracking
  JclStartExceptionTracking;

finalization
  JclStopExceptionTracking;
{$ENDIF}

end.
