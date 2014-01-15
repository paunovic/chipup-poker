unit uProtobufBaseObject;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils, System.Generics.Collections, pbOutput, uProtobufReader;

type
  TProtobufBaseObject = class
  private
    FModifiedFields: TList<Integer>;

  protected
    function IsModifiedField(const ATag: Integer): Boolean;
    procedure AddModifiedField(const ATag: Integer);

  public
    constructor Create(const APointer: pointer; const ASize: Integer); overload;
    constructor Create(const AProtobufReader: TProtobufReader; const ASize: Integer); overload;

    destructor Destroy; override;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); virtual; abstract;

    function GetProtobuf: TProtoBufOutput; virtual; abstract;
    function GetProtobufSize: Integer;
    procedure WriteToStream(const AStream: TStream);
  end;

  TProtobufOutputHelper = class helper for TProtobufOutput
  public
    procedure writeBytes(const AFieldNumber: Integer; const ABytes: TBytes);
    procedure writeProtobufBaseObject(const AFieldNumber: Integer; const AProtobufBaseObject: TProtobufBaseObject);
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

procedure TProtobufBaseObject.AddModifiedField(const ATag: Integer);
begin
  if not Assigned(FModifiedFields) then
    FModifiedFields := TList<Integer>.Create;

  if not IsModifiedField(ATag) then
    FModifiedFields.Add(ATag);
end;

function TProtobufBaseObject.IsModifiedField(const ATag: Integer): Boolean;
var
  C1: Integer;
begin
  if not Assigned(FModifiedFields) then
    Exit(FALSE);

  for C1 := 0 to FModifiedFields.Count - 1 do
    if FModifiedFields[C1] = ATag then
      Exit(TRUE);
  Exit(FALSE);
end;

constructor TProtobufBaseObject.Create(const AProtobufReader: TProtobufReader; const ASize: Integer);
begin
  LoadFromProtobufReader(AProtobufReader, ASize);
end;

destructor TProtobufBaseObject.Destroy;
begin
  if Assigned(FModifiedFields) then
    FModifiedFields.Free;

  inherited;
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

procedure TProtobufOutputHelper.writeProtobufBaseObject(const AFieldNumber: Integer; const AProtobufBaseObject: TProtobufBaseObject);
var
  pb: TProtobufOutput;
begin
  pb := AProtobufBaseObject.GetProtobuf;
  try
    writeMessage(AFieldNumber, pb);
  finally
    pb.Free;
  end;
end;

end.
