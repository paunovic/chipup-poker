unit uMainDataModule;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.ExtCtrls, System.Generics.Collections,
  uPlayerInfo, uServerSettings, uTables, uAvatars, uPB_StatusReply, Vcl.Forms, uFormsContainer;

type
  TdmMain = class(TDataModule)
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
      FFormsContainer: TFormsContainer;

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
    property FormsContainer: TFormsContainer read FFormsContainer;
  end;

var
  dmMain: TdmMain;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  Vcl.Graphics, Vcl.Controls, Winapi.Messages,
  uSocketClient, uSettings, uCommon, uDXCore;


procedure TdmMain.DataModuleCreate(Sender: TObject);
begin
  InitializeDXCore;

  LoadFonts;

  FServerSettings := TServerSettings.Create;

  FSelfInfo := TPlayerInfo.Create;
  FPlayers := TPlayerInfos.Create;
  FAvatars := TAvatars.Create(AppDataRoamingPath + TSettings.Hardcoded.AVATARS_SUBDIR);

  FTables := TTables.Create;

  SocketClient := TSocketClient.Create(TSettings.Hardcoded.TCP_SERVER_ADDRESS, TSettings.Hardcoded.TCP_SERVER_PORT);

  FFormsContainer := TFormsContainer.Create;
end;

procedure TdmMain.DataModuleDestroy(Sender: TObject);
begin
  FFormsContainer.Free;

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
