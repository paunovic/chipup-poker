unit Poker.Server.Validators;

interface

function ValidateUsername(const AUsername: String; out AError: String): Boolean;
function ValidatePassword(const APassword: String; out AError: String): Boolean;
function ValidateEMail(const AEMail: String; out AError: String): Boolean;
function ValidateClubName(const AClubName: String; out AError: String): Boolean;
function ValidateClubPassword(const AClubPassword: String; out AError: String): Boolean;
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
    if not IsValidString(AUsername, ServerSettings.ValidChars.Username) then
      AError := 'Invalid characters in username';

  result := AError = '';
end;

function ValidatePassword(const APassword: String; out AError: String): Boolean;
begin
  AError := '';
  if (Length(APassword) < ServerSettings.MinStringLengths.Password) or (Length(APassword) > ServerSettings.MaxStringLengths.Password) then
    AError := Format('Password length must be between %d and %d characters', [ServerSettings.MinStringLengths.Password, ServerSettings.MaxStringLengths.Password])
  else
    if not IsValidString(APassword, ServerSettings.ValidChars.Password) then
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
    if not IsValidString(AClubName, ServerSettings.ValidChars.ClubName) then
      AError := 'Invalid characters in club name';

  result := AError = '';
end;

function ValidateClubPassword(const AClubPassword: String; out AError: String): Boolean;
begin
  AError := '';
  if (Length(AClubPassword) < ServerSettings.MinStringLengths.ClubInvCode) or (Length(AClubPassword) > ServerSettings.MaxStringLengths.ClubInvCode) then
    AError := Format('Club password must be between %d and %d characters', [ServerSettings.MinStringLengths.ClubInvCode, ServerSettings.MaxStringLengths.ClubInvCode])
  else
    if not IsValidString(AClubPassword, ServerSettings.ValidChars.ClubPassword) then
      AError := 'Invalid characters in club password';

  result := AError = '';
end;

function ValidateGameName(const AGameName: String; out AError: String): Boolean;
begin
  if (Length(AGameName) < ServerSettings.MinStringLengths.GameName) or (Length(AGameName) > ServerSettings.MaxStringLengths.GameName) then
    AError := Format('Table name length must be between %d and %d characters', [ServerSettings.MinStringLengths.GameName, ServerSettings.MaxStringLengths.GameName])
  else
    if not IsValidString(AGameName, ServerSettings.ValidChars.GameName) then
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
