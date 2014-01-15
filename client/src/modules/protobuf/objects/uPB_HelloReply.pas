unit uPB_HelloReply;

interface

uses
  Winapi.Windows, pbOutput, uProtobufBaseObject, uProtobufReader, uPB_TokenPrices, uPB_StringSizes;

type
  TPB_HelloReply = class(TProtobufBaseObject)
  private
    const
      FN_TOKENPRICES = 1;
      FN_STRINGSIZES = 2;
      FN_CHANGEEXPIRETIME = 3;
      FN_FORGOTEXPIRETIME = 4;

    var
      FTokenprices: TPB_TokenPrices;
      FStringsizes: TPB_StringSizes;
      FChangeexpiretime: Integer;
      FForgotexpiretime: Integer;

    procedure SetTokenprices(const AValue: TPB_TokenPrices);
    procedure SetStringsizes(const AValue: TPB_StringSizes);
    procedure SetChangeexpiretime(const AValue: Integer);
    procedure SetForgotexpiretime(const AValue: Integer);

  public
    destructor Destroy; override;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property Tokenprices: TPB_TokenPrices read FTokenprices;
    property Stringsizes: TPB_StringSizes read FStringsizes;
    property Changeexpiretime: Integer read FChangeexpiretime;
    property Forgotexpiretime: Integer read FForgotexpiretime;
  end;

//  TPB_HelloReplys = TObjectList<TPB_HelloReply>;

implementation

uses
  pbPublic, pbInput;


destructor TPB_HelloReply.Destroy;
begin
  if Assigned(FTokenprices) then
    FTokenprices.Free;
  if Assigned(FStringsizes) then
    FStringsizes.Free;

  inherited;
end;

procedure TPB_HelloReply.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_TOKENPRICES: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        SetTokenprices(TPB_TokenPrices.Create(AProtobufReader, AProtobufReader.readInt32));
      end;
      FN_STRINGSIZES: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        SetStringsizes(TPB_StringSizes.Create(AProtobufReader, AProtobufReader.readInt32));
      end;
      FN_CHANGEEXPIRETIME: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetChangeexpiretime(AProtobufReader.readInt32);
      end;
      FN_FORGOTEXPIRETIME: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetForgotexpiretime(AProtobufReader.readInt32);
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_HelloReply.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
  if IsModifiedField(FN_TOKENPRICES) then
    pbout.writeProtobufBaseObject(FN_TOKENPRICES, FTokenprices);
  if IsModifiedField(FN_STRINGSIZES) then
    pbout.writeProtobufBaseObject(FN_STRINGSIZES, FStringsizes);
  if IsModifiedField(FN_CHANGEEXPIRETIME) then
    pbout.writeInt32(FN_CHANGEEXPIRETIME, FChangeexpiretime);
  if IsModifiedField(FN_FORGOTEXPIRETIME) then
    pbout.writeInt32(FN_FORGOTEXPIRETIME, FForgotexpiretime);
  result := pbout;
end;

procedure TPB_HelloReply.SetTokenprices(const AValue: TPB_TokenPrices);
begin
  FTokenprices := AValue;
  AddModifiedField(FN_TOKENPRICES);
end;

procedure TPB_HelloReply.SetStringsizes(const AValue: TPB_StringSizes);
begin
  FStringsizes := AValue;
  AddModifiedField(FN_STRINGSIZES);
end;

procedure TPB_HelloReply.SetChangeexpiretime(const AValue: Integer);
begin
  FChangeexpiretime := AValue;
  AddModifiedField(FN_CHANGEEXPIRETIME);
end;

procedure TPB_HelloReply.SetForgotexpiretime(const AValue: Integer);
begin
  FForgotexpiretime := AValue;
  AddModifiedField(FN_FORGOTEXPIRETIME);
end;

end.

