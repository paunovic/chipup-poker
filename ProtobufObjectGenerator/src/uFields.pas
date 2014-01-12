unit uFields;

interface

uses
  System.Generics.Collections;

type
  TFieldVarType = (fvtUnknown, fvtInt32, fvtString, fvtBoolean, fvtBytes, fvtClass);
  TFieldType    = (ftUnknown, ftRequired, ftOptional, ftRepeated);

  TField = class
  private
    FValid     : Boolean;
    FType      : TFieldType;
    FVarTypeStr: String;
    FVarType   : TFieldVarType;
    FName      : String;
    FTag       : Integer;

    function StringToFieldType(const AString: String): TFieldType;
    function StringToFieldVarType(const AString: String): TFieldVarType;
    function GetConst: String;
    function GetPrivateProperty: String;
    function GetPublicProperty: String;
    function GetVarTypeAsString: String;
    function GetProtobufReadFunction: String;
    function GetEmptyValue: String;
    function GetProtobufWriteFunction: String;
    function GetWireTypeConstant: String;

  public
    constructor Create(const ALine: String);

    property IsValid: Boolean read FValid;
    property FieldType: TFieldType read FType;
    property VarType: TFieldVarType read FVarType;
    property Name: String read FName;
    property Tag: Integer read FTag;

    property AsConst: String read GetConst;
    property AsPublicProperty: String read GetPublicProperty;
    property AsPrivateProperty: String read GetPrivateProperty;
    property VarTypeString: String read GetVarTypeAsString;
    property ProtobufReadFunction: String read GetProtobufReadFunction;
    property ProtobufWriteFunction: String read GetProtobufWriteFunction;
    property EmptyValue: String read GetEmptyValue;
    property WireTypeConstant: String read GetWireTypeConstant;
  end;

  TFields = TObjectList<TField>;

implementation

uses
  System.SysUtils;


constructor TField.Create(const ALine: String);
var
  tmp : String;
  wpos: Integer;
  line: String;
begin
  FValid := FALSE;

  line := Trim(ALine);
  if line = '' then
    Exit;
  if line[Length(line)] <> ';' then
    Exit;
  Delete(line, Length(line), 1);

  wpos := Pos(' ', line);
  if wpos = 0 then
    Exit;
  tmp := LowerCase(Copy(line, 1, wpos - 1));
  Delete(line, 1, Length(tmp) + 1);

  FType := StringToFieldType(tmp);

  wpos := Pos(' ', line);
  if wpos = 0 then
    Exit;
  tmp := Copy(line, 1, wpos - 1);
  Delete(line, 1, Length(tmp) + 1);

  FVarTypeStr := tmp;
  FVarType := StringToFieldVarType(LowerCase(FVarTypeStr));

  wpos := Pos(' ', line);
  if wpos = 0 then
    Exit;
  tmp := Copy(line, 1, wpos - 1);
  Delete(line, 1, Length(tmp) + 1);

  FName := tmp;

  wpos := Pos('=', line);
  if wpos = 0 then
    Exit;
  Delete(line, 1, wpos);
  line := Trim(line);

  wpos := Pos('[', line);
  if wpos > 0 then
    line := Trim(Copy(line, 1, wpos - 1));

  if not TryStrToInt(Trim(line), FTag) then
    Exit;

  FValid := TRUE;
end;

function TField.StringToFieldType(const AString: String): TFieldType;
begin
  if AString = 'required' then
    Exit(ftRequired);

  if AString = 'optional' then
    Exit(ftOptional);

  if AString = 'repeated' then
    Exit(ftRepeated);

  Exit(ftUnknown);
end;

function TField.StringToFieldVarType(const AString: String): TFieldVarType;
begin
  if AString = 'int32' then
    Exit(fvtInt32);

  if AString = 'string' then
    Exit(fvtString);

  if AString = 'bool' then
    Exit(fvtBoolean);

  if AString = 'bytes' then
    Exit(fvtBytes);

  Exit(fvtClass);
end;

function TField.GetConst: String;
begin
  result := Format('FN_%s', [UpperCase(AsPublicProperty)]);
end;

function TField.GetPrivateProperty: String;
begin
  result := 'F' + GetPublicProperty;
end;

function TField.GetPublicProperty: String;
var
  upos: Integer;
begin
  result := LowerCase(FName);
  upos := Pos('_', result);
  while upos > 0 do
  begin
    Delete(result, upos, 1);
    if upos <= Length(result) then
      result[upos] := UpCase(result[upos]);
    upos := Pos('_', result);
  end;
  result[1] := UpCase(result[1]);
end;

function TField.GetVarTypeAsString: String;
begin
  case FVarType of
    fvtUnknown: result := 'Unknown';
    fvtClass: result := 'TPB_' + FVarTypeStr;
    fvtInt32: result := 'Integer';
    fvtString: result := 'AnsiString';
    fvtBoolean: result := 'Boolean';
    fvtBytes: result := 'TBytes';
  end;

  case FType of
    ftRepeated: result := Format('TArray<%s>', [result]);
  end;
end;

function TField.GetProtobufReadFunction: String;
begin
  case FVarType of
    fvtUnknown: result := 'readUnknown';
    fvtClass: result := 'readClass';
    fvtInt32: result := 'readInt32';
    fvtString: result := 'readString';
    fvtBoolean: result := 'readBoolean';
    fvtBytes: result := Format('readBytes(%s)', [AsPrivateProperty]);
  end;
end;

function TField.GetProtobufWriteFunction: String;
begin
  case FVarType of
    fvtUnknown: result := 'writeUnknown';
    fvtInt32: result := 'writeInt32';
    fvtString: result := 'writeString';
    fvtBoolean: result := 'writeBoolean';
    fvtClass: result := 'writeClass';
    fvtBytes: result := Format('writeRawData(@%s[0], Length(%s))', [AsPrivateProperty, AsPrivateProperty]);
  end;
end;

function TField.GetEmptyValue: String;
begin
  case FVarType of
    fvtUnknown: result := 'UNKNOWN';
    fvtInt32: result := '0';
    fvtString: result := '''''';
    fvtBoolean: result := 'FALSE';
    fvtBytes: result := '''''';
  end;
end;

function TField.GetWireTypeConstant: String;
begin
  case FVarType of
    fvtUnknown: result := 'WIRETYPE_UNKNOWN';
    fvtClass: result := 'WIRETYPE_LENGTH_DELIMITED';
    fvtInt32: result := 'WIRETYPE_VARINT';
    fvtString: result := 'WIRETYPE_LENGTH_DELIMITED';
    fvtBoolean: result := 'WIRETYPE_VARINT';
    fvtBytes: result := 'WIRETYPE_LENGTH_DELIMITED';
  end;
end;

end.
