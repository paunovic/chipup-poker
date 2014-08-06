unit Poker.DataModule;

interface

{$I defines.inc}

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Generics.Collections, Poker.Players.Player,
  Vcl.Forms, dxSkinsForm, Poker.Clubs.Club, Poker.HardcodedSettings, cxHint, Poker.Protobufs.Objects.TableStatus,
  Poker.Protobufs.Objects.UpdateFileInfo, cxGraphics, Poker.Protobufs.Objects.LoginReply, dxSkinsCore, ChipUpPokerDarkSkin, dxScreenTip,
  dxCustomHint, cxLookAndFeels, Vcl.ImgList, Vcl.Controls, Poker.Protobufs.Objects.Club, Poker.Protobufs.Objects.Game, cxStyles, cxClasses;

type
  TdmMain = class(TDataModule)
    il20px: TcxImageList;
    SkinController: TdxSkinController;
    HintController: TcxHintStyleController;
    GridStyles: TcxStyleRepository;
    styleInactiveCell: TcxStyle;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure SkinControllerSkinForm(Sender: TObject; AForm: TCustomForm; var ASkinName: string; var UseSkin: Boolean);
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

    property SelfInfo: TPlayerInfo read FSelfInfo;
    property UpdateFiles: TObjectList<TPB_UpdateFileInfo> read FUpdateFiles;
  end;

var
  dmMain: TdmMain;
  SelfPath: String;
  AppDataPath: String;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Winapi.ShlObj, Vcl.Dialogs, Poker.Settings, Poker.Tables.Resources, Poker.Common.FormsContainer, Poker.Server.Socket,
  Poker.Common.Misc, Poker.DirectX.Core, Poker.DirectX.Timer, Poker.Database.Core, Poker.Common.Encryption, Poker.Server.MessageContainer,
  Poker.Avatars.AvatarList, Poker.Server.Settings, Poker.Sounds, Poker.Tables.TableList, Poker.Tables.StatsList, Poker.Forms.Table,
  Poker.Tables.Status, Poker.Forms.SystemTrayPopup, Poker.HandHistory.Core, Poker.Seats.Seat, Poker.Forms.About, Poker.Clubs.Member,
  Poker.Players.PlayerList, Poker.Tables.Table, Poker.Tables.Renderer, Poker.Forms.Login, Poker.Protobufs.Objects.ClubMember,
  Poker.Protobufs.Enum.ServerCodes, Poker.Types, Poker.Tournaments;


procedure TdmMain.DataModuleCreate(Sender: TObject);
var
  common, local: String;
  server_index: Integer;
begin
  SelfPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  local := GetSpecialFolderPath(CSIDL_LOCAL_APPDATA);
  common := GetSpecialFolderPath(CSIDL_COMMON_APPDATA);
  if Pos(LowerCase(common), LowerCase(SelfPath)) > 0 then
    AppDataPath := common
  else
    AppDataPath := local;
  AppDataPath := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(AppDataPath) + 'ChipUP Poker');

  ForceDirectories(AppDataPath);
  if (not DirectoryExists(AppDataPath)) or
     (not IsDirectoryWriteable(AppDataPath)) then
    AppDataPath := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(local) + 'ChipUP Poker');

  {$IFDEF DEBUG}
  TfrmDebug.Initialize;
  {$ENDIF}

  LoadFonts;

  TSettings.Initialize(AppDataPath + TSettings.Hardcoded.SETTINGS_FILENAME);
  TDatabase.Initialize(AppDataPath + TSettings.Hardcoded.DATABASE_FILENAME);
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

  if (Settings.DeveloperMode) and
     (Settings.ServerIndex in [1, 2]) then
    server_index := Settings.ServerIndex
  else
    server_index := 0;

  TServerSocket.Initialize(TSettings.Hardcoded.SERVER_CONFIG[server_index].TCPAddress, TSettings.Hardcoded.SERVER_CONFIG[server_index].TCPPort);

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
  TDatabase.Deinitialize;
  TSettings.Deinitialize;

  {$IFDEF DEBUG}
  TfrmDebug.Deinitialize;
  {$ENDIF}

  if (FUpdaterInstallerFile <> '') and (FileExists(FUpdaterInstallerFile)) then
    ShellOpen(PChar(FUpdaterInstallerFile), nil, '/verysilent /surpressmsgboxes /closeapplications');

  if (FUpdaterBatchFile <> '') and (FileExists(FUpdaterBatchFile)) then
    ShellOpen(PChar(FUpdaterBatchFile), nil, nil, nil, SW_HIDE);
end;

function TdmMain.CheckAuthed: Boolean;
begin
  result := FSelfInfo.Authed;
  if not result then
    ShowWarningDialog('You cannot do this action until you verify your account. Please check your inbox for verification E-Mail.');
end;

procedure TdmMain.OpenSiteLink;
begin
  ShellOpen(PChar(Settings.Hardcoded.SERVER_CONFIG[Settings.ServerIndex].URL));
end;

procedure TdmMain.OpenTACLink;
begin
  ShellOpen(PChar(Settings.Hardcoded.SERVER_CONFIG[Settings.ServerIndex].URL + Settings.Hardcoded.URL.TERMS_AND_CONDITIONS));
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
  C1: Integer;
begin
  FUpdateFiles.Clear;
  for C1 := 0 to AFiles.Count - 1 do
  begin
    ufi := TPB_UpdateFileInfo.Create;
    ufi.Path := AFiles[C1].Path;
    ufi.Hash := AFiles[C1].Hash;
    ufi.Url := AFiles[C1].Url;
    ufi.FileType := AFiles[C1].FileType;
    ufi.FileSize := AFiles[C1].FileSize;
    FUpdateFiles.Add(ufi);
  end;
end;

procedure TdmMain.UpdateSelfInfoInPlayers;
begin
  Players.AddPlayer(FSelfInfo.MongoId, FSelfInfo.Nick, FSelfInfo.EMail, FSelfInfo.AvatarId);
end;

procedure TdmMain.ProcessLoginReply(const ALoginReply: TPB_LoginReply);
var
  mstream: TMemoryStream;
  C1: Integer;
  pbts: TPB_TableStatus;
begin
  FSelfInfo.LoadFromLoginReply(ALoginReply);
  Avatars.Add(FSelfInfo.AvatarId, nil);
  Players.LoadFromUsersProtobuf(ALoginReply.Users);
  UpdateSelfInfoInPlayers;

  Tournaments.Assign(ALoginReply.TournamentInfos);

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
      begin
        if Tables.GetAndLockTable(mongoid, ttLive, table) then
        try
          to_remove_iid.Add(table.InternalId);
        finally
          Tables.Unlock;
        end;

        if Tables.GetAndLockTable(mongoid, ttTournament, table) then
        try
          to_remove_iid.Add(table.InternalId);
        finally
          Tables.Unlock;
        end;
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
      ttTournament: Tables.AddTournamentTable(tstatus.TableMongoId, TRUE);
    end;

    if Tables.GetAndLockTable(tstatus.TableMongoId, tstatus.TableType, table) then
    try
      table.SetTableStatus(tstatus, FALSE);
    finally
      Tables.Unlock;
    end;
  end;
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
            (dmMain.SelfInfo.Nick <> '');
end;

procedure TdmMain.ProcessClubObject(const AClub: TPB_Club; const AGames: TList<TPB_Game>; const AMethodId: Integer);
var
  club: TClubInfo;
  player: TPlayerInfo;
  query_users: TArray<TMongoId>;
  empty_avatar_id: TBytes;
  member: TClubMemberInfo;
  memberpb: TPB_ClubMember;
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

      for memberpb in AClub.Members do
        if (not Players.TryGetValue(memberpb.MongoId, player)) or
           (player.Nick = '') or
           (Length(player.AvatarId) = 0) then
        begin
          SetLength(query_users, Length(query_users) + 1);
          query_users[Length(query_users) - 1] := memberpb.MongoId;
          Players.AddPlayer(memberpb.MongoId, 'Retrieving...', '', empty_avatar_id);
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

