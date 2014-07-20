unit Poker.Protobufs.Objects.Base;

interface

uses
  System.Classes, pbOutput, Poker.Protobufs.Reader;

type
  TProtobufBaseObjectClass = class of TProtobufBaseObject;
  TProtobufBaseObject = class
  private
    FProtobufOutput: TProtoBufOutput;
    FLightweight: Boolean;

    function GetProtobufOutputSize: Word;

  protected
    procedure InitObjects; virtual;
    procedure HookNotifiers; virtual;

  public
    constructor Create(const ALightweight: Boolean = FALSE); overload;
    constructor Create(const APointer: pointer; const ASize: Integer; const ALightweight: Boolean = FALSE); overload;
    constructor Create(const AStream: TMemoryStream; const ALightweight: Boolean = FALSE); overload;
    constructor Create(const AProtobufReader: TProtobufReader; const ASize: Integer; const ALightweight: Boolean = FALSE); overload;

    destructor Destroy; override;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); virtual; abstract;
    function IsInitialized: Boolean; virtual; abstract;

    property ProtobufOutput: TProtoBufOutput read FProtobufOutput;
    property ProtobufOutputSize: Word read GetProtobufOutputSize;
    property Lightweight: Boolean read FLightweight;
  end;


implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  System.SysUtils;


constructor TProtobufBaseObject.Create(const ALightweight: Boolean = FALSE);
begin
  FLightweight := ALightweight;
  InitObjects;
  if not ALightweight then
    FProtobufOutput := TProtobufOutput.Create;
  HookNotifiers;
end;

constructor TProtobufBaseObject.Create(const APointer: pointer; const ASize: Integer; const ALightweight: Boolean = FALSE);
var
  protobuf_reader: TProtobufReader;
begin
  FLightweight := ALightweight;
  InitObjects;

  FProtobufOutput := TProtobufOutput.Create;
  FProtobufOutput.writeRawData(APointer, ASize);
  protobuf_reader := TProtobufReader.Create(APointer, ASize);
  try
    LoadFromProtobufReader(protobuf_reader, protobuf_reader.Size);
  finally
    protobuf_reader.Free;
  end;

  HookNotifiers;
end;

constructor TProtobufBaseObject.Create(const AProtobufReader: TProtobufReader; const ASize: Integer; const ALightweight: Boolean = FALSE);
begin
  FLightweight := ALightweight;
  InitObjects;

  FProtobufOutput := TProtobufOutput.Create;
  FProtobufOutput.writeRawData(PAnsiChar(Integer(AProtobufReader.Buffer) + AProtobufReader.BufferPos), ASize);
  LoadFromProtobufReader(AProtobufReader, ASize);

  HookNotifiers;
end;

constructor TProtobufBaseObject.Create(const AStream: TMemoryStream; const ALightweight: Boolean = FALSE);
var
  protobuf_reader: TProtobufReader;
begin
  FLightweight := ALightweight;
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
  if Assigned(FProtobufOutput) then
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
