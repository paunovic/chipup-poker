unit Poker.Types;

interface

uses
  System.SysUtils, System.DateUtils;

type
  TMongoId = array[0..11] of Byte;

const
  EMPTY_MONGO_ID: TMongoId = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

procedure PtrToMongoId(const APointer: pointer; out AMongoId: TMongoId);
function MongoIdToDateTime(const AMongoId: TMongoId): TDateTime;
procedure VariantToMongoId(const AVariant: Variant; out AMongoId: TMongoId);
function MongoIdToVariant(const AMongoId: TMongoId): Variant;
function CompareMongoId(const AMongoId1, AMongoId2: TMongoId): Boolean;
function ReverseDWORD(dw: Cardinal): Cardinal;
function BytesToHex(const ABytes: TBytes): String;


implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Winapi.Windows, System.Variants;

procedure PtrToMongoId(const APointer: pointer; out AMongoId: TMongoId);
begin
  Move(APointer^, AMongoId[0], Length(AMongoId));
end;

function MongoIdToDateTime(const AMongoId: TMongoId): TDateTime;
var
  unix_timestamp: UINT32;
begin
  unix_timestamp := ReverseDWORD(PUINT(@AMongoId[0])^);
  result := (unix_timestamp / 86400) + 25569;
end;

function ReverseDWORD(dw: Cardinal): Cardinal;
asm
  bswap eax
end;

function CompareMongoId(const AMongoId1, AMongoId2: TMongoId): Boolean;
begin
  result := CompareMem(@AMongoId1[0], @AMongoId2[0], Length(AMongoId1));
end;

procedure VariantToMongoId(const AVariant: Variant; out AMongoId: TMongoId);
var
  safe_array: PVarArray;
begin
  safe_array := VarArrayAsPSafeArray(AVariant);
  Move(safe_array.Data^, AMongoId[0], Length(AMongoId));
end;

function MongoIdToVariant(const AMongoId: TMongoId): Variant;
var
  safe_array: PVarArray;
begin
  result := VarArrayCreate([0, High(AMongoId)], varByte);
  safe_array := VarArrayAsPSafeArray(result);
  Move(AMongoId[0], safe_array.Data^, Length(AMongoId));
end;

function BytesToHex(const ABytes: TBytes): String;
var
  C1: Integer;
begin
  result := '';
  for C1 := Low(ABytes) to High(ABytes) do
    result := result + IntToHex(ABytes[C1], 2);
  result := LowerCase(result);
end;

end.


