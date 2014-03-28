unit Poker.HandDownloader;

interface

uses
  OverbyteIcsHttpProt, OverbyteIcsWSocket;

type
  THandDownloader = class
  private
    FProgress: Single;
    FHTTP    : TSslHttpCli;

    procedure HTTPRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure HTTPDocData(Sender: TObject; Buffer: Pointer; Len: Integer);
  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
    destructor Destroy; override;

    procedure Download(const AURL: String);

    property Progress: Single read FProgress;
  end;

var
  HandDownloader: THandDownloader;

implementation

uses
  System.SysUtils, System.Classes, Poker.Database.Core;


class procedure THandDownloader.Initialize;
begin
  HandDownloader := THandDownloader.Create;
end;

class procedure THandDownloader.Deinitialize;
begin
  FreeAndNil(HandDownloader);
end;


constructor THandDownloader.Create;
begin
  FHTTP := TSslHttpCli.Create(nil);
  FHTTP.SslContext := TSslContext.Create(nil);
  FHTTP.Connection := 'Keep-Alive';
  FHTTP.BandwidthLimit := 0;
  FHTTP.RequestVer := '1.1';
  FHTTP.OnDocData := HTTPDocData;
  FHTTP.OnRequestDone := HTTPRequestDone;
  FHTTP.SslContext.InitContext;
end;

destructor THandDownloader.Destroy;
begin
  FHTTP.SslContext.DeInitContext;
  FHTTP.SslContext.Free;
  FHTTP.Free;

  inherited;
end;

procedure THandDownloader.Download(const AURL: String);
begin
  Assert(not Assigned(FHTTP.RcvdStream));

  FHTTP.RcvdStream := TMemoryStream.Create;
  FHTTP.URL := AURL;
  FHTTP.GetASync;
end;

procedure THandDownloader.HTTPRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
var
  C1: Integer;
begin
  if Database.Connect then
  try

  finally
    Database.Disconnect;
  end;

  FHTTP.RcvdStream.Free;
  FHTTP.RcvdStream := nil;
end;

procedure THandDownloader.HTTPDocData(Sender: TObject; Buffer: Pointer; Len: Integer);
begin
  FProgress := (FHTTP.RcvdCount / FHTTP.ContentLength) * 100;
end;



end.
