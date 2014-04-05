unit Poker.Settings;

interface

uses
  superobject, System.Classes, Poker.HardcodedSettings;

type
  TSettings = class(THardcodedSettings)
  private
    const
      JSON_LOGIN             = 'login';
      JSON_PASSWORD          = 'password';
      JSON_REMEMBER_LOGIN    = 'remember_login';
      JSON_REMEMBER_PASSWORD = 'remember_password';
      JSON_DEVELOPER_MODE    = 'devmode';

    function GetLogin: String;
    procedure SetLogin(const AValue: String);
    function GetPassword: String;
    procedure SetPassword(const AValue: String);
    function GetRememberLogin: Boolean;
    procedure SetRememberLogin(const AValue: Boolean);
    function GetRememberPassword: Boolean;
    procedure SetRememberPassword(const AValue: Boolean);
    function GetDeveloperMode: Boolean;
    procedure SetDeveloperMode(const AValue: Boolean);

    var
      FJSON        : ISuperObject;
      FSettingsFile: String;

  public
    constructor Create(const ASettingsFile: String);
    destructor Destroy; override;

    class procedure Initialize;
    class procedure Deinitialize;

    function Load: Boolean;
    procedure Save;

    property JSON        : ISuperObject read FJSON;
    property SettingsFile: String read FSettingsFile;

    property Login           : String read GetLogin write SetLogin;
    property Password        : String read GetPassword write SetPassword;
    property RememberLogin   : Boolean read GetRememberLogin write SetRememberLogin;
    property RememberPassword: Boolean read GetRememberPassword write SetRememberPassword;
    property DeveloperMode   : Boolean read GetDeveloperMode write SetDeveloperMode;
  end;

var
  Settings: TSettings;


implementation

uses
  Winapi.Windows, System.SysUtils,
  Poker.Common.Misc, Poker.Common.Encryption;


class procedure TSettings.Initialize;
begin
  Settings := TSettings.Create(AppDataLocalPath + THardcodedSettings.Hardcoded.SETTINGS_FILENAME);
  Settings.Load;
end;

class procedure TSettings.Deinitialize;
begin
  Settings.Save;
  FreeAndNil(Settings);
end;

constructor TSettings.Create(const ASettingsFile: String);
begin
  FSettingsFile := ASettingsFile;
  FJSON := SO;
end;

destructor TSettings.Destroy;
begin
  inherited;
end;

function TSettings.Load: Boolean;
var
  mstream: TMemoryStream;
begin
  result := FALSE;
  if not FileExists(FSettingsFile) then
    Exit;

  mstream := TMemoryStream.Create;
  try
    mstream.LoadFromFile(FSettingsFile);

    if (DecompressStream(mstream)) and
       (AES256DecryptStream(mstream, TSettings.Hardcoded.SETTINGS_ENCRYPTION_KEY)) then
    begin
      mstream.Position := 0;
      FJSON := TSuperObject.ParseStream(mstream, FALSE);
      result := Assigned(FJSON);
      if not result then
        FJSON := SO;
      end;
  finally
    mstream.Free;
  end;
end;

procedure TSettings.Save;
var
  mstream: TMemoryStream;
begin
  mstream := TMemoryStream.Create;
  try
    FJSON.SaveTo(mstream);
    if (AES256EncryptStream(mstream, TSettings.Hardcoded.SETTINGS_ENCRYPTION_KEY)) and
       (CompressStream(mstream)) then
      mstream.SaveToFile(FSettingsFile);
  finally
    mstream.Free;
  end;
end;



function TSettings.GetLogin: String;
begin
  result := FJSON.S[JSON_LOGIN];
end;

function TSettings.GetPassword: String;
begin
  result := FJSON.S[JSON_PASSWORD];
end;

function TSettings.GetRememberLogin: Boolean;
begin
  result := FJSON.B[JSON_REMEMBER_LOGIN];
end;

function TSettings.GetRememberPassword: Boolean;
begin
  result := FJSON.B[JSON_REMEMBER_PASSWORD];
end;

function TSettings.GetDeveloperMode: Boolean;
begin
  result := FJSON.B[JSON_DEVELOPER_MODE];
end;

procedure TSettings.SetLogin(const AValue: String);
begin
  FJSON.S[JSON_LOGIN] := AValue;
end;

procedure TSettings.SetPassword(const AValue: String);
begin
  FJSON.S[JSON_PASSWORD] := AValue;
end;

procedure TSettings.SetRememberLogin(const AValue: Boolean);
begin
  FJSON.B[JSON_REMEMBER_LOGIN] := AValue;
end;

procedure TSettings.SetRememberPassword(const AValue: Boolean);
begin
  FJSON.B[JSON_REMEMBER_PASSWORD] := AValue;
end;

procedure TSettings.SetDeveloperMode(const AValue: Boolean);
begin
  FJSON.B[JSON_DEVELOPER_MODE] := AValue;
end;


end.

