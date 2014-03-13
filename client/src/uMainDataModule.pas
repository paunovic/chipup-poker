unit uMainDataModule;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.ExtCtrls, System.Generics.Collections,
  uPlayerInfo, uTables, uPB_StatusReply, Vcl.Forms;

type
  TdmMain = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    const
      FONTLIST: array[0..2] of String = ('SintonyBold', 'BarmenoBold', 'CardCharacters');

    var
      FSelfInfo: TPlayerInfo;
      FPlayers : TPlayerInfos;
      FTables  : TTables;

    procedure LoadFonts;

  public
    procedure ProcessStatusProtobuf(const AStatusProtobuf: TPB_StatusReply);

    function CheckAuthed: Boolean;

    procedure OpenCashierLink;
    procedure OpenTOSLink;

    property SelfInfo: TPlayerInfo read FSelfInfo;
    property Players : TPlayerInfos read FPlayers;
    property Tables  : TTables read FTables;
  end;

var
  dmMain: TdmMain;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  {$IFDEF DEBUG} uDebugForm, {$ENDIF}
  Vcl.Graphics, Vcl.Controls, Vcl.Dialogs, Winapi.Messages, uSettings, uTableResources, uFormsContainer,
  uSocketClient, uCommon, uDXCore, uDXTimer, uMessageContainer, uAvatars, uServerSettings;


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
  TSocketClient.Initialize(TSettings.Hardcoded.TCP_SERVER_ADDRESS, TSettings.Hardcoded.TCP_SERVER_PORT);

  FSelfInfo := TPlayerInfo.Create;
  FPlayers := TPlayerInfos.Create;
  FTables := TTables.Create;
end;

procedure TdmMain.DataModuleDestroy(Sender: TObject);
begin
  FTables.Free;
  FPlayers.Free;
  FSelfInfo.Free;

  if SocketClient.IsConnected then
    SocketClient.Disconnect;
  TSocketClient.Deinitialize;

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
