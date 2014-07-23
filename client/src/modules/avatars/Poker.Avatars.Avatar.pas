unit Poker.Avatars.Avatar;

interface

uses
  Vcl.Imaging.JPEG, Vcl.Graphics, System.Classes, System.SysUtils, Asphyre.Images, OverbyteIcsHttpProt, OverbyteIcsWSocket;

type
  TAvatar = class
  private
    {$IFDEF DEBUG} FDebugId: Integer; {$ENDIF}
    FId: TBytes;
    FIdAsString: String;
    FImage: TJPEGImage;
    FDXImage: TAsphyreImage;
    FHTTP: TSslHttpCli;
    FOnImageChanged: TNotifyEvent;

    procedure HTTPRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure SetId(const AValue: TBytes);
    procedure ImageChanged(Sender: TObject);
  public
    constructor Create(const AId: TBytes; const AImage: TJPEGImage);
    destructor Destroy; override;

    procedure Download;
    function Retrieve: Boolean;
    procedure Save;

    procedure SetImage(const AImage: TJPEGImage); overload;
    procedure SetImage(const AStream: TStream); overload;

    function GetImage: TJPEGImage;

    property Id: TBytes read FId;
    property IdAsString: String read FIdAsString;
    property Image: TJPEGImage read FImage;
    property DXImage: TAsphyreImage read FDXImage;
    property OnImageChanged: TNotifyEvent read FOnImageChanged write FOnImageChanged;
  end;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Poker.Helpers.AsphyreImage, Poker.Common.Misc, Poker.Database.Core, SynDBSQLite3, Poker.DataModule, Poker.Settings, Poker.Server.SSLCerts;

{ TAvatar }

constructor TAvatar.Create(const AId: TBytes; const AImage: TJPEGImage);
begin
  {$IFDEF DEBUG} RegisterDebugObject('Avatar'); {$ENDIF}
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

  {$IFDEF DEBUG} UnregisterDebugObject(FDebugId); {$ENDIF}

  inherited;
end;

procedure TAvatar.HTTPRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
begin
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
        Save;
        {$IFDEF DEBUG} DebugLn(FDebugId, Format('Avatar downloaded [%s] [%.2fkb]', [FIdAsString, FHTTP.RcvdStream.Size / 1024]), ditNetInc); {$ENDIF}
      end
      else
      begin
        {$IFDEF DEBUG} DebugLn(FDebugId, Format('Avatar is not JPEG stream [%s]', [FIdAsString]), ditException); {$ENDIF}
      end;
    end
    else
    begin
      {$IFDEF DEBUG} DebugLn(FDebugId, Format('Avatar not downloaded [%s] [ErrCode: %d; StatusCode: %d]', [FIdAsString, ErrCode, FHTTP.StatusCode]), ditException); {$ENDIF}
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
  FHTTP.URL := Format(Settings.Hardcoded.SERVER_CONFIG[Settings.ServerIndex].URL + Settings.Hardcoded.URL.GET_AVATAR, [EncodeURL(String(FIdAsString))]);
  FHTTP.OnRequestDone := HTTPRequestDone;
  FHTTP.SslContext.InitContext;
  FHTTP.SslContext.TrustCert(SSLCert_OfficialServer);
  FHTTP.SslContext.TrustCert(SSLCert_DevServer);
  FHTTP.GetAsync;
  {$IFDEF DEBUG} DebugLn(FDebugId, Format('Downlading avatar [%s]', [FIdAsString]), ditNetInc); {$ENDIF}
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
        if IsJPEGStream(mstream) then
        begin
          mstream.Position := 0;
          FImage.LoadFromStream(mstream);
          Exit(TRUE);
        end;
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

  if Assigned(FOnImageChanged) then
    FOnImageChanged(self);
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


end.
