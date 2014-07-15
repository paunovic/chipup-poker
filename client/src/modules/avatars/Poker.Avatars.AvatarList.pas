unit Poker.Avatars.AvatarList;

interface

uses
  Vcl.Imaging.JPEG, Vcl.Graphics, System.Generics.Collections, System.Classes, System.SysUtils, Asphyre.Images, Poker.Avatars.Avatar,
  OverbyteIcsHttpProt, OverbyteIcsWSocket;

type
  TAvatarList = class(TObjectDictionary<TBytes, TAvatar>)
  private
    FRetrievingImage: TJPEGImage;
    FOnAvatarChanged: TNotifyEvent;

    procedure AvatarChangedInternal(Sender: TObject);
  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
    destructor Destroy; override;

    function Add(const AId: TBytes; const AImage: TJPEGImage): TAvatar; overload;
    function DefaultAvatar: TAvatar;

    property OnAvatarChanged: TNotifyEvent read FOnAvatarChanged write FOnAvatarChanged;
  end;

var
  Avatars: TAvatarList;

implementation

uses
  Poker.Helpers.AsphyreImage, Poker.Common.Misc, Poker.Database.Core, SynDBSQLite3, Poker.DataModule,
  Poker.Settings;

{ TAvatars }

class procedure TAvatarList.Initialize;
begin
  Avatars := TAvatarList.Create;
end;

class procedure TAvatarList.Deinitialize;
begin
  FreeAndNil(Avatars);
end;

constructor TAvatarList.Create;
begin
  FRetrievingImage := TJPEGImage.Create;
  LoadJPGFromResource(FRetrievingImage, 'RetrievingAvatar');

  inherited Create([doOwnsValues]);
end;

destructor TAvatarList.Destroy;
begin
  FreeAndNil(FRetrievingImage);

  inherited;
end;

procedure TAvatarList.AvatarChangedInternal(Sender: TObject);
begin
  if Assigned(FOnAvatarChanged) then
    FOnAvatarChanged(Sender);
end;

function TAvatarList.DefaultAvatar: TAvatar;
var
  bytes: TBytes;
begin
  SetLength(bytes, 0);
  result := Add(bytes, nil);
end;

function TAvatarList.Add(const AId: TBytes; const AImage: TJPEGImage): TAvatar;
var
  avatar: TAvatar;
  id: TBytes;
begin
  id := AId;
  if Length(id) = 0 then
  begin
    SetLength(id, 1);
    id[0] := 33;
  end;

  if TryGetValue(id, avatar) then
  begin
    if Assigned(AImage) then
    begin
      avatar.SetImage(AImage);
      avatar.Save;
    end;
  end
  else
  begin
    if Assigned(AImage) then
      avatar := TAvatar.Create(id, AImage)
    else
      avatar := TAvatar.Create(id, FRetrievingImage);

    avatar.OnImageChanged := AvatarChangedInternal;

    inherited Add(id, avatar);

    if not Assigned(AImage) then
    begin
      if not avatar.Retrieve then
        avatar.Download;
    end
    else
      avatar.Save;
  end;

  result := avatar;
end;


end.
