unit uPB_TransferChipsParams;

interface

uses
  Winapi.Windows, pbOutput, uProtobufBaseObject, uProtobufReader, System.SysUtils;

type
  TPB_TransferChipsParams = class(TProtobufBaseObject)
  private
    const
      FN_CLUBSEQ = 1;
      FN_PLAYERMONGOID = 2;
      FN_CHIPAMOUNT = 3;

    var
      FClubSeq: Integer;
      FPlayerMongoId: TBytes;
      FChipAmount: Integer;

    procedure SetClubSeq(const AValue: Integer);
    procedure SetPlayerMongoId(const AValue: TBytes);
    procedure SetChipAmount(const AValue: Integer);

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;

    property ClubSeq: Integer read FClubSeq write SetClubSeq;
    property PlayerMongoId: TBytes read FPlayerMongoId write SetPlayerMongoId;
    property ChipAmount: Integer read FChipAmount write SetChipAmount;
  end;

implementation

uses
  pbPublic;

procedure TPB_TransferChipsParams.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
  bytes                               : TBytes;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_CLUBSEQ: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetClubSeq(AProtobufReader.readInt32);
      end;
      FN_PLAYERMONGOID: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        AProtobufReader.readBytes(bytes);
        SetPlayerMongoId(bytes);
      end;
      FN_CHIPAMOUNT: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetChipAmount(AProtobufReader.readInt32);
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

procedure TPB_TransferChipsParams.SetClubSeq(const AValue: Integer);
begin
  FClubSeq := AValue;
  ProtobufOutput.writeInt32(FN_CLUBSEQ, FClubSeq);
end;

procedure TPB_TransferChipsParams.SetPlayerMongoId(const AValue: TBytes);
begin
  FPlayerMongoId := AValue;
  ProtobufOutput.writeBytes(FN_PLAYERMONGOID, FPlayerMongoId);
end;

procedure TPB_TransferChipsParams.SetChipAmount(const AValue: Integer);
begin
  FChipAmount := AValue;
 ProtobufOutput.writeInt32(FN_CHIPAMOUNT, FChipAmount);
end;

end.

