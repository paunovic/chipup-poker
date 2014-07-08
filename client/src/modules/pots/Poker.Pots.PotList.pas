unit Poker.Pots.PotList;

interface

uses
  System.Generics.Collections, Poker.Protobufs.Objects.Pot, Poker.Pots.Pot;

type
  TPotList = class(TObjectList<TPotInfo>)
  private
  public
    procedure Assign(const APots: TList<TPB_Pot>); overload;
    procedure Assign(const APots: TPotList); overload;
  end;

implementation

{ TPotList }

procedure TPotList.Assign(const APots: TList<TPB_Pot>);
var
  pot: TPotInfo;
  C1: Integer;
begin
  Clear;

  for C1 := 0 to APots.Count - 1 do
  begin
    pot := TPotInfo.Create;
    pot.Assign(APots[C1]);
    Add(pot);
  end;
end;

procedure TPotList.Assign(const APots: TPotList);
var
  pot: TPotInfo;
  C1: Integer;
begin
  Clear;

  for C1 := 0 to APots.Count - 1 do
  begin
    pot := TPotInfo.Create;
    pot.Assign(APots[C1]);
    Add(pot);
  end;
end;

end.
