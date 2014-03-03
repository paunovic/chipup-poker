unit uDrawingCache;

interface

uses
  GR32, uDCSeatData;

type
  TStoreDrawingResult = (sdOK, sdExists);

  TDrawingCache = class
  private
    FSeatsData: TDCLSeatData;
  public
    constructor Create;
    destructor Destroy; override;

    property Seats: TDCLSeatData read FSeatsData;
  end;

implementation

constructor TDrawingCache.Create;
begin
  FSeatsData := TDCLSeatData.Create;
end;

destructor TDrawingCache.Destroy;
begin
  FSeatsData.Free;

  inherited;
end;

end.
