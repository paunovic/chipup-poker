unit uPB_Game;

interface

uses
  Winapi.Windows, System.SysUtils, System.Generics.Collections,
  pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_Game = class(TProtobufBaseObject)
    const
      FN_MONGOID = 1;
      FN_CREATOR = 2;
      FN_NAME = 3;
      FN_CLUBSEQ = 4;
      FN_GAMETYPE = 5;
      FN_GAMELIMIT = 6;
      FN_SMALLBLIND = 7;
      FN_BIGBLIND = 8;
      FN_SEATS = 9;

    var
      FMongoId: TBytes;
      FCreatorMongoId: TBytes;
      FName: AnsiString;
      FClubSeq: Integer;
      FGameType: Integer;
      FGameLimit: Integer;
      FSmallBlind: Integer;
      FBigBlind: Integer;
      FSeats: Integer;
  private
    function GetCreatorMongoId: AnsiString;
    function GetMongoId: AnsiString;

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property MongoId: AnsiString read GetMongoId;
    property CreatorMongoId: AnsiString read GetCreatorMongoId;
    property Name: AnsiString read FName;
    property ClubSeq: Integer read FClubSeq;
    property GameType: Integer read FGameType;
    property GameLimit: Integer read FGameLimit;
    property SmallBlind: Integer read FSmallBlind;
    property BigBlind: Integer read FBigBlind;
    property Seats: Integer read FSeats;
  end;

  TPB_Games = TObjectList<TPB_Game>;

implementation

uses
  pbPublic, uCommon;


procedure TPB_Game.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
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
      FN_CREATOR: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        AProtobufReader.readBytes(FCreatorMongoId);
      end;
      FN_NAME: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        FName := AProtobufReader.readString;
      end;
      FN_CLUBSEQ: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FClubSeq := AProtobufReader.readInt32;
      end;
      FN_GAMETYPE: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FGameType := AProtobufReader.readInt32;
      end;
      FN_GAMELIMIT: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FGameLimit := AProtobufReader.readInt32;
      end;
      FN_SMALLBLIND: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FSmallBlind := AProtobufReader.readInt32;
      end;
      FN_BIGBLIND: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FBigBlind := AProtobufReader.readInt32;
      end;
      FN_SEATS: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FSeats := AProtobufReader.readInt32;
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_Game.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
  result := pbout;
end;

function TPB_Game.GetCreatorMongoId: AnsiString;
begin
  result := BytesToHex(FCreatorMongoId);
end;

function TPB_Game.GetMongoId: AnsiString;
begin
  result := BytesToHex(FMongoId);
end;

end.

