unit Poker.Avatars;

interface

uses
  Winapi.Windows, Vcl.Imaging.JPEG, Vcl.Graphics, System.Generics.Collections, System.Classes, System.SysUtils, AsphyreImages, GR32,
  OverbyteIcsHttpProt;

type
  TAvatar = class
  private
    FId         : TBytes;
    FIdAsString : String;
    FImage      : TJPEGImage;
    FDXImage    : TAsphyreImage;
    FStoragePath: String;

    procedure HTTPRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure SetId(const AValue: TBytes);
    function GetAvatarPath: String;
    procedure MakeDXImage;

  public
    constructor Create(const AStoragePath: String; const AId: TBytes);
    destructor Destroy; override;

    procedure Refresh;

    procedure SetImage(const AImage: TJPEGImage); overload;
    function SetImage(const AMemoryStream: TMemoryStream): Boolean; overload;
    function SetImage(const AId: String): Boolean; overload;
    procedure Save;

    property Id        : TBytes read FId write SetId;
    property IdAsString: String read FIdAsString;
    property Image     : TJPEGImage read FImage;
    property DXImage   : TAsphyreImage read FDXImage;
    property Path      : String read GetAvatarPath;
  end;

  TAvatars = class(TObjectList<TAvatar>)
  private
    FStoragePath: String;
  public
    class procedure Initialize(const AStoragePath: String);
    class procedure Deinitialize;

    constructor Create(const AStoragePath: String);
    destructor Destroy; override;

    function IndexOf(const AId: TBytes): Integer;
    function Find(const AId: TBytes; out AAvatar: TAvatar): Boolean;
    function AddAvatar(const AId: TBytes; const AImage: TJPEGImage = nil): TAvatar;
    function RemoveAvatar(const AId: TBytes): Boolean;
    function RefreshAvatar(const AId: TBytes): Boolean;
    function SetAvatarImage(const AId: TBytes; const AImage: TJPEGImage): Boolean;
    function DefaultAvatar: TAvatar;
  end;

var
  Avatars: TAvatars;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  AsphyreBitmaps, GR32_Backends, AsphyreBMP, Poker.Helpers.AsphyreImage, Poker.Common.Misc,
  Poker.Settings;



{ TAvatar }

constructor TAvatar.Create(const AStoragePath: String; const AId: TBytes);
begin
  FStoragePath := AStoragePath;
  FImage := TJPEGImage.Create;
  FDXImage := TAsphyreImage.Create;
  SetId(AId);
end;

destructor TAvatar.Destroy;
begin
  FreeAndNil(FDXImage);
  FreeAndNil(FImage);

  inherited;
end;

function TAvatar.GetAvatarPath: String;
begin
  result := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(FStoragePath) + Copy(FIdAsString, 1, 3)) + FIdAsString + '.cupavt';
end;

procedure TAvatar.HTTPRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
var
  http: THTTPCli;
begin
  http := Sender as THTTPCli;

  {$IFDEF DEBUG} DebugLn(Format('GET avatar done: %s', [http.URL]), ditNetInc); {$ENDIF}

  if Assigned(http.SendStream) then
    (http.SendStream as TMemoryStream).Free;

  if Assigned(http.RcvdStream) then
  begin
    http.RcvdStream.Position := 0;
    SetImage(http.RcvdStream as TMemoryStream);
    (http.RcvdStream as TMemoryStream).Free;
  end;

  http.Free;
end;

procedure TAvatar.Refresh;
var
  http: THTTPCli;
begin
  {$IFDEF DEBUG} DebugLn(Format('GET avatar: %s...', [FIdAsString]), ditNetOut); {$ENDIF}

  http := THTTPCli.Create(nil);
  http.Connection := 'Keep-Alive';
  http.BandwidthLimit := 0;
  http.RequestVer := '1.1';
  http.RcvdStream := TMemoryStream.Create;
  http.URL := Format(Settings.Hardcoded.URL.GET_AVATAR, [EncodeURL(String(FIdAsString))]);
  http.OnRequestDone := HTTPRequestDone;
  http.GetAsync;
end;

procedure TAvatar.Save;
var
  apath: String;
begin
  if Assigned(FImage) then
  begin
    apath := GetAvatarPath;
    ForceDirectories(ExtractFilePath(apath));
    FImage.SaveToFile(apath);
  end;
end;

procedure TAvatar.SetId(const AValue: TBytes);
var
  C1: Integer;
begin
  FId := AValue;

  FIdAsString := '';
  for C1 := 0 to Length(AValue) - 1 do
    FIdAsString := FIdAsString + IntToHex(AValue[C1], 2);
  if FIdAsString = '' then
    FIdAsString := 'default';
  FIdAsString := LowerCase(FIdAsString);
end;

function TAvatar.SetImage(const AId: String): Boolean;
var
  ms   : TMemoryStream;
  apath: String;
begin
  apath := GetAvatarPath;
  if not FileExists(apath) then
    Exit(FALSE);

  ms := TMemoryStream.Create;
  try
    ms.LoadFromFile(apath);
    result := SetImage(ms);
  finally
    ms.Free;
  end;
end;

function TAvatar.SetImage(const AMemoryStream: TMemoryStream): Boolean;
var
  jpg: TJPEGImage;
begin
  if IsJPEGStream(AMemoryStream) then
  begin
    AMemoryStream.Position := 0;
    jpg := TJPEGImage.Create;
    try
      jpg.LoadFromStream(AMemoryStream);
      SetImage(jpg);
      result := TRUE;
    finally
      jpg.Free;
    end;
  end
  else
    result := FALSE;
end;

procedure TAvatar.SetImage(const AImage: TJPEGImage);
begin
  FImage.Assign(AImage);
  MakeDXImage;
  Save;
end;

procedure TAvatar.MakeDXImage;
var
  mstream: TMemoryStream;
begin
  mstream := TMemoryStream.Create;
  try
    FImage.SaveToStream(mstream);
    mstream.Position := 0;
    FDXImage.LoadFromStream('.jpg', mstream);
  finally
    mstream.Free;
  end;
end;



{ TAvatars }

class procedure TAvatars.Initialize(const AStoragePath: String);
begin
  Avatars := TAvatars.Create(AStoragePath);
end;

class procedure TAvatars.Deinitialize;
begin
  FreeAndNil(Avatars);
end;

constructor TAvatars.Create(const AStoragePath: String);
begin
  inherited Create;

  BitmapManager.RegisterExt('.cupavtr', BMPBitmap);

  FStoragePath := AStoragePath;
end;

destructor TAvatars.Destroy;
begin
  inherited;
end;

function TAvatars.IndexOf(const AId: TBytes): Integer;
var
  C1: Integer;
begin
  for C1 := 0 to Length(ToArray) - 1 do
    if CompareBytes(ToArray[C1].Id, AId) then
      Exit(C1);
  Exit(-1);
end;

function TAvatars.Find(const AId: TBytes; out AAvatar: TAvatar): Boolean;
var
  index: Integer;
begin
  index := IndexOf(AId);
  if index = -1 then
    Exit(FALSE);
  AAvatar := ToArray[index];
  Exit(TRUE);
end;

function TAvatars.DefaultAvatar: TAvatar;
var
  C1: Integer;
begin
  for C1 := 0 to Length(ToArray) - 1 do
    if ToArray[C1].IdAsString = 'default' then
      Exit(ToArray[C1]);
  Exit(nil);
end;

function TAvatars.AddAvatar(const AId: TBytes; const AImage: TJPEGImage): TAvatar;
var
  index : Integer;
  avatar: TAvatar;
begin
  avatar := nil;
  if Length(AId) = 0 then
    avatar := DefaultAvatar
  else
  begin
    index := IndexOf(AId);
    if index <> -1 then
    begin
      if Assigned(AImage) then
        ToArray[index].SetImage(AImage);

      if not Assigned(ToArray[index].Image) then
        ToArray[index].SetImage(ToArray[index].IdAsString);

      Exit(ToArray[index]);
    end;
  end;

  if not Assigned(avatar) then
  begin
    avatar := TAvatar.Create(FStoragePath, AId);
    if Assigned(AImage) then
      avatar.SetImage(AImage)
    else
      if not avatar.SetImage(avatar.IdAsString) then
        avatar.Refresh;

    Add(avatar);
  end;

  Exit(avatar);
end;

function TAvatars.RemoveAvatar(const AId: TBytes): Boolean;
var
  index: Integer;
begin
  index := IndexOf(AId);
  if index = -1 then
    Exit(FALSE);

  Delete(index);
  Exit(TRUE);
end;

function TAvatars.RefreshAvatar(const AId: TBytes): Boolean;
var
  avatar: TAvatar;
begin
  if not Find(AId, avatar) then
    Exit(FALSE);

  avatar.Refresh;
  Exit(TRUE);
end;

function TAvatars.SetAvatarImage(const AId: TBytes; const AImage: TJPEGImage): Boolean;
var
  avatar: TAvatar;
begin
  if not Find(AId, avatar) then
    Exit(FALSE);

  avatar.SetImage(AImage);
  Exit(TRUE);
end;


end.
