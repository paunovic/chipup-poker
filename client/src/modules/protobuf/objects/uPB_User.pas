unit uPB_User;

interface

uses
  Winapi.Windows, System.SysUtils, System.Generics.Collections, pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_User = class(TProtobufBaseObject)
  private
    const
      FN_MONGOID = 1;
      FN_AVATAR = 2;
      FN_DISPLAYNAME = 3;
      FN_TOKENS = 4;
      FN_EMAIL = 5;
      FN_AUTHED = 6;
      FN_CHIPS = 7;

    var
      FMongoId: TBytes;
      FAvatar: TBytes;
      FDisplayname: AnsiString;
      FTokens: Integer;
      FEmail: AnsiString;
      FAuthed: Boolean;
      FChips: Integer;

    function GetAvatar: AnsiString;
    procedure SetMongoId(const AValue: TBytes);
    procedure SetAvatar(const AValue: TBytes);
    procedure SetDisplayname(const AValue: AnsiString);
    procedure SetTokens(const AValue: Integer);
    procedure SetEmail(const AValue: AnsiString);
    procedure SetAuthed(const AValue: Boolean);
    procedure SetChips(const AValue: Integer);

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;

    property MongoId: TBytes read FMongoId;
    property Avatar: AnsiString read GetAvatar;
    property Displayname: AnsiString read FDisplayname write SetDisplayname;
    property Tokens: Integer read FTokens write SetTokens;
    property Email: AnsiString read FEmail write SetEmail;
    property Authed: Boolean read FAuthed write SetAuthed;
    property Chips: Integer read FChips write SetChips;
  end;

  TPB_Users = TObjectList<TPB_User>;

implementation

uses
  uCommon, pbPublic, Soap.EncdDecd;


procedure TPB_User.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
  bytes                               : TBytes;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_MONGOID: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        AProtobufReader.readBytes(bytes);
        SetMongoId(bytes);
      end;
      FN_AVATAR: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        AProtobufReader.readBytes(bytes);
        SetAvatar(bytes);
      end;
      FN_DISPLAYNAME: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        SetDisplayname(AProtobufReader.readString);
      end;
      FN_TOKENS: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetTokens(AProtobufReader.readInt32);
      end;
      FN_EMAIL: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        SetEmail(AProtobufReader.readString);
      end;
      FN_AUTHED: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetAuthed(AProtobufReader.readBoolean);
      end;
      FN_CHIPS: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetChips(AProtobufReader.readInt32);
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_User.GetAvatar: AnsiString;
begin
  result := EncodeBase64(@FAvatar[0], Length(FAvatar));
end;

procedure TPB_User.SetMongoId(const AValue: TBytes);
begin
  FMongoId := AValue;
  ProtobufOutput.writeBytes(FN_MONGOID, FMongoId);
end;

procedure TPB_User.SetAvatar(const AValue: TBytes);
begin
  FAvatar := AValue;
  ProtobufOutput.writeBytes(FN_AVATAR, FAvatar);
end;

procedure TPB_User.SetDisplayname(const AValue: AnsiString);
begin
  FDisplayname := AValue;
  ProtobufOutput.writeString(FN_DISPLAYNAME, FDisplayname);
end;

procedure TPB_User.SetTokens(const AValue: Integer);
begin
  FTokens := AValue;
  ProtobufOutput.writeInt32(FN_TOKENS, FTokens);
end;

procedure TPB_User.SetEmail(const AValue: AnsiString);
begin
  FEmail := AValue;
  ProtobufOutput.writeString(FN_EMAIL, FEmail);
end;

procedure TPB_User.SetAuthed(const AValue: Boolean);
begin
  FAuthed := AValue;
  ProtobufOutput.writeBoolean(FN_AUTHED, FAuthed);
end;

procedure TPB_User.SetChips(const AValue: Integer);
begin
  FChips := AValue;
  ProtobufOutput.writeInt32(FN_CHIPS, FChips);
end;

end.

