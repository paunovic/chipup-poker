unit Poker.DataModule;

interface

{$I defines.inc}

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Generics.Collections, Poker.Objects.PlayerInfo,
  Poker.Protobufs.Objects.StatusReply, Vcl.Forms, dxSkinsForm, Poker.Objects.ClubInfo, Poker.HardcodedSettings,
  cxHint, Poker.Protobufs.Objects.TableStatus, Poker.Protobufs.Objects.UpdateFileInfo,
  cxGraphics, Poker.Protobufs.Objects.LoginReply, dxSkinsCore, ChipUpPokerDarkSkin, dxScreenTip, dxCustomHint, cxLookAndFeels, Vcl.ImgList,
  Vcl.Controls;

type
  TdmMain = class(TDataModule)
    il20px: TcxImageList;
    SkinController: TdxSkinController;
    HintController: TcxHintStyleController;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure SkinControllerSkinForm(Sender: TObject; AForm: TCustomForm; var ASkinName: string; var UseSkin: Boolean);
  private
    const
      FONTLIST: array[0..0] of String = ('SintonyBold');

    var
      FSelfInfo: TPlayerInfo;
      FUpdateFiles: TObjectList<TPB_UpdateFileInfo>;
      FUpdaterBatchFile: String;
      FUpdaterInstallerFile: String;
      FReconnectedTables: TObjectList<TPB_TableStatus>;

    function GetAvailableBalance: UINT32;
    procedure LoadFonts;
    function GetUpdateFileObject(const AUpdateFile: TUpdateFile): TPB_UpdateFileInfo;

  public
    procedure ProcessStatusProtobuf(const AStatusProtobuf: TPB_StatusReply);
    procedure ProcessReconnectedTables;
    procedure ProcessLoginReply(const ALoginReply: TPB_LoginReply);

    function CheckAuthed: Boolean;

    procedure OpenCashierLink;
    procedure OpenTACLink;
    procedure OpenSiteLink;
    procedure UpdateSelfInfoInPlayers;
    procedure GetUpdateFilesList(const AFiles: TList<TPB_UpdateFileInfo>);
    procedure StoreUpdateFiles(const AFiles: TList<TPB_UpdateFileInfo>);
    procedure SetUpdaterBatchFile(const AFile: String);
    procedure SetUpdaterInstaller(const AFile: String);

    property SelfInfo: TPlayerInfo read FSelfInfo;
    property AvailableBalance: UINT32 read GetAvailableBalance;
    property UpdateFiles: TObjectList<TPB_UpdateFileInfo> read FUpdateFiles;
  end;

var
  dmMain: TdmMain;
  SelfPath: String;
  AppDataPath: String;
  DomainURL: String;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Winapi.ShlObj, Vcl.Dialogs, Poker.Settings, Poker.Table.Resources, Poker.Common.FormsContainer, Poker.Server.Socket, Poker.Common.Misc,
  Poker.DirectX.Core, Poker.DirectX.Timer, Poker.Database.Core, Poker.Common.Encryption, Poker.Server.MessageContainer, Poker.Avatars,
  Poker.Server.Settings, Poker.Sounds, Poker.Table.Tables, Poker.Stats.Table, Poker.Forms.Table, Poker.Objects.TableStatus,
  Poker.Objects.GameInfo, Poker.Forms.SystemTrayPopup, Poker.HandHistory.Core, Poker.Objects.SeatInfo, Poker.Forms.About;


procedure TdmMain.DataModuleCreate(Sender: TObject);
var
  common, local: String;
begin
  SelfPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  local := GetSpecialFolderPath(CSIDL_LOCAL_APPDATA);
  common := GetSpecialFolderPath(CSIDL_COMMON_APPDATA);
  if (Pos(LowerCase(common), LowerCase(SelfPath)) > 0) and
     (IsDirectoryWriteable(common)) then
    AppDataPath := common
  else
    AppDataPath := local;
  AppDataPath := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(AppDataPath) + 'ChipUP Poker');

  ForceDirectories(AppDataPath);

  {$IFDEF DEBUG}
  TfrmDebug.Initialize;
  {$ENDIF}

  LoadFonts;

  TSettings.Initialize(AppDataPath + TSettings.Hardcoded.SETTINGS_FILENAME);
  TDatabase.Initialize(AppDataPath + TSettings.Hardcoded.DATABASE_FILENAME);
  TAvatars.Initialize;
  TDXCore.Initialize;
  TDXTimer.Initialize;
  DXTimer.AnimationsEnabled := Settings.Animations;
  TServerSettings.Initialize;
  TMessageContainer.Initialize;
  TFormsContainer.Initialize;
  TSounds.Initialize;
  TTablesStats.Initialize;
  THandHistory.Initialize;

  if (Settings.DeveloperMode) and
     (Settings.ServerIndex = 1) then
  begin
    TServerSocket.Initialize(TSettings.Hardcoded.TCP_DEV_SERVER_ADDRESS, TSettings.Hardcoded.TCP_SERVER_PORT);
    DomainURL := DEV_URL_DOMAIN;
  end
  else
    if (Settings.DeveloperMode) and
       (Settings.ServerIndex = 2) then
    begin
      TServerSocket.Initialize(TSettings.Hardcoded.TCP_LOCAL_SERVER_ADDRESS, TSettings.Hardcoded.TCP_SERVER_PORT);
      DomainURL := LOCAL_URL_DOMAIN;
    end
    else
    begin
      TServerSocket.Initialize(TSettings.Hardcoded.TCP_SERVER_ADDRESS, TSettings.Hardcoded.TCP_SERVER_PORT);
      DomainURL := URL_DOMAIN;
    end;

  FSelfInfo := TPlayerInfo.Create;

  TPlayers.Initialize;
  TTables.Initialize;

  FUpdateFiles := TObjectList<TPB_UpdateFileInfo>.Create;
  FReconnectedTables := TObjectList<TPB_TableStatus>.Create;
end;

procedure TdmMain.DataModuleDestroy(Sender: TObject);
begin
  // deinit objects
  FreeAndNil(FUpdateFiles);
  FreeAndNil(FReconnectedTables);

  TFormsContainer.Deinitialize;
  TfrmSystemTrayPopup.DestroyIfExists;
  TTables.Deinitialize;
  TPlayers.Deinitialize;
  FSelfInfo.Free;
  TServerSocket.Deinitialize;
  THandHistory.Deinitialize;
  TTablesStats.Deinitialize;
  TSounds.Deinitialize;
  TMessageContainer.Deinitialize;
  TServerSettings.Deinitialize;
  TTableResources.Deinitialize;
  TDXTimer.Deinitialize;
  TDXCore.Deinitialize;
  TAvatars.Deinitialize;
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
    MessageDlg('You cannot do this action until you verify your account. Please check your inbox for verification E-Mail.', mtWarning, [mbOK], 0);
end;

procedure TdmMain.OpenCashierLink;
begin
  ShellOpen(PChar(Settings.Hardcoded.URL.CASHIER));
end;

procedure TdmMain.OpenSiteLink;
begin
  ShellOpen(URL_DOMAIN);
end;

procedure TdmMain.OpenTACLink;
begin
  ShellOpen(PChar(Settings.Hardcoded.URL.TERMS_AND_CONDITIONS));
end;

procedure TdmMain.ProcessStatusProtobuf(const AStatusProtobuf: TPB_StatusReply);
begin
  FSelfInfo.LoadFromStatusProtobuf(AStatusProtobuf);
  Avatars.Add(FSelfInfo.AvatarId, nil);
  Players.LoadFromUsersProtobuf(AStatusProtobuf.Users);
  UpdateSelfInfoInPlayers;
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
  Players.AddPlayer(FSelfInfo.Id, FSelfInfo.Nick, FSelfInfo.EMail, FSelfInfo.Balance, FSelfInfo.AvatarId);
end;

procedure TdmMain.ProcessLoginReply(const ALoginReply: TPB_LoginReply);
var
  mstream: TMemoryStream;
  C1: Integer;
  pbts: TPB_TableStatus;
begin
  ProcessStatusProtobuf(ALoginReply.Status);

  FReconnectedTables.Clear;
  mstream := TMemoryStream.Create;
  try
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
  club: TclubInfo;
  game: TGameInfo;
  table: TTable;
  tstatus: TPB_TableStatus;
  exists: Boolean;
  C1: Integer;
begin
  // first, close all tables that dont exist in reconnected tables array
  for C1 := Tables.Count - 1 downto 0 do
  begin
    exists := FALSE;
    for tstatus in FReconnectedTables do
      if CompareBytes(tstatus.TableMongoId, Tables[C1].Game.MongoId) then
      begin
        exists := TRUE;
        Break;
      end;

    if not exists then
      Tables.Delete(C1);
  end;

  // restore reconnected table states
  for tstatus in FReconnectedTables do
  begin
    table := nil;
    if not Tables.FindTable(tstatus.TableMongoId, table) then
      for club in FSelfInfo.Clubs do
        if club.Games.FindGame(tstatus.TableMongoId, game) then
        begin
          table := Tables.AddTable(club, game, TRUE, FALSE);
          Break;
        end;

    if not Assigned(table) then
      Continue;

    (table.Form as TfrmTable).SetTableStatus(tstatus, FALSE);
  end;
end;

procedure TdmMain.LoadFonts;
var
  rs: TResourceStream;
  nbFontAdded: DWORD;
  C1: Integer;
begin
  for C1 := Low(FONTLIST) to High(FONTLIST) do
  begin
    rs := TResourceStream.Create(HInstance, FONTLIST[C1], RT_RCDATA);
    try
      AddFontMemResourceEx(rs.Memory, rs.Size, nil, @nbFontAdded);
    finally
      rs.Free;
    end;
  end;
end;

function TdmMain.GetAvailableBalance: UINT32;
var
  table: TTable;
  seat: TSeatInfo;
begin
  result := FSelfInfo.Balance;
  for table in Tables do
    for seat in table.Renderer.TableStatus.Seats do
      if CompareBytes(seat.PlayerMongoId, FSelfInfo.Id) then
      begin
        Assert(seat.Chips <= result);
        Dec(result, seat.Chips)
      end;
end;

function TdmMain.GetUpdateFileObject(const AUpdateFile: TUpdateFile): TPB_UpdateFileInfo;
var
  fullpath: String;
  hash: RawByteString;
  hash_bytes: TBytes;
begin
  result := TPB_UpdateFileInfo.Create;
  fullpath := SelfPath + AUpdateFile.Path;
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
  result.Path := StringReplace(AUpdateFile.Path, '\', '/', [rfReplaceAll]);
  result.Hash := hash_bytes;
end;

procedure TdmMain.GetUpdateFilesList(const AFiles: TList<TPB_UpdateFileInfo>);
var
  update_file: TUpdateFile;
begin
  for update_file in Settings.Hardcoded.UPDATE_FILES do
    AFiles.Add(GetUpdateFileObject(update_file));
end;

end.

