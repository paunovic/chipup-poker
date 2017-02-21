unit Poker.SoftExceptions;

interface

procedure SoftException(const AException: String; const AData: String = '');

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Poker.Server.Socket;

procedure SoftException(const AException: String; const AData: String = '');
begin
  {$IFDEF DEBUG} DebugLn(AException, ditException, AData); {$ENDIF}

  if Assigned(ServerSocket) then
    ServerSocket.SoftException(AException, AData);
end;

end.
