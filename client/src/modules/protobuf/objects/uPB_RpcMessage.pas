unit uPB_RpcMessage;

interface

uses
  Winapi.Windows, pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_RpcMessage = class(TProtobufBaseObject)
  private
    const
      FN_METHODID = 1;
      FN_DATASIZE = 2;
      FN_TOKEN = 3;

    var
      FMethodid: Integer;
      FDatasize: Integer;
      FToken: Integer;

    procedure SetMethodid(const AValue: Integer);
    procedure SetDatasize(const AValue: Integer);
    procedure SetToken(const AValue: Integer);

  public
  	procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;

    property Methodid: Integer read FMethodid write SetMethodid;
    property Datasize: Integer read FDatasize write SetDatasize;
    property Token: Integer read FToken write SetToken;
  end;

implementation

uses
  pbPublic;

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
        SetMethodid(AProtobufReader.readInt32);
      end;
      FN_DATASIZE: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetDatasize(AProtobufReader.readInt32);
      end;
      FN_TOKEN: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetToken(AProtobufReader.readInt32);
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

procedure TPB_RpcMessage.SetMethodid(const AValue: Integer);
begin
  FMethodid := AValue;
  ProtobufOutput.writeInt32(FN_METHODID, FMethodid);
end;

procedure TPB_RpcMessage.SetDatasize(const AValue: Integer);
begin
  FDatasize := AValue;
  ProtobufOutput.writeInt32(FN_DATASIZE, FDatasize);
end;

procedure TPB_RpcMessage.SetToken(const AValue: Integer);
begin
  FToken := AValue;
  ProtobufOutput.writeInt32(FN_TOKEN, FToken);
end;

end.

