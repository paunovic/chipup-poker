unit Poker.Server.MessageCallbacks;

interface

uses
  System.Generics.Collections, Poker.Protobufs.Enum.ServerCodes, OverbyteIcsWSocket;

type
  TServerCodesSet = set of TServerCodes;

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
    FCodes: TServerCodesSet;
    FCallback: TServerMessageCallbackMethod;

  public
    constructor Create(const ACodes: TServerCodesSet; const ACallback: TServerMessageCallbackMethod); overload;
    constructor Create(const ACode: TServerCodes; const ACallback: TServerMessageCallbackMethod); overload;

    property Codes: TServerCodesSet read FCodes;
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
begin
  inherited Create(TRUE);

  FId := AId;
  AddRange(ACallbacks);
end;

{ TServerMessageCallback }

constructor TServerMessageCallback.Create(const ACodes: TServerCodesSet; const ACallback: TServerMessageCallbackMethod);
begin
  FCodes := ACodes;
  FCallback := ACallback;
end;

constructor TServerMessageCallback.Create(const ACode: TServerCodes; const ACallback: TServerMessageCallbackMethod);
begin
  FCodes := [ACode];
  FCallback := ACallback;
end;

{ TSocketStateChangeCallback }

constructor TSocketStateChangeCallback.Create(const ACallback: TSocketStateChangeCallbackMethod);
begin
  FCallback := ACallback;
end;

end.
