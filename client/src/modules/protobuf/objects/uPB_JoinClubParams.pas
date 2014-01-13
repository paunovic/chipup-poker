unit uPB_JoinClubParams;

interface

uses
  Winapi.Windows,
  pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_JoinClubParams = class(TProtobufBaseObject)
  private
    const
      FN_ID = 1;
      FN_CODE = 2;

    var
      FId: Integer;
      FCode: AnsiString;

  public
    constructor Create(const AId: Integer; const ACode: AnsiString); overload;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property Id: Integer read FId;
    property Code: AnsiString read FCode;
  end;

//  TPB_JoinClubParamss = TObjectList<TPB_JoinClubParams>;

implementation

uses
  pbPublic;

constructor TPB_JoinClubParams.Create(const AId: Integer; const ACode: AnsiString);
begin
  FId := AId;
  FCode := ACode;
end;

procedure TPB_JoinClubParams.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_ID: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FId := AProtobufReader.readInt32;
      end;
      FN_CODE: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        FCode := AProtobufReader.readString;
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_JoinClubParams.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
  pbout.writeInt32(FN_ID, FId);
  if FCode <> '' then
    pbout.writeString(FN_CODE, FCode);
  result := pbout;
end;

end.
