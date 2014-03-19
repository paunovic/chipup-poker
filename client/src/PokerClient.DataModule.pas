unit PokerClient.DataModule;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.ExtCtrls, System.Generics.Collections,
  PokerClient.Objects.PlayerInfo, PokerClient.Protobufs.Objects.StatusReply, Vcl.Forms, dxSkinsCore, dxsChipUpDark, dxsChipUpDarkTabs, dxsChipUpRedButton, cxLookAndFeels,
  dxSkinsForm;

type
  TdmMain = class(TDataModule)
    SkinController: TdxSkinController;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    const
      FONTLIST: array[0..2] of String = ('SintonyBold', 'BarmenoBold', 'CardCharacters');

    var
      FSelfInfo: TPlayerInfo;
      FPlayers : TPlayerInfos;

    procedure LoadFonts;

  public
    procedure ProcessStatusProtobuf(const AStatusProtobuf: TPB_StatusReply);

    function CheckAuthed: Boolean;

    procedure OpenCashierLink;
    procedure OpenTOSLink;

    property SelfInfo: TPlayerInfo read FSelfInfo;
    property Players : TPlayerInfos read FPlayers;
  end;

var
  dmMain: TdmMain;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  {$IFDEF DEBUG} PokerClient.Forms.Debug, {$ENDIF}
  Vcl.Graphics, Vcl.Controls, Vcl.Dialogs, Winapi.Messages, PokerClient.Settings, PokerClient.Table.Resources, PokerClient.Common.FormsContainer,
  PokerClient.Server.Socket, PokerClient.Common.Misc, PokerClient.DirectX.Core, PokerClient.DirectX.Timer,
  PokerClient.Server.MessageContainer, PokerClient.Avatars, PokerClient.Server.Settings, PokerClient.Sounds, PokerClient.Table.Tables;


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

  TSettings.Initialize;
  TDXCore.Initialize;
  TDXTimer.Initialize;
  TServerSettings.Initialize;
  TMessageContainer.Initialize;
  TFormsContainer.Initialize;
  TAvatars.Initialize(AppDataRoamingPath + TSettings.Hardcoded.AVATARS_SUBDIR);
  TServerSocket.Initialize(TSettings.Hardcoded.TCP_SERVER_ADDRESS, TSettings.Hardcoded.TCP_SERVER_PORT);
  TSounds.Initialize;

  FSelfInfo := TPlayerInfo.Create;
  FPlayers := TPlayerInfos.Create;

  TTables.Initialize;
end;

procedure TdmMain.DataModuleDestroy(Sender: TObject);
begin
  TTables.Deinitialize;

  FPlayers.Free;
  FSelfInfo.Free;

  if ServerSocket.IsConnected then
    ServerSocket.Disconnect;
  TServerSocket.Deinitialize;

  TSounds.Deinitialize;
  TAvatars.Deinitialize;
  TFormsContainer.Deinitialize;
  TMessageContainer.Deinitialize;
  FreeAndNil(ServerSettings);
  if Assigned(TableResources) then
    TTableResources.Deinitialize;
  TDXTimer.Deinitialize;
  TDXCore.Deinitialize;
  TSettings.Deinitialize;

  {$IFDEF DEBUG}
  TfrmDebug.Deinitialize;
  {$ENDIF}
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
  Avatars.AddAvatar(FSelfInfo.AvatarId);
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
