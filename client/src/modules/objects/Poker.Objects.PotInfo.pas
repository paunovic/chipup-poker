unit Poker.Objects.PotInfo;

interface

uses
  System.Generics.Collections, Poker.Objects.WinnerData, Poker.Protobufs.Objects.Pot, Poker.Protobufs.Objects.WinnerPotInfo;

type
  TPotInfo = class
  private
    FValue: UINT32;
    FRake: UINT32;
    FMembers: TArray<Integer>;
    FWinnerData: TWinnerDataList;
    function GetValueWithoutRake: UINT32;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(const APotProtobuf: TPB_Pot; const ARakePercent: UINT32); overload;
    procedure Assign(const APotInfo: TPotInfo; const ARakePercent: UINT32); overload;
    procedure Assign(const AWinnerPotInfo: TPB_WinnerPotInfo); overload;

    property Value: UINT32 read FValue write FValue;
    property Rake: UINT32 read FRake write FRake;
    property Members: TArray<Integer> read FMembers;
    property WinnerData: TWinnerDataList read FWinnerData;
    property ValueWithoutRake: UINT32 read GetValueWithoutRake;
  end;

  TPotInfos = class(TObjectList<TPotInfo>)
  private
  public
    procedure Assign(const APots: TObjectList<TPB_Pot>; const ARakePercent: UINT32); overload;
    procedure Assign(const APots: TPotInfos; const ARakePercent: UINT32); overload;
    procedure Assign(const APots: TObjectList<TPB_WinnerPotInfo>); overload;
  end;

implementation

{ TPotInfo }

constructor TPotInfo.Create;
begin
  FWinnerData := TWinnerDataList.Create;
end;

destructor TPotInfo.Destroy;
begin
  FWinnerData.Free;

  inherited;
end;

function TPotInfo.GetValueWithoutRake: UINT32;
begin
  if FRake >= FValue then
    result := 0
  else
    result := FValue - FRake;
end;

procedure TPotInfo.Assign(const APotProtobuf: TPB_Pot; const ARakePercent: UINT32);
begin
  FValue := APotProtobuf.Value;
  FRake := Round(FValue * (ARakePercent / 100));
  FMembers := APotProtobuf.Members;
  FWinnerData.Clear;
end;


procedure TPotInfo.Assign(const APotInfo: TPotInfo; const ARakePercent: UINT32);
begin
  FValue := APotInfo.Value;
  FRake := Round(FValue * (ARakePercent / 100));
  FMembers := APotInfo.Members;
  FWinnerData.Assign(APotInfo.WinnerData);
end;

procedure TPotInfo.Assign(const AWinnerPotInfo: TPB_WinnerPotInfo);
begin
  FValue := AWinnerPotInfo.Sum;
  FRake := AWinnerPotInfo.Rake;
  FMembers := AWinnerPotInfo.Seats;
  FWinnerData.Assign(AWinnerPotInfo.WinnerData);
end;

{ TPotInfos }

procedure TPotInfos.Assign(const APots: TObjectList<TPB_Pot>; const ARakePercent: UINT32);
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

procedure TPotInfos.Assign(const APots: TPotInfos; const ARakePercent: UINT32);
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

procedure TPotInfos.Assign(const APots: TObjectList<TPB_WinnerPotInfo>);
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
