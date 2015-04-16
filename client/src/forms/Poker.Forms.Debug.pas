unit Poker.Forms.Debug;

{$I defines.inc}

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, cxContainer, cxEdit, cxMemo, Vcl.ExtCtrls, Vcl.Menus, cxButtons,
  Vcl.ActnList, IdSync, cxLabel, RVScroll, RichView, RVStyle, RVTable, CRVData, dxBevel,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  ChipUPPokerDarkSkin, Vcl.StdCtrls, cxTextEdit, cxMaskEdit, cxDropDownEdit,
  cxCheckComboBox, System.Generics.Collections, cxRadioGroup, cxCheckBox,
  Poker.Common.SafeMutex, Poker.Common.CPUUsage, dxScreenTip, dxCustomHint,
  cxHint;

type
  TDebugInfoType = (ditException = 0, ditApplication, ditSocket, ditSocketInc,
    ditSocketOut, ditNetInc, ditNetOut, ditForm, ditPingPong, ditUnknown);
  TDebugRefreshItem = (dfiSystemMetrics, dfiSocket, dfiCallbacks,
    dfiSwapChains, dfiServer, dfiSoundBuffers, dfiAnimations);
  TDebugRefreshItemSet = set of TDebugRefreshItem;

  TDebugFormLog = class(TIdNotify)
  private
    FType: TDebugInfoType;
    FTime: String;
    FTypeStr: String;
    FData: String;
    FSubData: String;
  protected
    procedure DoNotify; override;
  public
    class procedure Add(const AType: TDebugInfoType; const ATime, ATypeStr, AData, ASubData: String);
  end;

  TDebugFormRefresh = class(TIdSync)
  private
    FRefreshItems: TDebugRefreshItemSet;
  protected
    procedure DoSynchronize; override;
  public
    class procedure Execute(const ARefreshItems: TDebugRefreshItemSet);
  end;

  TfrmDebug = class(TForm)
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
    RVStyles: TRVStyle;
    N1: TMenuItem;
    meSeatPos: TcxMemo;
    rvLog: TRichView;
    paInfo: TPanel;
    dxBevel1: TdxBevel;
    btSeatPos: TcxButton;
    pmiShowPings: TMenuItem;
    paTop: TPanel;
    teRegexFilter: TcxTextEdit;
    pmiRTTIEnabled: TMenuItem;
    teFindText: TcxTextEdit;
    rvMemoryState: TRichView;
    cbDebugInfo: TcxComboBox;
    btPause: TcxButton;
    paInfoPanel1: TPanel;
    paInfoPanel3: TPanel;
    dxBevel2: TdxBevel;
    lbvServer: TcxLabel;
    lbsServer: TcxLabel;
    lbsSocketState: TcxLabel;
    lbvSocketState: TcxLabel;
    lbsLatency: TcxLabel;
    lbvLatency: TcxLabel;
    lbsDataRecv: TcxLabel;
    lbvDataRecv: TcxLabel;
    lbvDataSent: TcxLabel;
    lbsDataSent: TcxLabel;
    paInfoPanel2: TPanel;
    lbsCallbacks: TcxLabel;
    lbvCallbacks: TcxLabel;
    lbsSwapChain: TcxLabel;
    lbvSwapChain: TcxLabel;
    lbsAnimations: TcxLabel;
    lbsSounds: TcxLabel;
    lbvSounds: TcxLabel;
    lbvAnimations: TcxLabel;
    lbsThreads: TcxLabel;
    lbvThreads: TcxLabel;
    lbsCPU: TcxLabel;
    lbvCPU: TcxLabel;
    lbvMemoryUsage: TcxLabel;
    lbsMemoryUsage: TcxLabel;
    HintStyleController: TcxHintStyleController;
    procedure FormCreate(Sender: TObject);
    procedure acClearLogExecute(Sender: TObject);
    procedure acSaveLogExecute(Sender: TObject);
    procedure acCopyLogSelectionExecute(Sender: TObject);
    procedure tiAppInfoRefreshTimer(Sender: TObject);
    procedure btSeatPosClick(Sender: TObject);
    procedure rvLogRVMouseUp(Sender: TCustomRichView; Button: TMouseButton; Shift: TShiftState; ItemNo, X, Y: Integer);
    procedure meSeatPosPropertiesChange(Sender: TObject);
    procedure teRegexFilterPropertiesChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure teFindTextEnter(Sender: TObject);
    procedure teFindTextExit(Sender: TObject);
    procedure teFindTextPropertiesChange(Sender: TObject);
    procedure cbDebugInfoPropertiesChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    const
      SCROLLBACK_LINES = 500;

    var
      FSelfCPUCounter: PCPUUsageData;

    function FindStyleWithName(const AName: String): Integer;
    procedure RefreshStats(const ARefreshItems: TDebugRefreshItemSet);
    procedure Add(const AType: TDebugInfoType; const ATime, ATypeStr, AData, ASubData: String);
    procedure UpdateMemoryUsageDetails;
    procedure RefreshSocketState;
    procedure RefreshSocketLatency;
    procedure RefreshSocketDataRecvSent;
    procedure RefreshSocketData;
    procedure RefreshSystemMetrics;
    procedure RefreshCallbacksData;
    procedure RefreshSwapChainData;
    procedure RefreshServerData;
    procedure RefreshSoundData;
    procedure RefreshAnimationsData;
  protected
    procedure CreateParams(var AParams: TCreateParams); override;
  public
    class procedure Initialize;
    class procedure Deinitialize;
  end;

  function IsDebugFormAssigned: Boolean;
  function IsDebugRTTIEnabled: Boolean;

  procedure DebugLn(const AData: String; const AType: TDebugInfoType; const ASubData: String = '');
  procedure RefreshDebugForm(const ARefreshItems: TDebugRefreshItemSet);

implementation

{$R *.dfm}

uses
  {$IFDEF SEAT_POSITIONS_CONFIGURATOR}
  JclExprEval, Poker.Tables.Resources,
  {$ENDIF}
  FastMM4, Poker.Common.InstanceController, RVItem, Poker.Common.Misc, Poker.Server.Socket, Poker.Server.MessageContainer, OverbyteIcsWSocket,
  Poker.DirectX.Core, System.RegularExpressionsAPI, System.RegularExpressions, Poker.DataModule, madExcept, Poker.Sounds, Poker.DirectX.Timer,
  RectMarks, Poker.Settings;


function AttachConsole(dwProcessID: Integer): Boolean; stdcall; external 'kernel32.dll';
function FreeConsole: Boolean; stdcall; external 'kernel32.dll';

var
  frmDebug: TfrmDebug;
  DebugFilePath: String = '';
  MemoryUsageFilePath: String = '';
  ConsoleAttached: Boolean = FALSE;
  ActiveNotifyObjects: TObjectList<TIdNotify>;


function IsDebugFormAssigned: Boolean;
begin
  result := Assigned(frmDebug);
end;

function IsDebugRTTIEnabled: Boolean;
begin
  result := frmDebug.pmiRTTIEnabled.Checked;
end;

procedure DebugLn(const AData: String; const AType: TDebugInfoType; const ASubData: String = '');
var
  time_str: String;
  type_str: String;
  output: String;
  fstream: TFileStream;
  fwriter: TStreamWriter;
begin
  time_str := FormatDateTime('hh:nn:ss:zzz', Now);

  case AType of
    ditException: type_str := 'EXCP';
    ditApplication: type_str := 'APPL';
    ditSocketInc: type_str := 'SINC';
    ditSocketOut: type_str := 'SOUT';
    ditSocket: type_str := 'SOCK';
    ditNetInc: type_str := 'NINC';
    ditNetOut: type_str := 'NOUT';
    ditForm: type_str := 'FORM';
    ditPingPong: type_str := 'PING';
  else
    type_str := 'UNKN';
  end;

  if IsDebugFormAssigned then
    TDebugFormLog.Add(AType, time_str, type_str, AData, ASubData);

  output := Format('%s [%s] %s', [time_str, type_str, AData]);

  OutputDebugString(PChar(output));

  if ConsoleAttached then
    WriteLn(output);

  // do NOT use SelfPath variable here, because this function can be called before SelfPath is initialized!
  if DebugFilePath = '' then
    DebugFilePath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + Format('debug\%s [%d].txt', [FormatDateTime('dd-mm-yyyy hh-nn-ss', Now), GetCurrentProcessId]);

  if MemoryUsageFilePath = '' then
    MemoryUsageFilePath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'debug\MemoryManagerState.txt';

  ForceDirectories(ExtractFilePath(DebugFilePath));
  if not FileExists(DebugFilePath) then
    fstream := TFileStream.Create(DebugFilePath, fmCreate or fmShareDenyNone)
  else
    fstream := TFileStream.Create(DebugFilePath, fmOpenWrite or fmShareDenyNone);
  try
    fstream.Seek(0, soFromEnd);
    fwriter := TStreamWriter.Create(fstream);
    try
      fwriter.WriteLine(output);
    finally
      fwriter.Free;
    end;
  finally
    fstream.Free;
  end;
end;

procedure RefreshDebugForm(const ARefreshItems: TDebugRefreshItemSet);
begin
  if IsDebugFormAssigned then
    TDebugFormRefresh.Execute(ARefreshItems);
end;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class procedure TfrmDebug.Initialize;
const
  ATTACH_PARENT_PROCESS = -1;
begin
  if not ConsoleAttached then
    ConsoleAttached := AttachConsole(ATTACH_PARENT_PROCESS);

  if not IsDebugFormAssigned then
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

  Left := 0;
  Top := 0;
  Width := Round(Screen.Monitors[0].Width / 2.7);
  Height := Round(Screen.Monitors[0].Height / 2.3);

  FSelfCPUCounter := TCPUUsage.CreateCounter(GetCurrentProcessId);
  Caption := Format('%s - Debug', [Settings.Hardcoded.PROJECT_CAPTION]);

  {$IFDEF SEAT_POSITIONS_CONFIGURATOR}
  btSeatPos.Visible := TRUE;
  {$ENDIF}
end;

procedure TfrmDebug.FormDestroy(Sender: TObject);
begin
  TCPUUsage.DestroyCounter(FSelfCPUCounter);
end;

procedure TfrmDebug.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  frmDebug := nil;
end;

procedure TfrmDebug.teFindTextEnter(Sender: TObject);
var
  teobj: TcxTextEdit;
begin
  teobj := Sender as TcxTextEdit;
  if teobj.Tag = 0 then
  begin
    teobj.Clear;
    teobj.Tag := 1;
  end;
end;

procedure TfrmDebug.teFindTextExit(Sender: TObject);
var
  teobj: TcxTextEdit;
begin
  teobj := Sender as TcxTextEdit;
  if (teobj.Tag = 1) and
     (teobj.Text = '') then
  begin
    teobj.Tag := 0;
    if teobj = teRegexFilter then
      teobj.Text := 'RegEx filtering...'
    else
      if teobj = teFindText then
        teobj.Text := 'Find text...';
  end;
end;

procedure TfrmDebug.teFindTextPropertiesChange(Sender: TObject);
var
  rv: TRichView;
begin
  if rvMemoryState.Visible then
    rv := rvMemoryState
  else
    rv := rvLog;

  ClearRectMarks(rv);

  if teFindText.Tag = 0 then
    Exit;

  if teFindText.Text <> '' then
    MarkSubstring(rv, teFindText.Text, clRed);

  rv.Format;
end;

procedure TfrmDebug.teRegexFilterPropertiesChange(Sender: TObject);
var
  valuesset: TcxContainerStyleValues;
begin
  if teRegexFilter.Tag = 0 then
    Exit;

  if IsValidRegex(teRegexFilter.Text) then
  begin
    teRegexFilter.Style.TextColor := clWindowText;
    valuesset := teRegexFilter.Style.AssignedValues;
    Exclude(valuesset, 7);
    teRegexFilter.Style.AssignedValues := valuesset;
  end
  else
    teRegexFilter.Style.TextColor := clRed;
end;

procedure TfrmDebug.tiAppInfoRefreshTimer(Sender: TObject);
begin
  RefreshStats([]);
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

function TfrmDebug.FindStyleWithName(const AName: String): Integer;
var
  C1: Integer;
begin
  for C1 := 0 to RVStyles.TextStyles.Count - 1 do
    if RVStyles.TextStyles[C1].StyleName = AName then
      Exit(C1);
  Exit(0);
end;

procedure TfrmDebug.Add(const AType: TDebugInfoType; const ATime, ATypeStr, AData, ASubData: String);
var
  table: TRVTableItemInfo;
  sl: TStringList;
  C1: Integer;
begin
  if (btPause.Down) and
     (rvLog.Visible) then
    Exit;

  if (AType = ditPingPong) and
     (not pmiShowPings.Checked) then
    Exit;

  if (teRegexFilter.Tag = 1) and
     (teRegexFilter.Text <> '') and
     (IsValidRegex(teRegexFilter.Text)) then
  begin
    if (not TRegEx.IsMatch(ATime, teRegexFilter.Text)) and
       (not TRegEx.IsMatch(ATypeStr, teRegexFilter.Text)) and
       (not TRegEx.IsMatch(AData, teRegexFilter.Text)) and
       (not TRegEx.IsMatch(ASubData, teRegexFilter.Text)) then
      Exit;
  end;

  if rvLog.ItemCount >= SCROLLBACK_LINES then
    rvLog.DeleteParas(0, rvLog.ItemCount - SCROLLBACK_LINES + 1);

  table := TRVTableItemInfo.CreateEx(1, 4, rvLog.RVData);
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

    Cells[0, 0].BestWidth := 80;
    Cells[0, 1].BestWidth := 40;
    Cells[0, 2].BestWidth := 10;

    Cells[0, 0].Clear;
    Cells[0, 1].Clear;
    Cells[0, 2].Clear;
    Cells[0, 3].Clear;

    Cells[0, 0].AddFmt('%s', [ATime], FindStyleWithName('Time'), 0);
    Cells[0, 1].AddFmt('%s', [ATypeStr], FindStyleWithName('T-' + ATypeStr), 1);
    if ASubData <> '' then
      Cells[0, 2].AddFmt('+', [], FindStyleWithName('Subdata'), 1)
    else
      Cells[0, 2].AddFmt('', [], FindStyleWithName('Subdata'), 1);
    Cells[0, 3].AddFmt('%s', [AData], FindStyleWithName('D-' + ATypeStr), 2);
  end;
  rvLog.AddItem('', table);

  if ASubData <> '' then
  begin
    table.Tag := 'E';
    table := TRVTableItemInfo.CreateEx(1, 4, rvLog.RVData);
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
      Cells[0, 1].BestWidth := 40;
      Cells[0, 2].BestWidth := 10;

      Cells[0, 0].Clear;
      Cells[0, 1].Clear;
      Cells[0, 2].Clear;
      Cells[0, 3].Clear;

      Cells[0, 0].AddFmt('', [], 0, 0);
      Cells[0, 1].AddFmt('', [], 0, 0);
      Cells[0, 2].AddFmt('', [], 0, 0);
      sl := TStringList.Create;
      try
        Split(#10, ASubData, sl);
        for C1 := 0 to sl.Count - 1 do
          Cells[0, 3].AddFmt('%s', [sl[C1]], FindStyleWithName('Subdata'), 2);
      finally
        sl.Free;
      end;
    end;
    rvLog.AddItem('', table);
    rvLog.SetItemExtraIntProperty(rvLog.ItemCount - 1, rvepHidden, 1);
  end;

  if (teFindText.Tag = 1) and
     (teFindText.Text <> '') then
  begin
    ClearRectMarks(rvLog);
    MarkSubstring(rvLog, teFindText.Text, clRed);
  end;

  if rvLog.VScrollPos < rvLog.VScrollMax then
    rvLog.Format
  else
    rvLog.FormatTail;
end;

procedure TfrmDebug.rvLogRVMouseUp(Sender: TCustomRichView; Button: TMouseButton; Shift: TShiftState; ItemNo, X, Y: Integer);
var
  is_hidden: Integer;
  rvtag: TRVTag;
  table: TRVTableItemInfo;
begin
  if ItemNo = -1 then
    Exit;

  if Button <> mbLeft then
    Exit;

  rvtag := rvLog.GetItemTag(ItemNo);
  if rvtag = 'E' then // row is expandable
  begin
    rvLog.GetItemExtraIntProperty(ItemNo + 1, rvepHidden, is_hidden);
    is_hidden := Abs(is_hidden - 1);
    rvLog.SetItemExtraIntProperty(ItemNo + 1, rvepHidden, is_hidden);
    table := rvLog.GetItem(ItemNo) as TRVTableItemInfo;
    if is_hidden = 0 then
      table.Cells[0, 2].SetItemText(0, '-')
    else
      table.Cells[0, 2].SetItemText(0, '+');
    rvLog.Format;
  end;
end;

procedure TfrmDebug.btSeatPosClick(Sender: TObject);
begin
  {$IFDEF SEAT_POSITIONS_CONFIGURATOR}
  meSeatPos.Visible := btSeatPos.Down;
  if meSeatPos.Visible then
    meSeatPos.BringToFront;
  {$ENDIF}
end;

procedure TfrmDebug.cbDebugInfoPropertiesChange(Sender: TObject);
begin
  case cbDebugInfo.ItemIndex of
    0: begin
      rvMemoryState.Visible := FALSE;
      rvLog.Visible := TRUE;
    end;
    1: begin
      rvMemoryState.Visible := TRUE;
      rvLog.Visible := FALSE;
    end;
  end;

  if rvMemoryState.Visible then
  begin
    ClearRectMarks(rvLog);
    UpdateMemoryUsageDetails;
    rvMemoryState.BringToFront;
  end
  else
  begin
    ClearRectMarks(rvMemoryState);
    teFindText.Properties.OnChange(nil);
  end;
end;

procedure TfrmDebug.meSeatPosPropertiesChange(Sender: TObject);
{$IFDEF SEAT_POSITIONS_CONFIGURATOR}
var
  C1, C2: Integer;
  line: String;
  tmp: String;
  val: Extended;
  cpos: Integer;
  evaluator: TEvaluator;
{$ENDIF}
begin
  {$IFDEF SEAT_POSITIONS_CONFIGURATOR}
  evaluator := TEvaluator.Create;
  try
    evaluator.AddConst('pi', pi);

    try
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
    except
      on E: Exception do;
    end;
  finally
    evaluator.Free;
  end;
  {$ENDIF}
end;

procedure TfrmDebug.RefreshAnimationsData;
begin
  if Assigned(DXTimer) then
    lbvAnimations.Caption := IntToStr(DXTimer.Animations.Count)
  else
    lbvAnimations.Caption := 'Unknown';
  lbvAnimations.Refresh;
end;

procedure TfrmDebug.RefreshCallbacksData;
begin
  lbvCallbacks.Caption := Format('%d', [MessageContainer.CallbackSetsCount]);
  lbvCallbacks.Hint := MessageContainer.CallbackSetsNames;
  lbvCallbacks.Refresh;
end;

procedure TfrmDebug.RefreshServerData;
var
  line: String;
  cpos: Integer;
begin
  if (Assigned(ServerSocket)) and
     (ServerSocket.Socket.Addr <> '') then
  begin
    line := ServerSocket.Socket.Addr;
    cpos := Pos('.', line);
    if cpos > 0 then
      line := Copy(line, 1, cpos - 1);
    lbvServer.Caption := line;
    lbvServer.Hint := Format('%s:%s', [ServerSocket.Socket.Addr, ServerSocket.Socket.Port]);
    if ServerSocket.Socket.SslEnable then
      lbvServer.Hint := lbvServer.Hint + ' (SSL enabled)'
    else
      lbvServer.Hint := lbvServer.Hint + ' (SSL disabled)';
  end
  else
  begin
    lbvServer.Caption := 'Unknown';
    lbvServer.Hint := '';
  end;

  lbvServer.Refresh;
end;

procedure TfrmDebug.RefreshSocketData;
begin
  RefreshSocketState;
  RefreshSocketLatency;
  RefreshSocketDataRecvSent;
end;

procedure TfrmDebug.RefreshSocketDataRecvSent;
begin
  if Assigned(ServerSocket) then
  begin
    lbvDataRecv.Caption := Format('%.2f kb', [ServerSocket.BytesDownloaded / 1024]);
    lbvDataSent.Caption := Format('%.2f kb', [ServerSocket.BytesSent / 1024]);
  end
  else
  begin
    lbvDataRecv.Caption := 'Unknown';
    lbvDataSent.Caption := 'Unknown';
  end;
  lbvDataRecv.Refresh;
  lbvDataSent.Refresh;
end;

procedure TfrmDebug.RefreshSocketLatency;
var
  latency: Integer;
  pinging: Boolean;
  unknown: Boolean;
begin
  unknown := FALSE;
  if (Assigned(ServerSocket)) and
     (ServerSocket.IsConnected) then
  begin
    latency := ServerSocket.Latency;
    pinging := ServerSocket.IsPinging;
    if latency > 0 then
    begin
      lbvLatency.Caption := Format('%dms', [latency]);
      if pinging then
        lbvLatency.Caption := lbvLatency.Caption + ' ...';
      if latency < 100 then
        lbvLatency.Style.TextColor := $001DE24F
      else
        if latency < 500 then
          lbvLatency.Style.TextColor := clYellow
        else
          lbvLatency.Style.TextColor := clRed;
    end
    else
      unknown := TRUE;
  end
  else
    unknown := TRUE;

  if unknown then
  begin
    lbvLatency.Caption := 'Unknown';
    lbvLatency.Style.TextColor := clWhite;
  end;

  lbvLatency.Refresh;
end;

procedure TfrmDebug.RefreshSocketState;
var
  server_socket_state: String;
  server_socket_state_color: TColor;
begin
  server_socket_state_color := clWhite;
  if Assigned(ServerSocket) then
  begin
    case ServerSocket.Socket.State of
      wsInvalidState: server_socket_state := 'Invalid state';
      wsOpened: server_socket_state := 'Opened';
      wsBound: server_socket_state := 'Bound';
      wsConnecting: server_socket_state := 'Connecting...';
      wsSocksConnected: server_socket_state := 'Scks connected'; // not a typo! wouldn't fit otherwise in label width
      wsConnected: begin
        server_socket_state := 'Connected';
        server_socket_state_color := $001DE24F;
      end;
      wsAccepting: server_socket_state := 'Accepting...';
      wsListening: server_socket_state := 'Listening...';
      wsClosed: begin
        server_socket_state := 'Closed';
        server_socket_state_color := clRed;
      end;
    else
      server_socket_state := 'Unknown';
    end;
  end
  else
  begin
    server_socket_state := 'Unassigned';
    server_socket_state_color := clRed;
  end;

  lbvSocketState.Caption := server_socket_state;
  lbvSocketState.Style.TextColor := server_socket_state_color;
  lbvSocketState.Refresh;
end;

procedure TfrmDebug.RefreshSoundData;
begin
  if Assigned(Sounds) then
    lbvSounds.Caption := IntToStr(Sounds.WavePlayer.Buffers.Count)
  else
    lbvSounds.Caption := 'Unknown';
  lbvSounds.Refresh;
end;

procedure TfrmDebug.RefreshSwapChainData;
var
  swap_chains_occupied: Integer;
  C1: Integer;
begin
  if (Assigned(DXCore)) and
     (Assigned(DXCore.Device)) then
  begin
    swap_chains_occupied := 0;
    for C1 := 1 to DXCore.Device.SwapChains.Count - 1 do
      if DXCore.Device.SwapChains[C1].WindowHandle <> DXCore.DummyWindow then
        Inc(swap_chains_occupied);
    lbvSwapChain.Caption := Format('%d/%d', [swap_chains_occupied, DXCore.Device.SwapChains.Count - 1]);
  end
  else
    lbvSwapChain.Caption := 'Unknown';
  lbvSwapChain.Refresh;
end;

procedure TfrmDebug.RefreshSystemMetrics;
begin
  lbvThreads.Caption := Format('%d', [GetThreadsCount(GetCurrentProcessId)]);
  lbvMemoryUsage.Caption := Format('%.2fmb', [GetWorkingSetSize / (1024 * 1024)]);
  lbvCPU.Caption := Format('%.2f%%', [TCPUUsage.Get(FSelfCPUCounter)]);
  lbvThreads.Refresh;
  lbvMemoryUsage.Refresh;
  lbvCPU.Refresh;

  if rvMemoryState.Visible then
    UpdateMemoryUsageDetails;
end;

procedure TfrmDebug.RefreshStats(const ARefreshItems: TDebugRefreshItemSet);
var
  refresh_items: TDebugRefreshItemSet;
  dfi: TDebugRefreshItem;
begin
  refresh_items := ARefreshItems;
  if refresh_items = [] then
    for dfi := Low(TDebugRefreshItem) to High(TDebugRefreshItem) do
      Include(refresh_items, dfi);

  if dfiSystemMetrics in refresh_items then
    RefreshSystemMetrics;

  if dfiCallbacks in refresh_items then
    RefreshCallbacksData;

  if dfiSocket in refresh_items then
    RefreshSocketData;

  if dfiSwapChains in refresh_items then
    RefreshSwapChainData;

  if dfiServer in refresh_items then
    RefreshServerData;

  if dfiSoundBuffers in refresh_items then
    RefreshSoundData;

  if dfiAnimations in refresh_items then
    RefreshAnimationsData;
end;

procedure TfrmDebug.UpdateMemoryUsageDetails;
var
  fs: TFileStream;
begin
  LogMemoryManagerStateToFile(MemoryUsageFilePath);
  if not btPause.Down then
  begin
    rvMemoryState.ClearAll;
    fs := TFileStream.Create(MemoryUsageFilePath, fmOpenRead);
    try
      fs.Position := 3; // skip first three weird chars (EF BB BF) (BOM?)
      rvMemoryState.LoadTextFromStream(fs, FindStyleWithName('MemoryState'), 2, FALSE);
    finally
      fs.Free;
    end;
    rvMemoryState.Format;
    teFindText.Properties.OnChange(nil);
  end;
end;

{ TDebugFormLog }

procedure TDebugFormLog.DoNotify;
begin
  if IsDebugFormAssigned then
    frmDebug.Add(FType, FTime, FTypeStr, FData, FSubData);

  ActiveNotifyObjects.Extract(self);
  ActiveNotifyObjects.TrimExcess;
end;

class procedure TDebugFormLog.Add(const AType: TDebugInfoType; const ATime, ATypeStr, AData, ASubData: String);
var
  dfl: TDebugFormLog;
begin
  dfl := TDebugFormLog.Create;
  ActiveNotifyObjects.Add(dfl);
  dfl.FType := AType;
  dfl.FTime := ATime;
  dfl.FTypeStr := ATypeStr;
  dfl.FData := AData;
  dfl.FSubData := ASubData;
  dfl.Notify;
end;

{ TDebugFormRefresh }

procedure TDebugFormRefresh.DoSynchronize;
begin
  if IsDebugFormAssigned then
    frmDebug.RefreshStats(FRefreshItems);
end;

class procedure TDebugFormRefresh.Execute(const ARefreshItems: TDebugRefreshItemSet);
var
  dfr: TDebugFormRefresh;
begin
  dfr := TDebugFormRefresh.Create;
  try
    dfr.FRefreshItems := ARefreshItems;
    dfr.Synchronize;
  finally
    dfr.Free;
  end;
end;

initialization
  ActiveNotifyObjects := TObjectList<TIdNotify>.Create;

finalization
  FreeAndNil(ActiveNotifyObjects);

end.


