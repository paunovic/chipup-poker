unit uPB_KickPlayerParams;

interface

uses
  Winapi.Windows,
  pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_KickPlayerParams = class(TProtobufBaseObject)
  private
    const
      FN_CLUBSEQ = 1;
      FN_PLAYERMONGOID = 2;

    var
      FClubSeq: Integer;
      FPlayerMongoId: AnsiString;

  public
    constructor Create(const AClubSeq: Integer; const APlayerMongoId: AnsiString); overload;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property ClubSeq: Integer read FClubSeq;
    property PlayerMongoId: AnsiString read FPlayerMongoId;
  end;

//  TPB_KickPlayerParamss = TObjectList<TPB_KickPlayerParams>;

implementation

uses
  pbPublic;

constructor TPB_KickPlayerParams.Create(const AClubSeq: Integer; const APlayerMongoId: AnsiString);
begin
  FClubSeq := AClubSeq;
  FPlayerMongoId := APlayerMongoId;
end;

procedure TPB_KickPlayerParams.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
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
      FN_PLAYERMONGOID: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        FPlayerMongoId := AProtobufReader.readString;
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_KickPlayerParams.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
  pbout.writeInt32(FN_CLUBSEQ, FClubSeq);
  pbout.writeString(FN_PLAYERMONGOID, FPlayerMongoId);
  result := pbout;
end;

end.
