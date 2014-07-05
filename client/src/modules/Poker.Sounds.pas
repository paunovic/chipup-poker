unit Poker.Sounds;

interface

type
  TSounds = class
  private
    {$IFDEF DEBUG} FDebugId: Integer; {$ENDIF}
  public
    const
      SOUND_DEALING        = 'Dealing';
      SOUND_CHECK          = 'Check';
      SOUND_PUTCHIPS_SMALL = 'PutChipsSmall';
      SOUND_MOVE_CHIPS     = 'MoveChips';
      SOUND_TIMEBAR        = 'Timebar';
      SOUND_TIMEBANK       = 'Timebank';

    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
    destructor Destroy; override;

    procedure Play(const ASound: String);
    procedure Stop;
  end;

var
  Sounds: TSounds;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Winapi.Windows, System.SysUtils, Winapi.MMSystem;


constructor TSounds.Create;
begin
  {$IFDEF DEBUG} FDebugId := RegisterDebugObject('Sounds'); {$ENDIF}
end;

destructor TSounds.Destroy;
begin
  {$IFDEF DEBUG} UnregisterDebugObject(FDebugId); {$ENDIF}
  inherited;
end;

class procedure TSounds.Initialize;
begin
  Sounds := TSounds.Create;
end;

class procedure TSounds.Deinitialize;
begin
  FreeAndNil(Sounds);
end;


procedure TSounds.Play(const ASound: String);
begin
  if not PlaySound(PChar(ASound), HInstance, SND_RESOURCE or SND_ASYNC or SND_NODEFAULT) then
  begin
    {$IFDEF DEBUG} DebugLn(FDebugId, Format('Failed to play sound [%s] [err: %d]', [ASound, GetLastError]), ditException); {$ENDIF}
  end;
end;

procedure TSounds.Stop;
begin
  PlaySound(nil, 0, 0);
end;

end.
