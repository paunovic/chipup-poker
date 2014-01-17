unit uPB_ChangeEMailParams;

interface

uses
  Winapi.Windows, pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_ChangeEMailParams = class(TProtobufBaseObject)
  private
    const
      FN_NEWMAIL = 1;

    var
      FNewMail: AnsiString;

    procedure SetNewMail(const AValue: AnsiString);

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;

    property NewMail: AnsiString read FNewMail write FNewMail;
  end;

implementation

uses
  pbPublic;

procedure TPB_ChangeEMailParams.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_NEWMAIL: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        SetNewMail(AProtobufReader.readString);
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

procedure TPB_ChangeEMailParams.SetNewMail(const AValue: AnsiString);
begin
  FNewMail := AValue;
  ProtobufOutput.writeString(FN_NEWMAIL, FNewMail);
end;

end.

