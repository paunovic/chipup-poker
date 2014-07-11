unit Poker.Sounds;

interface

uses
  System.Generics.Collections, Poker.Common.WavePlayer;

type
  TSounds = class
  private
    {$IFDEF DEBUG} FDebugId: Integer; {$ENDIF}
    FWavePlayer: TWavePlayer;
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

    function Play(ASound: String): Boolean;
    procedure StopAll;
  end;

var
  Sounds: TSounds;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Winapi.Windows, System.SysUtils, Poker.Common.WavePlayer.DirectSoundBuffer;


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
  FWavePlayer := TWavePlayer.Create;
end;

destructor TSounds.Destroy;
begin
  FreeAndNil(FWavePlayer);
  {$IFDEF DEBUG} UnregisterDebugObject(FDebugId); {$ENDIF}
  inherited;
end;

function TSounds.Play(ASound: String): Boolean;
var
  buffer: TDirectSoundBuffer;
begin
  result := (FWavePlayer.Load(ASound, buffer)) and
            (buffer.PlayBuffer);
  FWavePlayer.CleanupFinishedBuffers;

  if not result then
  begin
    {$IFDEF DEBUG} DebugLn(FDebugId, Format('Failed to play sound [%s]', [ASound]), ditException); {$ENDIF}
  end;
end;

procedure TSounds.StopAll;
begin
  FWavePlayer.Buffers.Clear;
end;


end.
