unit Poker.Server.Settings;

interface

uses
  Poker.Protobufs.Objects.HelloReply;

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
    FTimebank                   : Integer;
    FStringLengths              : TStringLengths;

  public
    class procedure Initialize;
    class procedure Deinitialize;

    procedure ParseHelloMessage(const AHelloReply: TPB_HelloReply);

    property EmailConfirmationExpiration: Integer read FEmailConfirmationExpiration;
    property Playtime: Integer read FPlaytime;
    property Timebank: Integer read FTimebank;
    property StringLengths: TStringLengths read FStringLengths;

  end;

var
  ServerSettings: TServerSettings;

implementation

uses
  System.SysUtils;

class procedure TServerSettings.Initialize;
begin
  ServerSettings := TServerSettings.Create;
end;

class procedure TServerSettings.Deinitialize;
begin
  FreeAndNil(ServerSettings);
end;

procedure TServerSettings.ParseHelloMessage(const AHelloReply: TPB_HelloReply);
begin
  FEmailConfirmationExpiration := AHelloReply.ChangeExpireTime;
  FPlaytime := AHelloReply.MaxPlayTime;
  FTimebank := AHelloReply.MaxTimebank;

  FStringLengths.EMail := AHelloReply.StringSizes.EMail;
  FStringLengths.Username := AHelloReply.StringSizes.Username;
  FStringLengths.Password := AHelloReply.StringSizes.Password;
  FStringLengths.ClubName := AHelloReply.StringSizes.ClubName;
  FStringLengths.ClubInvCode := AHelloReply.StringSizes.InvCode;
  FStringLengths.GameName := AHelloReply.StringSizes.GameName;
end;

end.
