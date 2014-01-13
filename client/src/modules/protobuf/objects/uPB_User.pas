unit uPB_User;

interface

uses
  Winapi.Windows, System.SysUtils, System.Generics.Collections,
  pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_User = class(TProtobufBaseObject)
  private
    const
      FN_MONGOID = 1;
      FN_AVATARMONGOID = 2;
      FN_DISPLAYNAME = 3;
      FN_TOKENS = 4;
      FN_EMAIL = 5;
      FN_AUTHED = 6;
      FN_CHIPS = 7;

    var
      FMongoId: TBytes;
      FAvatarMongoId: TBytes;
      FDisplayName: AnsiString;
      FTokens: Integer;
      FEmail: AnsiString;
      FAuthed: Boolean;
      FChips: Integer;

    function GetAvatar: AnsiString;
    function GetMongoId: AnsiString;

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property MongoId: AnsiString read GetMongoId;
    property AvatarMongoId: AnsiString read GetAvatar;
    property DisplayName: AnsiString read FDisplayName;
    property Tokens: Integer read FTokens;
    property Email: AnsiString read FEmail;
    property Authed: Boolean read FAuthed;
    property Chips: Integer read FChips;
  end;

  TPB_Users = TObjectList<TPB_User>;

implementation

uses
  pbPublic, uCommon, Soap.EncdDecd;


procedure TPB_User.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_MONGOID: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        AProtobufReader.readBytes(FMongoId);
      end;
      FN_AVATARMONGOID: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        AProtobufReader.readBytes(FAvatarMongoId);
      end;
      FN_DISPLAYNAME: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        FDisplayName := AProtobufReader.readString;
      end;
      FN_TOKENS: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FTokens := AProtobufReader.readInt32;
      end;
      FN_EMAIL: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        FEmail := AProtobufReader.readString;
      end;
      FN_AUTHED: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FAuthed := AProtobufReader.readBoolean;
      end;
      FN_CHIPS: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FChips := AProtobufReader.readInt32;
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_User.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
//  pbout.writeRawData(@FMongoId[0], Length(FMongoId))(FN_MONGOID, FMongoId);
//  pbout.writeRawData(@FAvatarMongoId[0], Length(FAvatarMongoId))(FN_AVATARMONGOID, FAvatarMongoId);
  pbout.writeString(FN_DISPLAYNAME, FDisplayName);
  if FTokens <> 0 then
    pbout.writeInt32(FN_TOKENS, FTokens);
  if FEmail <> '' then
    pbout.writeString(FN_EMAIL, FEmail);
  if FAuthed <> FALSE then
    pbout.writeBoolean(FN_AUTHED, FAuthed);
  if FChips <> 0 then
    pbout.writeInt32(FN_CHIPS, FChips);
  result := pbout;
end;


function TPB_User.GetAvatar: AnsiString;
begin
  result := EncodeBase64(@FAvatarMongoId[0], Length(FAvatarMongoId));
end;

function TPB_User.GetMongoId: AnsiString;
begin
  result := BytesToHex(FMongoId);
end;

end.

