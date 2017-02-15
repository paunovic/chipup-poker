unit Poker.Common.SSLCert;

interface

uses
  OverbyteIcsWSocket, OverbyteIcsLIBEAY, OverbyteIcsSSLEAY;

type
  TSSLCert = class(TX509Base)
  private
    FResourceName: String;
    FSize: Integer;
  public
    procedure LoadFromResource(const AResourceName: String; const APassword: PAnsiChar = nil);

    property CertResourceName: String read FResourceName;
    property Size: Integer read FSize;
  end;

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
    FSize := rstream.Size;
    bio := f_BIO_new_mem_buf(rstream.Memory, rstream.Size);
    try
      X509 := f_PEM_read_bio_x509(bio, nil, nil, APassword);
    finally
      f_BIO_free(bio);
    end;
  finally
    rstream.Free;
  end;

  FResourceName := AResourceName;
end;

end.
