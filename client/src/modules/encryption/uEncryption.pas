unit uEncryption;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils;

function AES256EncryptStream(const AInStream: TStream; const AOutStream: TStream; const APassword: String): Boolean; overload;
procedure AES256EncryptStream(const AStream: TMemoryStream; const AKey: String); overload;
function AES256DecryptStream(const AInStream: TStream; const AOutStream: TStream; const APassword: String): Boolean; overload;
procedure AES256DecryptStream(const AStream: TMemoryStream; const AKey: String); overload; overload;

implementation

uses
  DECCipher, DECHash, DECUtil, DECFmt;



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
  ASalt: Binary;
  AData: Binary;
  APass: Binary;
begin
  with ValidCipher(TCipher_Rijndael).Create, Context do
  try
    ASalt := RandomBinary(16);
    APass := ValidHash(THash_Whirlpool).KDFx(Binary(APassword), ASalt, KeySize);
    Mode := cmCBCx;
    Init(APass);
    WriteBinary(ASalt);
    EncodeStream(AInStream, AOutStream, AInStream.Size);
    result := TRUE;
  finally
    Free;
    ProtectBinary(ASalt);
    ProtectBinary(AData);
    ProtectBinary(APass);
  end;
end;

procedure AES256EncryptStream(const AStream: TMemoryStream; const AKey: String);
var
  tmpstream: TMemoryStream;
begin
  tmpstream := TMemoryStream.Create;
  try
    AStream.Position := 0;
    AES256EncryptStream(AStream, tmpstream, AKey);
    AStream.Clear;
    tmpstream.SaveToStream(AStream);
  finally
    tmpstream.Free;
  end;
end;

function AES256DecryptStream(const AInStream: TStream; const AOutStream: TStream; const APassword: String): Boolean;

  function ReadInteger: Integer;
  begin
    AInStream.ReadBuffer(result, SizeOf(result));
  end;

  function ReadBinary: Binary;
  begin
    SetLength(result, ReadInteger);
    AInStream.ReadBuffer(result[1], Length(result));
  end;

var
  ASalt: Binary;
  AData: Binary;
  APass: Binary;
begin
  with ValidCipher(TCipher_Rijndael).Create, Context do
  try
    ASalt := ReadBinary;
    APass := ValidHash(THash_Whirlpool).KDFx(Binary(APassword), ASalt, KeySize);
    Mode := cmCBCx;
    Init(APass);
    DecodeStream(AInStream, AOutStream, AInStream.Size - Length(ASalt) - SizeOf(Integer));
    result := TRUE;
  finally
    Free;
    ProtectBinary(ASalt);
    ProtectBinary(AData);
    ProtectBinary(APass);
  end;
end;

procedure AES256DecryptStream(const AStream: TMemoryStream; const AKey: String); overload;
var
  tmpstream: TMemoryStream;
begin
  tmpstream := TMemoryStream.Create;
  try
    AStream.Position := 0;
    AES256DecryptStream(AStream, tmpstream, AKey);
    AStream.Clear;
    tmpstream.SaveToStream(AStream);
  finally
    tmpstream.Free;
  end;
end;

end.
