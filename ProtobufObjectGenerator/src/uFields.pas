unit uFields;

interface

uses
  System.Generics.Collections;

type
  TFieldType = (ftUnknown, ftInteger, ftString, ftBoolean);

  TField = class
  private
    FRequired: Boolean;
    FName    : String;
    FTag     : Integer;
    FTypeStr : String;
    FType    : TFieldType;

    function GetFieldReadMethod: String;
    function GetFieldTypeDelphi: String;
    function GetOptionalCheckValue: String;
    function GetFieldWriteMethod: String;

  public
    constructor Create(const ALine: String);

    property Required: Boolean read FRequired;
    property Name: String read FName;
    property Tag: Integer read FTag;
    property FieldType: TFieldType read FType;
    property FieldTypeStr: String read FTypeStr;
    property FieldTypeDelphi: String read GetFieldTypeDelphi;
    property FieldReadMethod: String read GetFieldReadMethod;
    property FieldWriteMethod: String read GetFieldWriteMethod;
    property OptionalCheckValue: String read GetOptionalCheckValue;
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
  line := ALine;
  wpos := Pos(' ', line);
  if wpos = 0 then
    Exit;
  tmp := LowerCase(Copy(line, 1, wpos - 1));
  Delete(line, 1, Length(tmp) + 1);

  FRequired := tmp = 'required';

  wpos := Pos(' ', line);
  if wpos = 0 then
    Exit;
  tmp := LowerCase(Copy(line, 1, wpos - 1));
  Delete(line, 1, Length(tmp) + 1);

  FType := ftUnknown;
  FTypeStr := tmp;
  if FTypeStr = 'int32' then
    FType := ftInteger;
  if FTypeStr = 'string' then
    FType := ftString;
  if FTypeStr = 'bool' then
    FType := ftBoolean;

  wpos := Pos(' ', line);
  if wpos = 0 then
    Exit;
  tmp := Copy(line, 1, wpos - 1);
  Delete(line, 1, Length(tmp) + 1);

  FName := tmp;

  wpos := Pos(' ', line);
  if wpos = 0 then
    Exit;
  tmp := LowerCase(Copy(line, 1, wpos - 1));
  Delete(line, 1, Length(tmp) + 1);
  Delete(line, Length(line), 1);

  FTag := StrToInt(Trim(line));
end;

function TField.GetFieldReadMethod: String;
begin
  case FType of
    ftInteger: result := 'readInt32';
    ftString: result := 'readString';
    ftBoolean: result := 'readBoolean';
  else
    result := 'read' + FTypeStr;
  end;
end;

function TField.GetFieldWriteMethod: String;
begin
  case FType of
    ftInteger: result := 'writeInt32';
    ftString: result := 'writeString';
    ftBoolean: result := 'writeBoolean';
  else
    result := 'write' + FTypeStr;
  end;
end;

function TField.GetFieldTypeDelphi: String;
begin
  case FType of
    ftInteger: result := 'Integer';
    ftString: result := 'AnsiString';
    ftBoolean: result := 'Boolean';
  else
    result := FTypeStr;
  end;
end;

function TField.GetOptionalCheckValue: String;
begin
  case FType of
    ftInteger: result := '-1';
    ftString: result := '''''';
    ftBoolean: result := 'FALSE';
  else
    result := 'UNKNOWN';
  end;
end;

end.
