unit Poker.Protobufs.Reader;

interface

uses
  Winapi.Windows, System.SysUtils,
  pbInput, pbPublic;

type
  TProtobufReader = class(TProtoBufInput)
  private
    FSize: Integer;
  public
    constructor Create(const APointer: pointer; const ASize: DWORD);
    function GetNext(out ATag, AWireType, AFieldNumber: Integer): Boolean;
    function readBytes: TBytes;

    property Buffer: PAnsiChar read FBuffer;
    property BufferPos: Integer read FPos;
    property Size: Integer read FSize;
  end;

implementation

uses
  System.Classes;


constructor TProtobufReader.Create(const APointer: pointer; const ASize: DWORD);
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
  SetLength(Result, bsize);
  readRawBytes(Result[0], bsize);
end;

end.
