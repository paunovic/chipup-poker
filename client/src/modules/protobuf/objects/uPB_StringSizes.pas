unit uPB_StringSizes;

interface

uses
  Winapi.Windows, System.Classes, pbOutput, uProtobufBaseObject, uProtobufReader;

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
      FEMail: Integer;
      FPassword: Integer;
      FClubName: Integer;
      FInvCode: Integer;
      FUsername: Integer;
      FGameName: Integer;

  public
    constructor Create(const AEMail: Integer; const APassword: Integer; const AClubName: Integer; const AInvCode: Integer; const AUsername: Integer; const AGameName: Integer); overload;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property EMail: Integer read FEMail;
    property Password: Integer read FPassword;
    property ClubName: Integer read FClubName;
    property InvCode: Integer read FInvCode;
    property Username: Integer read FUsername;
    property GameName: Integer read FGameName;
  end;

implementation

uses
  System.SysUtils, pbPublic;


constructor TPB_StringSizes.Create(const AEMail: Integer; const APassword: Integer; const AClubName: Integer; const AInvCode: Integer; const AUsername: Integer; const AGameName: Integer);
begin
  FEMail := AEMail;
  FPassword := APassword;
  FClubName := AClubName;
  FInvCode := AInvCode;
  FUsername := AUsername;
  FGameName := AGameName;
end;

procedure TPB_StringSizes.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag         : Integer;
  wire_type   : Integer;
  field_number: Integer;
  endpos      : Integer;
begin
  FEMail := -1;
  FPassword := -1;
  FClubName := -1;
  FInvCode := -1;
  FUsername := -1;
  FGameName := -1;
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_EMAIL: FEMail := AProtobufReader.readInt32;
      FN_PASSWORD: FPassword := AProtobufReader.readInt32;
      FN_CLUBNAME: FClubName := AProtobufReader.readInt32;
      FN_INVCODE: FInvCode := AProtobufReader.readInt32;
      FN_USERNAME: FUsername := AProtobufReader.readInt32;
      FN_GAMENAME: FGameName := AProtobufReader.readInt32;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_StringSizes.GetProtobuf: TProtoBufOutput;
var
  pboutput: TProtoBufOutput;
begin
  pboutput := TProtoBufOutput.Create;
  pboutput.writeInt32(FN_EMAIL, FEMail);
  pboutput.writeInt32(FN_PASSWORD, FPassword);
  pboutput.writeInt32(FN_CLUBNAME, FClubName);
  pboutput.writeInt32(FN_INVCODE, FInvCode);
  pboutput.writeInt32(FN_USERNAME, FUsername);
  pboutput.writeInt32(FN_GAMENAME, FGameName);
  result := pboutput;
end;

end.
