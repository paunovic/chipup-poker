unit uPB_TokenPrices;

interface

uses
  Winapi.Windows, System.Classes, pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_TokenPrices = class(TProtobufBaseObject)
  private
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
  System.SysUtils, pbPublic;


procedure TPB_TokenPrices.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag         : Integer;
  wire_type   : Integer;
  field_number: Integer;
  endpos      : Integer;
begin
  FClubChangeDetails := -1;
  FClubCreation := -1;
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_CLUBCHANGEDETAILS: FClubChangeDetails := AProtobufReader.readInt32;
      FN_CLUBCREATION: FClubCreation := AProtobufReader.readInt32;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_TokenPrices.GetProtobuf: TProtoBufOutput;
var
  pboutput: TProtoBufOutput;
begin
  pboutput := TProtoBufOutput.Create;
  pboutput.writeInt32(FN_CLUBCHANGEDETAILS, FClubChangeDetails);
  pboutput.writeInt32(FN_CLUBCREATION, FClubCreation);
  result := pboutput;
end;

end.
