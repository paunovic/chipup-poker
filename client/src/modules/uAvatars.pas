unit uAvatars;

interface

uses
  JPEG, System.Generics.Collections, System.Classes,
  OverbyteIcsWndControl, OverbyteIcsHttpProt;

type
  TAvatar = class
  private
    FId   : AnsiString;
    FImage: TJPEGImage;

    procedure HTTPRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);

  public
    constructor Create(const AId: AnsiString); overload;
    constructor Create(const AStream: TStream); overload;
    destructor Destroy; override;

    procedure Refresh;
    procedure WriteToStream(const AStream: TStream);

    property Id   : AnsiString read FId;
    property Image: TJPEGImage read FImage;
  end;

  TAvatars = class(TObjectList<TAvatar>)
  public
    constructor Create;
    destructor Destroy; override;

    function IndexOf(const AId: AnsiString): Integer;
    function Find(const AId: AnsiString): TAvatar;
    function AddAvatar(const AId: AnsiString; const AImage: TJPEGImage = nil): TAvatar;
    function RemoveAvatar(const AId: AnsiString): Boolean;
    function RefreshAvatar(const AId: AnsiString): Boolean;
    function SetAvatarImage(const AId: AnsiString; const AImage: TJPEGImage): Boolean;

    procedure Load(const AFile: String);
    procedure Save(const AFile: String);
  end;

implementation

uses
  System.SysUtils,
  {$IFDEF DEBUG} uDebugForm, {$ENDIF}
  uCommon, uEncryption, uMainDataModule, uSettings;


{ TAvatar }

constructor TAvatar.Create(const AId: AnsiString);
begin
  FId := AId;
  FImage := TJPEGImage.Create;
end;

constructor TAvatar.Create(const AStream: TStream);
var
  id_len: Integer;
  bsize : Int64;
  tmpms : TMemoryStream;
begin
  AStream.ReadBuffer(id_len, SizeOf(id_len));
  if (id_len <= 0) or (id_len > 100 * 1024) then
    Exit;

  SetLength(FId, id_len);
  AStream.ReadBuffer(FId[1], id_len * SizeOf(Char));
  FImage := TJPEGImage.Create;
  AStream.ReadBuffer(bsize, SizeOf(bsize));
  tmpms := TMemoryStream.Create;
  try
    tmpms.CopyFrom(AStream, bsize);
    tmpms.Position := 0;
    FImage.LoadFromStream(tmpms);
  finally
    tmpms.Free;
  end;
end;

destructor TAvatar.Destroy;
begin
  FImage.Free;

  inherited;
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
  {$IFDEF DEBUG} DebugLn(Format('GET avatar: %s...', [FId]), ditNetOut); {$ENDIF}

  http := THTTPCli.Create(nil);
  http.Connection := 'Keep-Alive';
  http.BandwidthLimit := 0;
  http.RequestVer := '1.1';
  http.RcvdStream := TMemoryStream.Create;
  http.URL := Format(Settings.Hardcoded.URL.GET_AVATAR, [EncodeURL(String(FId))]);
  http.OnRequestDone := HTTPRequestDone;
  http.GetAsync;
end;

procedure TAvatar.WriteToStream(const AStream: TStream);
var
  id_len: Integer;
  bsize : Int64;
  tmpms : TMemoryStream;
begin
  id_len := Length(FId);
  AStream.WriteBuffer(id_len, SizeOf(id_len));
  AStream.WriteBuffer(FId[1], id_len * SizeOf(Char));

  tmpms := TMemoryStream.Create;
  try
    FImage.SaveToStream(tmpms);
    tmpms.Position := 0;
    bsize := tmpms.Size;
    AStream.WriteBuffer(bsize, SizeOf(bsize));
    tmpms.SaveToStream(AStream);
  finally
    tmpms.Free;
  end;
end;


{ TAvatars }

constructor TAvatars.Create;
begin
  inherited Create;

  Load(SelfPath + 'avatars.dat');
end;

destructor TAvatars.Destroy;
begin
  Save(SelfPath + 'avatars.dat');

  inherited;
end;

procedure TAvatars.Load(const AFile: String);
var
  ms    : TMemoryStream;
  avatar: TAvatar;
begin
  Clear;

  if not FileExists(AFile) then
    Exit;

  ms := TMemoryStream.Create;
  try
    ms.LoadFromFile(AFile);

    if (DecompressStream(ms)) and
       (AES256DecryptStream(ms, HardwareUID)) then
    begin
      if ms.Size = 0 then
        DeleteFile(AFile)
      else
      begin
        ms.Position := 0;
        while ms.Position < ms.Size do
        begin
          avatar := TAvatar.Create(ms);
          if Assigned(avatar.Image) then
            Add(avatar)
          else
          begin
            avatar.Free;
            DeleteFile(AFile);
            Break;
          end;
        end;
      end;
    end;
  finally
    ms.Free;
  end;
end;

procedure TAvatars.Save(const AFile: String);
var
  C1: Integer;
  ms: TMemoryStream;
begin
  ms := TMemoryStream.Create;
  try
    for C1 := 0 to Length(ToArray) - 1 do
      if Assigned(ToArray[C1].Image) then
        ToArray[C1].WriteToStream(ms);

    if (ms.Size > 0) and
       (AES256EncryptStream(ms, HardwareUID)) and
       (CompressStream(ms)) then
      ms.SaveToFile(AFile);
  finally
    ms.Free;
  end;
end;

function TAvatars.IndexOf(const AId: AnsiString): Integer;
var
  C1: Integer;
begin
  for C1 := 0 to Length(ToArray) - 1 do
    if ToArray[C1].Id = AId then
      Exit(C1);
  Exit(-1);
end;

function TAvatars.Find(const AId: AnsiString): TAvatar;
var
  index: Integer;
begin
  index := IndexOf(AId);
  if index = -1 then
    Exit(nil);
  Exit(ToArray[index]);
end;

function TAvatars.AddAvatar(const AId: AnsiString; const AImage: TJPEGImage): TAvatar;
var
  index : Integer;
  avatar: TAvatar;
begin
  index := IndexOf(AId);
  if index <> -1 then
  begin
    if Assigned(AImage) then
      ToArray[index].Image.Assign(AImage);
    Exit(ToArray[index]);
  end;

  {$IFDEF DEBUG} DebugLn(Format('Adding avatar to database: %s', [AId]), ditApplication); {$ENDIF}
  avatar := TAvatar.Create(AId);
  if Assigned(AImage) then
    avatar.Image.Assign(AImage)
  else
    avatar.Refresh;
  Add(avatar);

  Exit(avatar);
end;

function TAvatars.RemoveAvatar(const AId: AnsiString): Boolean;
var
  index: Integer;
begin
  index := IndexOf(AId);
  if index = -1 then
    Exit(FALSE);

  Delete(index);
  Exit(TRUE);
end;

function TAvatars.RefreshAvatar(const AId: AnsiString): Boolean;
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
