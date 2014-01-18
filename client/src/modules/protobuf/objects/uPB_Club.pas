unit uPB_Club;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Generics.Collections,
  pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_Club = class(TProtobufBaseObject)
  private
    const
      FN_MONGOID = 1;
      FN_CHIPS = 2;
      FN_NAME = 4;
      FN_OWNER = 5;
      FN_PASSWORD = 6;
      FN_ISPRIVATE = 7;
      FN_SEQ = 8;
      FN_MEMBERS = 9;
      FN_HASPASSWORD = 10;
      FN_MEMBERCOUNT = 11;

    var
      FMongoId: TBytes;
      FChips: Integer;
      FName: String;
      FOwner: TBytes;
      FPassword: String;
      FIsPrivate: Boolean;
      FSeq: Integer;
      FMembers: TArray<TBytes>;
      FHasPassword: Boolean;
      FMemberCount: Integer;

    procedure SetMongoId(const AValue: TBytes);
    procedure SetChips(const AValue: Integer);
    procedure SetName(const AValue: String);
    procedure SetOwner(const AValue: TBytes);
    procedure SetPassword(const AValue: String);
    procedure SetPrivate(const AValue: Boolean);
    procedure SetSeq(const AValue: Integer);
    procedure SetHasPassword(const AValue: Boolean);
    procedure SetMemberCount(const AValue: Integer);

  public
    destructor Destroy; override;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;

    property MongoId: TBytes read FMongoId write SetMongoId;
    property Chips: Integer read FChips write SetChips;
    property Name: String read FName write SetName;
    property Owner: TBytes read FOwner write SetOwner;
    property Password: String read FPassword write SetPassword;
    property IsPrivate: Boolean read FIsPrivate write SetPrivate;
    property Seq: Integer read FSeq write SetSeq;
    property Members: TArray<TBytes> read FMembers;
    property HasPassword: Boolean read FHasPassword write SetHasPassword;
    property MemberCount: Integer read FMemberCount write SetMemberCount;
  end;

  TPB_Clubs = TObjectList<TPB_Club>;

implementation

uses
  pbPublic, uCommon;


destructor TPB_Club.Destroy;
begin
{  if Assigned(FMembers) then
    FMembers.Free;
 }
  inherited;
end;

procedure TPB_Club.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
  bytes                               : TBytes;
begin
{  if not Assigned(FMembers) then
  begin
    FMembers := TStringList.Create;
    FMembers.Sorted := TRUE;
    FMembers.Duplicates := dupIgnore;
    FMembers.CaseSensitive := FALSE;
  end;
  FMembers.Clear;
  }
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_MONGOID: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        AProtobufReader.readBytes(bytes);
        SetMongoId(bytes);
      end;
      FN_CHIPS: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetChips(AProtobufReader.readInt32);
      end;
      FN_NAME: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        SetName(AProtobufReader.readUtf8String);
      end;
      FN_OWNER: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        AProtobufReader.readBytes(bytes);
        SetOwner(bytes);
      end;
      FN_PASSWORD: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        SetPassword(AProtobufReader.readUtf8String);
      end;
      FN_ISPRIVATE: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetPrivate(AProtobufReader.readBoolean);
      end;
      FN_SEQ: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetSeq(AProtobufReader.readInt32);
      end;
      FN_MEMBERS: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        Inc(FMemberCount);
        SetLength(FMembers, FMemberCount);
        AProtobufReader.readBytes(FMembers[FMemberCount - 1]);
      end;
      FN_HASPASSWORD: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetHasPassword(AProtobufReader.readBoolean);
      end;
      FN_MEMBERCOUNT: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetMemberCount(AProtobufReader.readInt32);
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

procedure TPB_Club.SetMongoId(const AValue: TBytes);
begin
  FMongoId := AValue;
  ProtobufOutput.writeBytes(FN_MONGOID, FMongoId);
end;

procedure TPB_Club.SetChips(const AValue: Integer);
begin
  FChips := AValue;
  ProtobufOutput.writeInt32(FN_CHIPS, FChips);
end;

procedure TPB_Club.SetName(const AValue: String);
begin
  FName := AValue;
  ProtobufOutput.writeString(FN_NAME, FName);
end;

procedure TPB_Club.SetOwner(const AValue: TBytes);
begin
  FOwner := AValue;
  ProtobufOutput.writeBytes(FN_OWNER, FOwner);
end;

procedure TPB_Club.SetPassword(const AValue: String);
begin
  FPassword := AValue;
  ProtobufOutput.writeString(FN_PASSWORD, FPassword);
end;

procedure TPB_Club.SetPrivate(const AValue: Boolean);
begin
  FIsPrivate := AValue;
  ProtobufOutput.writeBoolean(FN_ISPRIVATE, FIsPrivate);
end;

procedure TPB_Club.SetSeq(const AValue: Integer);
begin
  FSeq := AValue;
  ProtobufOutput.writeInt32(FN_SEQ, FSeq);
end;

procedure TPB_Club.SetHasPassword(const AValue: Boolean);
begin
  FHasPassword := AValue;
  ProtobufOutput.writeBoolean(FN_HASPASSWORD, FHasPassword);
end;

procedure TPB_Club.SetMemberCount(const AValue: Integer);
begin
  FMemberCount := AValue;
  ProtobufOutput.writeInt32(FN_MEMBERCOUNT, FMemberCount);
end;

end.

