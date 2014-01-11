unit uPB_Club;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils, System.Generics.Collections, pbOutput, uProtobufBaseObject, uProtobufReader;

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
      FN_ID = 8;
      FN_MEMBERS = 9;
      FN_HAS_PASSWORD = 10;
      FN_MEMBER_COUNT = 11;

    function GetMongoId: AnsiString;
    function GetOwnerMongoId: AnsiString;

    var
      FMongoId: TBytes;
      FChips: Integer;
      FName: AnsiString;
      FOwnerMongoId: TBytes;
      FPassword: AnsiString;
      FPrivate: Boolean;
      FId: Integer;
      FMembers: TStringList;
      FHasPassword: Boolean;
      FMemberCount: Integer;

  public
    constructor Create(const AMongoId: AnsiString; const AChips: Integer; const AName: AnsiString; const AOwnerMongoId: AnsiString; const APassword: AnsiString; const APrivate: Boolean; const AId: Integer); overload;
    destructor Destroy; override;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property MongoId: AnsiString read GetMongoId;
    property Chips: Integer read FChips;
    property Name: AnsiString read FName;
    property OwnerMongoId: AnsiString read GetOwnerMongoId;
    property Password: AnsiString read FPassword;
    property Private: Boolean read FPrivate;
    property Id: Integer read FId;
    property Members: TStringList read FMembers;
    property HasPassword: Boolean read FHasPassword;
    property MemberCount: Integer read FMemberCount;
  end;

  TPB_Clubs = TObjectList<TPB_Club>;

implementation

uses
  pbPublic, uCommon;


constructor TPB_Club.Create(const AMongoId: AnsiString; const AChips: Integer; const AName: AnsiString; const AOwnerMongoId: AnsiString; const APassword: AnsiString; const APrivate: Boolean; const AId: Integer);
begin
  HexToBytes(AMongoId, FMongoId);
  FChips := AChips;
  FName := AName;
  HexToBytes(AOwnerMongoId, FOwnerMongoId);
  FPassword := APassword;
  FPrivate := APrivate;
  FId := AId;
  FHasPassword := APassword <> '';
  FMemberCount := 0;
  FMembers := TStringList.Create;
  FMembers.Sorted := TRUE;
  FMembers.Duplicates := dupIgnore;
  FMembers.CaseSensitive := FALSE;
end;

destructor TPB_Club.Destroy;
begin
  FMembers.Free;

  inherited;
end;

procedure TPB_Club.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag         : Integer;
  wire_type   : Integer;
  field_number: Integer;
  endpos      : Integer;
  member      : TBytes;
begin
  if not Assigned(FMembers) then
  begin
    FMembers := TStringList.Create;
    FMembers.Sorted := TRUE;
    FMembers.Duplicates := dupIgnore;
    FMembers.CaseSensitive := FALSE;
  end;
  FMembers.Clear;

  FChips := -1;
  FId := -1;
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_MONGOID: AProtobufReader.readMongoId(FMongoId);
      FN_CHIPS: FChips := AProtobufReader.readInt32;
      FN_NAME: FName := AProtobufReader.readString;
      FN_OWNERMONGOID: AProtobufReader.readMongoId(FOwnerMongoId);
      FN_PASSWORD: FPassword := AProtobufReader.readString;
      FN_PRIVATE: FPrivate := AProtobufReader.readBoolean;
      FN_ID: FId := AProtobufReader.readInt32;
      FN_MEMBERS: begin
                    AProtobufReader.readMongoId(member);
                    FMembers.Add(String(BytesToHex(member)));
                    FMemberCount := FMembers.Count;
                  end;
      FN_HAS_PASSWORD: AProtobufReader.readBoolean;
      FN_MEMBER_COUNT: AProtobufReader.readInt32;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_Club.GetProtobuf: TProtoBufOutput;
var
  pboutput: TProtoBufOutput;
begin
  pboutput := TProtoBufOutput.Create;
  pboutput.writeInt32(FN_CHIPS, FChips);
  pboutput.writeString(FN_NAME, FName);
  if FPassword <> '' then
    pboutput.writeString(FN_PASSWORD, FPassword);
  if FPrivate <> FALSE then
    pboutput.writeBoolean(FN_PRIVATE, FPrivate);
  pboutput.writeInt32(FN_ID, FId);
  pboutput.writeBoolean(FN_HAS_PASSWORD, FHasPassword);
  pboutput.writeInt32(FN_MEMBER_COUNT, FMemberCount);
  result := pboutput;
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

