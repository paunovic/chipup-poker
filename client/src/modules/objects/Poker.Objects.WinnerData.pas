unit Poker.Objects.WinnerData;

interface

uses
  System.Generics.Collections, Poker.Protobufs.Objects.WinnerData;

type
  TWinnerData = class
  private
    FSeat: Integer;
    FMsg : String;
  public
    constructor Create(const APBWinnerData: TPB_WinnerData); overload;
    constructor Create(const AWinnerData: TWinnerData); overload;

    procedure Assign(const APBWinnerData: TPB_WinnerData); overload;
    procedure Assign(const AWinnerData: TWinnerData); overload;

    property Seat: Integer read FSeat;
    property Msg: String read FMsg;
  end;

  TWinnerDataList = class(TObjectList<TWinnerData>)
  public
    procedure Assign(const AWinnerData: TObjectList<TPB_WinnerData>); overload;
    procedure Assign(const AWinnerData: TWinnerDataList); overload;
  end;


implementation

{ TWinnerData }

constructor TWinnerData.Create(const APBWinnerData: TPB_WinnerData);
begin
  Assign(APBWinnerData);
end;

constructor TWinnerData.Create(const AWinnerData: TWinnerData);
begin
  Assign(AWinnerData);
end;


procedure TWinnerData.Assign(const APBWinnerData: TPB_WinnerData);
begin
  FSeat := APBWinnerData.Seat;
  FMsg := APBWinnerData.Msg;
end;

procedure TWinnerData.Assign(const AWinnerData: TWinnerData);
begin
  FSeat := AWinnerData.Seat;
  FMsg := AWinnerData.Msg;
end;



{ TWinnerDataList }

procedure TWinnerDataList.Assign(const AWinnerData: TObjectList<TPB_WinnerData>);
var
  C1: Integer;
begin
  Clear;
  for C1 := 0 to AWinnerData.Count - 1 do
    Add(TWinnerData.Create(AWinnerData[C1]));
end;

procedure TWinnerDataList.Assign(const AWinnerData: TWinnerDataList);
var
  C1: Integer;
begin
  Clear;
  for C1 := 0 to AWinnerData.Count - 1 do
    Add(TWinnerData.Create(AWinnerData[C1]));
end;


end.
