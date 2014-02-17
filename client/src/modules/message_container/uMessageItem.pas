unit uMessageItem;

interface

uses
  Winapi.Windows, System.Generics.Collections, OverbyteIcsWSocket;

type
  TMessageType = (mtServerResponse, mtSocketChangeState);

  TMessageItem = class
  private
    FId         : Integer;
    FMessageType: TMessageType;
    FReaders    : TList<HWND>;

    FMethodId   : Integer;
    FObject     : TObject;

    FOldState   : TSocketState;
    FNewState   : TSocketState;

    function GetReaderCount: Integer;

  public
    constructor Create(const AId: Integer; const AMessageType: TMessageType; const AReaders: TList<HWND>);
    destructor Destroy; override;

    procedure SetServerResponseParams(const AMethodId: Integer; const AObject: TObject);
    procedure SetSocketChangeStateParams(const AOldState, ANewState: TSocketState);
    procedure NotifyHandlers(const ANewMessage: DWORD);
    procedure RemoveReader(const AHandle: HWND);

    property Id         : Integer read FId;
    property ReaderCount: Integer read GetReaderCount;
    property MessageType: TMessageType read FMessageType;

    property MethodId: Integer read FMethodId;
    property Object_ : TObject read FObject;

    property OldState: TSocketState read FOldState;
    property NewState: TSocketState read FNewState;
  end;

  TMessageItems = TObjectList<TMessageItem>;

implementation


constructor TMessageItem.Create(const AId: Integer; const AMessageType: TMessageType; const AReaders: TList<HWND>);
begin
  FId := AId;
  FMessageType := AMessageType;
  FReaders := TList<HWND>.Create;
  FReaders.AddRange(AReaders);
end;

destructor TMessageItem.Destroy;
begin
  case FMessageType of
    mtServerResponse: if Assigned(FObject) then FObject.Free;
    mtSocketChangeState: ;
  end;

  FReaders.Free;

  inherited;
end;

function TMessageItem.GetReaderCount: Integer;
begin
  result := FReaders.Count;
end;

procedure TMessageItem.NotifyHandlers(const ANewMessage: DWORD);
var
  C1: Integer;
begin
  C1 := 0;
  while C1 < FReaders.Count do
    if PostMessage(FReaders[C1], ANewMessage, FId, 0) then
      Inc(C1)
    else
      RemoveReader(FReaders[C1]);
end;

procedure TMessageItem.RemoveReader(const AHandle: HWND);
begin
  while FReaders.Remove(AHandle) <> -1 do;
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
