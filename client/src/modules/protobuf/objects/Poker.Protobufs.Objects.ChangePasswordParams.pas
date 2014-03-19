unit Poker.Protobufs.Objects.ChangePasswordParams;

interface

uses
  Winapi.Windows, pbOutput, Poker.Protobufs.Objects.Base, Poker.Protobufs.Reader;

type
  TPB_ChangePasswordParams = class(TProtobufBaseObject)
  private
    const
      FN_NEWPASSWORD = 1;

    var
      FNewPassword: String;

    procedure SetNewPassword(const AValue: String);

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;

    property NewPassword: String read FNewPassword write SetNewPassword;
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
        SetNewPassword(AProtobufReader.readUtf8String);
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

procedure TPB_ChangePasswordParams.SetNewPassword(const AValue: String);
begin
  FNewPassword := AValue;
  ProtobufOutput.writeString(FN_NEWPASSWORD, FNewPassword);
end;

end.

