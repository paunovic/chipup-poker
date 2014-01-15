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
      FName: AnsiString;
      FOwner: TBytes;
      FPassword: AnsiString;
      FIsPrivate: Boolean;
      FSeq: Integer;
      FMembers: TStringList;
      FHasPassword: Boolean;
      FMemberCount: Integer;

    function GetOwnerMongoIdHex: String;
    procedure SetMongoId(const AValue: TBytes);
    procedure SetChips(const AValue: Integer);
    procedure SetName(const AValue: AnsiString);
    procedure SetOwner(const AValue: TBytes);
    procedure SetPassword(const AValue: AnsiString);
    procedure SetPrivate(const AValue: Boolean);
    procedure SetSeq(const AValue: Integer);
    procedure SetHasPassword(const AValue: Boolean);
    procedure SetMemberCount(const AValue: Integer);

  public
    destructor Destroy; override;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property MongoId: TBytes read FMongoId write SetMongoId;
    property Chips: Integer read FChips write SetChips;
    property Name: AnsiString read FName write SetName;
    property Owner: TBytes read FOwner write SetOwner;
    property OwnerMongoId: String read GetOwnerMongoIdHex;
    property Password: AnsiString read FPassword write SetPassword;
    property IsPrivate: Boolean read FIsPrivate write SetPrivate;
    property Seq: Integer read FSeq write SetSeq;
    property Members: TStringList read FMembers;
    property HasPassword: Boolean read FHasPassword write SetHasPassword;
    property MemberCount: Integer read FMemberCount write SetMemberCount;
  end;

  TPB_Clubs = TObjectList<TPB_Club>;

implementation

uses
  pbPublic, uCommon;


destructor TPB_Club.Destroy;
begin
  if Assigned(FMembers) then
    FMembers.Free;

  inherited;
end;

procedure TPB_Club.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
  bytes                               : TBytes;
begin
  if not Assigned(FMembers) then
  begin
    FMembers := TStringList.Create;
    FMembers.Sorted := TRUE;
    FMembers.Duplicates := dupIgnore;
    FMembers.CaseSensitive := FALSE;
  end;
  FMembers.Clear;
  FHasPassword := FALSE;

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
        SetName(AProtobufReader.readString);
      end;
      FN_OWNER: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        AProtobufReader.readBytes(bytes);
        SetOwner(bytes);
      end;
      FN_PASSWORD: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        SetPassword(AProtobufReader.readString);
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
        AProtobufReader.readBytes(bytes);
        FMembers.Add(String(BytesToHex(bytes)));
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

function TPB_Club.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
  if IsModifiedField(FN_MONGOID) then
    pbout.writeBytes(FN_MONGOID, FMongoId);
  if IsModifiedField(FN_CHIPS) then
    pbout.writeInt32(FN_CHIPS, FChips);
  if IsModifiedField(FN_NAME) then
    pbout.writeString(FN_NAME, FName);
  if IsModifiedField(FN_OWNER) then
    pbout.writeBytes(FN_OWNER, FOwner);
  if IsModifiedField(FN_PASSWORD) then
    pbout.writeString(FN_PASSWORD, FPassword);
  if IsModifiedField(FN_ISPRIVATE) then
    pbout.writeBoolean(FN_ISPRIVATE, FIsPrivate);
  if IsModifiedField(FN_SEQ) then
    pbout.writeInt32(FN_SEQ, FSeq);
  if IsModifiedField(FN_HASPASSWORD) then
    pbout.writeBoolean(FN_HASPASSWORD, FHasPassword);
  if IsModifiedField(FN_MEMBERCOUNT) then
    pbout.writeInt32(FN_MEMBERCOUNT, FMemberCount);
  result := pbout;
end;

function TPB_Club.GetOwnerMongoIdHex: String;
begin
  result := String(BytesToHex(FOwner));
end;

procedure TPB_Club.SetMongoId(const AValue: TBytes);
begin
  FMongoId := AValue;
  AddModifiedField(FN_MONGOID);
end;

procedure TPB_Club.SetChips(const AValue: Integer);
begin
  FChips := AValue;
  AddModifiedField(FN_CHIPS);
end;

procedure TPB_Club.SetName(const AValue: AnsiString);
begin
  FName := AValue;
  AddModifiedField(FN_NAME);
end;

procedure TPB_Club.SetOwner(const AValue: TBytes);
begin
  FOwner := AValue;
  AddModifiedField(FN_OWNER);
end;

procedure TPB_Club.SetPassword(const AValue: AnsiString);
begin
  FPassword := AValue;
  AddModifiedField(FN_PASSWORD);
end;

procedure TPB_Club.SetPrivate(const AValue: Boolean);
begin
  FIsPrivate := AValue;
  AddModifiedField(FN_ISPRIVATE);
end;

procedure TPB_Club.SetSeq(const AValue: Integer);
begin
  FSeq := AValue;
  AddModifiedField(FN_SEQ);
end;

procedure TPB_Club.SetHasPassword(const AValue: Boolean);
begin
  FHasPassword := AValue;
  AddModifiedField(FN_HASPASSWORD);
end;

procedure TPB_Club.SetMemberCount(const AValue: Integer);
begin
  FMemberCount := AValue;
  AddModifiedField(FN_MEMBERCOUNT);
end;

end.

