unit uMainDataModule;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.ExtCtrls, cxLabel,
  uPlayerInfo, uServerSettings, uTables, uAvatars, uPB_StatusReply;

type
  TdmMain = class(TDataModule)
    tiServerReconnect: TTimer;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    const
      FONTLIST: array[0..2] of String = ('SintonyBold', 'BarmenoBold', 'CardCharacters');

    var
      FSelfInfo      : TPlayerInfo;
      FPlayers       : TPlayerInfos;
      FServerSettings: TServerSettings;
      FTables        : TTables;
      FAvatars       : TAvatars;

    procedure LoadFonts;

  public
    procedure ProcessStatusProtobuf(const AStatusProtobuf: TPB_StatusReply);

    procedure OpenCashierLink;
    procedure OpenTOSLink;

    property SelfInfo      : TPlayerInfo read FSelfInfo;
    property Players       : TPlayerInfos read FPlayers;
    property ServerSettings: TServerSettings read FServerSettings;
    property Tables        : TTables read FTables;
    property Avatars       : TAvatars read FAvatars;
  end;

var
  dmMain: TdmMain;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Winapi.Messages,
  uSocketClient, uSettings, uCommon;



procedure TdmMain.DataModuleCreate(Sender: TObject);
begin
  LoadFonts;

  FServerSettings := TServerSettings.Create;

  FSelfInfo := TPlayerInfo.Create;
  FPlayers := TPlayerInfos.Create;
  FAvatars := TAvatars.Create(AppDataRoamingPath + TSettings.Hardcoded.AVATARS_SUBDIR);

  FTables := TTables.Create;

  SocketClient := TSocketClient.Create(TSettings.Hardcoded.TCP_SERVER_ADDRESS, TSettings.Hardcoded.TCP_SERVER_PORT);
end;

procedure TdmMain.DataModuleDestroy(Sender: TObject);
begin
  FTables.Free;

  FAvatars.Free;
  FPlayers.Free;
  FSelfInfo.Free;

  FServerSettings.Free;

  if SocketClient.IsConnected then
    SocketClient.Disconnect;
  FreeAndNil(SocketClient);
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
  FAvatars.AddAvatar(FSelfInfo.AvatarId);
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
