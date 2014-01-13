unit uPB_StringSizes;

interface

uses
  Winapi.Windows,
  pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_StringSizes = class(TProtobufBaseObject)
  private
    const
      FN_EMAIL = 1;
      FN_PASSWORD = 2;
      FN_CLUBNAME = 3;
      FN_INVCODE = 4;
      FN_USERNAME = 5;
      FN_GAMENAME = 6;

    var
      FEmail: Integer;
      FPassword: Integer;
      FClubName: Integer;
      FInvCode: Integer;
      FUsername: Integer;
      FGameName: Integer;

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property Email: Integer read FEmail;
    property Password: Integer read FPassword;
    property ClubName: Integer read FClubName;
    property InvCode: Integer read FInvCode;
    property Username: Integer read FUsername;
    property GameName: Integer read FGameName;
  end;

implementation

uses
  pbPublic;

procedure TPB_StringSizes.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_EMAIL: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FEmail := AProtobufReader.readInt32;
      end;
      FN_PASSWORD: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FPassword := AProtobufReader.readInt32;
      end;
      FN_CLUBNAME: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FClubName := AProtobufReader.readInt32;
      end;
      FN_INVCODE: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FInvCode := AProtobufReader.readInt32;
      end;
      FN_USERNAME: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FUsername := AProtobufReader.readInt32;
      end;
      FN_GAMENAME: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FGameName := AProtobufReader.readInt32;
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_StringSizes.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
  pbout.writeInt32(FN_EMAIL, FEmail);
  pbout.writeInt32(FN_PASSWORD, FPassword);
  pbout.writeInt32(FN_CLUBNAME, FClubName);
  pbout.writeInt32(FN_INVCODE, FInvCode);
  pbout.writeInt32(FN_USERNAME, FUsername);
  pbout.writeInt32(FN_GAMENAME, FGameName);
  result := pbout;
end;

end.

