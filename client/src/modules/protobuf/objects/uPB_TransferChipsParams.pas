unit uPB_TransferChipsParams;

interface

uses
  Winapi.Windows,
  pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_TransferChipsParams = class(TProtobufBaseObject)
  private
    const
      FN_CLUBSEQ = 1;
      FN_PLAYERMONGOID = 2;
      FN_CHIPAMOUNT = 3;

    var
      FClubSeq: Integer;
      FPlayerMongoId: AnsiString;
      FChipAmount: Integer;

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property ClubSeq: Integer read FClubSeq write FClubSeq;
    property PlayerMongoId: AnsiString read FPlayerMongoId write FPlayerMongoId;
    property ChipAmount: Integer read FChipAmount write FChipAmount;
  end;

//  TPB_TransferChipsParamss = TObjectList<TPB_TransferChipsParams>;

implementation

uses
  pbPublic;


procedure TPB_TransferChipsParams.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
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
      FN_CHIPAMOUNT: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FChipAmount := AProtobufReader.readInt32;
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_TransferChipsParams.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
  pbout.writeInt32(FN_CLUBSEQ, FClubSeq);
  pbout.writeString(FN_PLAYERMONGOID, FPlayerMongoId);
  pbout.writeInt32(FN_CHIPAMOUNT, FChipAmount);
  result := pbout;
end;

end.
