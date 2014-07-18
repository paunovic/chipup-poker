unit Poker.Types;

interface

type
  TMongoId = array[0..11] of Byte;

procedure PtrToMongoId(const APointer: pointer; out AMongoId: TMongoId);

implementation

procedure PtrToMongoId(const APointer: pointer; out AMongoId: TMongoId);
begin
  Move(APointer^, AMongoId[0], Length(AMongoId));
end;

end.
