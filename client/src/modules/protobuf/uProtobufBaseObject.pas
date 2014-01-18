unit uProtobufBaseObject;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils, System.Generics.Collections, pbOutput, uProtobufReader;

type
  TProtobufBaseObject = class
  private
    FModifiedFields: TList<Integer>;
    FProtobufOutput: TProtoBufOutput;

    function GetProtobufOutputSize: Word;

  public
    constructor Create; overload;
    constructor Create(const APointer: pointer; const ASize: Integer); overload;
    constructor Create(const AProtobufReader: TProtobufReader; const ASize: Integer); overload;

    destructor Destroy; override;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); virtual; abstract;

    property ProtobufOutput: TProtoBufOutput read FProtobufOutput;
    property ProtobufOutputSize: Word read GetProtobufOutputSize;
  end;


implementation

uses
  pbPublic;


constructor TProtobufBaseObject.Create;
begin
  FProtobufOutput := TProtobufOutput.Create;
end;

constructor TProtobufBaseObject.Create(const APointer: pointer; const ASize: Integer);
var
  protobuf_reader: TProtobufReader;
begin
  FProtobufOutput := TProtobufOutput.Create;

  protobuf_reader := TProtobufReader.Create(APointer, ASize);
  try
    LoadFromProtobufReader(protobuf_reader, ASize);
  finally
    protobuf_reader.Free;
  end;
end;

constructor TProtobufBaseObject.Create(const AProtobufReader: TProtobufReader; const ASize: Integer);
begin
  FProtobufOutput := TProtobufOutput.Create;

  LoadFromProtobufReader(AProtobufReader, ASize);
end;

destructor TProtobufBaseObject.Destroy;
begin
  if Assigned(FModifiedFields) then
    FModifiedFields.Free;

  FProtobufOutput.Free;

  inherited;
end;

function TProtobufBaseObject.GetProtobufOutputSize: Word;
begin
  result := FProtobufOutput.getSerializedSize;
end;


end.
