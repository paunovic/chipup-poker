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
      FN_OWNERMONGOID = 5;
      FN_PASSWORD = 6;
      FN_PRIVATE = 7;
      FN_SEQ = 8;
      FN_MEMBERS = 9;
      FN_HAS_PASSWORD = 10;
      FN_MEMBER_COUNT = 11;

    var
      FMongoId: TBytes;
      FChips: Integer;
      FName: AnsiString;
      FOwnerMongoId: TBytes;
      FPassword: AnsiString;
      FPrivate: Boolean;
      FSeq: Integer;
      FMembers: TStringList;
      FMemberCount: Integer;
      FHasPassword: Boolean;

    function GetMongoId: AnsiString;
    function GetOwnerMongoId: AnsiString;

  public
    destructor Destroy; override;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property MongoId: AnsiString read GetMongoId;
    property Chips: Integer read FChips;
    property Name: AnsiString read FName;
    property OwnerMongoId: AnsiString read GetOwnerMongoId;
    property Password: AnsiString read FPassword;
    property Private: Boolean read FPrivate;
    property Seq: Integer read FSeq;
    property Members: TStringList read FMembers;
    property MemberCount: Integer read FMemberCount;
    property HasPassword: Boolean read FHasPassword;
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
  member                              : TBytes;
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
        AProtobufReader.readBytes(FMongoId);
      end;
      FN_CHIPS: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FChips := AProtobufReader.readInt32;
      end;
      FN_NAME: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        FName := AProtobufReader.readString;
      end;
      FN_OWNERMONGOID: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        AProtobufReader.readBytes(FOwnerMongoId);
      end;
      FN_PASSWORD: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        FPassword := AProtobufReader.readString;
        FHasPassword := FPassword <> '';
      end;
      FN_PRIVATE: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FPrivate := AProtobufReader.readBoolean;
      end;
      FN_SEQ: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FSeq := AProtobufReader.readInt32;
      end;
      FN_MEMBERS: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        AProtobufReader.readBytes(member);
        FMembers.Add(String(BytesToHex(member)));
        FMemberCount := FMembers.Count;
      end;
      FN_HAS_PASSWORD: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FHasPassword := AProtobufReader.readBoolean;
      end;
      FN_MEMBER_COUNT: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FMemberCount := AProtobufReader.readInt32;
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
  result := pbout;
end;

function TPB_Club.GetMongoId: AnsiString;
begin
  result := BytesToHex(FMongoId);
end;

function TPB_Club.GetOwnerMongoId: AnsiString;
begin
  result := BytesToHex(FOwnerMongoId);
end;

end.

