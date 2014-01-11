unit uProtobufReader;

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
    procedure readMongoId(var ABytes: TBytes);

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

procedure TProtobufReader.readMongoId(var ABytes: TBytes);
var
  bsize: Integer;
begin
  bsize := readInt32;
  SetLength(ABytes, bsize);
  readRawBytes(ABytes[0], bsize);
end;

end.
