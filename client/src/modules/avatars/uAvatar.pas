unit uAvatar;

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

  TAvatarList = class(TObjectList<TAvatar>)
  public
    function IndexOf(const AId: AnsiString): Integer;
    function Find(const AId: AnsiString): TAvatar;

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
  if id_len <= 0 then
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

{ TAvatarList }

procedure TAvatarList.Load(const AFile: String);
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

    if DecompressStream(ms) then
    begin
      AES256DecryptStream(ms, HardwareUID);

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

procedure TAvatarList.Save(const AFile: String);
var
  C1: Integer;
  ms: TMemoryStream;
begin
  ms := TMemoryStream.Create;
  try
    for C1 := 0 to Length(ToArray) - 1 do
      if Assigned(ToArray[C1].Image) then
        ToArray[C1].WriteToStream(ms);

    if ms.Size > 0 then
    begin
      AES256EncryptStream(ms, HardwareUID);
      if CompressStream(ms) then
        ms.SaveToFile(AFile);
    end;
  finally
    ms.Free;
  end;
end;

function TAvatarList.IndexOf(const AId: AnsiString): Integer;
var
  C1: Integer;
begin
  for C1 := 0 to Length(ToArray) - 1 do
    if ToArray[C1].Id = AId then
      Exit(C1);
  Exit(-1);
end;

function TAvatarList.Find(const AId: AnsiString): TAvatar;
var
  index: Integer;
begin
  index := IndexOf(AId);
  if index = -1 then
    Exit(nil);
  Exit(ToArray[index]);
end;


end.
