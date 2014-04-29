unit Poker.Server.Validators;

interface

const
  USERNAME_ALLOWED_CHARS = 'abcdefghijklmnopqrstuvwxyz0123456789 -_';
  PASSWORD_ALLOWED_CHARS = 'abcdefghijklmnopqrstuvwxyz0123456789-_!@#$%^&*()+=~`';
  CLUBNAME_ALLOWED_CHARS = 'abcdefghijklmnopqrstuvwxyz0123456789 -!()[]{}@#$%&*+=/\''';
  CLUBCODE_ALLOWED_CHARS = 'abcdefghijklmnopqrstuvwxyz0123456789';
  GAMENAME_ALLOWED_CHARS = 'abcdefghijklmnopqrstuvwxyz0123456789 -!()[]{}@#$%&*+=/\''';


function ValidateUsername(const AUsername: String; out AError: String): Boolean;
function ValidatePassword(const APassword: String; out AError: String): Boolean;
function ValidateEMail(const AEMail: String; out AError: String): Boolean;
function ValidateClubName(const AClubName: String; out AError: String): Boolean;
function ValidateClubCode(const AClubCode: String; out AError: String): Boolean;
function ValidateGameName(const AGameName: String; out AError: String): Boolean;
function ValidateContactMessage(const AMessage: String; out AError: String): Boolean;

implementation

uses
  Vcl.Controls, System.SysUtils, Poker.Server.Settings, Poker.Common.Misc;


function ValidateUsername(const AUsername: String; out AError: String): Boolean;
begin
  AError := '';
  if (Length(AUsername) < ServerSettings.MinStringLengths.Username) or (Length(AUsername) > ServerSettings.MaxStringLengths.Username) then
    AError := Format('Username length must be between %d and %d characters', [ServerSettings.MinStringLengths.Username, ServerSettings.MaxStringLengths.Username])
  else
    if not IsValidString(AUsername, USERNAME_ALLOWED_CHARS) then
      AError := 'Invalid characters in username';

  result := AError = '';
end;

function ValidatePassword(const APassword: String; out AError: String): Boolean;
begin
  AError := '';
  if (Length(APassword) < ServerSettings.MinStringLengths.Password) or (Length(APassword) > ServerSettings.MaxStringLengths.Password) then
    AError := Format('Password length must be between %d and %d characters', [ServerSettings.MinStringLengths.Password, ServerSettings.MaxStringLengths.Password])
  else
    if not IsValidString(APassword, PASSWORD_ALLOWED_CHARS) then
      AError := 'Invalid characters in password';

  result := AError = '';
end;

function ValidateEMail(const AEMail: String; out AError: String): Boolean;
begin
  AError := '';
  if (Pos('@', AEMail) = 0) or
     (Pos(' ', AEMail) <> 0) then
    AError := 'Invalid E-mail address';

  result := AError = '';
end;

function ValidateClubName(const AClubName: String; out AError: String): Boolean;
begin
  AError := '';
  if (Length(AClubName) < ServerSettings.MinStringLengths.ClubName) or (Length(AClubName) > ServerSettings.MaxStringLengths.ClubName) then
    AError := Format('Club name length must be between %d and %d characters', [ServerSettings.MinStringLengths.ClubName, ServerSettings.MaxStringLengths.ClubName])
  else
    if not IsValidString(AClubName, CLUBNAME_ALLOWED_CHARS) then
      AError := 'Invalid characters in club name';

  result := AError = '';
end;

function ValidateClubCode(const AClubCode: String; out AError: String): Boolean;
begin
  AError := '';
  if (Length(AClubCode) < ServerSettings.MinStringLengths.ClubInvCode) or (Length(AClubCode) > ServerSettings.MaxStringLengths.ClubInvCode) then
    AError := Format('Club password must be between %d and %d characters', [ServerSettings.MinStringLengths.ClubInvCode, ServerSettings.MaxStringLengths.ClubInvCode])
  else
    if not IsValidString(AClubCode, CLUBCODE_ALLOWED_CHARS) then
      AError := 'Invalid characters in club password';

  result := AError = '';
end;

function ValidateGameName(const AGameName: String; out AError: String): Boolean;
begin
  if (Length(AGameName) < ServerSettings.MinStringLengths.GameName) or (Length(AGameName) > ServerSettings.MaxStringLengths.GameName) then
    AError := Format('Table name length must be between %d and %d characters', [ServerSettings.MinStringLengths.GameName, ServerSettings.MaxStringLengths.GameName])
  else
    if not IsValidString(AGameName, GAMENAME_ALLOWED_CHARS) then
      AError := 'Invalid characters in table name';

  result := AError = '';
end;

function ValidateContactMessage(const AMessage: String; out AError: String): Boolean;
begin
  if (Length(AMessage) < ServerSettings.MinStringLengths.ContactMessage) or (Length(AMessage) > ServerSettings.MaxStringLengths.ContactMessage) then
    AError := Format('Message length must be between %d and %d characters', [ServerSettings.MinStringLengths.ContactMessage, ServerSettings.MaxStringLengths.ContactMessage]);

  result := AError = '';
end;

end.
