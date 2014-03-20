unit Poker.Sounds;

interface

type
  TSounds = class
  private
  public
    const
      SOUND_DEALING        = 'Dealing';
      SOUND_CHECK          = 'Check';
      SOUND_PUTCHIPS_SMALL = 'PutChipsSmall';
      SOUND_ALLIN          = 'AllIn';

    class procedure Initialize;
    class procedure Deinitialize;

    procedure Play(const ASound: String);
    procedure Stop;
  end;

var
  Sounds: TSounds;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Winapi.Windows, System.SysUtils, Winapi.MMSystem;


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
 // if not PlaySound(PChar(ASound), HInstance, SND_RESOURCE or SND_ASYNC or SND_NODEFAULT) then
  begin
  //  {$IFDEF DEBUG} DebugLn(Format('Failed to play sound [%s] [err: %d]', [ASound, GetLastError]), ditException); {$ENDIF}
  end;
end;

procedure TSounds.Stop;
begin
  PlaySound(nil, 0, 0);
end;

end.
