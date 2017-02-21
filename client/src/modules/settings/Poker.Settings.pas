unit Poker.Settings;

interface

uses
  superobject, Poker.HardcodedSettings, Vcl.Forms;

type
  TSettings = class(THardcodedSettings)
  private
    const
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
      PROPINDEX_FORMS_SETTINGS = 12;

      JSON_INDEX_FORM_NAME = 1;
      JSON_INDEX_FORM_MAXIMIZED = 2;
      JSON_INDEX_FORM_X = 3;
      JSON_INDEX_FORM_Y = 4;
      JSON_INDEX_FORM_W = 5;
      JSON_INDEX_FORM_H = 6;

      STRING_FIELDS = [PROPINDEX_LOGIN_USERNAME, PROPINDEX_LOGIN_PASSWORD];
      INTEGER_FIELDS = [PROPINDEX_SERVER_INDEX];
      BOOLEAN_FIELDS = [PROPINDEX_REMEMBER_LOGIN, PROPINDEX_REMEMBER_PASSWORD, PROPINDEX_DEVELOPER_MODE, PROPINDEX_SOUNDS,
                        PROPINDEX_FOLD_CHECKS, PROPINDEX_ANIMATIONS, PROPINDEX_FOLD_CONFIRMATION, PROPINDEX_ALWAYS_RUN_TWICE];

    function GetStringValue(const AIndex: Integer): String;
    procedure SetStringValue(const AIndex: Integer; const AValue: String);
    function GetIntegerValue(const AIndex: Integer): Int64;
    procedure SetIntegerValue(const AIndex: Integer; const AValue: Int64);
    function GetBooleanValue(const AIndex: Integer): Boolean;
    procedure SetBooleanValue(const AIndex: Integer; const AValue: Boolean);

    var
      FJSON: ISuperObject;

  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
    function Load(const ABlob: RawByteString): Boolean;
    function AsBlob: RawByteString;
    procedure SaveFormSettings(const AForm: TForm);
    procedure LoadFormSettings(const AForm: TForm; const ADefaultX, ADefaultY: Integer);
    procedure ResetToDefaults;

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
  Poker.SoftExceptions, System.Classes, System.SysUtils, Poker.Common.Misc, Poker.Common.Encryption;


class procedure TSettings.Initialize;
begin
  Settings := TSettings.Create;
end;

class procedure TSettings.Deinitialize;
begin
  FreeAndNil(Settings);
end;

constructor TSettings.Create;
begin
  ResetToDefaults;
end;

procedure TSettings.ResetToDefaults;
begin
  FJSON := SA([]);
  FJSON.AsArray.S[PROPINDEX_LOGIN_USERNAME] := '';
  FJSON.AsArray.S[PROPINDEX_LOGIN_PASSWORD] := '';
  FJSON.AsArray.I[PROPINDEX_SERVER_INDEX] := 0;
  FJSON.AsArray.B[PROPINDEX_REMEMBER_LOGIN] := TRUE;
  FJSON.AsArray.B[PROPINDEX_REMEMBER_PASSWORD] := FALSE;
  FJSON.AsArray.B[PROPINDEX_DEVELOPER_MODE] := FALSE;
  FJSON.AsArray.B[PROPINDEX_SOUNDS] := TRUE;
  FJSON.AsArray.B[PROPINDEX_FOLD_CHECKS] := FALSE;
  FJSON.AsArray.B[PROPINDEX_ANIMATIONS] := TRUE;
  FJSON.AsArray.B[PROPINDEX_FOLD_CONFIRMATION] := FALSE;
  FJSON.AsArray.B[PROPINDEX_ALWAYS_RUN_TWICE] := FALSE;
  FJSON.AsArray.O[PROPINDEX_FORMS_SETTINGS] := SA([]);
end;

function TSettings.Load(const ABlob: RawByteString): Boolean;
var
  mstream: TMemoryStream;
begin
  result := FALSE;
  if ABlob = '' then
    Exit;

  mstream := TMemoryStream.Create;
  try
    mstream.WriteBuffer(ABlob[1], Length(ABlob));
    if (DecompressStream(mstream)) and
       (AES256EncryptStream(mstream, Hardcoded.SETTINGS_ENCRYPTION_KEY, FALSE)) then
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

function TSettings.AsBlob: RawByteString;
var
  mstream: TMemoryStream;
begin
  mstream := TMemoryStream.Create;
  try
    FJSON.SaveTo(mstream);
    if (AES256EncryptStream(mstream, Hardcoded.SETTINGS_ENCRYPTION_KEY, TRUE)) and
       (CompressStream(mstream)) then
    begin
      SetLength(result, mstream.Size);
      mstream.Position := 0;
      mstream.ReadBuffer(result[1], mstream.Size)
    end;
  finally
    mstream.Free;
  end;
end;

procedure TSettings.SaveFormSettings(const AForm: TForm);
var
  C1: Integer;
  forms_settings, formjson: ISuperObject;
begin
  forms_settings := FJSON.AsArray[PROPINDEX_FORMS_SETTINGS];

  formjson := nil;
  for C1 := forms_settings.AsArray.Length - 1 downto 0 do
    if forms_settings.AsArray.O[C1].AsArray.S[JSON_INDEX_FORM_NAME] = AForm.Name then
    begin
      formjson := forms_settings.AsArray.O[C1];
      forms_settings.AsArray.Delete(C1);
    end;

  if not Assigned(formjson) then
    formjson := SA([]);

  formjson.AsArray.S[JSON_INDEX_FORM_NAME] := AForm.Name;
  formjson.AsArray.B[JSON_INDEX_FORM_MAXIMIZED] := AForm.WindowState = wsMaximized;
  if AForm.WindowState <> wsMaximized then
  begin
    formjson.AsArray.I[JSON_INDEX_FORM_X] := AForm.Left;
    formjson.AsArray.I[JSON_INDEX_FORM_Y] := AForm.Top;
    formjson.AsArray.I[JSON_INDEX_FORM_W] := AForm.Width;
    formjson.AsArray.I[JSON_INDEX_FORM_H] := AForm.Height;
  end;

  forms_settings.AsArray.Add(formjson);
end;

procedure TSettings.LoadFormSettings(const AForm: TForm; const ADefaultX, ADefaultY: Integer);
var
  C1: Integer;
  forms_settings, formjson: ISuperObject;
begin
  formjson := nil;
  forms_settings := FJSON.AsArray[PROPINDEX_FORMS_SETTINGS];
  for C1 := 0 to forms_settings.AsArray.Length - 1 do
    if forms_settings.AsArray.O[C1].AsArray.S[JSON_INDEX_FORM_NAME] = AForm.Name then
    begin
      formjson := forms_settings.AsArray.O[C1];
      Break;
    end;

  if Assigned(formjson) then
  begin
    if Assigned(formjson.AsArray.O[JSON_INDEX_FORM_X]) then
      AForm.Left := formjson.AsArray.I[JSON_INDEX_FORM_X];
    if Assigned(formjson.AsArray.O[JSON_INDEX_FORM_Y]) then
      AForm.Top := formjson.AsArray.I[JSON_INDEX_FORM_Y];
    if Assigned(formjson.AsArray.O[JSON_INDEX_FORM_W]) then
      AForm.Width := formjson.AsArray.I[JSON_INDEX_FORM_W];
    if Assigned(formjson.AsArray.O[JSON_INDEX_FORM_H]) then
      AForm.Height := formjson.AsArray.I[JSON_INDEX_FORM_H];

    if formjson.AsArray.B[JSON_INDEX_FORM_MAXIMIZED] then
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
    AForm.Top := Screen.DesktopHeight - AForm.Height;
  if AForm.Left < 0 then
    AForm.Left := 0;
  if AForm.Top < 0 then
    AForm.Top := 0;
end;

function TSettings.GetStringValue(const AIndex: Integer): String;
begin
  result := '';
  if AIndex in STRING_FIELDS then
    result := FJSON.AsArray.S[AIndex]
  else
    SoftException(Format('TSettings.GetStringValue(%d): index not found', [AIndex]));
end;

function TSettings.GetIntegerValue(const AIndex: Integer): Int64;
begin
  result := 0;
  if AIndex in INTEGER_FIELDS then
    result := FJSON.AsArray.I[AIndex]
  else
    SoftException(Format('TSettings.GetIntegerValue(%d): index not found', [AIndex]));
end;

function TSettings.GetBooleanValue(const AIndex: Integer): Boolean;
begin
  result := FALSE;
  if AIndex in BOOLEAN_FIELDS then
    result := FJSON.AsArray.B[AIndex]
  else
    SoftException(Format('TSettings.GetBooleanValue(%d): index not found', [AIndex]));
end;

procedure TSettings.SetStringValue(const AIndex: Integer; const AValue: String);
begin
  if AIndex in STRING_FIELDS then
    FJSON.AsArray.S[AIndex] := AValue
  else
    SoftException(Format('TSettings.SetStringValue(%d, %s): index not found', [AIndex, AValue]));
end;

procedure TSettings.SetIntegerValue(const AIndex: Integer; const AValue: Int64);
begin
  if AIndex in INTEGER_FIELDS then
    FJSON.AsArray.I[AIndex] := AValue
  else
    SoftException(Format('TSettings.SetIntegerValue(%d, %d): index not found', [AIndex, AValue]));
end;

procedure TSettings.SetBooleanValue(const AIndex: Integer; const AValue: Boolean);
begin
  if AIndex in BOOLEAN_FIELDS then
    FJSON.AsArray.B[AIndex] := AValue
  else
    SoftException(Format('TSettings.SetIntegerValue(%d, %s): index not found', [AIndex, BoolToStr(AValue, TRUE)]));
end;

end.
