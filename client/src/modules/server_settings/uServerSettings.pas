unit uServerSettings;

interface

uses
  uPB_HelloArguments;

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
    procedure ParseHelloMessage(const AHelloArguments: TPB_HelloArguments);

    property EmailConfirmationExpiration: Integer read FEmailConfirmationExpiration;
    property StringLengths: TStringLengths read FStringLengths;
    property TokenPrices: TTokenPrices read FTokenPrices;

  end;

implementation

uses
  superobject;


procedure TServerSettings.ParseHelloMessage(const AHelloArguments: TPB_HelloArguments);
begin
  FEmailConfirmationExpiration := AHelloArguments.ChangeExpireTime;

  FStringLengths.EMail := AHelloArguments.StringSizes.EMail;
  FStringLengths.Username := AHelloArguments.StringSizes.Username;
  FStringLengths.Password := AHelloArguments.StringSizes.Password;
  FStringLengths.ClubName := AHelloArguments.StringSizes.ClubName;
  FStringLengths.ClubInvCode := AHelloArguments.StringSizes.InvCode;
  FStringLengths.GameName := AHelloArguments.StringSizes.GameName;

  FTokenPrices.ClubCreation := AHelloArguments.TokenPrices.ClubCreation;
  FTokenPrices.ClubChangeDetails := AHelloArguments.TokenPrices.ClubChangeDetails;
end;

end.
