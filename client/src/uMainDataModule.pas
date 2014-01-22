unit uMainDataModule;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.ExtCtrls, cxLabel,
  uPlayerInfo, uServerSettings, uTables, uAvatars;

type
  TdmMain = class(TDataModule)
    tiServerReconnect: TTimer;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FSelfInfo      : TPlayerInfo;
    FPlayers       : TPlayerInfos;
    FServerSettings: TServerSettings;
    FTables        : TTables;
    FAvatars       : TAvatars;

    procedure lbGetTokensClick(Sender: TObject);

  public
    function MakeTokenCostMessage(const ALabel: TcxLabel; const APrefix: String; const ACost: Integer): String;
    procedure OpenBuyTokensLink;
    procedure OpenBuyChipsLink;
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
  Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  uSocketClient, uSettings, uCommon;



procedure TdmMain.DataModuleCreate(Sender: TObject);
begin
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

function TdmMain.MakeTokenCostMessage(const ALabel: TcxLabel; const APrefix: String; const ACost: Integer): String;
var
  caption: String;
begin
  caption := Format('%s costs %d tokens. You currently have %d tokens left.', [APrefix, ACost, dmMain.SelfInfo.Tokens]);
  if ACost > dmMain.SelfInfo.Tokens then
  begin
    caption := caption + #10 + 'Click here to get more tokens';
    ALabel.OnClick := lbGetTokensClick;
    ALabel.Cursor := crHandPoint;
    ALabel.Style.TextColor := clAqua;
    ALabel.Style.TextStyle := [fsUnderline];
  end
  else
  begin
    ALabel.OnClick := nil;
    ALabel.Cursor := crDefault;
    ALabel.Style.TextColor := clWindowText;
    ALabel.Style.TextStyle := [];
    ALabel.Style.AssignedValues := [];
  end;

  ALabel.Caption := caption;
end;

procedure TdmMain.OpenBuyChipsLink;
begin
  ShellOpen(PChar(Settings.Hardcoded.URL.BUY_CHIPS));
end;

procedure TdmMain.OpenBuyTokensLink;
begin
  ShellOpen(PChar(Settings.Hardcoded.URL.BUY_TOKENS));
end;

procedure TdmMain.OpenTOSLink;
begin
  ShellOpen(PChar(Settings.Hardcoded.URL.TOS));
end;

procedure TdmMain.lbGetTokensClick(Sender: TObject);
begin
  OpenBuyTokensLink;
end;



end.
