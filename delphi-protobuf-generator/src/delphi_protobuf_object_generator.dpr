{$APPTYPE CONSOLE}

program delphi_protobuf_object_generator;

uses
  System.SysUtils,
  uFields in 'uFields.pas',
  uGenerator in 'uGenerator.pas';

var
  input_file, output_path: String;

procedure Work;
var
  sfile   : TextFile;
  line    : String;
  wpos    : Integer;
  fields  : TFields;
  field   : TField;
  msg_name: String;
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

        msg_name := line;

        fields := TFields.Create;
        try
          while not Eof(sfile) do
          begin
            ReadLn(sfile, line);
            if Trim(line) = '}'  then
              Break;
            field := TField.Create(line);
            if field.IsValid then
              fields.Add(field)
            else
              WriteLn(Format('Invalid field [%s]', [line]));
          end;

          TGenerator.Generate(msg_name, fields, Format('%su%s.pas', [IncludeTrailingPathDelimiter(output_path), msg_name]));
        finally
          fields.Free;
        end;
      end;
    end;
  finally
    CloseFile(sfile);
  end;
end;

begin
  input_file := ExpandFileName(ParamStr(1));
  output_path := ExpandFileName(ParamStr(2));
  Work;
end.
