unit uProtobufBaseObject;

interface

uses
  Winapi.Windows, System.Classes, pbOutput, uProtobufReader;

type
  TProtobufBaseObject = class
  public
    constructor Create(const APointer: pointer; const ASize: Integer); overload;
    constructor Create(const AProtobufReader: TProtobufReader; const ASize: Integer); overload;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); virtual; abstract;

    function GetProtobuf: TProtoBufOutput; virtual; abstract;
    function GetProtobufSize: Integer;
    procedure WriteToStream(const AStream: TStream);
  end;

implementation


constructor TProtobufBaseObject.Create(const APointer: pointer; const ASize: Integer);
var
  protobuf_reader: TProtobufReader;
begin
  protobuf_reader := TProtobufReader.Create(APointer, ASize);
  try
    LoadFromProtobufReader(protobuf_reader, ASize);
  finally
    protobuf_reader.Free;
  end;
end;

constructor TProtobufBaseObject.Create(const AProtobufReader: TProtobufReader; const ASize: Integer);
begin
  LoadFromProtobufReader(AProtobufReader, ASize);
end;

function TProtobufBaseObject.GetProtobufSize: Integer;
var
  pbo: TProtoBufOutput;
begin
  pbo := GetProtobuf;
  try
    result := pbo.getSerializedSize;
  finally
    pbo.Free;
  end;
end;

procedure TProtobufBaseObject.WriteToStream(const AStream: TStream);
var
  pboutput: TProtoBufOutput;
begin
  pboutput := GetProtobuf;
  try
    pboutput.SaveToStream(AStream);
  finally
    pboutput.Free;
  end;
end;

end.
