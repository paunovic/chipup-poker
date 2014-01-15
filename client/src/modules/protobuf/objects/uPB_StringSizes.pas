unit uPB_StringSizes;

interface

uses
  Winapi.Windows, pbOutput, uProtobufBaseObject, uProtobufReader;

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
      FClubname: Integer;
      FInvcode: Integer;
      FUsername: Integer;
      FGamename: Integer;

    procedure SetEmail(const AValue: Integer);
    procedure SetPassword(const AValue: Integer);
    procedure SetClubname(const AValue: Integer);
    procedure SetInvcode(const AValue: Integer);
    procedure SetUsername(const AValue: Integer);
    procedure SetGamename(const AValue: Integer);

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property Email: Integer read FEmail write SetEmail;
    property Password: Integer read FPassword write SetPassword;
    property Clubname: Integer read FClubname write SetClubname;
    property Invcode: Integer read FInvcode write SetInvcode;
    property Username: Integer read FUsername write SetUsername;
    property Gamename: Integer read FGamename write SetGamename;
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
        SetEmail(AProtobufReader.readInt32);
      end;
      FN_PASSWORD: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetPassword(AProtobufReader.readInt32);
      end;
      FN_CLUBNAME: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetClubname(AProtobufReader.readInt32);
      end;
      FN_INVCODE: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetInvcode(AProtobufReader.readInt32);
      end;
      FN_USERNAME: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetUsername(AProtobufReader.readInt32);
      end;
      FN_GAMENAME: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetGamename(AProtobufReader.readInt32);
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
  if IsModifiedField(FN_EMAIL) then
    pbout.writeInt32(FN_EMAIL, FEmail);
  if IsModifiedField(FN_PASSWORD) then
    pbout.writeInt32(FN_PASSWORD, FPassword);
  if IsModifiedField(FN_CLUBNAME) then
    pbout.writeInt32(FN_CLUBNAME, FClubname);
  if IsModifiedField(FN_INVCODE) then
    pbout.writeInt32(FN_INVCODE, FInvcode);
  if IsModifiedField(FN_USERNAME) then
    pbout.writeInt32(FN_USERNAME, FUsername);
  if IsModifiedField(FN_GAMENAME) then
    pbout.writeInt32(FN_GAMENAME, FGamename);
  result := pbout;
end;

procedure TPB_StringSizes.SetEmail(const AValue: Integer);
begin
  FEmail := AValue;
  AddModifiedField(FN_EMAIL);
end;

procedure TPB_StringSizes.SetPassword(const AValue: Integer);
begin
  FPassword := AValue;
  AddModifiedField(FN_PASSWORD);
end;

procedure TPB_StringSizes.SetClubname(const AValue: Integer);
begin
  FClubname := AValue;
  AddModifiedField(FN_CLUBNAME);
end;

procedure TPB_StringSizes.SetInvcode(const AValue: Integer);
begin
  FInvcode := AValue;
  AddModifiedField(FN_INVCODE);
end;

procedure TPB_StringSizes.SetUsername(const AValue: Integer);
begin
  FUsername := AValue;
  AddModifiedField(FN_USERNAME);
end;

procedure TPB_StringSizes.SetGamename(const AValue: Integer);
begin
  FGamename := AValue;
  AddModifiedField(FN_GAMENAME);
end;

end.

