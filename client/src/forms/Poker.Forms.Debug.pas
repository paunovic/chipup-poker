unit Poker.Forms.Debug;

{$I defines.inc}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  cxTextEdit, cxMemo, cxCheckBox, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus, cxButtons, Vcl.ActnList,
  Vcl.ComCtrls, Vcl.AppEvnts, cxSplitter, cxLabel, RVScroll, RichView, RVStyle, RVTable, CRVData, dxBevel, ChipUpPokerDarkSkin;

type
  TDebugInfoType = (ditException = 0, ditApplication, ditSocket, ditSocketInc, ditSocketOut, ditNetInc, ditNetOut, ditForm);
  TDebugInfoTypes = set of TDebugInfoType;

  TfrmDebug = class(TForm)
    paLog: TPanel;
    paInfo: TPanel;
    alDebug: TActionList;
    acClearLog: TAction;
    acSaveLog: TAction;
    SaveDialog: TSaveDialog;
    pmLog: TPopupMenu;
    pmiLogCopy: TMenuItem;
    acCopyLogSelection: TAction;
    tiAppInfoRefresh: TTimer;
    pmiLogSave: TMenuItem;
    pmiLogClear: TMenuItem;
    N2: TMenuItem;
    lbsThreads: TcxLabel;
    lbsMemoryUsage: TcxLabel;
    lbsSocketState: TcxLabel;
    lbsCalbackSets: TcxLabel;
    lbvThreads: TcxLabel;
    lbvMemoryUsage: TcxLabel;
    lbvCallbackSets: TcxLabel;
    lbvSocketState: TcxLabel;
    RVStyle: TRVStyle;
    N1: TMenuItem;
    rvLog: TRichView;
    btSeatPos: TcxButton;
    btSet: TcxButton;
    meSeatPos: TcxMemo;
    btPause: TcxButton;
    dxBevel1: TdxBevel;
    procedure FormCreate(Sender: TObject);
    procedure acClearLogExecute(Sender: TObject);
    procedure acSaveLogExecute(Sender: TObject);
    procedure acCopyLogSelectionExecute(Sender: TObject);
    procedure tiAppInfoRefreshTimer(Sender: TObject);
    procedure btSeatPosClick(Sender: TObject);
    procedure btSetClick(Sender: TObject);
  private
    procedure ActiveFormChange(Sender: TObject);
  protected
    procedure CreateParams(var AParams: TCreateParams); override;
  public
    class procedure Initialize;
    class procedure Deinitialize;

    procedure Add(const ATime, AType, AData: String; const ATypeStyle, ADataStyle: Integer);
  end;

procedure DebugLn(const AData: String; const AType: TDebugInfoType);

implementation

{$R *.dfm}

uses
  {$IFDEF SEAT_POSITIONS_CONFIGURATOR}
  JclExprEval, Poker.Table.Resources,
  {$ENDIF}
  Poker.Common.Misc, Poker.Server.Socket, Poker.Server.MessageContainer, OverbyteIcsWSocket;


function AttachConsole(dwProcessID: Integer): Boolean; stdcall; external 'kernel32.dll';
function FreeConsole: Boolean; stdcall; external 'kernel32.dll';

var
  frmDebug: TfrmDebug;
  DebugFilePath: String = '';
  ConsoleAttached: Boolean = FALSE;


procedure DebugLn(const AData: String; const AType: TDebugInfoType);
var
  time_str: String;
  type_str: String;
  tstyle  : Integer;
  dstyle  : Integer;
  output  : String;
  tfile   : TextFile;
begin
  time_str := FormatDateTime('hh:nn:ss:zzz', Now);

  case AType of
    ditException: begin
      type_str := 'EXCP';
      tstyle := 1;
      dstyle := 7;
    end;
    ditApplication: begin
      type_str := 'APPL';
      tstyle := 2;
      dstyle := 8;
    end;
    ditSocketInc: begin
      type_str := 'SINC';
      tstyle := 3;
      dstyle := 9;
    end;
    ditSocketOut: begin
      type_str := 'SOUT';
      tstyle := 3;
      dstyle := 9;
    end;
    ditSocket: begin
      type_str := 'SOCK';
      tstyle := 3;
      dstyle := 9;
    end;
    ditNetInc: begin
      type_str := 'NINC';
      tstyle := 4;
      dstyle := 10;
    end;
    ditNetOut: begin
      type_str := 'NOUT';
      tstyle := 4;
      dstyle := 10;
    end;
    ditForm: begin
      type_str := 'FORM';
      tstyle := 5;
      dstyle := 11;
    end
  else
    type_str := 'UNKN';
    tstyle := 6;
    dstyle := 12;
  end;

  if Assigned(frmDebug) then
    frmDebug.Add(time_str, type_str, AData, tstyle, dstyle);

  output := Format('%s [%s] %s', [time_str, type_str, AData]);

  OutputDebugString(PChar(output));

  if ConsoleAttached then
    WriteLn(output);

  if DebugFilePath = '' then
    DebugFilePath := SelfPath + Format('debug\%s.txt', [FormatDateTime('dd-mm-yyyy hh-nn-ss', Now)]);

  ForceDirectories(ExtractFilePath(DebugFilePath));
  AssignFile(tfile, DebugFilePath);
  if FileExists(DebugFilePath) then
    Append(tfile)
  else
    Rewrite(tfile);
  try
    WriteLn(tfile, output);
  finally
    CloseFile(tfile);
  end;
end;


class procedure TfrmDebug.Initialize;
const
  ATTACH_PARENT_PROCESS = -1;
begin
  ConsoleAttached := AttachConsole(ATTACH_PARENT_PROCESS);

  frmDebug := TfrmDebug.Create(nil);
  frmDebug.Show;
end;

class procedure TfrmDebug.Deinitialize;
begin
  FreeAndNil(frmDebug);

  if ConsoleAttached then
    FreeConsole;
end;


procedure TfrmDebug.FormCreate(Sender: TObject);
begin
  Left := 0;
  Top := 0;

  rvLog.ClearAll;
  rvLog.Format;

  Screen.OnActiveFormChange := ActiveFormChange;

  Width := Round(Screen.Monitors[0].Width / 2.8);
  Height := Round(Screen.Monitors[0].Height / 2.5);

  {$IFDEF SEAT_POSITIONS_CONFIGURATOR}
  btSeatPos.Visible := TRUE;
  {$ENDIF}
end;

procedure TfrmDebug.tiAppInfoRefreshTimer(Sender: TObject);
var
  tmp: String;
begin
  lbvThreads.Caption := Format('%d', [GetThreadsCount(GetCurrentProcessId)]);
  lbvMemoryUsage.Caption := Format('%dkb', [GetWorkingSetSize div 1024]);
  lbvCallbackSets.Caption := Format('%d', [MessageContainer.CallbackSetsCount]);

  case ServerSocket.Socket.State of
    wsInvalidState: tmp := 'InvalidState';
    wsOpened: tmp := 'Opened';
    wsBound: tmp := 'Bound';
    wsConnecting: tmp := 'Connecting';
    wsSocksConnected: tmp := 'SocksConnected';
    wsConnected: tmp := 'Connected';
    wsAccepting: tmp := 'Accepting';
    wsListening: tmp := 'Listening';
    wsClosed: tmp := 'Closed';
  else
    tmp := 'Unknown';
  end;

  lbvSocketState.Caption := Format('%s', [tmp]);
end;

procedure TfrmDebug.CreateParams(var AParams: TCreateParams);
begin
  inherited;

  AParams.WndParent := 0;
end;

procedure TfrmDebug.acClearLogExecute(Sender: TObject);
begin
  rvLog.ClearAll;
  rvLog.Format;
end;

procedure TfrmDebug.acCopyLogSelectionExecute(Sender: TObject);
begin
  rvLog.CopyText;
end;

procedure TfrmDebug.acSaveLogExecute(Sender: TObject);
begin
  if SaveDialog.Execute(Handle) then
    case SaveDialog.FilterIndex of
      1: rvLog.SaveRTF(ChangeFileExt(SaveDialog.FileName, '.rtf'), FALSE);
      2: rvLog.SaveText(ChangeFileExt(SaveDialog.FileName, '.txt'), 0);
    end;
end;

procedure TfrmDebug.ActiveFormChange(Sender: TObject);
begin
  if not Assigned(Screen.ActiveForm) then
    Exit;

  if Screen.ActiveForm = self then
    Exit;

  DebugLn(Format('Active form: %s [%s]', [Screen.ActiveForm.Name, Screen.ActiveForm.Caption]), ditForm);
end;

procedure TfrmDebug.Add(const ATime, AType, AData: String; const ATypeStyle, ADataStyle: Integer);
const
  SCROLLBACK_LINES = 250;
var
  table: TRVTableItemInfo;
begin
  if btPause.Down then
    Exit;

  if rvLog.ItemCount >= SCROLLBACK_LINES then
    rvLog.DeleteParas(0, rvLog.ItemCount - SCROLLBACK_LINES + 1);

  table := TRVTableItemInfo.CreateEx(1, 3, rvLog.RVData);
  with table do
  begin
    BorderWidth := 0;
    CellVPadding := 0;
    CellBorderWidth := 0;
    CellVSpacing := 0;
    BorderVSpacing := 0;
    Color := clNone;
    BestWidth := 0;
    Options := [rvtoRTFAllowAutofit];

    Cells[0, 0].BestWidth := 75;
    Cells[0, 1].BestWidth := 50;

    Cells[0, 0].Clear;
    Cells[0, 1].Clear;
    Cells[0, 2].Clear;

    Cells[0, 0].AddFmt('%s', [ATime], 0, 0);
    Cells[0, 1].AddFmt('%s', [AType], ATypeStyle, 1);
    Cells[0, 2].AddFmt('%s', [AData], ADataStyle, 2);
  end;

  rvLog.AddItem('', table);

  if rvLog.VScrollPos < rvLog.VScrollMax then
    rvLog.Format
  else
    rvLog.FormatTail;
end;


procedure TfrmDebug.btSeatPosClick(Sender: TObject);
begin
  {$IFDEF SEAT_POSITIONS_CONFIGURATOR}
  meSeatPos.Visible := btSeatPos.Down;
  if meSeatPos.Visible then
    meSeatPos.BringToFront;
  btSet.Visible := btSeatPos.Down;
  {$ENDIF}
end;

procedure TfrmDebug.btSetClick(Sender: TObject);
{$IFDEF SEAT_POSITIONS_CONFIGURATOR}
var
  C1, C2: Integer;
  line  : String;
  tmp   : String;
  val   : Extended;
  cpos  : Integer;
  evaluator: TEvaluator;
{$ENDIF}
begin
  {$IFDEF SEAT_POSITIONS_CONFIGURATOR}
  evaluator := TEvaluator.Create;
  try
    evaluator.AddConst('pi', pi);

    for C1 := 2 to 10 do
    begin
      line := meSeatPos.Lines[C1 - 2];
      for C2 := 0 to 9 do
      begin
        cpos := Pos(',', line);
        if cpos = 0 then
        begin
          cpos := Pos(')', line);
          if cpos = 0 then
            exit;
        end;

        tmp := Copy(line, 1, cpos - 1);
        Delete(line, 1, cpos);

        cpos := Pos('(', tmp);
        if cpos > 0 then
          Delete(tmp, 1, cpos);
        cpos := Pos(')', tmp);
        if cpos > 0 then
          Delete(tmp, cpos, 1);
        tmp := Trim(tmp);

        val := evaluator.Evaluate(tmp);
        TableResources.SEAT_POINTS[C1, C2] := val;
      end;
    end;
  finally
    evaluator.Free;
  end;
  {$ENDIF}
end;

end.

