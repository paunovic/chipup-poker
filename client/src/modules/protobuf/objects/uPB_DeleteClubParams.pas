unit uPB_DeleteClubParams;

interface

uses
  Winapi.Windows,
  pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_DeleteClubParams = class(TProtobufBaseObject)
  private
    const
      FN_CLUBSEQ = 1;

    var
      FClubSeq: Integer;

  public
    constructor Create(const AClubSeq: Integer); overload;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property ClubSeq: Integer read FClubSeq;
  end;

//  TPB_DeleteClubParamss = TObjectList<TPB_DeleteClubParams>;

implementation

uses
  pbPublic;

constructor TPB_DeleteClubParams.Create(const AClubSeq: Integer);
begin
  FClubSeq := AClubSeq;
end;

procedure TPB_DeleteClubParams.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_CLUBSEQ: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FClubSeq := AProtobufReader.readInt32;
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_DeleteClubParams.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
  pbout.writeInt32(FN_CLUBSEQ, FClubSeq);
  result := pbout;
end;

end.
