unit Poker.DataModule;

interface

{$I defines.inc}

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Generics.Collections, Poker.Objects.PlayerInfo,
  Poker.Protobufs.Objects.StatusReply, Vcl.Forms, dxSkinsCore, cxLookAndFeels, dxSkinsForm, Poker.Objects.ClubInfo, dxScreenTip,
  dxCustomHint, cxHint, ChipUpPokerDarkSkin, Poker.Protobufs.Objects.TableStatus, Poker.Protobufs.Objects.UpdateFileInfo;

type
  TdmMain = class(TDataModule)
    SkinController: TdxSkinController;
    HintController: TcxHintStyleController;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    const
      FONTLIST: array[0..2] of String = ('SintonyBold', 'BarmenoBold', 'CardCharacters');

    var
      FSelfInfo: TPlayerInfo;
      FUpdateFiles: TObjectList<TPB_UpdateFileInfo>;
      FUpdaterBatchFile: String;
      FUpdaterInstallerFile: String;

    function GetAvailableBalance: UINT32;
    procedure LoadFonts;

  public
    procedure ProcessStatusProtobuf(const AStatusProtobuf: TPB_StatusReply);
    procedure ProcessReconnectedTables(const AReconnectedTables: TObjectList<TPB_TableStatus>);

    function CheckAuthed: Boolean;

    procedure OpenCashierLink;
    procedure OpenTACLink;
    procedure OpenSiteLink;
    procedure UpdateSelfInfoInPlayers;
    procedure GetUpdateFilesList(const AFiles: TObjectList<TPB_UpdateFileInfo>);
    procedure StoreUpdateFiles(const AFiles: TObjectList<TPB_UpdateFileInfo>);
    procedure SetUpdaterBatchFile(const AFile: String);
    procedure SetUpdaterInstaller(const AFile: String);

    property SelfInfo: TPlayerInfo read FSelfInfo;
    property AvailableBalance: UINT32 read GetAvailableBalance;
    property UpdateFiles: TObjectList<TPB_UpdateFileInfo> read FUpdateFiles;
  end;

var
  dmMain: TdmMain;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Vcl.Graphics, Vcl.Controls, Vcl.Dialogs, Winapi.Messages, Poker.Settings, Poker.Table.Resources, Poker.Common.FormsContainer,
  Poker.Server.Socket, Poker.Common.Misc, Poker.DirectX.Core, Poker.DirectX.Timer, Poker.Database.Core, Poker.Common.Encryption,
  Poker.Server.MessageContainer, Poker.Avatars, Poker.Server.Settings, Poker.Sounds, Poker.Table.Tables, Poker.HardcodedSettings,
  Poker.Stats.Table, Poker.Protobufs.Objects.Game, Poker.Forms.Table, Poker.Table.Status, Poker.Objects.GameInfo, Poker.Forms.Reconnect;


function TdmMain.CheckAuthed: Boolean;
begin
  result := FSelfInfo.Authed;

  if not result then
    MessageDlg('You cannot do this action until you verify your account. Please check your inbox for verification E-Mail.', mtWarning, [mbOK], 0);
end;

procedure TdmMain.DataModuleCreate(Sender: TObject);
begin
  {$IFDEF DEBUG}
  TfrmDebug.Initialize;
  {$ENDIF}

  LoadFonts;

  TSettings.Initialize(AppDataLocalPath + TSettings.Hardcoded.SETTINGS_FILENAME);
  TDatabase.Initialize(AppDataLocalPath + TSettings.Hardcoded.DATABASE_FILENAME);
  TAvatars.Initialize;
  TDXCore.Initialize;
  TDXTimer.Initialize;
  TServerSettings.Initialize;
  TMessageContainer.Initialize;
  TFormsContainer.Initialize;
  TSounds.Initialize;
  TTablesStats.Initialize;

  if (Settings.DeveloperMode) and
     (Settings.ServerIndex = 1) then
  begin
    TServerSocket.Initialize(TSettings.Hardcoded.TCP_DEV_SERVER_ADDRESS, TSettings.Hardcoded.TCP_SERVER_PORT);
    Settings.DomainURL := DEV_URL_DOMAIN;
  end
  else
  begin
    TServerSocket.Initialize(TSettings.Hardcoded.TCP_SERVER_ADDRESS, TSettings.Hardcoded.TCP_SERVER_PORT);
    Settings.DomainURL := URL_DOMAIN;
  end;

  FSelfInfo := TPlayerInfo.Create;

  TPlayers.Initialize;
  TTables.Initialize;

  FUpdateFiles := TObjectList<TPB_UpdateFileInfo>.Create;
end;

procedure TdmMain.DataModuleDestroy(Sender: TObject);
begin
  FUpdateFiles.Free;

  TTables.Deinitialize;
  TPlayers.Deinitialize;

  FSelfInfo.Free;

  TServerSocket.Deinitialize;
  TTablesStats.Deinitialize;
  TSounds.Deinitialize;
  TFormsContainer.Deinitialize;
  TMessageContainer.Deinitialize;
  FreeAndNil(ServerSettings);
  if Assigned(TableResources) then
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
  UpdateSelfInfoInPlayers
end;

procedure TdmMain.SetUpdaterBatchFile(const AFile: String);
begin
  FUpdaterBatchFile := AFile;
end;

procedure TdmMain.SetUpdaterInstaller(const AFile: String);
begin
  FUpdaterInstallerFile := AFile;
end;

procedure TdmMain.StoreUpdateFiles(const AFiles: TObjectList<TPB_UpdateFileInfo>);
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

procedure TdmMain.ProcessReconnectedTables(const AReconnectedTables: TObjectList<TPB_TableStatus>);
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
    for tstatus in AReconnectedTables do
      if CompareBytes(tstatus.TableMongoId, Tables[C1].Game.MongoId) then
      begin
        exists := TRUE;
        Break;
      end;

    if not exists then
      Tables.Delete(C1);
  end;

  // restore reconnected table states
  for tstatus in AReconnectedTables do
  begin
    table := nil;
    if not Tables.FindTable(tstatus.TableMongoId, table) then
      for club in FSelfInfo.Clubs do
        if club.Games.FindGame(tstatus.TableMongoId, game) then
        begin
          table := Tables.AddTable(club, game, FALSE, FALSE);
          Break;
        end;

    if not Assigned(table) then
      Continue;

    (table.Form as TfrmTable).Reconnected(tstatus);
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
  tstatus: TTableStatus;
  seat: TSeatInfo;
begin
  result := FSelfInfo.Balance;
  for table in Tables do
    if Assigned(table.Form) then
    begin
      tstatus := (table.Form as TfrmTable).TableStatus;
      for seat in tstatus.Seats do
        if CompareBytes(seat.PlayerMongoId, FSelfInfo.Id) then
        begin
          Assert(seat.Chips <= result);
          Dec(result, seat.Chips)
        end;
    end;
end;

procedure TdmMain.GetUpdateFilesList(const AFiles: TObjectList<TPB_UpdateFileInfo>);
const
  FILES_COUNT = 7;
  FILES: array[0..FILES_COUNT - 1] of String = ('chipuppoker.exe', 'libeay32.dll', 'ssleay32.dll', 'VclStylesInno.dll', 'Carbon.vsf',
     'bspatch.exe', 'sqlite3.dll');
var
  pb_ufi: TPB_UpdateFileInfo;
  C1: Integer;
  fullpath: String;
  hash: RawByteString;
  hash_bytes: TBytes;
begin
  for C1 := Low(FILES) to High(FILES) do
  begin
    pb_ufi := TPB_UpdateFileInfo.Create;
    pb_ufi.Path := FILES[C1];
    fullpath := SelfPath + pb_ufi.Path;
    SetLength(hash_bytes, 0);
    if FileExists(fullpath) then
    begin
      hash := SHA256File(FILES[C1]);
      if Length(hash) > 0 then
      begin
        SetLength(hash_bytes, Length(hash));
        Move(hash[1], hash_bytes[0], Length(hash));
      end;
    end;
    pb_ufi.Hash := hash_bytes;
    AFiles.Add(pb_ufi);
  end;
end;

end.

