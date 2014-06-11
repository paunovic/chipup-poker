unit Poker.Protobufs.Objects.Base;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils, System.Generics.Collections, pbOutput, Poker.Protobufs.Reader;

type
  TProtobufBaseObject = class
  private
    FProtobufOutput: TProtoBufOutput;

    function GetProtobufOutputSize: Word;

  protected
    procedure InitObjects; virtual;
    procedure HookNotifiers; virtual;

  public
    constructor Create; overload;
    constructor Create(const APointer: pointer; const ASize: Integer); overload;
    constructor Create(const AStream: TMemoryStream); overload;
    constructor Create(const AProtobufReader: TProtobufReader; const ASize: Integer); overload;

    destructor Destroy; override;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); virtual; abstract;

    property ProtobufOutput: TProtoBufOutput read FProtobufOutput;
    property ProtobufOutputSize: Word read GetProtobufOutputSize;
  end;


implementation




constructor TProtobufBaseObject.Create;
begin
  InitObjects;
  FProtobufOutput := TProtobufOutput.Create;
end;

constructor TProtobufBaseObject.Create(const APointer: pointer; const ASize: Integer);
var
  protobuf_reader: TProtobufReader;
begin
  InitObjects;
  HookNotifiers;

  FProtobufOutput := TProtobufOutput.Create;
  FProtobufOutput.writeRawData(APointer, ASize);
  protobuf_reader := TProtobufReader.Create(APointer, ASize);
  try
    LoadFromProtobufReader(protobuf_reader, protobuf_reader.Size);
  finally
    protobuf_reader.Free;
  end;
end;

constructor TProtobufBaseObject.Create(const AProtobufReader: TProtobufReader; const ASize: Integer);
begin
  InitObjects;
  HookNotifiers;

  FProtobufOutput := TProtobufOutput.Create;
  FProtobufOutput.writeRawData(PAnsiChar(Integer(AProtobufReader.Buffer) + AProtobufReader.BufferPos), ASize);
  LoadFromProtobufReader(AProtobufReader, ASize);
end;

constructor TProtobufBaseObject.Create(const AStream: TMemoryStream);
var
  protobuf_reader: TProtobufReader;
begin
  InitObjects;

  FProtobufOutput := TProtobufOutput.Create;
  FProtobufOutput.writeRawData(AStream.Memory, AStream.Size);
  protobuf_reader := TProtobufReader.Create(AStream.Memory, AStream.Size);
  try
    LoadFromProtobufReader(protobuf_reader, protobuf_reader.Size);
  finally
    protobuf_reader.Free;
  end;

  HookNotifiers;
end;

destructor TProtobufBaseObject.Destroy;
begin
  FProtobufOutput.Free;

  inherited;
end;

function TProtobufBaseObject.GetProtobufOutputSize: Word;
begin
  result := FProtobufOutput.getSerializedSize;
end;

procedure TProtobufBaseObject.HookNotifiers;
begin
//
end;

procedure TProtobufBaseObject.InitObjects;
begin
//
end;


end.
