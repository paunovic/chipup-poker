unit Poker.CommandLineParamProcesser;

interface

type
  TCommandLineParamProcesser = class
  private
    class var
      FNoUpdateFlag: Boolean;
  public
    class procedure ParseParams;

    class property NoUpdateFlag: Boolean read FNoUpdateFlag;
  end;

implementation

{ TCommandLineParamProcesser }

class procedure TCommandLineParamProcesser.ParseParams;
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
