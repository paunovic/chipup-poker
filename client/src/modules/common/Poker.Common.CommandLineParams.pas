unit Poker.Common.CommandLineParams;

interface

type
  TCommandLineParams = class
  private
    class var
      FNoUpdateFlag: Boolean;
  public
    class procedure ParseParams;

    class property NoUpdateFlag: Boolean read FNoUpdateFlag;
  end;

implementation

{ TCommandLineParams }

class procedure TCommandLineParams.ParseParams;
var
  C1: Integer;
begin
  for C1 := 1 to ParamCount do
  begin
    if ParamStr(C1) = '-noupdate' then
      FNoUpdateFlag := TRUE;
  end;
end;

end.
