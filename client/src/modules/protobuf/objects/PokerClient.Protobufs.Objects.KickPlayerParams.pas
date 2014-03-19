unit PokerClient.Protobufs.Objects.KickPlayerParams;

interface

uses
  Winapi.Windows, System.SysUtils, pbOutput, PokerClient.Protobufs.Objects.Base, PokerClient.Protobufs.Reader;

type
  TPB_KickPlayerParams = class(TProtobufBaseObject)
  private
    const
      FN_CLUBSEQ = 1;
      FN_PLAYERMONGOID = 2;

    var
      FClubSeq: Integer;
      FPlayerMongoId: TBytes;

    procedure SetClubSeq(const AValue: Integer);
    procedure SetPlayerMongoId(const AValue: TBytes);

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;

    property ClubSeq: Integer read FClubSeq write SetClubSeq;
    property PlayerMongoId: TBytes read FPlayerMongoId write SetPlayerMongoId;
  end;

implementation

uses
  pbPublic;

procedure TPB_KickPlayerParams.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
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
    else
      AProtobufReader.skipField(tag);
    end;
end;

procedure TPB_KickPlayerParams.SetClubSeq(const AValue: Integer);
begin
  FClubSeq := AValue;
  ProtobufOutput.writeInt32(FN_CLUBSEQ, FClubSeq);
end;

procedure TPB_KickPlayerParams.SetPlayerMongoId(const AValue: TBytes);
begin
  FPlayerMongoId := AValue;
  ProtobufOutput.writeBytes(FN_PLAYERMONGOID, FPlayerMongoId);
end;

end.

