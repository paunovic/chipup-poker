unit uAvatars;

interface

uses
  JPEG,
  uAvatar;

type
  TAvatars = class
  private
    FAvatarList: TAvatarList;

  public
    constructor Create;
    destructor Destroy; override;

    function IndexOf(const AId: AnsiString): Integer;
    function Find(const AId: AnsiString): TAvatar;
    function Add(const AId: AnsiString; const AImage: TJPEGImage = nil): TAvatar;
    function Remove(const AId: AnsiString): Boolean;
    function Refresh(const AId: AnsiString): Boolean;
    function SetAvatarImage(const AId: AnsiString; const AImage: TJPEGImage): Boolean;
  end;

implementation

uses
  uMainDataModule, uCommon,
  {$IFDEF DEBUG} uDebugForm, {$ENDIF}
  System.SysUtils, System.Classes;


constructor TAvatars.Create;
begin
  FAvatarList := TAvatarList.Create;
  FAvatarList.Load(SelfPath + 'avatars.dat');
end;

destructor TAvatars.Destroy;
begin
  FAvatarList.Save(SelfPath + 'avatars.dat');
  FAvatarList.Free;

  inherited;
end;

function TAvatars.IndexOf(const AId: AnsiString): Integer;
begin
  result := FAvatarList.IndexOf(AId);
end;

function TAvatars.Find(const AId: AnsiString): TAvatar;
begin
  result := FAvatarList.Find(AId);
end;

function TAvatars.Add(const AId: AnsiString; const AImage: TJPEGImage = nil): TAvatar;
var
  index : Integer;
  avatar: TAvatar;
begin
  index := IndexOf(AId);
  if index <> -1 then
  begin
    if Assigned(AImage) then
      FAvatarList[index].Image.Assign(AImage);
    Exit(FAvatarList[index]);
  end;

  {$IFDEF DEBUG} DebugLn(Format('Adding avatar to database: %s', [AId]), ditApplication); {$ENDIF}
  avatar := TAvatar.Create(AId);
  if Assigned(AImage) then
    avatar.Image.Assign(AImage)
  else
    avatar.Refresh;
  FAvatarList.Add(avatar);

  Exit(avatar);
end;

function TAvatars.Remove(const AId: AnsiString): Boolean;
var
  index: Integer;
begin
  index := IndexOf(AId);
  if index = -1 then
    Exit(FALSE);

  FAvatarList.Delete(index);
  Exit(TRUE);
end;

function TAvatars.Refresh(const AId: AnsiString): Boolean;
var
  avatar: TAvatar;
begin
  avatar := Find(AId);
  if not Assigned(avatar) then
    Exit(FALSE);

  avatar.Refresh;
  Exit(TRUE);
end;

function TAvatars.SetAvatarImage(const AId: AnsiString; const AImage: TJPEGImage): Boolean;
var
  avatar: TAvatar;
begin
  avatar := Find(AId);
  if not Assigned(avatar) then
    Exit(FALSE);

  avatar.Image.Assign(AImage);
  Exit(TRUE);
end;

end.


