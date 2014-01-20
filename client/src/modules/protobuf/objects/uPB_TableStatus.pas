unit uPB_TableStatus;

interface

uses
  Winapi.Windows, System.SysUtils, pbOutput, uProtobufBaseObject, uProtobufReader, uPB_SeatInfo;

type
  TPB_TableStatus = class(TProtobufBaseObject)
  private
    const
      FN_TABLEID = 1;
      FN_SEATS = 2;

    var
      FTableId: TBytes;
      FSeats: TPB_SeatInfos;

    procedure SetTableId(const AValue: TBytes);

  public
    destructor Destroy; override;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;

    property TableMongoId: TBytes read FTableId write SetTableId;
    property Seats: TPB_SeatInfos read FSeats write FSeats;
  end;

implementation

uses
  pbPublic, uCommon;


destructor TPB_TableStatus.Destroy;
begin
  FSeats.Free;

  inherited;
end;

procedure TPB_TableStatus.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
  bytes                               : TBytes;
begin
  if not Assigned(FSeats) then
    FSeats := TPB_SeatInfos.Create;

  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_TABLEID: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        AProtobufReader.readBytes(bytes);
        SetTableId(bytes);
      end;
      FN_SEATS: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        FSeats.Add(TPB_SeatInfo.Create(AProtobufReader, AProtobufReader.readInt32));
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

procedure TPB_TableStatus.SetTableId(const AValue: TBytes);
begin
  FTableId := AValue;
  ProtobufOutput.writeBytes(FN_TABLEID, FTableId);
end;

end.
