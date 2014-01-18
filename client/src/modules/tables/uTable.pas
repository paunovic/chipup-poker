unit uTable;

interface

uses
  Winapi.Windows, System.Classes, uGameInfo,
  uClubInfo, Vcl.Forms;

type
  TTable = class
  private
    FForm        : TForm;
    FSeatIndex   : Integer;
    FGame        : TGameInfo;
    FClub        : TClubInfo;
    FTablesObject: TObject;

  public
    constructor Create(const ATablesObject: TObject; const AClub: TClubInfo; const AGame: TGameInfo);
    destructor Destroy; override;

    procedure NotifyClose;
    function IsSitting: Boolean;

    property Game     : TGameInfo read FGame;
    property Club     : TClubInfo read FClub;
    property Form     : TForm read FForm;
    property SeatIndex: Integer read FSeatIndex write FSeatIndex;
  end;

implementation

uses
  Vcl.Controls, uTables, uTableForm;


constructor TTable.Create(const ATablesObject: TObject; const AClub: TClubInfo; const AGame: TGameInfo);
begin
  FSeatIndex := -1;
  FGame := AGame;
  FClub := AClub;
  FTablesObject := ATablesObject;
  FForm := TfrmTable.Create(self);
end;

destructor TTable.Destroy;
begin
  FForm.Free;

  inherited;
end;

function TTable.IsSitting: Boolean;
begin
  result := FSeatIndex <> -1;
end;

procedure TTable.NotifyClose;
begin
  (FTablesObject as TTables).NotifyClose(FGame.MongoId);
end;


end.
