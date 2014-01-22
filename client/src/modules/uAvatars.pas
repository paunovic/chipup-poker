unit uAvatars;

interface

uses
  JPEG, System.Generics.Collections, System.Classes, System.SysUtils,
  OverbyteIcsWndControl, OverbyteIcsHttpProt;

type
  TAvatar = class
  private
    FId        : TBytes;
    FIdAsString: String;
    FImage     : TJPEGImage;

    procedure HTTPRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure SetId(const AValue: TBytes);
    function GetAvatarPath(const AStoragePath: String): String;

  public
    constructor Create(const AId: TBytes); overload;
    destructor Destroy; override;

    procedure Refresh;

    procedure SetImage(const AImage: TJPEGImage); overload;
    function SetImage(const AStoragePath, AId: String): Boolean; overload;
    procedure Save(const AStoragePath: String);

    property Id        : TBytes read FId write SetId;
    property IdAsString: String read FIdAsString;
    property Image     : TJPEGImage read FImage;
  end;

  TAvatars = class(TObjectList<TAvatar>)
  private
    FStoragePath: String;
  public
    constructor Create(const AStoragePath: String);
    destructor Destroy; override;

    function IndexOf(const AId: TBytes): Integer;
    function Find(const AId: TBytes; out AAvatar: TAvatar): Boolean;
    function AddAvatar(const AId: TBytes; const AImage: TJPEGImage = nil): TAvatar;
    function RemoveAvatar(const AId: TBytes): Boolean;
    function RefreshAvatar(const AId: TBytes): Boolean;
    function SetAvatarImage(const AId: TBytes; const AImage: TJPEGImage): Boolean;

    procedure Save;
  end;

implementation

uses
  {$IFDEF DEBUG} uDebugForm, {$ENDIF}
  uCommon, uMainDataModule, uSettings, uEncryption;


{ TAvatar }

constructor TAvatar.Create(const AId: TBytes);
begin
  SetId(AId);
end;

destructor TAvatar.Destroy;
begin
  if Assigned(FImage) then
    FreeAndNil(FImage);

  inherited;
end;

function TAvatar.GetAvatarPath(const AStoragePath: String): String;
begin
  result := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(AStoragePath) + Copy(FIdAsString, 1, 3)) + FIdAsString;
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
    if IsJPEGStream(http.RcvdStream) then
    begin
      if not Assigned(FImage) then
        FImage := TJPEGImage.Create;
      http.RcvdStream.Position := 0;
      FImage.LoadFromStream(http.RcvdStream);
    end;
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

procedure TAvatar.Save(const AStoragePath: String);
var
  apath: String;
begin
  if Assigned(FImage) then
  begin
    apath := GetAvatarPath(AStoragePath);
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
  FIdAsString := LowerCase(FIdAsString);
end;

function TAvatar.SetImage(const AStoragePath, AId: String): Boolean;
var
  ms   : TMemoryStream;
  apath: String;
begin
  result := FALSE;

  apath := GetAvatarPath(AStoragePath);
  if not FileExists(apath) then
    Exit;

  ms := TMemoryStream.Create;
  try
    ms.LoadFromFile(apath);
    if IsJPEGStream(ms) then
    begin
      FImage := TJPEGImage.Create;
      ms.Position := 0;
      FImage.LoadFromStream(ms);
      result := TRUE;
    end;
  finally
    ms.Free;
  end;
end;

procedure TAvatar.SetImage(const AImage: TJPEGImage);
begin
  if not Assigned(FImage) then
    FImage := TJPEGImage.Create;

  FImage.Assign(AImage);
end;

{ TAvatars }

constructor TAvatars.Create(const AStoragePath: String);
begin
  inherited Create;

  FStoragePath := AStoragePath;
end;

destructor TAvatars.Destroy;
begin
  Save;

  inherited;
end;

procedure TAvatars.Save;
var
  C1: Integer;
begin
  for C1 := 0 to Length(ToArray) - 1 do
    ToArray[C1].Save(FStoragePath);
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

function TAvatars.AddAvatar(const AId: TBytes; const AImage: TJPEGImage): TAvatar;
var
  index : Integer;
  avatar: TAvatar;
begin
  index := IndexOf(AId);
  if index <> -1 then
  begin
    if Assigned(AImage) then
      ToArray[index].SetImage(AImage);

    if not Assigned(ToArray[index].Image) then
      ToArray[index].SetImage(FStoragePath, ToArray[index].IdAsString);

    Exit(ToArray[index]);
  end;

  avatar := TAvatar.Create(AId);
  if Assigned(AImage) then
    avatar.SetImage(AImage)
  else
    if not avatar.SetImage(FStoragePath, avatar.IdAsString) then
      avatar.Refresh;

  Add(avatar);

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
