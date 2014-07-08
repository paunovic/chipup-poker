unit Poker.Pots.Pot;

interface

uses
  System.Generics.Collections, Poker.Objects.WinnerData, Poker.Protobufs.Objects.Pot;

type
  TPotInfo = class
  private
    FValue: UINT32;
    FRake: UINT32;
    FMembers: TList<Integer>;
    FWinnerData: TWinnerDataList;
    function GetValueWithoutRake: UINT32;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(const APotProtobuf: TPB_Pot); overload;
    procedure Assign(const APotInfo: TPotInfo); overload;

    property Value: UINT32 read FValue write FValue;
    property Rake: UINT32 read FRake write FRake;
    property Members: TList<Integer> read FMembers;
    property WinnerData: TWinnerDataList read FWinnerData;
    property ValueWithoutRake: UINT32 read GetValueWithoutRake;
  end;

implementation

{ TPotInfo }

constructor TPotInfo.Create;
begin
  FValue := 0;
  FRake := 0;
  FWinnerData := TWinnerDataList.Create;
  FMembers := TList<Integer>.Create;
end;

destructor TPotInfo.Destroy;
begin
  FMembers.Free;
  FWinnerData.Free;

  inherited;
end;

function TPotInfo.GetValueWithoutRake: UINT32;
begin
  if FValue <= FRake then
    result := 0
  else
    result := FValue - FRake;
end;

procedure TPotInfo.Assign(const APotProtobuf: TPB_Pot);
begin
  FValue := APotProtobuf.Value;
  FRake := APotProtobuf.Rake;
  FMembers.AddRange(APotProtobuf.Members);
  FWinnerData.Assign(APotProtobuf.WinnerData);
end;

procedure TPotInfo.Assign(const APotInfo: TPotInfo);
begin
  FValue := APotInfo.Value;
  FRake := APotInfo.Rake;
  FMembers.AddRange(APotInfo.Members);
  FWinnerData.Assign(APotInfo.WinnerData);
end;

end.
