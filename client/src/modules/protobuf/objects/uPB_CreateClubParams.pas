unit uPB_CreateClubParams;

interface

uses
  Winapi.Windows,
  pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_CreateClubParams = class(TProtobufBaseObject)
  private
    const
      FN_NAME = 1;
      FN_PRIVATE = 2;
      FN_INVCODE = 3;

    var
      FName: AnsiString;
      FPrivate: Boolean;
      FInvCode: AnsiString;

  public
    constructor Create(const AName: AnsiString; const APrivate: Boolean; const AInvCode: AnsiString); overload;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property Name: AnsiString read FName;
    property Private: Boolean read FPrivate;
    property InvCode: AnsiString read FInvCode;
  end;

//  TPB_CreateClubParamss = TObjectList<TPB_CreateClubParams>;

implementation

uses
  pbPublic;

constructor TPB_CreateClubParams.Create(const AName: AnsiString; const APrivate: Boolean; const AInvCode: AnsiString);
begin
  FName := AName;
  FPrivate := APrivate;
  FInvCode := AInvCode;
end;

procedure TPB_CreateClubParams.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_NAME: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        FName := AProtobufReader.readString;
      end;
      FN_PRIVATE: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FPrivate := AProtobufReader.readBoolean;
      end;
      FN_INVCODE: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        FInvCode := AProtobufReader.readString;
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_CreateClubParams.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
  pbout.writeString(FN_NAME, FName);
  pbout.writeBoolean(FN_PRIVATE, FPrivate);
  if FInvCode <> '' then
    pbout.writeString(FN_INVCODE, FInvCode);
  result := pbout;
end;

end.
