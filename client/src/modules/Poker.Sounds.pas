unit Poker.Sounds;

interface

uses
  System.Generics.Collections, Poker.Common.WavePlayer;

type
  TSounds = class
  private
    FWavePlayer: TWavePlayer;
  public
    const
      SOUND_DEALING        = 'Dealing';
      SOUND_CHECK          = 'Check';
      SOUND_PUTCHIPS_SMALL = 'PutChipsSmall';
      SOUND_MOVE_CHIPS     = 'MoveChips';
      SOUND_TIMEBAR        = 'Timebar';
      SOUND_TIMEBANK       = 'Timebank';

    class procedure Initialize(const AHandle: THandle);
    class procedure Deinitialize;

    constructor Create(const AHandle: THandle);
    destructor Destroy; override;

    function Play(ASound: String): Boolean;
    procedure StopAll;

    property WavePlayer: TWavePlayer read FWavePlayer;
  end;

var
  Sounds: TSounds;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Winapi.Windows, System.SysUtils, Poker.Common.WavePlayer.DirectSoundBuffer, Poker.SoftExceptions;


class procedure TSounds.Initialize(const AHandle: THandle);
begin
  Sounds := TSounds.Create(AHandle);
end;

class procedure TSounds.Deinitialize;
begin
  FreeAndNil(Sounds);
end;

constructor TSounds.Create(const AHandle: THandle);
begin
  FWavePlayer := TWavePlayer.Create(AHandle);
end;

destructor TSounds.Destroy;
begin
  FreeAndNil(FWavePlayer);
  inherited;
end;

function TSounds.Play(ASound: String): Boolean;
var
  buffer: TDirectSoundBuffer;
begin
  result := (FWavePlayer.Load(ASound, buffer)) and
            (buffer.PlayBuffer);

  if not result then
    SoftException(Format('Failed to play sound [%s]', [ASound]));
end;

procedure TSounds.StopAll;
begin
  FWavePlayer.Buffers.Clear;
end;


end.
