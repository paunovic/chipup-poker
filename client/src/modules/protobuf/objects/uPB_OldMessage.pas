unit uPB_OldMessage;

interface

uses
  Winapi.Windows, System.Classes, pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_OldMessage = class(TProtobufBaseObject)
  private
    const
      FN_CODE = 1;
      FN_MSG = 2;
      FN_COMMAND = 3;

    var
      FCode: Integer;
      FMsg: AnsiString;
      FCommand: AnsiString;

  public
    constructor Create(const ACode: Integer; const AMsg: AnsiString; const ACommand: AnsiString); overload;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property Code: Integer read FCode;
    property Msg: AnsiString read FMsg;
    property Command: AnsiString read FCommand;
  end;

implementation

uses
  System.SysUtils, pbPublic;


constructor TPB_OldMessage.Create(const ACode: Integer; const AMsg: AnsiString; const ACommand: AnsiString);
begin
  FCode := ACode;
  FMsg := AMsg;
  FCommand := ACommand;
end;

procedure TPB_OldMessage.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag         : Integer;
  wire_type   : Integer;
  field_number: Integer;
  endpos      : Integer;
begin
  FCode := -1;
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_CODE: FCode := AProtobufReader.readInt32;
      FN_MSG: FMsg := AProtobufReader.readString;
      FN_COMMAND: FCommand := AProtobufReader.readString;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_OldMessage.GetProtobuf: TProtoBufOutput;
var
  pboutput: TProtoBufOutput;
begin
  pboutput := TProtoBufOutput.Create;
  if FCode <> -1 then
    pboutput.writeInt32(FN_CODE, FCode);
  if FMsg <> '' then
    pboutput.writeString(FN_MSG, FMsg);
  if FCommand <> '' then
    pboutput.writeString(FN_COMMAND, FCommand);
  result := pboutput;
end;

end.

