unit uPB_GiveClubOwnershipParams;

interface

uses
  Winapi.Windows, pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_GiveClubOwnershipParams = class(TProtobufBaseObject)
  private
    const
      FN_CLUBSEQ = 1;
      FN_PLAYERMONGOID = 2;

    var
      FClubSeq: Integer;
      FPlayerMongoId: AnsiString;

    procedure SetClubSeq(const AValue: Integer);
    procedure SetPlayerMongoId(const AValue: AnsiString);

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;

    property ClubSeq: Integer read FClubSeq write SetClubSeq;
    property PlayerMongoId: AnsiString read FPlayerMongoId write SetPlayerMongoId;
  end;

implementation

uses
  pbPublic;

procedure TPB_GiveClubOwnershipParams.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
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
    else
      AProtobufReader.skipField(tag);
    end;
end;

procedure TPB_GiveClubOwnershipParams.SetClubSeq(const AValue: Integer);
begin
  FClubSeq := AValue;
  ProtobufOutput.writeInt32(FN_CLUBSEQ, FClubSeq);
end;

procedure TPB_GiveClubOwnershipParams.SetPlayerMongoId(const AValue: AnsiString);
begin
  FPlayerMongoId := AValue;
  ProtobufOutput.writeString(FN_PLAYERMONGOID, FPlayerMongoId);
end;

end.

