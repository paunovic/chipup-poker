unit Poker.DataModule;

interface

{$I defines.inc}

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Generics.Collections, Poker.Objects.PlayerInfo,
  Poker.Protobufs.Objects.StatusReply, Vcl.Forms, dxSkinsCore, dxsChipUpDark, dxsChipUpDarkTabs, dxsChipUpRedButton, cxLookAndFeels,
  dxSkinsForm, Poker.Objects.ClubInfo;

type
  TdmMain = class(TDataModule)
    SkinController: TdxSkinController;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    const
      FONTLIST: array[0..2] of String = ('SintonyBold', 'BarmenoBold', 'CardCharacters');

    var
      FSelfInfo   : TPlayerInfo;
      FPlayers    : TPlayerInfos;
      FPublicClubs: TClubsInfo;
      FUpdaterFile: String;

    procedure LoadFonts;

  public
    procedure ProcessStatusProtobuf(const AStatusProtobuf: TPB_StatusReply);

    function CheckAuthed: Boolean;

    procedure OpenCashierLink;
    procedure OpenTOSLink;

    property SelfInfo   : TPlayerInfo read FSelfInfo;
    property PublicClubs: TClubsInfo read FPublicClubs;
    property Players    : TPlayerInfos read FPlayers;
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
  Poker.Server.MessageContainer, Poker.Avatars, Poker.Server.Settings, Poker.Sounds, Poker.Table.Tables, Poker.HardcodedSettings;


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

  if Settings.DeveloperMode then
  begin
    TServerSocket.Initialize(TSettings.Hardcoded.TCP_DEV_SERVER_ADDRESS, TSettings.Hardcoded.TCP_SERVER_PORT);
    Settings.DomainURL := DEV_URL_DOMAIN;
  end
  else
  begin
    TServerSocket.Initialize(TSettings.Hardcoded.TCP_SERVER_ADDRESS, TSettings.Hardcoded.TCP_SERVER_PORT);
    Settings.DomainURL := URL_DOMAIN;
  end;

  FPublicClubs := TClubsInfo.Create;
  FSelfInfo := TPlayerInfo.Create;
  FPlayers := TPlayerInfos.Create;

  TTables.Initialize;
end;

procedure TdmMain.DataModuleDestroy(Sender: TObject);
begin
  TTables.Deinitialize;

  FPlayers.Free;
  FSelfInfo.Free;
  FPublicClubs.Free;

  TServerSocket.Deinitialize;
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
var
  C1: Integer;
begin
  FSelfInfo.LoadFromStatusProtobuf(AStatusProtobuf);
  Avatars.Add(FSelfInfo.AvatarId, nil);

  FPublicClubs.Clear;
  for C1 := 0 to AStatusProtobuf.PublicClubs.Count - 1 do
    FPublicClubs.AddClub(AStatusProtobuf.PublicClubs[C1]);

  FPlayers.LoadFromUsersProtobuf(AStatusProtobuf.Users);
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

end.
