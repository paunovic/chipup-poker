{$APPTYPE CONSOLE}

program ProtobufObjectGenerator;

uses
  System.SysUtils,
  uFields in 'uFields.pas';

var
  input_file: String;

procedure ProcessObject(const AFile: TextFile; const AObjectName: String);
var
  tfile     : TextFile;
  fields    : TFields;
  line      : String;
  C1        : Integer;
  cc        : String;
  whitespace: String;
begin
  WriteLn(Format('Creating u%s.pas...', [AObjectName]));

  fields := TFields.Create;
  try
    while not Eof(AFile) do
    begin
      ReadLn(AFile, line);
      if Trim(line) = '}' then
        Break;

      fields.Add(TField.Create(Trim(line)));
    end;

    AssignFile(tfile, Format('uPB_%s.pas', [AObjectName]));
    Rewrite(tfile);
    try
      WriteLn(tfile, Format('unit uPB_%s;', [AObjectName]));
      WriteLn(tfile);
      WriteLn(tfile, 'interface');
      WriteLn(tfile);
      WriteLn(tfile, 'uses');
      WriteLn(tfile, '  Winapi.Windows, System.Classes, pbOutput, uProtobufBaseObject, uProtobufReader;');
      WriteLn(tfile);
      WriteLn(tfile, 'type');
      WriteLn(tfile, Format('  TPB_%s = class(TProtobufBaseObject)', [AObjectName]));
      WriteLn(tfile, '  private');
      WriteLn(tfile, '    const');
      for C1 := 0 to fields.Count - 1 do
        WriteLn(tfile, Format('      FN_%s = %d;', [UpperCase(fields[C1].Name), fields[C1].Tag]));
      WriteLn(tfile);
      WriteLn(tfile, '    var');
      for C1 := 0 to fields.Count - 1 do
        WriteLn(tfile, Format('      F%s: %s;', [fields[C1].Name, fields[C1].FieldTypeDelphi]));
      WriteLn(tfile);
      WriteLn(tfile, '  public');
      cc := '';
      for C1 := 0 to fields.Count - 1 do
      begin
        cc := cc + Format('const A%s: %s', [fields[C1].Name, fields[C1].FieldTypeDelphi]);
        if C1 < fields.Count - 1 then
          cc := cc + '; ';
      end;
      cc := cc + ');';
      WriteLn(tfile, '    constructor Create(' + cc + ' overload;');
      WriteLn(tfile);
      WriteLn(tfile, '    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader); override;');
      WriteLn(tfile, '    function GetProtobuf: TProtoBufOutput; override;');
      WriteLn(tfile);
      for C1 := 0 to fields.Count - 1 do
        WriteLn(tfile, Format('    property %s: %s read F%s;', [fields[C1].Name, fields[C1].FieldTypeDelphi, fields[C1].Name]));
      WriteLn(tfile, '  end;');
      WriteLn(tfile);
      WriteLn(tfile, 'implementation');
      WriteLn(tfile);
      WriteLn(tfile, 'uses');
      WriteLn(tfile, '  System.SysUtils, pbPublic;');
      WriteLn(tfile);
      WriteLn(tfile);
      WriteLn(tfile, Format('constructor TPB_%s.Create(', [AObjectName]) + cc);
      WriteLn(tfile, 'begin');
      for C1 := 0 to fields.Count - 1 do
        WriteLn(tfile, Format('  F%s := A%s;', [fields[C1].Name, fields[C1].Name]));
      WriteLn(tfile, 'end;');
      WriteLn(tfile);
      WriteLn(tfile, Format('procedure TPB_%s.LoadFromProtobufReader(const AProtobufReader: TProtobufReader);', [AObjectName]));
      WriteLn(tfile, 'var');
      WriteLn(tfile, '  tag         : Integer;');
      WriteLn(tfile, '  wire_type   : Integer;');
      WriteLn(tfile, '  field_number: Integer;');
      WriteLn(tfile, '  size, endpos: Integer;');
      WriteLn(tfile, 'begin');
      for C1 := 0 to fields.Count - 1 do
        if fields[C1].FieldType = ftInteger then
          WriteLn(tfile, Format('  F%s := -1;', [fields[C1].Name]));

      WriteLn(tfile, '  size := AProtobufReader.readInt32;');
      WriteLn(tfile, '  endpos := AProtobufReader.getPos + size;');
      WriteLn(tfile, '  while (AProtobufReader.getPos < endpos) and');
      WriteLn(tfile, '        (AProtobufReader.GetNext(tag, wire_type, field_number)) do');
      WriteLn(tfile, '    case field_number of');
      for C1 := 0 to fields.Count - 1 do
        WriteLn(tfile, Format('      FN_%s: F%s := AProtobufReader.%s;', [UpperCase(fields[C1].Name), fields[C1].Name, fields[C1].FieldReadMethod]));
      WriteLn(tfile, '    else');
      WriteLn(tfile, '      AProtobufReader.skipField(tag);');
      WriteLn(tfile, '    end;');
      WriteLn(tfile, 'end;');
      WriteLn(tfile);
      WriteLn(tfile, Format('function TPB_%s.GetProtobuf: TProtoBufOutput;', [AObjectName]));
      WriteLn(tfile, 'var');
      WriteLn(tfile, '  pboutput: TProtoBufOutput;');
      WriteLn(tfile, 'begin');
      WriteLn(tfile, '  pboutput := TProtoBufOutput.Create;');
      for C1 := 0 to fields.Count - 1 do
      begin
        if not fields[C1].Required then
        begin
          WriteLn(tfile, Format('  if F%s <> %s then', [fields[C1].Name, fields[C1].OptionalCheckValue]));
          whitespace := '  ';
        end
        else
          whitespace := '';
        WriteLn(tfile, Format('  %spboutput.%s(FN_%s, F%s);', [whitespace, fields[C1].FieldWriteMethod, UpperCase(fields[C1].Name), fields[C1].Name]));
      end;
      WriteLn(tfile, '  result := pboutput;');
      WriteLn(tfile, 'end;');
      WriteLn(tfile);
      WriteLn(tfile, 'end.');
    finally
      CloseFile(tfile);
    end;
  finally
    fields.Free;
  end;
end;

procedure Work;
var
  sfile: TextFile;
  line : String;
  wpos : Integer;
begin
  AssignFile(sfile, input_file);
  Reset(sfile);
  try
    while not Eof(sfile) do
    begin
      ReadLn(sfile, line);
      line := Trim(line);
      wpos := Pos(' ', line);
      if wpos = 0 then
        Continue;

      if LowerCase(Copy(line, 1, wpos - 1)) = 'message' then
      begin
        Delete(line, 1, wpos);
        if line = '' then
          Continue;

        if line[Length(line)] <> '{' then
          Continue;

        Delete(line, Length(line), 1);
        line := Trim(line);

        ProcessObject(sfile, line);
      end;
    end;
  finally
    CloseFile(sfile);
  end;
end;

begin
  input_file := ParamStr(1);
  Work;
  Write('Done!');
  ReadLn;
end.
