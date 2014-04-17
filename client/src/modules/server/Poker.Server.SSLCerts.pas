unit Poker.Server.SSLCerts;

interface

uses
  OverbyteIcsWSocket, OverbyteIcsLIBEAY, OverbyteIcsSSLEAY;

type
  TSSLCert = class(TX509Base)
    procedure LoadFromResource(const AResourceName: String; const APassword: PAnsiChar = nil);
  end;

var
  SSLCert_Server: TSSLCert;

implementation

uses
  Winapi.Windows, System.SysUtils, System.Classes;

{ TSSLCert }

procedure TSSLCert.LoadFromResource(const AResourceName: String; const APassword: PAnsiChar = nil);
var
  bio: PBio;
  rstream: TResourceStream;
begin
  InitializeSsl;

  rstream := TResourceStream.Create(HInstance, AResourceName, RT_RCDATA);
  try
    bio := f_BIO_new_mem_buf(rstream.Memory, rstream.Size);
    try
      X509 := f_PEM_read_bio_x509(bio, nil, nil, APassword);
    finally
      f_BIO_free(bio);
    end;
  finally
    rstream.Free;
  end;
end;

initialization
  SSLCert_Server := TSSLCert.Create(nil);
  SSLCert_Server.LoadFromResource('ServerCert');

finalization
  FreeAndNil(SSLCert_Server);

end.
