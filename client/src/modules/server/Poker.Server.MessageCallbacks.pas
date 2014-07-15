unit Poker.Server.MessageCallbacks;

interface

uses
  System.Generics.Collections, Poker.Protobufs.Enum.ServerCodes, OverbyteIcsWSocket;

type
  TCallbackSet = class(TObjectList<TObject>)
  private
    FId: Integer;
  public
    constructor Create(const AId: Integer; const ACallbacks: array of TObject);

    property Id: Integer read FId;
  end;

  TServerMessageCallbackMethod = procedure(const AMethodId: Integer; const AObject: TObject) of object;
  TServerMessageCallback = class
  private
    FCode: TServerCodes;
    FCallback: TServerMessageCallbackMethod;

  public
    constructor Create(const ACode: TServerCodes; const ACallback: TServerMessageCallbackMethod);

    property Code: TServerCodes read FCode;
    property Callback: TServerMessageCallbackMethod read FCallback;
  end;

  TSocketStateChangeCallbackMethod = procedure(const AOldState, ANewState: TSocketState) of object;
  TSocketStateChangeCallback = class
  private
    FCallback: TSocketStateChangeCallbackMethod;
  public
    constructor Create(const ACallback: TSocketStateChangeCallbackMethod);

    property Callback: TSocketStateChangeCallbackMethod read FCallback;
  end;

implementation


{ TCallbackSet }

constructor TCallbackSet.Create(const AId: Integer; const ACallbacks: array of TObject);
var
  callback: TObject;
begin
  inherited Create(TRUE);

  FId := AId;
  for callback in ACallbacks do
    Add(callback);
end;

{ TServerMessageCallback }

constructor TServerMessageCallback.Create(const ACode: TServerCodes; const ACallback: TServerMessageCallbackMethod);
begin
  FCode := ACode;
  FCallback := ACallback;
end;

{ TSocketStateChangeCallback }

constructor TSocketStateChangeCallback.Create(const ACallback: TSocketStateChangeCallbackMethod);
begin
  FCallback := ACallback;
end;

end.
