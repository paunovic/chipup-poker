unit uPB_TokenPrices;

interface

uses
  Winapi.Windows,
  pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_TokenPrices = class(TProtobufBaseObject)
    const
      FN_CLUBCHANGEDETAILS = 1;
      FN_CLUBCREATION = 2;

    var
      FClubChangeDetails: Integer;
      FClubCreation: Integer;

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property ClubChangeDetails: Integer read FClubChangeDetails;
    property ClubCreation: Integer read FClubCreation;
  end;

implementation

uses
  pbPublic;


procedure TPB_TokenPrices.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_CLUBCHANGEDETAILS: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FClubChangeDetails := AProtobufReader.readInt32;
      end;
      FN_CLUBCREATION: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FClubCreation := AProtobufReader.readInt32;
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_TokenPrices.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
  pbout.writeInt32(FN_CLUBCHANGEDETAILS, FClubChangeDetails);
  pbout.writeInt32(FN_CLUBCREATION, FClubCreation);
  result := pbout;
end;

end.

