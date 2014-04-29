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
    ContactMessage: Integer;
  end;

  TServerSettings = class
  private
    FEmailConfirmationExpiration: Integer;
    FPlaytime                   : Integer;
    FTimebank                   : Integer;
    FMinStringLengths           : TStringLengths;
    FMaxStringLengths           : TStringLengths;

  public
    class procedure Initialize;
    class procedure Deinitialize;

    procedure ParseHelloMessage(const AHelloReply: TPB_HelloReply);

    property EmailConfirmationExpiration: Integer read FEmailConfirmationExpiration;
    property Playtime: Integer read FPlaytime;
    property Timebank: Integer read FTimebank;
    property MinStringLengths: TStringLengths read FMinStringLengths;
    property MaxStringLengths: TStringLengths read FMaxStringLengths;

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

  FMinStringLengths.EMail := AHelloReply.MinSizes.EMail;
  FMinStringLengths.Username := AHelloReply.MinSizes.Username;
  FMinStringLengths.Password := AHelloReply.MinSizes.Password;
  FMinStringLengths.ClubName := AHelloReply.MinSizes.ClubName;
  FMinStringLengths.ClubInvCode := AHelloReply.MinSizes.InvCode;
  FMinStringLengths.GameName := AHelloReply.MinSizes.GameName;
  FMinStringLengths.ContactMessage := AHelloReply.MinSizes.ContactMessage;

  FMaxStringLengths.EMail := AHelloReply.StringSizes.EMail;
  FMaxStringLengths.Username := AHelloReply.StringSizes.Username;
  FMaxStringLengths.Password := AHelloReply.StringSizes.Password;
  FMaxStringLengths.ClubName := AHelloReply.StringSizes.ClubName;
  FMaxStringLengths.ClubInvCode := AHelloReply.StringSizes.InvCode;
  FMaxStringLengths.GameName := AHelloReply.StringSizes.GameName;
  FMaxStringLengths.ContactMessage := AHelloReply.StringSizes.ContactMessage;
end;

end.
