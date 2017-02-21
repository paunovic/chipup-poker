unit Poker.Protobufs.Reader;

interface

uses
  Winapi.Windows, System.SysUtils, pbInput, pbPublic, Poker.Types;

type
  TProtobufReader = class(TProtoBufInput)
  private
    FSize: Integer;
  public
    constructor Create(const APointer: pointer; const ASize: Integer);
    function GetNext(out ATag, AWireType, AFieldNumber: Integer): Boolean;
    function readBytes: TBytes;
    function readMongoId: TMongoId;

    property Size: Integer read FSize;
    property Buffer: PAnsiChar read FBuffer;
    property BufferPos: Integer read FPos;
  end;

implementation

uses
  System.Classes;


constructor TProtobufReader.Create(const APointer: pointer; const ASize: Integer);
var
  mstream: TMemoryStream;
begin
  inherited Create;

  mstream := TMemoryStream.Create;
  try
    mstream.WriteBuffer(APointer^, ASize);
    FSize := ASize;
    LoadFromStream(mstream);
  finally
    mstream.Free;
  end;
end;

function TProtobufReader.GetNext(out ATag, AWireType, AFieldNumber: Integer): Boolean;
begin
  if getPos >= FSize then
    Exit(FALSE);

  ATag := self.readTag;
  AWireType := getTagWireType(ATag);
  AFieldNumber := getTagFieldNumber(ATag);
  Exit(TRUE);
end;

function TProtobufReader.readBytes: TBytes;
var
  bsize: Integer;
begin
  bsize := readInt32;
  SetLength(result, bsize);
  readRawBytes(result[0], bsize);
end;

function TProtobufReader.readMongoId: TMongoId;
var
  bsize: Integer;
begin
  bsize := readInt32;
  Assert(bsize = 12, Format('Received MongoId with invalid length [%d]', [bsize]));
  readRawBytes(result.Memory^, bsize);
end;

end.
