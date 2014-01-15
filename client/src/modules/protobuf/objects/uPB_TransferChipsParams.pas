unit uPB_TransferChipsParams;

interface

uses
  Winapi.Windows, pbOutput, uProtobufBaseObject, uProtobufReader;

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

    procedure SetClubSeq(const AValue: Integer);
    procedure SetPlayerMongoId(const AValue: AnsiString);
    procedure SetChipAmount(const AValue: Integer);

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property ClubSeq: Integer read FClubSeq write SetClubSeq;
    property PlayerMongoId: AnsiString read FPlayerMongoId write SetPlayerMongoId;
    property ChipAmount: Integer read FChipAmount write SetChipAmount;
  end;

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
        SetClubSeq(AProtobufReader.readInt32);
      end;
      FN_PLAYERMONGOID: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        SetPlayerMongoId(AProtobufReader.readString);
      end;
      FN_CHIPAMOUNT: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetChipAmount(AProtobufReader.readInt32);
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
  if IsModifiedField(FN_CLUBSEQ) then
    pbout.writeInt32(FN_CLUBSEQ, FClubSeq);
  if IsModifiedField(FN_PLAYERMONGOID) then
    pbout.writeString(FN_PLAYERMONGOID, FPlayerMongoId);
  if IsModifiedField(FN_CHIPAMOUNT) then
    pbout.writeInt32(FN_CHIPAMOUNT, FChipAmount);
  result := pbout;
end;

procedure TPB_TransferChipsParams.SetClubSeq(const AValue: Integer);
begin
  FClubSeq := AValue;
  AddModifiedField(FN_CLUBSEQ);
end;

procedure TPB_TransferChipsParams.SetPlayerMongoId(const AValue: AnsiString);
begin
  FPlayerMongoId := AValue;
  AddModifiedField(FN_PLAYERMONGOID);
end;

procedure TPB_TransferChipsParams.SetChipAmount(const AValue: Integer);
begin
  FChipAmount := AValue;
  AddModifiedField(FN_CHIPAMOUNT);
end;

end.

