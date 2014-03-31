unit Poker.Common.Encryption;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils;


function SHA256Stream(const AStream: TStream): RawByteString;
function SHA256Bytes(const ABytes: TBytes): RawByteString;
function SHA256String(const AString: String): RawByteString;
function AES256EncryptStream(const AInStream: TStream; const AOutStream: TStream; const APassword: String): Boolean; overload;
function AES256EncryptStream(const AStream: TMemoryStream; const AKey: String): Boolean; overload;
function AES256DecryptStream(const AInStream: TStream; const AOutStream: TStream; const APassword: String): Boolean; overload;
function AES256DecryptStream(const AStream: TMemoryStream; const AKey: String): Boolean; overload; overload;

implementation

uses
  DECCipher, DECHash, DECUtil, DECFmt;



function SHA256Stream(const AStream: TStream): RawByteString;
var
  hash: THash_SHA256;
begin
  hash := THash_SHA256.Create;
  try
    hash.Init;
    result := hash.CalcStream(AStream, AStream.Size, TFormat_Copy);
    hash.Done;
  finally
    hash.Free;
  end;
end;

function SHA256Bytes(const ABytes: TBytes): RawByteString;
var
  hash: THash_SHA256;
begin
  hash := THash_SHA256.Create;
  try
    hash.Init;
    result := hash.CalcBuffer(ABytes[0], Length(ABytes), TFormat_Copy);
    hash.Done;
  finally
    hash.Free;
  end;
end;

function SHA256String(const AString: String): RawByteString;
var
  bytes: TBytes;
begin
  SetLength(bytes, Length(AString) * 2);
  Move(AString[1], bytes[0], Length(bytes));
  result := SHA256Bytes(bytes);
end;

function AES256EncryptStream(const AInStream: TStream; const AOutStream: TStream; const APassword: String): Boolean;

  procedure WriteInteger(const AValue: Integer);
  begin
    AOutStream.WriteBuffer(AValue, SizeOf(Integer));
  end;

  procedure WriteBinary(const ABinary: Binary);
  begin
    WriteInteger(Length(ABinary));
    AOutStream.WriteBuffer(ABinary[1], Length(ABinary));
  end;

var
  ASalt : Binary;
  AData : Binary;
  APass : Binary;
  sha256: RawByteString;
begin
  with ValidCipher(TCipher_Rijndael).Create, Context do
  try
    ASalt := RandomBinary(16);
    APass := ValidHash(THash_Whirlpool).KDFx(Binary(APassword), ASalt, KeySize);
    Mode := cmCBCx;
    Init(APass);
    WriteBinary(ASalt);
    sha256 := SHA256Stream(AInStream);
    WriteBinary(sha256);
    AInStream.Position := 0;
    EncodeStream(AInStream, AOutStream, AInStream.Size);
    result := TRUE;
  finally
    Free;
    ProtectBinary(ASalt);
    ProtectBinary(AData);
    ProtectBinary(APass);
  end;
end;

function AES256EncryptStream(const AStream: TMemoryStream; const AKey: String): Boolean;
var
  tmpstream: TMemoryStream;
begin
  tmpstream := TMemoryStream.Create;
  try
    AStream.Position := 0;
    if not AES256EncryptStream(AStream, tmpstream, AKey) then
      Exit(FALSE);
    AStream.Clear;
    tmpstream.SaveToStream(AStream);
    Exit(TRUE);
  finally
    tmpstream.Free;
  end;
end;

function AES256DecryptStream(const AInStream: TStream; const AOutStream: TStream; const APassword: String): Boolean;

  function ReadInteger(var AInteger: Integer): Boolean;
  begin
    if SizeOf(AInteger) > AInStream.Size then
      Exit(FALSE);

    AInStream.ReadBuffer(AInteger, SizeOf(AInteger));
    Exit(TRUE);
  end;

  function ReadBinary(var ABinary: Binary): Boolean;
  var
    bin_len: Integer;
  begin
    if (not ReadInteger(bin_len)) or
       (SizeOf(bin_len) + bin_len > AInStream.Size) then
      Exit(FALSE);

    SetLength(ABinary, bin_len);
    AInStream.ReadBuffer(ABinary[1], bin_len);
    Exit(TRUE);
  end;

var
  ASalt : Binary;
  AData : Binary;
  APass : Binary;
  sha256: RawByteString;
begin
  with ValidCipher(TCipher_Rijndael).Create, Context do
  try
    ReadBinary(ASalt);
    ReadBinary(sha256);
    APass := ValidHash(THash_Whirlpool).KDFx(Binary(APassword), ASalt, KeySize);
    Mode := cmCBCx;
    Init(APass);
    DecodeStream(AInStream, AOutStream, AInStream.Size - Length(ASalt) - Length(sha256) - 2 * SizeOf(Integer));
    AOutStream.Position := 0;
    result := SHA256Stream(AOutStream) = sha256;
  finally
    Free;
    ProtectBinary(ASalt);
    ProtectBinary(AData);
    ProtectBinary(APass);
  end;
end;

function AES256DecryptStream(const AStream: TMemoryStream; const AKey: String): Boolean; overload;
var
  tmpstream: TMemoryStream;
begin
  tmpstream := TMemoryStream.Create;
  try
    AStream.Position := 0;
    if not AES256DecryptStream(AStream, tmpstream, AKey) then
      Exit(FALSE);
    AStream.Clear;
    tmpstream.SaveToStream(AStream);
    Exit(TRUE);
  finally
    tmpstream.Free;
  end;
end;

end.
