unit uPB_ListClubsReply;

interface

uses
  WinApi.Windows, System.Classes, System.SysUtils, pbOutput, uProtobufBaseObject, uProtobufReader, uPB_Club;

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
    function GetProtobuf: TProtoBufOutput; override;

    property Clubs: TPB_Clubs read FClubs;
  end;

implementation

uses
  pbInput, pbPublic;


destructor TPB_ListClubsReply.Destroy;
begin
  if Assigned(FClubs) then
    FClubs.Free;

  inherited;
end;

procedure TPB_ListClubsReply.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, field_number, wire_type, endpos: Integer;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_clubs: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        if not Assigned(Fclubs) then
          Fclubs := TPB_Clubs.Create;
        Fclubs.Add(TPB_Club.Create(AProtobufReader,AProtobufReader.readInt32));
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_ListClubsReply.GetProtobuf: TProtoBufOutput;
var
  pboutput: TProtoBufOutput;
begin
  pboutput := TProtoBufOutput.Create;
  result := pboutput;
end;

end.
