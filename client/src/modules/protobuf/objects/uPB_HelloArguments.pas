unit uPB_HelloArguments;

interface

uses
  Winapi.Windows, uPB_TokenPrices, uPB_StringSizes,
  pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_HelloArguments = class(TProtobufBaseObject)
  private
    const
      FN_TOKENPRICES = 1;
      FN_STRINGSIZES = 2;
      FN_CHANGEEXPIRETIME = 3;
      FN_FORGOTEXPIRETIME = 4;

    var
      FTokenPrices: TPB_TokenPrices;
      FStringSizes: TPB_StringSizes;
      FChangeExpireTime: Integer;
      FForgotExpireTime: Integer;

  public
    destructor Destroy; override;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property TokenPrices: TPB_TokenPrices read FTokenPrices;
    property StringSizes: TPB_StringSizes read FStringSizes;
    property ChangeExpireTime: Integer read FChangeExpireTime;
    property ForgotExpireTime: Integer read FForgotExpireTime;
  end;

implementation

uses
  pbPublic;


destructor TPB_HelloArguments.Destroy;
begin
  if Assigned(FTokenPrices) then
    FTokenPrices.Free;
  if Assigned(FStringSizes) then
    FStringSizes.Free;

  inherited;
end;

procedure TPB_HelloArguments.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
begin
  if not Assigned(FTokenPrices) then
    FTokenPrices := TPB_TokenPrices.Create;

  if not Assigned(FStringSizes) then
    FStringSizes := TPB_StringSizes.Create;

  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_TOKENPRICES: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        FTokenPrices.LoadFromProtobufReader(AProtobufReader, AProtobufReader.readInt32);
      end;
      FN_STRINGSIZES: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        FStringSizes.LoadFromProtobufReader(AProtobufReader, AProtobufReader.readInt32);
      end;
      FN_CHANGEEXPIRETIME: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FChangeExpireTime := AProtobufReader.readInt32;
      end;
      FN_FORGOTEXPIRETIME: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FForgotExpireTime := AProtobufReader.readInt32;
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_HelloArguments.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
  result := pbout;
end;

end.

