unit Poker.Pots.PotList;

interface

uses
  System.Generics.Collections, Poker.Protobufs.Objects.Pot, Poker.Protobufs.Objects.WinnerPotInfo, Poker.Pots.Pot;

type
  TPotList = class(TObjectList<TPotInfo>)
  private
  public
    procedure Assign(const APots: TList<TPB_Pot>; const ARakePercent: UINT32); overload;
    procedure Assign(const APots: TPotList; const ARakePercent: UINT32); overload;
    procedure Assign(const APots: TList<TPB_WinnerPotInfo>); overload;
  end;

implementation

{ TPotList }

procedure TPotList.Assign(const APots: TList<TPB_Pot>; const ARakePercent: UINT32);
var
  pot: TPotInfo;
  C1: Integer;
begin
  Clear;

  for C1 := 0 to APots.Count - 1 do
  begin
    pot := TPotInfo.Create;
    pot.Assign(APots[C1], ARakePercent);
    Add(pot);
  end;
end;

procedure TPotList.Assign(const APots: TPotList; const ARakePercent: UINT32);
var
  pot: TPotInfo;
  C1 : Integer;
begin
  Clear;

  for C1 := 0 to APots.Count - 1 do
  begin
    pot := TPotInfo.Create;
    pot.Assign(APots[C1], ARakePercent);
    Add(pot);
  end;
end;

procedure TPotList.Assign(const APots: TList<TPB_WinnerPotInfo>);
var
  pot: TPotInfo;
  C1 : Integer;
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
