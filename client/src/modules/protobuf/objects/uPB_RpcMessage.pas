unit uPB_RpcMessage;

interface

uses
  Winapi.Windows, System.Classes, uProtobufBaseObject, uProtobufReader,
  pbOutput;

type
  TPB_RpcMessage = class(TProtobufBaseObject)
  private
    const
      FN_METHOD_ID = 1;
      FN_DATA_SIZE = 2;

    var
      FMethodId: Integer;
      FDataSize: Integer;
      FValid   : Boolean;

  public
    constructor Create(const AMethodId, ADataSize: Integer); overload;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property MethodId: Integer read FMethodId;
    property DataSize: Integer read FDataSize;
    property IsValid : Boolean read FValid;
  end;

implementation

uses
  pbPublic;


constructor TPB_RpcMessage.Create(const AMethodId, ADataSize: Integer);
begin
  FMethodId := AMethodId;
  FDataSize := ADataSize;
  FValid := TRUE;
end;

procedure TPB_RpcMessage.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, field_number, wire_type: Integer;
  validity, endpos            : Integer;
begin
  validity := 0;
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
  begin
    case field_number of
      FN_METHOD_ID: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FmethodId := AProtobufReader.readInt32;
        Inc(validity);
      end;
      FN_DATA_SIZE: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FdataSize := AProtobufReader.readInt32;
        Inc(validity);
      end;
    else
      AProtobufReader.skipField(tag);
    end;
  end;
  FValid := validity = 2;
end;

function TPB_RpcMessage.GetProtobuf: TProtoBufOutput;
var
  pboutput: TProtoBufOutput;
begin
  pboutput := TProtoBufOutput.Create;
  pboutput.writeInt32(FN_METHOD_ID, FMethodId);
  if FDataSize > 0 then
    pboutput.writeInt32(FN_DATA_SIZE, FDataSize);
  result := pboutput;
end;



end.
