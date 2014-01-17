unit uPB_ListClubsReply;

interface

uses
  Winapi.Windows, pbOutput, uProtobufBaseObject, uProtobufReader, uPB_Club;

type
  TPB_ListClubsReply = class(TProtobufBaseObject)
  private
    const
      FN_CLUBS = 1;

    var
      FClubs: TPB_Clubs;

  public
    destructor Destroy; override;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;

    property Clubs: TPB_Clubs read FClubs;
  end;

//  TPB_ListClubsReplys = TObjectList<TPB_ListClubsReply>;

implementation

uses
  pbPublic;


destructor TPB_ListClubsReply.Destroy;
begin
  if Assigned(FClubs) then
    FClubs.Free;

  inherited;
end;

procedure TPB_ListClubsReply.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
begin
  if not Assigned(FClubs) then
    FClubs := TPB_Clubs.Create;

  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_CLUBS: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        FClubs.Add(TPB_Club.Create(AProtobufReader, AProtobufReader.readInt32));
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

end.

