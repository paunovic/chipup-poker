unit uServerSettings;

interface

uses
  uPB_HelloReply;

type
  TStringLengths = record
    EMail      : Integer;
    Username   : Integer;
    Password   : Integer;
    ClubName   : Integer;
    ClubInvCode: Integer;
    GameName   : Integer;
  end;

  TServerSettings = class
  private
    FEmailConfirmationExpiration: Integer;
    FPlaytime                   : Integer;
    FStringLengths              : TStringLengths;

  public
    procedure ParseHelloMessage(const AHelloReply: TPB_HelloReply);

    property EmailConfirmationExpiration: Integer read FEmailConfirmationExpiration;
    property Playtime: Integer read FPlaytime;
    property StringLengths: TStringLengths read FStringLengths;

  end;

implementation


procedure TServerSettings.ParseHelloMessage(const AHelloReply: TPB_HelloReply);
begin
  FEmailConfirmationExpiration := AHelloReply.ChangeExpireTime;
  FPlaytime := AHelloReply.MaxPlayTime;

  FStringLengths.EMail := AHelloReply.StringSizes.EMail;
  FStringLengths.Username := AHelloReply.StringSizes.Username;
  FStringLengths.Password := AHelloReply.StringSizes.Password;
  FStringLengths.ClubName := AHelloReply.StringSizes.ClubName;
  FStringLengths.ClubInvCode := AHelloReply.StringSizes.InvCode;
  FStringLengths.GameName := AHelloReply.StringSizes.GameName;
end;

end.
