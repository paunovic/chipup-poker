unit uPB_ChangePasswordParams;

interface

uses
  Winapi.Windows, pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_ChangePasswordParams = class(TProtobufBaseObject)
  private
    const
      FN_NEWPASSWORD = 1;

    var
      FNewPassword: AnsiString;

    procedure SetNewPassword(const AValue: AnsiString);

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property NewPassword: AnsiString read FNewPassword write FNewPassword;
  end;

implementation

uses
  pbPublic;

procedure TPB_ChangePasswordParams.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_NEWPASSWORD: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        SetNewPassword(AProtobufReader.readString);
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_ChangePasswordParams.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
  if IsModifiedField(FN_NEWPASSWORD) then
    pbout.writeString(FN_NEWPASSWORD, FNewPassword);
  result := pbout;
end;

procedure TPB_ChangePasswordParams.SetNewPassword(const AValue: AnsiString);
begin
  FNewPassword := AValue;
  AddModifiedField(FN_NEWPASSWORD);
end;

end.

