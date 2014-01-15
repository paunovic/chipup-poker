unit uGenerator;

interface

uses
  uFields;

type
  TGenerator = class
    class procedure Generate(const AMessageName: String; const AFields: TFields; const AOutputFile: String);
  end;

implementation

uses
  System.Classes, System.SysUtils;


class procedure TGenerator.Generate(const AMessageName: String; const AFields: TFields; const AOutputFile: String);
var
  fwriter            : TStreamWriter;
  C1                 : Integer;
  writable_properties: Boolean;
begin
  writable_properties := Pos('Reply', AMessageName) = 0;

  ForceDirectories(ExtractFilePath(AOutputFile));
  fwriter := TStreamWriter.Create(AOutputFile);
  try
    fwriter.WriteLine(Format('unit uPB_%s;', [AMessageName]));
    fwriter.WriteLine();
    fwriter.WriteLine('interface');
    fwriter.WriteLine();
    fwriter.WriteLine('uses');
    fwriter.WriteLine('  Winapi.Windows, pbOutput, uProtobufBaseObject, uProtobufReader;');
    fwriter.WriteLine();
    fwriter.WriteLine('type');
    fwriter.WriteLine(Format('  TPB_%s = class(TProtobufBaseObject)', [AMessageName]));
    fwriter.WriteLine('  private');
    fwriter.WriteLine('    const');
    for C1 := 0 to AFields.Count - 1 do
      fwriter.WriteLine(Format('      %s = %d;', [AFields[C1].AsConst, AFields[C1].Tag]));
    fwriter.WriteLine();
    fwriter.WriteLine('    var');
    for C1 := 0 to AFields.Count - 1 do
      fwriter.WriteLine(Format('      %s: %s;', [AFields[C1].AsPrivateProperty, AFields[C1].VarTypeString]));
    fwriter.WriteLine();
    for C1 := 0 to AFields.Count - 1 do
      fwriter.WriteLine(Format('    procedure Set%s(const AValue: %s);', [AFields[C1].AsPublicProperty, AFields[C1].VarTypeString]));
    fwriter.WriteLine();
    fwriter.WriteLine('  public');
    fwriter.WriteLine('    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;');
    fwriter.WriteLine('    function GetProtobuf: TProtoBufOutput; override;');
    fwriter.WriteLine();
    for C1 := 0 to AFields.Count - 1 do
    begin
      fwriter.Write(Format('    property %s: %s read %s', [AFields[C1].AsPublicProperty, AFields[C1].VarTypeString, AFields[C1].AsPrivateProperty]));
      if writable_properties then
        fwriter.Write(Format(' write Set%s', [AFields[C1].AsPublicProperty]));
      fwriter.WriteLine(';');
    end;
    fwriter.WriteLine('  end;');
    fwriter.WriteLine();
    if not writable_properties then
    begin
      fwriter.WriteLine(Format('//  TPB_%ss = TObjectList<TPB_%s>;', [AMessageName, AMessageName]));
      fwriter.WriteLine();
    end;
    fwriter.WriteLine('implementation');
    fwriter.WriteLine();
    fwriter.WriteLine('uses');
    fwriter.WriteLine('  pbPublic;');
    fwriter.WriteLine();
    fwriter.WriteLine(Format('procedure TPB_%s.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);', [AMessageName]));
    fwriter.WriteLine('var');
    fwriter.WriteLine('  tag, wire_type, field_number, endpos: Integer;');
    fwriter.WriteLine('begin');
    fwriter.WriteLine('  endpos := AProtobufReader.getPos + ASize;');
    fwriter.WriteLine('  while (AProtobufReader.getPos < endpos) and');
    fwriter.WriteLine('        (AProtobufReader.GetNext(tag, wire_type, field_number)) do');
    fwriter.WriteLine('    case field_number of');
    for C1 := 0 to AFields.Count - 1 do
    begin
      fwriter.WriteLine(Format('      %s: begin', [AFields[C1].AsConst]));
      fwriter.WriteLine(Format('        Assert(wire_type = %s);', [AFields[C1].WireTypeConstant]));
      fwriter.WriteLine(Format('        Set%s(AProtobufReader.%s);', [AFields[C1].AsPublicProperty, AFields[C1].ProtobufReadFunction]));
      fwriter.WriteLine('      end;');
    end;
    fwriter.WriteLine('    else');
    fwriter.WriteLine('      AProtobufReader.skipField(tag);');
    fwriter.WriteLine('    end;');
    fwriter.WriteLine('end;');
    fwriter.WriteLine();
    fwriter.WriteLine(Format('function TPB_%s.GetProtobuf: TProtoBufOutput;', [AMessageName]));
    fwriter.WriteLine('var');
    fwriter.WriteLine('  pbout: TProtoBufOutput;');
    fwriter.WriteLine('begin');
    fwriter.WriteLine('  pbout := TProtoBufOutput.Create;');
    for C1 := 0 to AFields.Count - 1 do
    begin
      fwriter.WriteLine(Format('  if IsModifiedField(%s) then', [AFields[C1].AsConst]));
      fwriter.WriteLine(Format('    pbout.%s(%s, %s);', [AFields[C1].ProtobufWriteFunction, AFields[C1].AsConst, AFields[C1].AsPrivateProperty]));
    end;
    fwriter.WriteLine('  result := pbout;');
    fwriter.WriteLine('end;');
    fwriter.WriteLine();
    for C1 := 0 to AFields.Count - 1 do
    begin
      fwriter.WriteLine(Format('procedure TPB_%s.Set%s(const AValue: %s);', [AMessageName, AFields[C1].AsPublicProperty, AFields[C1].VarTypeString]));
      fwriter.WriteLine('begin');
      fwriter.WriteLine(Format('  %s := AValue;', [AFields[C1].AsPrivateProperty]));
      fwriter.WriteLine(Format('  AddModifiedField(%s);', [AFields[C1].AsConst]));
      fwriter.WriteLine('end;');
      fwriter.WriteLine();
    end;
    fwriter.WriteLine('end.');

  finally
    fwriter.Free;
  end;
end;

end.
