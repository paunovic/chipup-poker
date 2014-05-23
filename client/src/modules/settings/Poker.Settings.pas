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
      JSON_SERVER_INDEX      = 'serverindex';
      JSON_SOUNDS            = 'sounds';
      JSON_FOLD_CHECKS       = 'fold_checks';

      JSON_DEFAULT_LOGIN             = '';
      JSON_DEFAULT_PASSWORD          = '';
      JSON_DEFAULT_REMEMBER_LOGIN    = TRUE;
      JSON_DEFAULT_REMEMBER_PASSWORD = FALSE;
      JSON_DEFAULT_DEVELOPER_MODE    = FALSE;
      JSON_DEFAULT_SERVER_INDEX      = 0;
      JSON_DEFAULT_SOUNDS            = TRUE;
      JSON_DEFAULT_FOLD_CHECKS       = FALSE;

    function GetJSONString(const AField, ADefaultValue: String): String;
    function GetJSONInt(const AField: String; const ADefaultValue: Int64): Int64;
    function GetJSONBool(const AField: String; const ADefaultValue: Boolean): Boolean;

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
    function GetServerIndex: Integer;
    procedure SetServerIndex(const AValue: Integer);
    function GetSounds: Boolean;
    procedure SetSounds(const AValue: Boolean);
    function GetFoldChecks: Boolean;
    procedure SetFoldChecks(const AValue: Boolean);

    var
      FJSON: ISuperObject;
      FSettingsFile: String;
      FDomainURL: String;

  public
    constructor Create(const ASettingsFile: String);
    destructor Destroy; override;

    class procedure Initialize(const APath: String);
    class procedure Deinitialize;

    function Load: Boolean;
    procedure Save;

    property SettingsFile: String read FSettingsFile;

    property Login: String read GetLogin write SetLogin;
    property Password: String read GetPassword write SetPassword;
    property RememberLogin: Boolean read GetRememberLogin write SetRememberLogin;
    property RememberPassword: Boolean read GetRememberPassword write SetRememberPassword;
    property DeveloperMode: Boolean read GetDeveloperMode write SetDeveloperMode;
    property ServerIndex: Integer read GetServerIndex write SetServerIndex;
    property Sounds: Boolean read GetSounds write SetSounds;
    property FoldChecks: Boolean read GetFoldChecks write SetFoldChecks;

    property DomainURL: String read FDomainURL write FDomainURL;
  end;

var
  Settings: TSettings;


implementation

uses
  Winapi.Windows, System.SysUtils,
  Poker.Common.Misc, Poker.Common.Encryption;


class procedure TSettings.Initialize(const APath: String);
begin
  Settings := TSettings.Create(APath);
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

////////////////////////////////////////////////////////////////////////////////////

function TSettings.GetJSONString(const AField, ADefaultValue: String): String;
var
  o: ISuperObject;
begin
  o := FJSON.O[AField];
  if not Assigned(o) then
    result := ADefaultValue
  else
    result := o.AsString;
end;

function TSettings.GetJSONInt(const AField: String; const ADefaultValue: Int64): Int64;
var
  o: ISuperObject;
begin
  o := FJSON.O[AField];
  if not Assigned(o) then
    result := ADefaultValue
  else
    result := o.AsInteger;
end;

function TSettings.GetJSONBool(const AField: String; const ADefaultValue: Boolean): Boolean;
var
  o: ISuperObject;
begin
  o := FJSON.O[AField];
  if not Assigned(o) then
    result := ADefaultValue
  else
    result := o.AsBoolean;
end;

////////////////////////////////////////////////////////////////////////////////////

function TSettings.GetLogin: String;
begin
  result := GetJSONString(JSON_LOGIN, JSON_DEFAULT_LOGIN);
end;

function TSettings.GetPassword: String;
begin
  result := GetJSONString(JSON_PASSWORD, JSON_DEFAULT_PASSWORD);
end;

function TSettings.GetRememberLogin: Boolean;
begin
  result := GetJSONBool(JSON_REMEMBER_LOGIN, JSON_DEFAULT_REMEMBER_LOGIN);
end;

function TSettings.GetRememberPassword: Boolean;
begin
  result := GetJSONBool(JSON_REMEMBER_PASSWORD, JSON_DEFAULT_REMEMBER_PASSWORD);
end;

function TSettings.GetServerIndex: Integer;
begin
  result := GetJSONInt(JSON_SERVER_INDEX, JSON_DEFAULT_SERVER_INDEX);
end;

function TSettings.GetSounds: Boolean;
begin
  result := GetJSONBool(JSON_SOUNDS, JSON_DEFAULT_SOUNDS);
end;

function TSettings.GetDeveloperMode: Boolean;
begin
  result := GetJSONBool(JSON_DEVELOPER_MODE, JSON_DEFAULT_DEVELOPER_MODE);
end;

function TSettings.GetFoldChecks: Boolean;
begin
  result := GetJSONBool(JSON_FOLD_CHECKS, JSON_DEFAULT_FOLD_CHECKS);
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

procedure TSettings.SetServerIndex(const AValue: Integer);
begin
  FJSON.I[JSON_SERVER_INDEX] := AValue;
end;

procedure TSettings.SetSounds(const AValue: Boolean);
begin
  FJSON.B[JSON_SOUNDS] := AValue;
end;

procedure TSettings.SetDeveloperMode(const AValue: Boolean);
begin
  FJSON.B[JSON_DEVELOPER_MODE] := AValue;
end;

procedure TSettings.SetFoldChecks(const AValue: Boolean);
begin
  FJSON.B[JSON_FOLD_CHECKS] := AValue;
end;

end.

