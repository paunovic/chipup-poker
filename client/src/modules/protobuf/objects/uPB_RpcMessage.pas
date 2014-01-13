unit uPB_RpcMessage;

interface

uses
  Winapi.Windows,
  pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_RpcMessage = class(TProtobufBaseObject)
  private
    const
      FN_METHODID = 1;
      FN_DATASIZE = 2;
      FN_TOKEN = 3;

    var
      FMethodId: Integer;
      FDataSize: Integer;
      FToken: Integer;

  public
    constructor Create(const AMethodId, ADataSize: Integer); overload;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property MethodId: Integer read FMethodId;
    property DataSize: Integer read FDataSize;
    property Token: Integer read FToken;
  end;

implementation

uses
  pbPublic;


constructor TPB_RpcMessage.Create(const AMethodId, ADataSize: Integer);
begin
  FMethodId := AMethodId;
  FDataSize := ADataSize;
end;

procedure TPB_RpcMessage.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_METHODID: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FMethodId := AProtobufReader.readInt32;
      end;
      FN_DATASIZE: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FDataSize := AProtobufReader.readInt32;
      end;
      FN_TOKEN: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FToken := AProtobufReader.readInt32;
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_RpcMessage.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
  pbout.writeInt32(FN_METHODID, FMethodId);
  if FDataSize <> 0 then
    pbout.writeInt32(FN_DATASIZE, FDataSize);
  if FToken <> 0 then
    pbout.writeInt32(FN_TOKEN, FToken);
  result := pbout;
end;

end.

