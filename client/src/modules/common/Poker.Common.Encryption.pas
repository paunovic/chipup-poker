unit Poker.Common.Encryption;

interface

uses
  System.Classes, System.SysUtils;

function SHA256Raw(const AData: RawByteString): RawByteString;
function SHA256Stream(const AStream: TStream): RawByteString;
function SHA256String(const AString: String): RawByteString;
function SHA256File(const AFile: String): RawByteString;
function AES256EncryptStream(const AInStream, AOutStream: TStream; const APassword: String; const AEncrypt: Boolean): Boolean; overload;
function AES256EncryptStream(const AStream: TMemoryStream; const APassword: String; const AEncrypt: Boolean): Boolean; overload;

implementation

uses
  syncrypto;


function SHA256Raw(const AData: RawByteString): RawByteString;
var
  SHA: TSHA256;
  digest: TSHA256Digest;
begin
  SHA.Full(pointer(AData), Length(AData), digest);
  SetLength(result, SizeOf(digest));
  Move(digest[0], result[1], SizeOf(digest));
end;

function SHA256Stream(const AStream: TStream): RawByteString;
var
  data: RawByteString;
begin
  SetLength(data, AStream.Size);
  AStream.ReadBuffer(data[1], AStream.Size);
  result := SHA256Raw(data)
end;

function SHA256String(const AString: String): RawByteString;
begin
  result := SHA256Raw(UTF8Encode(AString));
end;

function SHA256File(const AFile: String): RawByteString;
var
  fs: TFileStream;
begin
  fs := TFileStream.Create(AFile, fmOpenRead or fmShareDenyWrite);
  try
    result := SHA256Stream(fs);
  finally
    fs.Free;
  end;
end;

function AES256EncryptStream(const AInStream, AOutStream: TStream; const APassword: String; const AEncrypt: Boolean): Boolean;
var
  data_in, data_out: RawByteString;
  password: RawByteString;
begin
  try
    password := UTF8Encode(APassword);
    SetLength(data_in, AInStream.Size);
    AInStream.ReadBuffer(data_in[1], AInStream.Size);
    data_out := TAESCFB.SimpleEncrypt(data_in, password, AEncrypt, TRUE);
    AOutStream.Size := 0;
    AOutStream.WriteBuffer(data_out[1], Length(data_out));
    result := TRUE;
  except
    result := FALSE;
  end;
end;

function AES256EncryptStream(const AStream: TMemoryStream; const APassword: String; const AEncrypt: Boolean): Boolean;
var
  tmpstream: TMemoryStream;
begin
  try
    tmpstream := TMemoryStream.Create;
    try
      AStream.Position := 0;
      if not AES256EncryptStream(AStream, tmpstream, APassword, AEncrypt) then
        Exit(FALSE);
      AStream.Clear;
      tmpstream.SaveToStream(AStream);
      Exit(TRUE);
    finally
      tmpstream.Free;
    end;
    result := TRUE;
  except
    result := FALSE;
  end;
end;


end.
