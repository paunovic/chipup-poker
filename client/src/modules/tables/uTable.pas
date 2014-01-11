unit uTable;

interface

uses
  Winapi.Windows, System.Classes,
  uTableForm;

type
  TTable = class
  private
    FId          : DWORD;
    FForm        : TfrmTable;
    FTablesObject: TObject;

  public
    constructor Create(const ATablesObject: TObject; const AId: DWORD);
    destructor Destroy; override;

    procedure NotifyClose;

    property Id  : DWORD read FId;
    property Form: TfrmTable read FForm;

  end;

implementation

uses
  Vcl.Controls, uTables;


constructor TTable.Create(const ATablesObject: TObject; const AId: DWORD);
begin
  FId := AId;
  FTablesObject := ATablesObject;
  FForm := TfrmTable.Create(self, AId);
end;

destructor TTable.Destroy;
begin
  FForm.Free;

  inherited;
end;

procedure TTable.NotifyClose;
begin
  (FTablesObject as TTables).NotifyClose(FId);
end;


end.
