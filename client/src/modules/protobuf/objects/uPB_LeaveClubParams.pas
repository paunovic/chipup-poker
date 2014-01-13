unit uPB_LeaveClubParams;

interface

uses
  Winapi.Windows,
  pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_LeaveClubParams = class(TProtobufBaseObject)
  private
    const
      FN_ID = 1;

    var
      FId: Integer;

  public
    constructor Create(const AId: Integer); overload;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property Id: Integer read FId;
  end;

//  TPB_LeaveClubParamss = TObjectList<TPB_LeaveClubParams>;

implementation

uses
  pbPublic;

constructor TPB_LeaveClubParams.Create(const AId: Integer);
begin
  FId := AId;
end;

procedure TPB_LeaveClubParams.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
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
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_LeaveClubParams.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
  pbout.writeInt32(FN_ID, FId);
  result := pbout;
end;

end.
