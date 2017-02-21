unit Poker.DataModule;

interface

{$I defines.inc}

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Generics.Collections,
  Poker.Players.Player, Vcl.Forms, dxSkinsForm, Poker.Clubs.Club,
  Poker.HardcodedSettings, cxHint, Poker.Protobufs.Objects.TableStatus,
  Poker.Protobufs.Objects.UpdateFileInfo, cxGraphics, Poker.Protobufs.Objects.LoginReply,
  dxSkinsCore, ChipUpPokerDarkSkin, dxScreenTip, dxCustomHint, cxLookAndFeels,
  Vcl.ImgList, Vcl.Controls, Poker.Protobufs.Objects.Club,
  Poker.Protobufs.Objects.Game, Vcl.ExtCtrls, cxStyles, cxClasses,
  System.ImageList;

type
  TdmMain = class(TDataModule)
    il20px: TcxImageList;
    SkinController: TdxSkinController;
    HintController: TcxHintStyleController;
    GridStyles: TcxStyleRepository;
    styleInactiveCell: TcxStyle;
    tiSkinControllerRefresh: TTimer;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure SkinControllerSkinForm(Sender: TObject; AForm: TCustomForm; var ASkinName: string; var UseSkin: Boolean);
    procedure tiSkinControllerRefreshTimer(Sender: TObject);
  private
    FSelfInfo: TPlayerInfo;
    FUpdateFiles: TObjectList<TPB_UpdateFileInfo>;
    FUpdaterBatchFile: String;
    FUpdaterInstallerFile: String;
    FReconnectedTables: TObjectList<TPB_TableStatus>;

    procedure LoadFonts;
    function GetUpdateFileObject(const AUpdateFilePath: String): TPB_UpdateFileInfo;
  public
    procedure ProcessLoginReply(const ALoginReply: TPB_LoginReply);
    procedure ProcessReconnectedTables;
    procedure ProcessOpenedTournamentLobbies;
    procedure ProcessClubObject(const AClub: TPB_Club; const AGames: TList<TPB_Game>; const AMethodId: Integer);

    function CheckAuthed: Boolean;
    function IsLoggedIn: Boolean;

    procedure OpenTACLink;
    procedure OpenSiteLink;
    procedure UpdateSelfInfoInPlayers;
    procedure GetUpdateFilesList(const AFiles: TList<TPB_UpdateFileInfo>);
    procedure StoreUpdateFiles(const AFiles: TList<TPB_UpdateFileInfo>);
    procedure SetUpdaterBatchFile(const AFile: String);
    procedure SetUpdaterInstaller(const AFile: String);
    procedure RefreshSkinControllerDelayed;
    procedure ServerSocketConnect;

    property SelfInfo: TPlayerInfo read FSelfInfo;
    property UpdateFiles: TObjectList<TPB_UpdateFileInfo> read FUpdateFiles;
  end;

var
  dmMain: TdmMain;
  SelfPath: String;
  UserDataPath: String;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  SynSQLite3Static,
  Winapi.ShlObj, Vcl.Dialogs, Poker.Settings, Poker.Tables.Resources, Poker.Common.FormsContainer, Poker.Server.Socket,
  Poker.Common.Misc, Poker.DirectX.Core, Poker.DirectX.Timer, Poker.Database.Core, Poker.Common.Encryption, Poker.Server.MessageContainer,
  Poker.Avatars.AvatarList, Poker.Server.Settings, Poker.Sounds, Poker.Tables.TableList, Poker.Tables.StatsList, Poker.Forms.Table,
  Poker.Tables.Status, Poker.Forms.SystemTrayPopup, Poker.HandHistory.Core, Poker.Seats.Seat, Poker.Forms.About,
  Poker.Players.PlayerList, Poker.Tables.Table, Poker.Tables.Renderer, Poker.Forms.Login, Poker.Protobufs.Objects.ClubMember,
  Poker.Protobufs.Enum.ServerCodes, Poker.Types, Poker.Tournaments, Poker.Games.Game, Poker.Tournaments.Info,
  Poker.Forms.TournamentLobby, Poker.Common.ModalDialogs;


procedure TdmMain.DataModuleCreate(Sender: TObject);
begin
  SelfPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  UserDataPath := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetSpecialFolderPath(CSIDL_LOCAL_APPDATA)) + Settings.Hardcoded.PROJECT_CAPTION);
  ForceDirectories(UserDataPath);

  {$IFDEF DEBUG}
  TfrmDebug.Initialize;
  DebugLn(Format('Revision: %s', [Settings.Hardcoded.REVISION]), ditApplication);
  {$ENDIF}

  LoadFonts;

  try
    TDatabase.Initialize(UserDataPath + TSettings.Hardcoded.DATABASE_FILENAME, Settings.Hardcoded.DATABASE_PASSWORD);
  except
    on E: Exception do
    begin
      TDatabase.Deinitialize;
      DeleteFile(UserDataPath + TSettings.Hardcoded.DATABASE_FILENAME);
      TDatabase.Initialize(UserDataPath + TSettings.Hardcoded.DATABASE_FILENAME, Settings.Hardcoded.DATABASE_PASSWORD);
    end;
  end;

  TSettings.Initialize;
  try
    Settings.Load(Database.GetSettingsBlob);
  except
    on E: Exception do
    begin
      TSettings.Deinitialize;
      TSettings.Initialize;
      Database.SaveSettings(Settings.AsBlob);
    end;
  end;

  TServerSocket.Initialize;
  TAvatarList.Initialize;
  TDXCore.Initialize;
  TDXTimer.Initialize;
  DXTimer.AnimationsEnabled := Settings.Animations;
  TSounds.Initialize(Application.Handle);
  TServerSettings.Initialize;
  TMessageContainer.Initialize;
  TFormsContainer.Initialize;
  TTablesStatsList.Initialize;
  THandHistory.Initialize;
  TTournamentList.Initialize;
  TModalDialogs.Initialize;

  FSelfInfo := TPlayerInfo.Create;

  TPlayerList.Initialize;
  TTableList.Initialize;

  FUpdateFiles := TObjectList<TPB_UpdateFileInfo>.Create;
  FReconnectedTables := TObjectList<TPB_TableStatus>.Create;
end;

procedure TdmMain.DataModuleDestroy(Sender: TObject);
begin
  // free/deinit objects
  FreeAndNil(FUpdateFiles);
  FreeAndNil(FReconnectedTables);

  TModalDialogs.Deinitialize;
  TFormsContainer.Deinitialize;
  TServerSocket.Deinitialize;
  TMessageContainer.Deinitialize;
  TfrmSystemTrayPopup.DestroyIfExists;
  TTableList.Deinitialize;
  TPlayerList.Deinitialize;
  FSelfInfo.Free;
  THandHistory.Deinitialize;
  TTablesStatsList.Deinitialize;
  TTournamentList.Deinitialize;
  TSounds.Deinitialize;
  TServerSettings.Deinitialize;
  TTableResources.Deinitialize;
  TDXTimer.Deinitialize;
  TDXCore.Deinitialize;
  TAvatarList.Deinitialize;
  Database.SaveSettings(Settings.AsBlob);
  TDatabase.Deinitialize;
  TSettings.Deinitialize;

  {$IFDEF DEBUG}
  TfrmDebug.Deinitialize;
  {$ENDIF}

  if (FUpdaterInstallerFile <> '') and
     (FileExists(FUpdaterInstallerFile)) then
    ShellOpen(PChar(FUpdaterInstallerFile), nil, '/verysilent /surpressmsgboxes /closeapplications');

  if (FUpdaterBatchFile <> '') and
     (FileExists(FUpdaterBatchFile)) then
    ShellOpen(PChar(FUpdaterBatchFile), nil, nil, nil, SW_HIDE);
end;

function TdmMain.CheckAuthed: Boolean;
begin
  result := FSelfInfo.Authed;
  if not result then
    ModalDialogs.ShowWarning('You cannot do this action until you verify your account. Please check your inbox for verification E-Mail.');
end;

procedure TdmMain.OpenSiteLink;
begin
  ShellOpen(PChar(Settings.Hardcoded.SERVER_LIST[Settings.ServerIndex].URL));
end;

procedure TdmMain.OpenTACLink;
begin
  ShellOpen(PChar(Settings.Hardcoded.SERVER_LIST[Settings.ServerIndex].URL + Settings.Hardcoded.URL.TERMS_AND_CONDITIONS));
end;

procedure TdmMain.ServerSocketConnect;
var
  server_index: Integer;
begin
  if (Settings.ServerIndex > 0) and
     (Settings.DeveloperMode) then
    server_index := Settings.ServerIndex
  else
    server_index := 0;

  ServerSocket.Connect(Settings.Hardcoded.SERVER_LIST[server_index].Address,
    Settings.Hardcoded.SERVER_LIST[server_index].Port,
    Settings.Hardcoded.SERVER_LIST[server_index].SSLEnable,
    Settings.Hardcoded.SERVER_LIST[server_index].SSLCertificate);
end;

procedure TdmMain.SetUpdaterBatchFile(const AFile: String);
begin
  FUpdaterBatchFile := AFile;
end;

procedure TdmMain.SetUpdaterInstaller(const AFile: String);
begin
  FUpdaterInstallerFile := AFile;
end;

procedure TdmMain.SkinControllerSkinForm(Sender: TObject; AForm: TCustomForm; var ASkinName: string; var UseSkin: Boolean);
begin
  UseSkin := not (AForm is TfrmAbout);
end;

procedure TdmMain.StoreUpdateFiles(const AFiles: TList<TPB_UpdateFileInfo>);
var
  ufi: TPB_UpdateFileInfo;
begin
  FUpdateFiles.Clear;
  for ufi in AFiles do
    FUpdateFiles.Add(TPB_UpdateFileInfo.Create(ufi, TRUE));
end;

procedure TdmMain.tiSkinControllerRefreshTimer(Sender: TObject);
begin
  SkinController.Refresh;
  tiSkinControllerRefresh.Enabled := FALSE;
end;

procedure TdmMain.UpdateSelfInfoInPlayers;
begin
  Players.AddPlayer(FSelfInfo.MongoId, FSelfInfo.Displayname, FSelfInfo.EMail, FSelfInfo.Avatar);
end;

procedure TdmMain.ProcessLoginReply(const ALoginReply: TPB_LoginReply);
var
  mstream: TMemoryStream;
  C1: Integer;
  pbts: TPB_TableStatus;
begin
  Players.LoadFromUsersProtobuf(ALoginReply.Users);
  Tournaments.Assign(ALoginReply.TournamentInfos);
  FSelfInfo.LoadFromLoginReply(ALoginReply);
  UpdateSelfInfoInPlayers;
  Avatars.Add(FSelfInfo.Avatar, nil);

  FSelfInfo.RegisteredTournaments.Clear;
  FSelfInfo.RegisteredTournaments.AddRange(ALoginReply.RegisteredTournaments);

  FReconnectedTables.Clear;
  mstream := TMemoryStream.Create;
  try
    if Assigned(ALoginReply.ReconnectTables) then
      for C1 := 0 to ALoginReply.ReconnectTables.Count - 1 do
      begin
        mstream.Clear;
        ALoginReply.ReconnectTables[C1].ProtobufOutput.SaveToStream(mstream);
        pbts := TPB_TableStatus.Create(mstream);
        FReconnectedTables.Add(pbts);
      end;
  finally
    mstream.Free;
  end;
end;

procedure TdmMain.ProcessOpenedTournamentLobbies;
var
  form: TForm;
begin
  for form in FormsContainer.Items do
    if form is TfrmTournamentLobby then
      ServerSocket.OpenTournamentLobby((form as TfrmTournamentLobby).TournamentId);
end;

procedure TdmMain.ProcessReconnectedTables;
var
  table: TTable;
  tstatus: TPB_TableStatus;
  exists: Boolean;
  to_remove: TList<TMongoId>;
  to_remove_iid: TList<Integer>;
  mongoid: TMongoId;
  C1: Integer;
begin
  // first, close all tables that dont exist in reconnected tables array
  to_remove := TList<TMongoId>.Create;
  try
    Tables.Lock;
    try
      for table in Tables.Values do
      begin
        exists := FALSE;
        for tstatus in FReconnectedTables do
          if tstatus.TableMongoId = table.GameId then
          begin
            exists := TRUE;
            Break;
          end;

        if not exists then
          to_remove.Add(table.GameId);
      end;
    finally
      Tables.Unlock;
    end;

    to_remove_iid := TList<Integer>.Create;
    try
      for mongoid in to_remove do
        if (Tables.GetAndLockTable(mongoid, ttLive, table)) or
           (Tables.GetAndLockTable(mongoid, ttTournament, table)) then
        try
          to_remove_iid.Add(table.InternalId);
        finally
          Tables.Unlock;
        end;

      for C1 := 0 to to_remove_iid.Count - 1 do
        Tables.Remove(to_remove_iid[C1]);
    finally
      to_remove_iid.Free;
    end;
  finally
    to_remove.Free;
  end;

  // restore reconnected table states
  for tstatus in FReconnectedTables do
  begin
    case tstatus.TableType of
      ttLive: Tables.AddLiveTable(tstatus.TableMongoId, TRUE, FALSE);
      ttTournament: Tables.AddTournamentTable(tstatus.TableMongoId, TRUE, FALSE);
    end;

    if Tables.GetAndLockTable(tstatus.TableMongoId, tstatus.TableType, table) then
    try
      table.SetTableStatus(tstatus, FALSE);
      table.Show;
    finally
      Tables.Unlock;
    end;
  end;
end;

procedure TdmMain.RefreshSkinControllerDelayed;
begin
  tiSkinControllerRefresh.Enabled := TRUE;
end;

procedure TdmMain.LoadFonts;
const
  FONTLIST: array[0..0] of String = ('SintonyBold');
var
  nbFontAdded: DWORD;
  rs: TResourceStream;
  font: String;
begin
  for font in FONTLIST do
  begin
    rs := TResourceStream.Create(HInstance, font, RT_RCDATA);
    try
      AddFontMemResourceEx(rs.Memory, rs.Size, nil, @nbFontAdded);
    finally
      rs.Free;
    end;
  end;
end;

function TdmMain.GetUpdateFileObject(const AUpdateFilePath: String): TPB_UpdateFileInfo;
var
  fullpath: String;
  hash: RawByteString;
  hash_bytes: TBytes;
begin
  result := TPB_UpdateFileInfo.Create;
  fullpath := SelfPath + AUpdateFilePath;
  SetLength(hash_bytes, 0);
  if FileExists(fullpath) then
  begin
    hash := SHA256File(fullpath);
    if Length(hash) > 0 then
    begin
      SetLength(hash_bytes, Length(hash));
      Move(hash[1], hash_bytes[0], Length(hash));
    end;
  end;
  result.Path := StringReplace(AUpdateFilePath, '\', '/', [rfReplaceAll]);
  result.Hash := hash_bytes;
end;

procedure TdmMain.GetUpdateFilesList(const AFiles: TList<TPB_UpdateFileInfo>);
var
  C1: Integer;
begin
  for C1 := Low(Settings.Hardcoded.UPDATE_FILES) to High(Settings.Hardcoded.UPDATE_FILES) do
    AFiles.Add(GetUpdateFileObject(Settings.Hardcoded.UPDATE_FILES[C1].Path));
end;

function TdmMain.IsLoggedIn: Boolean;
begin
  result := (not FormsContainer.Contains(TfrmChipUpLogin)) and
            (dmMain.SelfInfo.Displayname <> '');
end;

procedure TdmMain.ProcessClubObject(const AClub: TPB_Club; const AGames: TList<TPB_Game>; const AMethodId: Integer);
var
  club: TClubInfo;
  player: TPlayerInfo;
  query_users: TArray<TMongoId>;
  empty_avatar_id: TBytes;
  member: TPB_ClubMember;
begin
  if AMethodId <> Integer(srClubDisbandOk) then
  begin
    dmMain.SelfInfo.Clubs.AddClub(AClub);
    if dmMain.SelfInfo.Clubs.GetAndLock(AClub.MongoId, club) then
    try
      SetLength(query_users, 0);
      SetLength(empty_avatar_id, 0);

      if not Players.TryGetValue(AClub.Owner, player) then
      begin
        SetLength(query_users, 1);
        query_users[0] := AClub.Owner;
        Players.AddPlayer(AClub.Owner, 'Retrieving...', '', empty_avatar_id);
      end;

      for member in AClub.Members do
        if (not Players.TryGetValue(member.MongoId, player)) or
           (player.Displayname = '') then
        begin
          SetLength(query_users, Length(query_users) + 1);
          query_users[Length(query_users) - 1] := member.MongoId;
          Players.AddPlayer(member.MongoId, 'Retrieving...', '', empty_avatar_id);
        end;

      if Length(query_users) > 0 then
        ServerSocket.GetUserInfos(query_users);

      if (AMethodId in [Integer(srJoinClubReply), Integer(srChangeClubDetailsReply)]) and
         (Assigned(club)) then
        club.Games.Assign(AGames);

      // we got kicked.. or club got deleted
      if (not club.GetMemberInfo(dmMain.SelfInfo.MongoId, member)) and
         (club.IsPrivate) then
      begin
        Tables.CloseTablesForClub(club.MongoId);
        dmMain.SelfInfo.Clubs.Remove(club.MongoId);
        club := nil;
      end;
    finally
      dmMain.SelfInfo.Clubs.Unlock;
    end;
  end
  else
  begin
    Tables.CloseTablesForClub(AClub.MongoId);
    dmMain.SelfInfo.Clubs.Lock;
    try
      dmMain.SelfInfo.Clubs.Remove(AClub.MongoId);
    finally
      dmMain.SelfInfo.Clubs.Unlock;
    end;
    club := nil;
  end;

  Tables.Lock;
  try
    Tables.UpdateClubObject(AClub.MongoId);
  finally
    Tables.Unlock;
  end;
end;

end.

