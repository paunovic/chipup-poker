program clientTests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  pbOutput in '..\..\delphi-3rd-party\protobufs\pbOutput.pas',
  StrBuffer in '..\..\delphi-3rd-party\protobufs\StrBuffer.pas',
  pbPublic in '..\..\delphi-3rd-party\protobufs\pbPublic.pas',
  pbInput in '..\..\delphi-3rd-party\protobufs\pbInput.pas',
  SvSerializer in '..\..\delphi-3rd-party\SvSerializer\Persistence\SvSerializer.pas',
  SvSerializerFactory in '..\..\delphi-3rd-party\SvSerializer\Persistence\SvSerializerFactory.pas',
  SvSerializerAbstract in '..\..\delphi-3rd-party\SvSerializer\Persistence\SvSerializerAbstract.pas',
  SvSerializerRtti in '..\..\delphi-3rd-party\SvSerializer\Persistence\SvSerializerRtti.pas',
  SvSerializerSuperJson in '..\..\delphi-3rd-party\SvSerializer\Persistence\SvSerializerSuperJson.pas',
  Poker.Common.Misc in '..\src\modules\common\Poker.Common.Misc.pas',
  Poker.Interfaces.ModalForm in '..\src\interfaces\Poker.Interfaces.ModalForm.pas',
  Poker.Interfaces.FormParams in '..\src\interfaces\Poker.Interfaces.FormParams.pas',
  Poker.Protobufs.Objects.Game in '..\src\modules\protobuf\objects\Poker.Protobufs.Objects.Game.pas',
  Poker.Protobufs.Objects.Base in '..\src\modules\protobuf\Poker.Protobufs.Objects.Base.pas',
  Poker.Protobufs.Reader in '..\src\modules\protobuf\Poker.Protobufs.Reader.pas',
  Poker.HandStrengthCalculator in '..\src\modules\Poker.HandStrengthCalculator.pas',
  utCards in 'utCards.pas',
  utHandStrengthCalculator in 'utHandStrengthCalculator.pas',
  Poker.Cards in '..\src\modules\Poker.Cards.pas';

{$R *.RES}

begin
  Randomize;
  DUnitTestRunner.RunRegisteredTests;
end.

