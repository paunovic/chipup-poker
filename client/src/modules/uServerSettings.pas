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

  TTokenPrices = record
    ClubCreation     : Integer;
    ClubChangeDetails: Integer;
  end;

  TServerSettings = class
  private
    FEmailConfirmationExpiration: Integer;
    FStringLengths              : TStringLengths;
    FTokenPrices                : TTokenPrices;

  public
    procedure ParseHelloMessage(const AHelloReply: TPB_HelloReply);

    property EmailConfirmationExpiration: Integer read FEmailConfirmationExpiration;
    property StringLengths: TStringLengths read FStringLengths;
    property TokenPrices: TTokenPrices read FTokenPrices;

  end;

implementation


procedure TServerSettings.ParseHelloMessage(const AHelloReply: TPB_HelloReply);
begin
  FEmailConfirmationExpiration := AHelloReply.ChangeExpireTime;

  FStringLengths.EMail := AHelloReply.StringSizes.EMail;
  FStringLengths.Username := AHelloReply.StringSizes.Username;
  FStringLengths.Password := AHelloReply.StringSizes.Password;
  FStringLengths.ClubName := AHelloReply.StringSizes.ClubName;
  FStringLengths.ClubInvCode := AHelloReply.StringSizes.InvCode;
  FStringLengths.GameName := AHelloReply.StringSizes.GameName;

  FTokenPrices.ClubCreation := AHelloReply.TokenPrices.ClubCreation;
  FTokenPrices.ClubChangeDetails := AHelloReply.TokenPrices.ClubChangeDetails;
end;

end.
