unit Poker.Forms.Debug;

{$I defines.inc}

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxContainer, cxEdit,
  cxMemo, Vcl.ExtCtrls, Vcl.Menus, cxButtons, Vcl.ActnList, IdSync,
  cxLabel, RVScroll, RichView, RVStyle, RVTable, CRVData, dxBevel, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  dxSkinsCore, ChipUpPokerDarkSkin, Vcl.StdCtrls, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxCheckComboBox;

type
  TDebugInfoType = (ditException = 0, ditApplication, ditSocket, ditSocketInc, ditSocketOut, ditNetInc, ditNetOut, ditForm, ditPingPong, ditUnknown);
  TDebugRefreshItem = (dfiSystemMetrics, dfiSocketState, dfiLatency, dfiCallbacks, dfiSwapChains);
  TDebugRefreshItemSet = set of TDebugRefreshItem;

  TDebugObject = class
    Enabled: Boolean;
    Id: Integer;
    Name: String;
  end;

  TDebugFormLog = class(TIdSync)
  private
    FDebugId: Integer;
    FType: TDebugInfoType;
    FTime: String;
    FTypeStr: String;
    FData: String;
    FSubData: String;
    FTypeStyle: Integer;
    FDataStyle: Integer;
  protected
    procedure DoSynchronize; override;
  public
    class procedure Add(const ADebugId: Integer; const AType: TDebugInfoType; const ATime, ATypeStr, AData, ASubData: String; const ATypeStyle, ADataStyle: Integer);
  end;

  TDebugFormRefresh = class(TIdSync)
  private
    FRefreshItems: TDebugRefreshItemSet;
  protected
    procedure DoSynchronize; override;
  public
    class procedure Execute(const ARefreshItems: TDebugRefreshItemSet);
  end;

  TDebugFormObjectChange = class(TIdSync)
  protected
    procedure DoSynchronize; override;
  public
    class procedure Execute;
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
    dxBevel2: TdxBevel;
    lbsThreads: TcxLabel;
    lbsMemoryUsage: TcxLabel;
    lbsSocketState: TcxLabel;
    lbsCalbackSets: TcxLabel;
    lbvThreads: TcxLabel;
    lbvMemoryUsage: TcxLabel;
    lbvCallbackSets: TcxLabel;
    lbvSocketState: TcxLabel;
    btSeatPos: TcxButton;
    btPause: TcxButton;
    lbsLatency: TcxLabel;
    lbvLatency: TcxLabel;
    btRunAnotherInstance: TcxButton;
    acRunNewInstance: TAction;
    btServerTest: TcxButton;
    acServerCrashTest: TAction;
    pmiShowPings: TMenuItem;
    lbsSwapChains: TcxLabel;
    lbvSwapChains: TcxLabel;
    dxBevel3: TdxBevel;
    ccbLogForms: TcxCheckComboBox;
    procedure FormCreate(Sender: TObject);
    procedure acClearLogExecute(Sender: TObject);
    procedure acSaveLogExecute(Sender: TObject);
    procedure acCopyLogSelectionExecute(Sender: TObject);
    procedure tiAppInfoRefreshTimer(Sender: TObject);
    procedure btSeatPosClick(Sender: TObject);
    procedure rvLogRVMouseUp(Sender: TCustomRichView; Button: TMouseButton; Shift: TShiftState; ItemNo, X, Y: Integer);
    procedure acServerCrashTestExecute(Sender: TObject);
    procedure acRunNewInstanceExecute(Sender: TObject);
    procedure meSeatPosPropertiesChange(Sender: TObject);
    procedure ccbLogFormsPropertiesChange(Sender: TObject);
  private
  protected
    procedure CreateParams(var AParams: TCreateParams); override;
  public
    class procedure Initialize;
    class procedure Deinitialize;

    procedure Add(const ADebugId: Integer; const AType: TDebugInfoType; const ATime, ATypeStr, AData, ASubData: String; const ATypeStyle, ADataStyle: Integer);
    procedure RefreshStats(const ARefreshItems: TDebugRefreshItemSet);
    procedure RefreshDebugObjects;
  end;

  procedure DebugLn(const ADebugId: Integer; const AData: String; const AType: TDebugInfoType; const ASubData: String = '');
  procedure RefreshDebugForm(const ARefreshItems: TDebugRefreshItemSet);

  function RegisterDebugObject(const AName: String): Integer;
  procedure UnregisterDebugObject(const AId: Integer);

implementation

{$R *.dfm}

uses
  {$IFDEF SEAT_POSITIONS_CONFIGURATOR}
  JclExprEval, Poker.Table.Resources,
  {$ENDIF}
  Poker.Common.InstanceController, RVItem, Poker.Common.Misc, Poker.Server.Socket.Commands, Poker.Server.MessageContainer, OverbyteIcsWSocket,
  System.Generics.Collections, Poker.DirectX.Core;


function AttachConsole(dwProcessID: Integer): Boolean; stdcall; external 'kernel32.dll';
function FreeConsole: Boolean; stdcall; external 'kernel32.dll';

var
  frmDebug: TfrmDebug;
  DebugFilePath: String = '';
  ConsoleAttached: Boolean = FALSE;
  FDebugObjects: TObjectList<TDebugObject>;

  
function RegisterDebugObject(const AName: String): Integer;
var
  id: Integer;
  found: Boolean;
  debug_object: TDebugObject;
  enabled: Boolean;
begin
  id := 0;
  repeat
    Inc(id);
    found := FALSE;
    for debug_object in FDebugObjects do
      if debug_object.Id = id then
      begin
        found := TRUE;
        Break;
      end;
  until not found;

  enabled := TRUE;
  for debug_object in FDebugObjects do
    if not debug_object.Enabled then
    begin
      enabled := FALSE;
      Break;
    end;

  debug_object := TDebugObject.Create;
  debug_object.Id := id;
  debug_object.Name := AName;
  debug_object.Enabled := enabled;
  FDebugObjects.Add(debug_object);

  TDebugFormObjectChange.Execute;

  result := id;
end;

procedure UnregisterDebugObject(const AId: Integer);
var 
  C1: Integer;
begin
  for C1 := FDebugObjects.Count - 1 downto 0 do
    if FDebugObjects[C1].Id = AId then
      FDebugObjects.Delete(C1);

  TDebugFormObjectChange.Execute;
end;


procedure DebugLn(const ADebugId: Integer; const AData: String; const AType: TDebugInfoType; const ASubData: String = '');
var
  time_str: String;
  type_str: String;
  tstyle: Integer;
  dstyle: Integer;
  output: String;
  fstream: TFileStream;
  fwriter: TStreamWriter;
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
    end;
    ditPingPong: begin
      type_str := 'PING';
      tstyle := 3;
      dstyle := 9;
    end;
  else
    type_str := 'UNKN';
    tstyle := 6;
    dstyle := 12;
  end;

  if Assigned(frmDebug) then
    TDebugFormLog.Add(ADebugId, AType, time_str, type_str, AData, ASubData, tstyle, dstyle);

  output := Format('%s [%s] %s', [time_str, type_str, AData]);

  OutputDebugString(PChar(output));

  if ConsoleAttached then
    WriteLn(output);

  // do NOT use SelfPath variable here, because this function can be called before SelfPath is initialized!
  if DebugFilePath = '' then
    DebugFilePath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + Format('debug\%s [%d].txt', [FormatDateTime('dd-mm-yyyy hh-nn-ss', Now), GetCurrentProcessId]);

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
  if Assigned(frmDebug) then
    TDebugFormRefresh.Execute(ARefreshItems);
end;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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

  Left := 0;
  Top := 0;
  Width := Round(Screen.Monitors[0].Width / 2.9);
  Height := Round(Screen.Monitors[0].Height / 2.6);

  {$IFDEF SEAT_POSITIONS_CONFIGURATOR}
  btSeatPos.Visible := TRUE;
  {$ENDIF}
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

procedure TfrmDebug.acRunNewInstanceExecute(Sender: TObject);
begin
  TInstanceController.UnregisterInstance;
  ShellOpen(PChar(ParamStr(0)), nil, PChar(ParamStr(1)));
end;

procedure TfrmDebug.acSaveLogExecute(Sender: TObject);
begin
  if SaveDialog.Execute(Handle) then
    case SaveDialog.FilterIndex of
      1: rvLog.SaveRTF(ChangeFileExt(SaveDialog.FileName, '.rtf'), FALSE);
      2: rvLog.SaveText(ChangeFileExt(SaveDialog.FileName, '.txt'), 0);
    end;
end;

procedure TfrmDebug.acServerCrashTestExecute(Sender: TObject);
begin
  {$IFDEF DEBUG}
  ServerSocket.CrashTest;
  {$ENDIF}
end;

procedure TfrmDebug.Add(const ADebugId: Integer; const AType: TDebugInfoType; const ATime, ATypeStr, AData, ASubData: String; const ATypeStyle, ADataStyle: Integer);
const
  SCROLLBACK_LINES = 500;
var
  table: TRVTableItemInfo;
  sl: TStringList;
  C1: Integer;
  debug_object: TDebugObject;
begin
  if btPause.Down then
    Exit;

  if (AType = ditPingPong) and
     (not pmiShowPings.Checked) then
    Exit;

  debug_object := nil;
  for C1 := 0 to FDebugObjects.Count - 1 do
    if FDebugObjects[C1].Id = ADebugId then
    begin
      debug_object := FDebugObjects[C1];
      Break;
    end;

  if (ADebugId > 0) and
     ((not Assigned(debug_object)) or
      (not debug_object.Enabled)) then
    Exit;

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

    Cells[0, 0].BestWidth := 75;
    Cells[0, 1].BestWidth := 40;
    Cells[0, 2].BestWidth := 10;

    Cells[0, 0].Clear;
    Cells[0, 1].Clear;
    Cells[0, 2].Clear;
    Cells[0, 3].Clear;

    Cells[0, 0].AddFmt('%s', [ATime], 0, 0);
    Cells[0, 1].AddFmt('%s', [ATypeStr], ATypeStyle, 1);
    if ASubData <> '' then
      Cells[0, 2].AddFmt('+', [], 13, 1)
    else
      Cells[0, 2].AddFmt('', [], 13, 1);
    Cells[0, 3].AddFmt('%s', [AData], ADataStyle, 2);
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
          Cells[0, 3].AddFmt('%s', [sl[C1]], 13, 2);
      finally
        sl.Free;
      end;
    end;
    rvLog.AddItem('', table);
    rvLog.SetItemExtraIntProperty(rvLog.ItemCount - 1, rvepHidden, 1);
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

procedure TfrmDebug.ccbLogFormsPropertiesChange(Sender: TObject);
var
  C1: Integer;
  debug_object: TDebugObject;
begin
  for C1 := 0 to ccbLogForms.Properties.Items.Count - 1 do
    for debug_object in FDebugObjects do
      if ccbLogForms.Properties.Items[C1].Tag = debug_object.Id then
        debug_object.Enabled := ccbLogForms.States[C1] = cbsChecked;
end;

procedure TfrmDebug.meSeatPosPropertiesChange(Sender: TObject);
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

procedure TfrmDebug.RefreshDebugObjects;
var
  C1: Integer;
  ccbi: TcxCheckComboBoxItem;
begin
  for C1 := 0 to FDebugObjects.Count - 1 do
    if (ccbLogForms.Properties.Items.Count <= C1) or
       (FDebugObjects[C1].Id <> ccbLogForms.Properties.Items[C1].Tag) then
    begin
      while ccbLogForms.Properties.Items.Count > C1 do
        ccbLogForms.Properties.Items.Delete(ccbLogForms.Properties.Items.Count - 1);
      Break;
    end;

  for C1 := ccbLogForms.Properties.Items.Count to FDebugObjects.Count - 1 do
  begin
    ccbi := ccbLogForms.Properties.Items.Add;
    ccbi.Tag := FDebugObjects[C1].Id;
    ccbi.Description := FDebugObjects[C1].Name;
    if FDebugObjects[C1].Enabled then
      ccbLogForms.States[ccbi.Index] := cbsChecked;
  end;

  while ccbLogForms.Properties.Items.Count > FDebugObjects.Count do
    ccbLogForms.Properties.Items.Delete(ccbLogForms.Properties.Items.Count - 1);

  ccbLogForms.Refresh;
end;

procedure TfrmDebug.RefreshStats(const ARefreshItems: TDebugRefreshItemSet);
var
  server_socket_connected: Boolean;
  server_socket_state: String;
  server_socket_state_color: TColor;
  swap_chains_occupied: Integer;
  C1: Integer;
  refresh_items: TDebugRefreshItemSet;
  dfi: TDebugRefreshItem;
begin
  refresh_items := ARefreshItems;
  if refresh_items = [] then
    for dfi := Low(TDebugRefreshItem) to High(TDebugRefreshItem) do
      Include(refresh_items, dfi);

  if dfiSystemMetrics in refresh_items then
  begin
    lbvThreads.Caption := Format('%d', [GetThreadsCount(GetCurrentProcessId)]);
    lbvMemoryUsage.Caption := Format('%.2fmb', [GetWorkingSetSize / (1024 * 1024)]);
  end;

  if dfiCallbacks in refresh_items then
    lbvCallbackSets.Caption := Format('%d', [MessageContainer.CallbackSetsCount]);

  if (dfiSocketState in refresh_items) or
     (dfiLatency in refresh_items) then
  begin
    server_socket_connected := FALSE;
    server_socket_state_color := clWhite;
    if Assigned(ServerSocket) then
    begin
      case ServerSocket.Socket.State of
        wsInvalidState: server_socket_state := 'Invalid state';
        wsOpened: server_socket_state := 'Opened';
        wsBound: server_socket_state := 'Bound';
        wsConnecting: server_socket_state := 'Connecting';
        wsSocksConnected: server_socket_state := 'Socks connected';
        wsConnected: begin
          server_socket_connected := TRUE;
          server_socket_state := 'Connected';
          server_socket_state_color := clLime;
        end;
        wsAccepting: server_socket_state := 'Accepting';
        wsListening: server_socket_state := 'Listening';
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

    if dfiSocketState in refresh_items then
    begin
      lbvSocketState.Caption := server_socket_state;
      lbvSocketState.Style.TextColor := server_socket_state_color;
    end;

    if dfiLatency in refresh_items then
    begin
      if (server_socket_connected) and
         (Assigned(ServerSocket)) and
         (ServerSocket.Latency > 0) then
      begin
        lbvLatency.Caption := Format('%dms', [ServerSocket.Latency]);
        if ServerSocket.IsPinging then
          lbvLatency.Caption := lbvLatency.Caption + ' ...';
        if ServerSocket.Latency < 100 then
          lbvLatency.Style.TextColor := clLime
        else
          if ServerSocket.Latency < 500 then
            lbvLatency.Style.TextColor := clYellow
          else
            lbvLatency.Style.TextColor := clRed;
      end
      else
      begin
        lbvLatency.Caption := 'Unknown';
        lbvLatency.Style.TextColor := clWhite;
      end;
    end;
  end;

  if dfiSwapChains in refresh_items then
  begin
    if (Assigned(DXCore)) and
       (Assigned(DXCore.Device)) then
    begin
      swap_chains_occupied := 0;
      for C1 := 1 to DXCore.Device.SwapChains.Count - 1 do
        if DXCore.Device.SwapChains[C1].WindowHandle <> DXCore.DummyWindow then
          Inc(swap_chains_occupied);
      lbvSwapChains.Caption := Format('%d/%d', [swap_chains_occupied, DXCore.Device.SwapChains.Count - 1]);
    end
    else
      lbvSwapChains.Caption := 'Unknown';
  end;
end;

{ TMemoLog }

class procedure TDebugFormLog.Add(const ADebugId: Integer; const AType: TDebugInfoType; const ATime, ATypeStr, AData, ASubData: String; const ATypeStyle, ADataStyle: Integer);
var
  dfl: TDebugFormLog;
begin
  dfl := TDebugFormLog.Create;
  try
    dfl.FDebugId := ADebugId;
    dfl.FType := AType;
    dfl.FTime := ATime;
    dfl.FTypeStr := ATypeStr;
    dfl.FData := AData;
    dfl.FSubData := ASubData;
    dfl.FTypeStyle := ATypeStyle;
    dfl.FDataStyle := ADataStyle;
    dfl.Synchronize;
  finally
    dfl.Free;
  end;
end;

procedure TDebugFormLog.DoSynchronize;
begin
  frmDebug.Add(FDebugId, FType, FTime, FTypeStr, FData, FSubData, FTypeStyle, FDataStyle);
end;

{ TDebugFormRefresh }

procedure TDebugFormRefresh.DoSynchronize;
begin
  inherited;
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

{ TDebugFormObjectChange }

procedure TDebugFormObjectChange.DoSynchronize;
begin
  inherited;
  frmDebug.RefreshDebugObjects;
end;

class procedure TDebugFormObjectChange.Execute;
var
  dfoc: TDebugFormObjectChange;
begin
  dfoc := TDebugFormObjectChange.Create;
  try
    dfoc.Synchronize;
  finally
    dfoc.Free;
  end;
end;

initialization
  FDebugObjects := TObjectList<TDebugObject>.Create;

finalization
  FreeAndNil(FDebugObjects);

end.

