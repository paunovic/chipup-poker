unit Poker.Types;

interface

uses
  Winapi.Windows, System.SysUtils, System.DateUtils, System.Rtti;

type
  TMongoId = record
  strict private
    FMongoIdArray: array[0..11] of Byte;

    function GetMongoIdByte(Index: Integer): Byte;
    procedure SetMongoIdByte(Index: Integer; const Value: Byte);
    function GetMemory: pointer;

    property MongoIdArray[Index: Integer]: Byte read GetMongoIdByte write SetMongoIdByte; default;
  public
    class operator Implicit(const APointer: pointer): TMongoId;
    class operator Implicit(const AVariant: Variant): TMongoId;
    class operator Implicit(const AString: String): TMongoId;
    class operator Equal(const AMongoId1, AMongoId2: TMongoId): Boolean;
    class operator NotEqual(const AMongoId1, AMongoId2: TMongoId): Boolean;

    function ToDateTime: TDateTime;
    function ToVariant: Variant;
    function ToString: String;
    function IsEmpty: Boolean;
    procedure Clear;

    property Memory: pointer read GetMemory;
  end;

  TPokerTypes = class
  public
    class function TryCast<T>(const AValue: TValue; var AOutput: T): Boolean;
  end;

function ReverseDWORD(const AValue: DWORD): DWORD;
function BytesToHex(const ABytes: TBytes): String;


implementation

uses
  System.Variants, System.Classes;


function ReverseDWORD(const AValue: Cardinal): Cardinal;
asm
  bswap eax
end;

function BytesToHex(const ABytes: TBytes): String;
begin
  SetLength(result, 2 * Length(ABytes));
  BinToHex(@ABytes[0], PChar(@result[1]), Length(ABytes));
  result := LowerCase(result);
end;

class function TPokerTypes.TryCast<T>(const AValue: TValue; var AOutput: T): Boolean;
begin
  result := AValue.TryAsType<T>(AOutput);
end;

{ TMongoId }

class operator TMongoId.Implicit(const APointer: pointer): TMongoId;
begin
  if Assigned(APointer) then
    Move(APointer^, result.FMongoIdArray[0], 12)
  else
    result.Clear;
end;

class operator TMongoId.Implicit(const AString: String): TMongoId;
var
  C1: Integer;
begin
  if AString = '' then
    result.Clear
  else
    if Length(AString) = 24 then
      for C1 := 0 to 11 do
        result.MongoIdArray[C1] := StrToInt('$' + Copy(AString, C1 * 2, 2));
end;

function TMongoId.GetMemory: pointer;
begin
  result := @FMongoIdArray[0];
end;

function TMongoId.GetMongoIdByte(Index: Integer): Byte;
begin
  result := FMongoIdArray[Index];
end;

procedure TMongoId.SetMongoIdByte(Index: Integer; const Value: Byte);
begin
  FMongoIdArray[Index] := Value;
end;

function TMongoId.IsEmpty: Boolean;
const
  EMPTY_MONGO_ID: array[0..11] of Byte = (0, 0, 0, 0, 0, 0, 0, 0, 0,	0, 0, 0);
begin
  result := CompareMem(@FMongoIdArray[0], @EMPTY_MONGO_ID[0], 12);
end;

class operator TMongoId.Implicit(const AVariant: Variant): TMongoId;
var
  safe_array: PVarArray;
begin
  safe_array := VarArrayAsPSafeArray(AVariant);
  Move(safe_array.Data^, result.FMongoIdArray[0], 12);
end;

procedure TMongoId.Clear;
begin
  FillChar(FMongoIdArray[0], 12, 0);
end;

class operator TMongoId.Equal(const AMongoId1, AMongoId2: TMongoId): Boolean;
begin
  result := CompareMem(AMongoId1.Memory, AMongoId2.Memory, 12);
end;

class operator TMongoId.NotEqual(const AMongoId1, AMongoId2: TMongoId): Boolean;
begin
  result := not CompareMem(AMongoId1.Memory, AMongoId2.Memory, 12);
end;

function TMongoId.ToDateTime: TDateTime;
var
  unix_timestamp: UINT32;
begin
  unix_timestamp := ReverseDWORD(PUINT(@FMongoIdArray[0])^);
  result := (unix_timestamp / 86400) + 25569;
end;

function TMongoId.ToVariant: Variant;
var
  safe_array: PVarArray;
begin
  result := VarArrayCreate([0, 11], varByte);
  safe_array := VarArrayAsPSafeArray(result);
  Move(FMongoIdArray[0], safe_array.Data^, 12);
end;

function TMongoId.ToString: String;
begin
  SetLength(result, 24);
  BinToHex(@FMongoIdArray[0], PChar(@result[1]), 12);
  result := LowerCase(result);
end;

end.


