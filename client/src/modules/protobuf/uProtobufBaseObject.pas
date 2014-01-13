unit uProtobufBaseObject;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils, pbOutput, uProtobufReader;

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

  TProtobufOutputHelper = class helper for TProtobufOutput
  public
    procedure writeBytes(const AFieldNumber: Integer; const ABytes: TBytes);
  end;

implementation

uses
  pbPublic;


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

{ TProtobufOutputHelper }

procedure TProtobufOutputHelper.writeBytes(const AFieldNumber: Integer; const ABytes: TBytes);
begin
  writeTag(AFieldNumber, WIRETYPE_LENGTH_DELIMITED);
  writeRawVarint32(Length(ABytes));
  writeRawData(@ABytes[0], Length(ABytes));
end;

end.
