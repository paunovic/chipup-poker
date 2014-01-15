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
    constructor Create(const AMethodId: Integer; const ADataSize: Integer = 0; const AToken: Integer = 0); overload;

  	procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property Methodid: Integer read FMethodid write SetMethodid;
    property Datasize: Integer read FDatasize write SetDatasize;
    property Token: Integer read FToken write SetToken;
  end;

implementation

uses
  pbPublic;


constructor TPB_RpcMessage.Create(const AMethodId: Integer; const ADataSize: Integer = 0; const AToken: Integer = 0);
begin
  SetMethodid(AMethodId);
  if ADataSize <> 0 then
    SetDataSize(ADataSize);
  if AToken <> 0 then
    SetToken(AToken);
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

function TPB_RpcMessage.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
  if IsModifiedField(FN_METHODID) then
    pbout.writeInt32(FN_METHODID, FMethodid);
  if IsModifiedField(FN_DATASIZE) then
    pbout.writeInt32(FN_DATASIZE, FDatasize);
  if IsModifiedField(FN_TOKEN) then
    pbout.writeInt32(FN_TOKEN, FToken);
  result := pbout;
end;

procedure TPB_RpcMessage.SetMethodid(const AValue: Integer);
begin
  FMethodid := AValue;
  AddModifiedField(FN_METHODID);
end;

procedure TPB_RpcMessage.SetDatasize(const AValue: Integer);
begin
  FDatasize := AValue;
  AddModifiedField(FN_DATASIZE);
end;

procedure TPB_RpcMessage.SetToken(const AValue: Integer);
begin
  FToken := AValue;
  AddModifiedField(FN_TOKEN);
end;

end.

