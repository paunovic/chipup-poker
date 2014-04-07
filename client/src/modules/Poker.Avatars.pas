unit Poker.Avatars;

interface

uses
  Winapi.Windows, Vcl.Imaging.JPEG, Vcl.Graphics, System.Generics.Collections, System.Classes, System.SysUtils, AsphyreImages,
  OverbyteIcsHttpProt, OverbyteIcsWSocket;

type
  TAvatar = class
  private
    FId: TBytes;
    FIdAsString: String;
    FImage: TJPEGImage;
    FDXImage: TAsphyreImage;
    FHTTP: TSslHttpCli;

    procedure HTTPRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure SetId(const AValue: TBytes);
    procedure ImageChanged(Sender: TObject);

  protected
    procedure Download;
    function Retrieve: Boolean;
    procedure Save;

  public
    constructor Create(const AId: TBytes; const AImage: TJPEGImage);
    destructor Destroy; override;

    procedure SetImage(const AImage: TJPEGImage); overload;
    procedure SetImage(const AStream: TStream); overload;

    function GetImage: TJPEGImage;

    property Id: TBytes read FId;
    property IdAsString: String read FIdAsString;
    property DXImage: TAsphyreImage read FDXImage;
  end;

  TAvatars = class(TObjectList<TAvatar>)
  private
    FRetrievingImage: TJPEGImage;
  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
    destructor Destroy; override;

    function Add(const AId: TBytes; const AImage: TJPEGImage): TAvatar; overload;
    function DefaultAvatar: TAvatar;

    function IndexOf(const AId: TBytes): Integer;
    function Find(const AId: TBytes; out AAvatar: TAvatar): Boolean;

  end;

var
  Avatars: TAvatars;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  AsphyreBitmaps, AsphyreBMP, Poker.Helpers.AsphyreImage, Poker.Common.Misc, Poker.Database.Core, SynDBSQLite3,
  Poker.Settings;




{ TAvatar }

constructor TAvatar.Create(const AId: TBytes; const AImage: TJPEGImage);
begin
  FDXImage := TAsphyreImage.Create;

  SetId(AId);

  FImage := TJPEGImage.Create;
  if Assigned(AImage) then
    SetImage(AImage);

  FImage.OnChange := ImageChanged;
end;

destructor TAvatar.Destroy;
begin
  if Assigned(FHTTP) then
  begin
    FHTTP.OnRequestDone := nil;
    FHTTP.Abort;
    FreeAndNil(FHTTP);
  end;

  FreeAndNil(FImage);
  FreeAndNil(FDXImage);

  inherited;
end;

procedure TAvatar.HTTPRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
begin
  {$IFDEF DEBUG} DebugLn(Format('GET avatar done: %s', [FHTTP.URL]), ditNetInc); {$ENDIF}

  if Assigned(FHTTP.SendStream) then
  begin
    FHTTP.SendStream.Free;
    FHTTP.SendStream := nil;
  end;

  if Assigned(FHTTP.RcvdStream) then
  begin
    if (ErrCode = 0) and
       (FHTTP.StatusCode = 200) then
    begin
      FHTTP.RcvdStream.Position := 0;
      if IsJPEGStream(FHTTP.RcvdStream) then
      begin
        FHTTP.RcvdStream.Position := 0;
        FImage.LoadFromStream(FHTTP.RcvdStream);
        ImageChanged(FImage);
        Save;
      end;
    end;

    FHTTP.RcvdStream.Free;
    FHTTP.RcvdStream := nil;
  end;

  FHTTP.SslContext.DeInitContext;
  FHTTP.SslContext.Free;
  FreeAndNil(FHTTP);
end;

procedure TAvatar.Download;
begin
  if Assigned(FHTTP) then
    Exit;

  FHTTP := TSslHttpCli.Create(nil);
  FHTTP.SslContext := TSslContext.Create(nil);
  FHTTP.Connection := 'Keep-Alive';
  FHTTP.BandwidthLimit := 0;
  FHTTP.RequestVer := '1.1';
  FHTTP.RcvdStream := TMemoryStream.Create;
  FHTTP.URL := Format(Settings.DomainURL + Settings.Hardcoded.URL.GET_AVATAR, [EncodeURL(String(FIdAsString))]);
  FHTTP.OnRequestDone := HTTPRequestDone;
  FHTTP.SslContext.InitContext;
  FHTTP.GetAsync;
end;

function TAvatar.GetImage: TJPEGImage;
begin
  result := FImage;
end;

function TAvatar.Retrieve: Boolean;
var
  conn: TSQLDBSQLite3ConnectionProperties;
  mstream: TMemoryStream;
begin
  conn := Database.NewConnection;
  try
    mstream := TMemoryStream.Create;
    try
      result := Database.RetrieveAvatarData(conn, FId, mstream);
      if result then
      begin
        mstream.Position := 0;
        FImage.LoadFromStream(mstream);
      end;
    finally
      mstream.Free;
    end;
  finally
    conn.Free;
  end;
end;

procedure TAvatar.Save;
var
  conn: TSQLDBSQLite3ConnectionProperties;
  mstream: TMemoryStream;
begin
  conn := Database.NewConnection;
  try
    mstream := TMemoryStream.Create;
    try
      FImage.SaveToStream(mstream);
      Database.InsertAvatar(conn, FId, mstream);
    finally
      mstream.Free;
    end;
  finally
    conn.Free;
  end;
end;

procedure TAvatar.ImageChanged(Sender: TObject);
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

procedure TAvatar.SetId(const AValue: TBytes);
var
  C1: Integer;
begin
  FId := AValue;

  FIdAsString := '';
  if Length(AValue) = 1 then
    FIdAsString := 'default'
  else
  begin
    for C1 := 0 to Length(AValue) - 1 do
      FIdAsString := FIdAsString + IntToHex(AValue[C1], 2);
    FIdAsString := LowerCase(FIdAsString);
  end;
end;

procedure TAvatar.SetImage(const AStream: TStream);
begin
  FImage.LoadFromStream(AStream);
  ImageChanged(FImage);
end;

procedure TAvatar.SetImage(const AImage: TJPEGImage);
begin
  FImage.Assign(AImage);
  ImageChanged(FImage);
end;

{ TAvatars }

class procedure TAvatars.Initialize;
begin
  Avatars := TAvatars.Create;
end;

class procedure TAvatars.Deinitialize;
begin
  FreeAndNil(Avatars);
end;

constructor TAvatars.Create;
begin
  FRetrievingImage := TJPEGImage.Create;
  LoadJPGFromResource(FRetrievingImage, 'RetrievingAvatar');

  inherited Create;
end;

destructor TAvatars.Destroy;
begin
  FreeAndNil(FRetrievingImage);

  inherited;
end;

function TAvatars.DefaultAvatar: TAvatar;
var
  bytes: TBytes;
begin
  SetLength(bytes, 0);
  result := Add(bytes, nil);
end;

function TAvatars.Add(const AId: TBytes; const AImage: TJPEGImage): TAvatar;
var
  avatar: TAvatar;
begin
  if Find(AId, avatar) then
  begin
    if Assigned(AImage) then
    begin
      avatar.SetImage(AImage);
      avatar.Save;
    end;
  end
  else
  begin
    avatar := TAvatar.Create(AId, AImage);
    if not Assigned(AImage) then
    begin
      avatar.SetImage(FRetrievingImage);
      if not avatar.Retrieve then
        avatar.Download;
    end
    else
      avatar.Save;
    inherited Add(avatar);
  end;

  result := avatar;
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


end.
