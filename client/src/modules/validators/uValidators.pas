unit uValidators;

interface

const
  USERNAME_ALLOWED_CHARS = 'abcdefghijklmnopqrstuvwxyz0123456789 -_';
  PASSWORD_ALLOWED_CHARS = 'abcdefghijklmnopqrstuvwxyz0123456789-_!@#$%^&*()+=~`';
  CLUBNAME_ALLOWED_CHARS = 'abcdefghijklmnopqrstuvwxyz0123456789 -!()[]{}@#$%&*+=/\''';
  CLUBCODE_ALLOWED_CHARS = 'abcdefghijklmnopqrstuvwxyz0123456789';


function ValidateUsername(const AUsername: String; out AError: String): Boolean;
function ValidatePassword(const APassword: String; out AError: String): Boolean;
function ValidateEMail(const AEMail: String; out AError: String): Boolean;
function ValidateClubName(const AClubName: String; out AError: String): Boolean;
function ValidateClubCode(const AClubCode: String; out AError: String): Boolean;
function ValidatePrivateClubCode(const APrivate: Boolean; const AClubCode: String; out AError: String): Boolean;
function ValidateGameName(const AGameName: String; out AError: String): Boolean;

implementation

uses
  Vcl.Controls, System.SysUtils,
  uCommon, uMainDataModule, uSettings;

function ValidateUsername(const AUsername: String; out AError: String): Boolean;
begin
  AError := '';
  if (Length(AUsername) < 3) or (Length(AUsername) > dmMain.ServerSettings.StringLengths.Username) then
    AError := Format('Username length must be between 3 and %d characters', [dmMain.ServerSettings.StringLengths.Username])
  else
    if not IsValidString(AUsername, USERNAME_ALLOWED_CHARS) then
      AError := 'Invalid characters in username';

  result := AError = '';
end;

function ValidatePassword(const APassword: String; out AError: String): Boolean;
begin
  AError := '';
  if (Length(APassword) < 6) or (Length(APassword) > dmMain.ServerSettings.StringLengths.Password) then
    AError := Format('Password length must be between 6 and %d characters', [dmMain.ServerSettings.StringLengths.Password])
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
  if (Length(AClubName) < 6) or (Length(AClubName) > dmMain.ServerSettings.StringLengths.ClubName) then
    AError := Format('Club name length must be between 6 and %d characters', [dmMain.ServerSettings.StringLengths.ClubName])
  else
    if not IsValidString(AClubName, CLUBNAME_ALLOWED_CHARS) then
      AError := 'Invalid characters in club name';

  result := AError = '';
end;

function ValidateClubCode(const AClubCode: String; out AError: String): Boolean;
begin
  AError := '';
  if (Length(AClubCode) > dmMain.ServerSettings.StringLengths.ClubInvCode) then
    AError := Format('Club invitation code can''t be longer than %d characters', [dmMain.ServerSettings.StringLengths.ClubInvCode])
  else
    if not IsValidString(AClubCode, CLUBCODE_ALLOWED_CHARS) then
      AError := 'Invalid characters in club invitation code';

  result := AError = '';
end;


function ValidatePrivateClubCode(const APrivate: Boolean; const AClubCode: String; out AError: String): Boolean;
begin
  if not APrivate then
    Exit(TRUE);

  if AClubCode = '' then
  begin
    AError := 'Private clubs must have invitation code';
    Exit(FALSE);
  end;

  Exit(TRUE);
end;

function ValidateGameName(const AGameName: String; out AError: String): Boolean;
begin
  if (Length(AGameName) < 3) or (Length(AGameName) > dmMain.ServerSettings.StringLengths.GameName) then
  begin
    AError := Format('Game name length must be between 3 and %d characters', [dmMain.ServerSettings.StringLengths.GameName]);
    Exit(FALSE);
  end;

  Exit(TRUE);
end;

end.
