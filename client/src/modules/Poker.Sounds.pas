unit Poker.Sounds;

interface

uses
  System.Generics.Collections, Poker.WavePlayer.Player, System.SyncObjs;

type
  TSounds = class
  private
    {$IFDEF DEBUG} FDebugId: Integer; {$ENDIF}
    FLock: TCriticalSection;
    FWavePlayers: TObjectList<TWavePlayer>;
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

    procedure CleanupFinishedSounds;

    function Play(const AHandle: THandle; ASound: String): Boolean;
    procedure Stop;
  end;

var
  Sounds: TSounds;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Winapi.Windows, System.SysUtils;


class procedure TSounds.Initialize;
begin
  Sounds := TSounds.Create;
end;

class procedure TSounds.Deinitialize;
begin
  FreeAndNil(Sounds);
end;

constructor TSounds.Create;
begin
  {$IFDEF DEBUG} FDebugId := RegisterDebugObject('Sounds'); {$ENDIF}
  FLock := TCriticalSection.Create;
  FWavePlayers := TObjectList<TWavePlayer>.Create;
end;

destructor TSounds.Destroy;
begin
  FreeAndNil(FWavePlayers);
  FreeAndNil(FLock);
  {$IFDEF DEBUG} UnregisterDebugObject(FDebugId); {$ENDIF}
  inherited;
end;

function TSounds.Play(const AHandle: THandle; ASound: String): Boolean;
var
  wave_player: TWavePlayer;
begin
  wave_player := TWavePlayer.Create(AHandle);
  wave_player.FreeOnDone := TRUE;
  if (not wave_player.Load(ASound)) or
     (not wave_player.PlayBuffer(FALSE)) then
  begin
    wave_player.Free;
    result := FALSE;
    {$IFDEF DEBUG} DebugLn(FDebugId, Format('Failed to play sound [%s]', [ASound]), ditException); {$ENDIF}
  end
  else
  begin
    FLock.Enter;
    try
      FWavePlayers.Add(wave_player);
    finally
      FLock.Leave;
    end;
    result := TRUE;
  end;

  CleanupFinishedSounds;
end;

procedure TSounds.Stop;
begin
  FWavePlayers.Clear;
end;

procedure TSounds.CleanupFinishedSounds;
var
  C1: Integer;
begin
  FLock.Enter;
  try
    for C1 := FWavePlayers.Count - 1 downto 0 do
      if FWavePlayers[C1].IsBufferPlaying = dsbsNone then
        FWavePlayers.Delete(C1);
  finally
    FLock.Leave;
  end;
end;


end.
