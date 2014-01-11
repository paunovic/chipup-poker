unit uPB_ForgotPasswordParams;

interface

uses
  Winapi.Windows, System.Classes, pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_ForgotPasswordParams = class(TProtobufBaseObject)
  private
    const
      FN_EMAIL = 1;

    var
      FEMail: AnsiString;

  public
    constructor Create(const AEMail: AnsiString); overload;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property EMail: AnsiString read FEMail;
  end;

implementation

uses
  System.SysUtils, pbPublic;


constructor TPB_ForgotPasswordParams.Create(const AEMail: AnsiString);
begin
  FEMail := AEMail;
end;

procedure TPB_ForgotPasswordParams.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
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
      FN_EMAIL: FEMail := AProtobufReader.readString;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_ForgotPasswordParams.GetProtobuf: TProtoBufOutput;
var
  pboutput: TProtoBufOutput;
begin
  pboutput := TProtoBufOutput.Create;
  pboutput.writeString(FN_EMAIL, FEMail);
  result := pboutput;
end;

end.
