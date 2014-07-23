unit Poker.Tournaments;

interface

uses
  Poker.Protobufs.Objects.TournamentList, System.SyncObjs;

type
  TTournamentList = class(TPB_TournamentList)
  private
    FLock: TCriticalSection;
  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
    destructor Destroy; override;

    procedure Lock;
    procedure Unlock;
  end;

var
  Tournaments: TTournamentList;

implementation

uses
  System.SysUtils;

{ TTournamentList }

class procedure TTournamentList.Initialize;
begin
  Tournaments := TTournamentList.Create;
end;

class procedure TTournamentList.Deinitialize;
begin
  FreeAndNil(Tournaments);
end;

constructor TTournamentList.Create;
begin
  FLock := TCriticalSection.Create;
  inherited Create;
end;

destructor TTournamentList.Destroy;
begin
  FLock.Free;
  inherited;
end;


procedure TTournamentList.Lock;
begin
  FLock.Enter;
end;

procedure TTournamentList.Unlock;
begin
  FLock.Leave;
end;

end.
