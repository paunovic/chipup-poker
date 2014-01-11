unit uPB_User;

interface

uses
  Winapi.Windows, System.Classes, System.Generics.Collections, pbOutput, uProtobufBaseObject, uProtobufReader,
  System.SysUtils;

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
    function GetAvatar: AnsiString;
    function GetMongoId: AnsiString;

    var
      FMongoId: TBytes;
      FAvatarMongoId: TBytes;
      FDisplayName: AnsiString;
      FEMail: AnsiString;
      FTokens: Integer;
      FAuthed: Boolean;
      FChips: Integer;

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property MongoId: AnsiString read GetMongoId;
    property AvatarMongoId: AnsiString read GetAvatar;
    property DisplayName: AnsiString read FDisplayName;
    property EMail: AnsiString read FEMail;
    property Tokens: Integer read FTokens;
    property Authed: Boolean read FAuthed;
    property Chips: Integer read FChips;
  end;

  TPB_Users = TObjectList<TPB_User>;

implementation

uses
  pbPublic, EncdDecd, uCommon;


procedure TPB_User.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag         : Integer;
  wire_type   : Integer;
  field_number: Integer;
  endpos      : Integer;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_MONGOID: AProtobufReader.readMongoId(FMongoId);
      FN_AVATAR: AProtobufReader.readMongoId(FAvatarMongoId);
      FN_DISPLAYNAME: FDisplayName := AProtobufReader.readString;
      FN_TOKENS: FTokens := AProtobufReader.readInt32;
      FN_EMAIL: FEMail := AProtobufReader.readString;
      FN_AUTHED: FAuthed := AProtobufReader.readBoolean;
      FN_CHIPS: FChips := AProtobufReader.readInt32;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_User.GetProtobuf: TProtoBufOutput;
var
  pboutput: TProtoBufOutput;
begin
  pboutput := TProtoBufOutput.Create;
  result := pboutput;
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
