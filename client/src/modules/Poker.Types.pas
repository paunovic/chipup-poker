unit Poker.Types;

interface

uses
  System.SysUtils, System.DateUtils;

type
  TMongoId = array[0..11] of Byte;

procedure PtrToMongoId(const APointer: pointer; out AMongoId: TMongoId);
function MongoIdToDateTime(const AMongoId: TMongoId): TDateTime; overload;
function MongoIdToDateTime(const AMongoId: TBytes): TDateTime; overload; // FIXME: REMOVE
function ReverseDWORD(dw: Cardinal): Cardinal;

implementation

uses
  Winapi.Windows;

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

function MongoIdToDateTime(const AMongoId: TBytes): TDateTime; // FIXME: REMOVE
var
  unix_timestamp: UINT32;
begin
  unix_timestamp := ReverseDWORD(PUINT(@AMongoId[0])^);
  result := (unix_timestamp / 86400) + 25569;
end;

end.
