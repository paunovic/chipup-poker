unit uPB_TokenPrices;

interface

uses
  Winapi.Windows, pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_TokenPrices = class(TProtobufBaseObject)
  private
    const
      FN_CLUBCHANGEDETAILS = 1;
      FN_CLUBCREATION = 2;

    var
      FClubChangeDetails: Integer;
      FClubCreation: Integer;

    procedure SetClubChangeDetails(const AValue: Integer);
    procedure SetClubCreation(const AValue: Integer);

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property ClubChangeDetails: Integer read FClubChangeDetails write SetClubChangeDetails;
    property ClubCreation: Integer read FClubCreation write SetClubCreation;
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
        SetClubChangeDetails(AProtobufReader.readInt32);
      end;
      FN_CLUBCREATION: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetClubCreation(AProtobufReader.readInt32);
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
  if IsModifiedField(FN_CLUBCHANGEDETAILS) then
    pbout.writeInt32(FN_CLUBCHANGEDETAILS, FClubChangeDetails);
  if IsModifiedField(FN_CLUBCREATION) then
    pbout.writeInt32(FN_CLUBCREATION, FClubCreation);
  result := pbout;
end;

procedure TPB_TokenPrices.SetClubChangeDetails(const AValue: Integer);
begin
  FClubChangeDetails := AValue;
  AddModifiedField(FN_CLUBCHANGEDETAILS);
end;

procedure TPB_TokenPrices.SetClubCreation(const AValue: Integer);
begin
  FClubCreation := AValue;
  AddModifiedField(FN_CLUBCREATION);
end;

end.

