unit uServerMessageCallback;

interface

uses
  Winapi.Windows, Winapi.Messages,
  uServerCodes, uMessageItem;

type
  TServerMessageCallbackMethod = procedure(const AMessage: TMessageItem) of object;

  TServerMessageCallback = record
    Code    : TServerCodes;
    Callback: TServerMessageCallbackMethod;

    constructor Create(const ACode: TServerCodes; const ACallback: TServerMessageCallbackMethod);
  end;

procedure ProcessServerMessage(const AMessage: TMessageItem; const ACallbacks: array of TServerMessageCallback);

implementation

uses
  uMessageContainer;


constructor TServerMessageCallback.Create(const ACode: TServerCodes; const ACallback: TServerMessageCallbackMethod);
begin
  Code := ACode;
  Callback := ACallback;
end;

procedure ProcessServerMessage(const AMessage: TMessageItem; const ACallbacks: array of TServerMessageCallback);
var
  callback: TServerMessageCallback;
begin
  for callback in ACallbacks do
    if Integer(callback.Code) = AMessage.MethodId then
      callback.Callback(AMessage);
end;



end.
