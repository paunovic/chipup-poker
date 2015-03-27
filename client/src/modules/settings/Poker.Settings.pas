unit Poker.Settings;

interface

uses
  superobject, System.Classes, Poker.HardcodedSettings, Vcl.Forms;

type
  TSettings = class(THardcodedSettings)
  private
    const
      // property indexes
      PROPINDEX_LOGIN_USERNAME = 1;
      PROPINDEX_LOGIN_PASSWORD = 2;
      PROPINDEX_SERVER_INDEX = 3;
      PROPINDEX_REMEMBER_LOGIN = 4;
      PROPINDEX_REMEMBER_PASSWORD = 5;
      PROPINDEX_DEVELOPER_MODE = 6;
      PROPINDEX_SOUNDS = 7;
      PROPINDEX_FOLD_CHECKS = 8;
      PROPINDEX_ANIMATIONS = 9;
      PROPINDEX_FOLD_CONFIRMATION = 10;
      PROPINDEX_ALWAYS_RUN_TWICE = 11;
      PROPINDEX_MAIN_FORM_MAXIMIZED = 12;
      PROPINDEX_MAIN_FORM_X = 13;
      PROPINDEX_MAIN_FORM_Y = 14;
      PROPINDEX_MAIN_FORM_WIDTH = 15;
      PROPINDEX_MAIN_FORM_HEIGHT = 16;

      // json field names
      JSON_LOGIN_USERNAME = 'login_username';
      JSON_LOGIN_PASSWORD = 'login_password';
      JSON_SERVER_INDEX = 'server_index';
      JSON_REMEMBER_LOGIN = 'remember_login';
      JSON_REMEMBER_PASSWORD = 'remember_password';
      JSON_DEVELOPER_MODE = 'devmode';
      JSON_SOUNDS = 'sounds';
      JSON_FOLD_CHECKS = 'fold_checks';
      JSON_ANIMATIONS = 'animations';
      JSON_FOLD_CONFIRMATION = 'fold_confirmation';
      JSON_ALWAYS_RUN_IT_TWICE = 'always_run_it_twice';
      JSON_FORM_SETTINGS = 'forms';
      JSON_FORM_NAME = 'name';
      JSON_FORM_MAXIMIZED = 'maximized';
      JSON_FORM_X = 'x';
      JSON_FORM_Y = 'y';
      JSON_FORM_WIDTH = 'width';
      JSON_FORM_HEIGHT = 'height';

      // default values
      DEFAULT_LOGIN_USERNAME = '';
      DEFAULT_LOGIN_PASSWORD = '';
      DEFAULT_REMEMBER_LOGIN = TRUE;
      DEFAULT_REMEMBER_PASSWORD = FALSE;
      DEFAULT_DEVELOPER_MODE = FALSE;
      DEFAULT_SERVER_INDEX = 0;
      DEFAULT_SOUNDS = TRUE;
      DEFAULT_FOLD_CHECKS = FALSE;
      DEFAULT_ANIMATIONS = TRUE;
      DEFAULT_FOLD_CONFIRMATION = FALSE;
      DEFAULT_ALWAYS_RUN_IT_TWICE = FALSE;

    function GetStringValue(const AIndex: Integer): String;
    procedure SetStringValue(const AIndex: Integer; const AValue: String);

    function GetIntegerValue(const AIndex: Integer): Int64;
    procedure SetIntegerValue(const AIndex: Integer; const AValue: Int64);

    function GetBooleanValue(const AIndex: Integer): Boolean;
    procedure SetBooleanValue(const AIndex: Integer; const AValue: Boolean);

    var
      FJSON: ISuperObject;
      FSettingsFile: String;

  public
    constructor Create(const ASettingsFile: String);

    class procedure Initialize(const ASettingsFile: String);
    class procedure Deinitialize;

    function Load: Boolean;
    procedure Save;

    procedure SaveFormSettings(const AForm: TForm);
    procedure LoadFormSettings(const AForm: TForm; const ADefaultX, ADefaultY: Integer);

    property SettingsFile: String read FSettingsFile;

    property LoginUsername: String index PROPINDEX_LOGIN_USERNAME read GetStringValue write SetStringValue;
    property LoginPassword: String index PROPINDEX_LOGIN_PASSWORD read GetStringValue write SetStringValue;

    property ServerIndex: Int64 index PROPINDEX_SERVER_INDEX read GetIntegerValue write SetIntegerValue;

    property RememberLogin: Boolean index PROPINDEX_REMEMBER_LOGIN read GetBooleanValue write SetBooleanValue;
    property RememberPassword: Boolean index PROPINDEX_REMEMBER_PASSWORD read GetBooleanValue write SetBooleanValue;
    property DeveloperMode: Boolean index PROPINDEX_DEVELOPER_MODE read GetBooleanValue write SetBooleanValue;
    property Sounds: Boolean index PROPINDEX_SOUNDS read GetBooleanValue write SetBooleanValue;
    property FoldChecks: Boolean index PROPINDEX_FOLD_CHECKS read GetBooleanValue write SetBooleanValue;
    property Animations: Boolean index PROPINDEX_ANIMATIONS read GetBooleanValue write SetBooleanValue;
    property FoldConfirmation: Boolean index PROPINDEX_FOLD_CONFIRMATION read GetBooleanValue write SetBooleanValue;
    property AlwaysRunItTwice: Boolean index PROPINDEX_ALWAYS_RUN_TWICE read GetBooleanValue write SetBooleanValue;
  end;

var
  Settings: TSettings;


implementation

uses
  Poker.SoftExceptions, System.SysUtils, Poker.Common.Misc, Poker.Common.Encryption;


class procedure TSettings.Initialize(const ASettingsFile: String);
begin
  Settings := TSettings.Create(ASettingsFile);
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

procedure TSettings.SaveFormSettings(const AForm: TForm);
var
  C1: Integer;
  formsettings, formjson: ISuperObject;
begin
  if not Assigned(FJSON.O[JSON_FORM_SETTINGS]) then
    FJSON.O[JSON_FORM_SETTINGS] := SA([]);
  formsettings := FJSON.O[JSON_FORM_SETTINGS];

  formjson := nil;
  for C1 := formsettings.AsArray.Length - 1 downto 0 do
    if formsettings.AsArray.O[C1].S[JSON_FORM_NAME] = AForm.Name then
    begin
      formjson := formsettings.AsArray.O[C1];
      formsettings.AsArray.Delete(C1);
    end;

  if not Assigned(formjson) then
    formjson := SO;

  formjson.S[JSON_FORM_NAME] := AForm.Name;
  formjson.B[JSON_FORM_MAXIMIZED] := AForm.WindowState = wsMaximized;
  if AForm.WindowState <> wsMaximized then
  begin
    formjson.I[JSON_FORM_X] := AForm.Left;
    formjson.I[JSON_FORM_Y] := AForm.Top;
    formjson.I[JSON_FORM_WIDTH] := AForm.Width;
    formjson.I[JSON_FORM_HEIGHT] := AForm.Height;
  end;

  formsettings.AsArray.Add(formjson);
end;

procedure TSettings.LoadFormSettings(const AForm: TForm; const ADefaultX, ADefaultY: Integer);
var
  C1: Integer;
  formjson: ISuperObject;
begin
  formjson := nil;
  if Assigned(FJSON.O[JSON_FORM_SETTINGS]) then
    for C1 := 0 to FJSON.O[JSON_FORM_SETTINGS].AsArray.Length - 1 do
      if FJSON.O[JSON_FORM_SETTINGS].AsArray.O[C1].S[JSON_FORM_NAME] = AForm.Name then
      begin
        formjson := FJSON.O[JSON_FORM_SETTINGS].AsArray.O[C1];
        Break;
      end;

  if Assigned(formjson) then
  begin
    if Assigned(formjson.O[JSON_FORM_X]) then
      AForm.Left := formjson.I[JSON_FORM_X];
    if Assigned(formjson.O[JSON_FORM_Y]) then
      AForm.Top := formjson.I[JSON_FORM_Y];
    if Assigned(formjson.O[JSON_FORM_WIDTH]) then
      AForm.Width := formjson.I[JSON_FORM_WIDTH];
    if Assigned(formjson.O[JSON_FORM_HEIGHT]) then
      AForm.Height := formjson.I[JSON_FORM_HEIGHT];

    if formjson.B[JSON_FORM_MAXIMIZED] then
      AForm.WindowState := wsMaximized
    else
      AForm.WindowState := wsNormal;
  end
  else
  begin
    if ADefaultX <> -1 then
      AForm.Left := ADefaultX;
    if ADefaultY <> -1 then
      AForm.Top := ADefaultY;
  end;

  if AForm.Left + AForm.Width > Screen.DesktopWidth then
    AForm.Left := Screen.DesktopWidth - AForm.Width;
  if AForm.Top + AForm.Height > Screen.DesktopHeight then
    AForm.Top := Screen.DesktopHeight - AForm.Top;
  if AForm.Left < 0 then
    AForm.Left := 0;
  if AForm.Top < 0 then
    AForm.Top := 0;
end;


////////////////////////////////////////////////////////////////////////////////

function TSettings.GetStringValue(const AIndex: Integer): String;
var
  o: ISuperObject;
  field, default_value: String;
begin
  case AIndex of
    PROPINDEX_LOGIN_USERNAME: begin
      field := JSON_LOGIN_USERNAME;
      default_value := DEFAULT_LOGIN_USERNAME;
    end;
    PROPINDEX_LOGIN_PASSWORD: begin
      field := JSON_LOGIN_PASSWORD;
      default_value := DEFAULT_LOGIN_PASSWORD;
    end;
  else
    SoftException(Format('TSettings.GetStringValue(%d): index not found', [AIndex]));
    Exit;
  end;

  o := FJSON.O[field];
  if not Assigned(o) then
    result := default_value
  else
    result := o.AsString;
end;

function TSettings.GetIntegerValue(const AIndex: Integer): Int64;
var
  o: ISuperObject;
  field: String;
  default_value: Integer;
begin
  case AIndex of
    PROPINDEX_SERVER_INDEX: begin
      field := JSON_SERVER_INDEX;
      default_value := DEFAULT_SERVER_INDEX;
    end;
  else
    SoftException(Format('TSettings.GetIntegerValue(%d): index not found', [AIndex]));
    Exit(0);
  end;

  o := FJSON.O[field];
  if not Assigned(o) then
    result := default_value
  else
    result := o.AsInteger;
end;

function TSettings.GetBooleanValue(const AIndex: Integer): Boolean;
var
  o: ISuperObject;
  field: String;
  default_value: Boolean;
begin
  case AIndex of
    PROPINDEX_REMEMBER_LOGIN: begin
      field := JSON_REMEMBER_LOGIN;
      default_value := DEFAULT_REMEMBER_LOGIN;
    end;
    PROPINDEX_REMEMBER_PASSWORD: begin
      field := JSON_REMEMBER_PASSWORD;
      default_value := DEFAULT_REMEMBER_PASSWORD;
    end;
    PROPINDEX_DEVELOPER_MODE: begin
      field := JSON_DEVELOPER_MODE;
      default_value := DEFAULT_DEVELOPER_MODE;
    end;
    PROPINDEX_SOUNDS: begin
      field := JSON_SOUNDS;;
      default_value := DEFAULT_SOUNDS;
    end;
    PROPINDEX_FOLD_CHECKS: begin
      field := JSON_FOLD_CHECKS;
      default_value := DEFAULT_FOLD_CHECKS;
    end;
    PROPINDEX_ANIMATIONS: begin
      field := JSON_ANIMATIONS;
      default_value := DEFAULT_ANIMATIONS;
    end;
    PROPINDEX_FOLD_CONFIRMATION: begin
      field := JSON_FOLD_CONFIRMATION;
      default_value := DEFAULT_FOLD_CONFIRMATION;
    end;
    PROPINDEX_ALWAYS_RUN_TWICE: begin
      field := JSON_ALWAYS_RUN_IT_TWICE;
      default_value := DEFAULT_ALWAYS_RUN_IT_TWICE;
    end;
  else
    SoftException(Format('TSettings.GetBooleanValue(%d): index not found', [AIndex]));
    Exit(FALSE);
  end;

  o := FJSON.O[field];
  if not Assigned(o) then
    result := default_value
  else
    result := o.AsBoolean;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TSettings.SetStringValue(const AIndex: Integer; const AValue: String);
var
  field_name: String;
begin
  case AIndex of
    PROPINDEX_LOGIN_USERNAME: field_name := JSON_LOGIN_USERNAME;
    PROPINDEX_LOGIN_PASSWORD: field_name := JSON_LOGIN_PASSWORD;
  else
    SoftException(Format('TSettings.SetStringValue(%d, %s): index not found', [AIndex, AValue]));
    Exit;
  end;

  FJSON.S[field_name] := AValue;
end;

procedure TSettings.SetIntegerValue(const AIndex: Integer; const AValue: Int64);
var
  field_name: String;
begin
  case AIndex of
    PROPINDEX_SERVER_INDEX: field_name := JSON_SERVER_INDEX;
  else
    SoftException(Format('TSettings.SetIntegerValue(%d, %d): index not found', [AIndex, AValue]));
    Exit;
  end;

  FJSON.I[field_name] := AValue;
end;

procedure TSettings.SetBooleanValue(const AIndex: Integer; const AValue: Boolean);
var
  field_name: String;
begin
  case AIndex of
    PROPINDEX_REMEMBER_LOGIN: field_name := JSON_REMEMBER_LOGIN;
    PROPINDEX_REMEMBER_PASSWORD: field_name:= JSON_REMEMBER_PASSWORD;
    PROPINDEX_DEVELOPER_MODE: field_name:= JSON_DEVELOPER_MODE;
    PROPINDEX_SOUNDS: field_name:= JSON_SOUNDS;
    PROPINDEX_FOLD_CHECKS: field_name:= JSON_FOLD_CHECKS;
    PROPINDEX_ANIMATIONS: field_name:= JSON_ANIMATIONS;
    PROPINDEX_FOLD_CONFIRMATION: field_name:= JSON_FOLD_CONFIRMATION;
    PROPINDEX_ALWAYS_RUN_TWICE: field_name:= JSON_ALWAYS_RUN_IT_TWICE;
  else
    SoftException(Format('TSettings.SetIntegerValue(%d, %s): index not found', [AIndex, BoolToStr(AValue, TRUE)]));
    Exit;
  end;

  FJSON.B[field_name] := AValue;
end;

end.
