unit uMessageItem;

interface

uses
  System.Generics.Collections, OverbyteIcsWSocket;

type
  TMessageType = (mtServerResponse, mtSocketChangeState);

  TMessageItem = class
  private
    FId         : Integer;
    FMessageType: TMessageType;
    FReaders    : Integer;
    FReadCount  : Integer;

    FMethodId   : Integer;
    FObject     : TObject;

    FOldState   : TSocketState;
    FNewState   : TSocketState;

  public
    constructor Create(const AId: Integer; const AMessageType: TMessageType; const AReaders: Integer);
    destructor Destroy; override;

    procedure IncReadCount;
    procedure SetServerResponseParams(const AMethodId: Integer; const AObject: TObject);
    procedure SetSocketChangeStateParams(const AOldState, ANewState: TSocketState);

    property Id         : Integer read FId;
    property Readers    : Integer read FReaders;
    property ReadCount  : Integer read FReadCount;
    property MessageType: TMessageType read FMessageType;

    property MethodId: Integer read FMethodId;
    property Object_ : TObject read FObject;

    property OldState: TSocketState read FOldState;
    property NewState: TSocketState read FNewState;
  end;

  TMessageItems = TObjectList<TMessageItem>;

implementation


constructor TMessageItem.Create(const AId: Integer; const AMessageType: TMessageType; const AReaders: Integer);
begin
  FId := AId;
  FMessageType := AMessageType;
  FReaders := AReaders;
end;

destructor TMessageItem.Destroy;
begin
  case FMessageType of
    mtServerResponse: if Assigned(FObject) then FObject.Free;
    mtSocketChangeState: ;
  end;

  inherited;
end;

procedure TMessageItem.IncReadCount;
begin
  Inc(FReadCount)
end;

procedure TMessageItem.SetServerResponseParams(const AMethodId: Integer; const AObject: TObject);
begin
  FMethodId := AMethodId;
  FObject := AObject;
end;

procedure TMessageItem.SetSocketChangeStateParams(const AOldState, ANewState: TSocketState);
begin
  FOldState := AOldState;
  FNewState := ANewState;
end;

end.
