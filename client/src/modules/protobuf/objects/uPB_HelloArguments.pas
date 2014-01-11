unit uPB_HelloArguments;

interface

uses
  Winapi.Windows, System.Classes, pbOutput, uProtobufBaseObject, uProtobufReader,
  uPB_TokenPrices, uPB_StringSizes;

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

    property TokenPrices: TPB_TokenPrices read FtokenPrices;
    property StringSizes: TPB_StringSizes read FstringSizes;
    property ChangeExpireTime: Integer read FChangeExpireTime;
    property ForgotExpireTime: Integer read FForgotExpireTime;
  end;

implementation

uses
  System.SysUtils, pbPublic;


destructor TPB_HelloArguments.Destroy;
begin
  FTokenPrices.Free;
  FStringSizes.Free;

  inherited;
end;

procedure TPB_HelloArguments.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag         : Integer;
  wire_type   : Integer;
  field_number: Integer;
  endpos      : Integer;
begin
  if not Assigned(FTokenPrices) then
    FTokenPrices := TPB_TokenPrices.Create;

  if not Assigned(FStringSizes) then
    FStringSizes := TPB_StringSizes.Create;

  FChangeExpireTime := -1;
  FForgotExpireTime := -1;
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_TOKENPRICES: FTokenPrices.LoadFromProtobufReader(AProtobufReader, AProtobufReader.readInt32);
      FN_STRINGSIZES: FStringSizes.LoadFromProtobufReader(AProtobufReader, AProtobufReader.readInt32);
      FN_CHANGEEXPIRETIME: FChangeExpireTime := AProtobufReader.readInt32;
      FN_FORGOTEXPIRETIME: FForgotExpireTime := AProtobufReader.readInt32;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_HelloArguments.GetProtobuf: TProtoBufOutput;
var
  pboutput: TProtoBufOutput;
begin
  pboutput := TProtoBufOutput.Create;
  result := pboutput;
end;

end.
