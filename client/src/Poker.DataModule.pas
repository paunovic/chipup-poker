unit Poker.DataModule;

interface

{$I defines.inc}

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Generics.Collections, Poker.Objects.PlayerInfo,
  Poker.Protobufs.Objects.StatusReply, Vcl.Forms, dxSkinsCore, cxLookAndFeels, dxSkinsForm, Poker.Objects.ClubInfo, dxScreenTip,
  dxCustomHint, cxHint, ChipUpPokerDarkSkin, Poker.Protobufs.Objects.TableStatus;

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
      FSelfInfo   : TPlayerInfo;
      FUpdaterFile: String;

    function GetAvailableBalance: UINT32;
    procedure LoadFonts;

  public
    procedure ProcessStatusProtobuf(const AStatusProtobuf: TPB_StatusReply);
    procedure ProcessReconnectedTables(const AReconnectedTables: TObjectList<TPB_TableStatus>);

    function CheckAuthed: Boolean;

    procedure OpenCashierLink;
    procedure OpenTOSLink;

    property SelfInfo: TPlayerInfo read FSelfInfo;
    property AvailableBalance: UINT32 read GetAvailableBalance;
    property UpdaterFile: String read FUpdaterFile write FUpdaterFile;
  end;

var
  dmMain: TdmMain;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Vcl.Graphics, Vcl.Controls, Vcl.Dialogs, Winapi.Messages, Poker.Settings, Poker.Table.Resources, Poker.Common.FormsContainer,
  Poker.Server.Socket, Poker.Common.Misc, Poker.DirectX.Core, Poker.DirectX.Timer, Poker.Database.Core,
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
end;

procedure TdmMain.DataModuleDestroy(Sender: TObject);
begin
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

  if (FUpdaterFile <> '') and (FileExists(FUpdaterFile)) then
    ShellOpen(PChar(FUpdaterFile), nil, '/verysilent /surpressmsgboxes /closeapplications');
end;

procedure TdmMain.OpenCashierLink;
begin
  ShellOpen(PChar(Settings.Hardcoded.URL.CASHIER));
end;

procedure TdmMain.OpenTOSLink;
begin
  ShellOpen(PChar(Settings.Hardcoded.URL.TOS));
end;

procedure TdmMain.ProcessStatusProtobuf(const AStatusProtobuf: TPB_StatusReply);
begin
  FSelfInfo.LoadFromStatusProtobuf(AStatusProtobuf);
  Avatars.Add(FSelfInfo.AvatarId, nil);
  Players.LoadFromUsersProtobuf(AStatusProtobuf.Users);
end;

procedure TdmMain.ProcessReconnectedTables(const AReconnectedTables: TObjectList<TPB_TableStatus>);
var
  club: TclubInfo;
  game: TGameInfo;
  table: TTable;
  tstatus: TPB_TableStatus;
begin
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
  rs         : TResourceStream;
  nbFontAdded: DWORD;
  C1         : Integer;
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

end.

