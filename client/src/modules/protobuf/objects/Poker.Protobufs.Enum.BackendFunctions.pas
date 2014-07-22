unit Poker.Protobufs.Enum.BackendFunctions;

interface

type
  TBackendFunctions = (
    Hello = 0,
    StartServer = 1,
    StopServer = 2,
    RestartServer = 3,
    Starting = 4,
    Stopping = 5,
    PerClientMsgEvent = 6,
    GlobalMsgEvent = 7,
    PerGameMsgEvent = 8,
    scStartBot = 9,
    srBotStarted = 10,
    scStopBot = 11,
    srBotStopped = 12
  );

{$IFDEF DEBUG}
function TranslateCode(const ACode: Integer): String;
{$ENDIF DEBUG}

implementation

{$IFDEF DEBUG}
uses System.SysUtils;

function TranslateCode(const ACode: Integer): String;
var
  sc: TBackendFunctions;
  sc_valid: Boolean;
begin
  sc_valid := FALSE;
  for sc := Low(TBackendFunctions) to High(TBackendFunctions) do
    if Integer(sc) = ACode then
    begin
      sc_valid := TRUE;
      Break;
    end;

  if not sc_valid then
    Exit(Format('UNKNOWN CODE [%d]', [ACode]));

  case TBackendFunctions(ACode) of
    Hello: result := 'Hello';
    StartServer: result := 'StartServer';
    StopServer: result := 'StopServer';
    RestartServer: result := 'RestartServer';
    Starting: result := 'Starting';
    Stopping: result := 'Stopping';
    PerClientMsgEvent: result := 'PerClientMsgEvent';
    GlobalMsgEvent: result := 'GlobalMsgEvent';
    PerGameMsgEvent: result := 'PerGameMsgEvent';
    scStartBot: result := 'scStartBot';
    srBotStarted: result := 'srBotStarted';
    scStopBot: result := 'scStopBot';
    srBotStopped: result := 'srBotStopped';
  end;
end;
{$ENDIF DEBUG}

end.