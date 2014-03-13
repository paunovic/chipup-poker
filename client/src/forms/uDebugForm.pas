unit uDebugForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  cxTextEdit, cxMemo, cxRichEdit, cxCheckBox, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus, cxButtons, Vcl.ActnList,
  Vcl.ComCtrls, Vcl.AppEvnts, cxSplitter, dxsChipUpDark, dxsChipUpDarkTabs, dxsChipUpRedButton, cxLabel;

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
    N1: TMenuItem;
    pmiLogWordWrap: TMenuItem;
    acWordWrap: TAction;
    pmiLogSave: TMenuItem;
    pmiLogClear: TMenuItem;
    N2: TMenuItem;
    btPause: TcxButton;
    lbsThreads: TcxLabel;
    lbsMemoryUsage: TcxLabel;
    lbsSocketState: TcxLabel;
    lbsCalbackSets: TcxLabel;
    lbvThreads: TcxLabel;
    lbvMemoryUsage: TcxLabel;
    lbvCallbackSets: TcxLabel;
    lbvSocketState: TcxLabel;
    reLog: TcxRichEdit;
    procedure FormCreate(Sender: TObject);
    procedure acClearLogExecute(Sender: TObject);
    procedure acSaveLogExecute(Sender: TObject);
    procedure acCopyLogSelectionExecute(Sender: TObject);
    procedure tiAppInfoRefreshTimer(Sender: TObject);
    procedure acWordWrapExecute(Sender: TObject);
  private
    procedure ActiveFormChange(Sender: TObject);
  protected
    procedure CreateParams(var AParams: TCreateParams); override;
  public
    class procedure Initialize;
    class procedure Deinitialize;
  end;

procedure DebugLn(const AData: String; const AType: TDebugInfoType);

implementation

{$R *.dfm}

uses
  uCommon, uSocketClient, uMainDataModule, uMessageContainer;


function AttachConsole(dwProcessID: Integer): Boolean; stdcall; external 'kernel32.dll';
function FreeConsole: Boolean; stdcall; external 'kernel32.dll';

var
  frmDebug: TfrmDebug;
  ConsoleAttached: Boolean;


procedure DebugLn(const AData: String; const AType: TDebugInfoType);
var
  time_str  : String;
  type_str  : String;
  type_color: TColor;
  logit     : Boolean;
  output    : String;
begin
  time_str := FormatDateTime('hh:nn:ss:zzz', Now);

  logit := TRUE;

  case AType of
    ditException: begin
      type_str := 'EXCP';
      type_color := clRed;
    end;
    ditApplication: begin
      type_str := 'APPL';
      type_color := clWhite;
    end;
    ditSocketInc: begin
      type_str := 'SINC';
      type_color := clLime;
    end;
    ditSocketOut: begin
      type_str := 'SOUT';
      type_color := clLime;
    end;
    ditSocket: begin
      type_str := 'SOCK';
      type_color := clLime;
    end;
    ditNetInc: begin
      type_str := 'NINC';
      type_color := clMoneyGreen;
    end;
    ditNetOut: begin
      type_str := 'NOUT';
      type_color := clMoneyGreen;
    end;
    ditForm: begin
      type_str := 'FORM';
      type_color := clGray;
    end
  else
    type_str := 'UNKN';
    type_color := clRed;
    logit := TRUE;
  end;

  if not logit then
    Exit;

  if (Assigned(frmDebug)) and
     (not frmDebug.btPause.Down) then
  begin
    frmDebug.reLog.SelStart := frmDebug.reLog.GetTextLen;
    frmDebug.reLog.SelAttributes.Color := type_color;
    output := Format('%s [%s] %s', [time_str, type_str, AData]);
    frmDebug.reLog.Lines.Add(output);

    SendMessage(frmDebug.reLog.Handle, WM_VSCROLL, SB_BOTTOM, 0);
  end;

  OutputDebugString(PChar(output));

  if ConsoleAttached then
    WriteLn(output);
end;



class procedure TfrmDebug.Initialize;
begin
  ConsoleAttached := AttachConsole(-1); // ATTACH_PARENT_PROCESS

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
  reLog.Clear;

  pmiLogWordWrap.Checked := TRUE;
  acWordWrap.Execute;

  Screen.OnActiveFormChange := ActiveFormChange;

  Width := Screen.Monitors[0].Width div 3;
  Height := Round(Screen.Monitors[0].Height / 2.5);
end;

procedure TfrmDebug.tiAppInfoRefreshTimer(Sender: TObject);
begin
  lbvThreads.Caption := Format('%d', [GetThreadsCount(GetCurrentProcessId)]);
  lbvMemoryUsage.Caption := Format('%dkb', [GetWorkingSetSize div 1024]);
  lbvCallbackSets.Caption := Format('%d', [MessageContainer.CallbackSetsCount]);
  lbvSocketState.Caption := Format('%d', [Integer(SocketClient.Socket.State)]);
end;

procedure TfrmDebug.CreateParams(var AParams: TCreateParams);
begin
  inherited;

  AParams.WndParent := 0;
end;

procedure TfrmDebug.acClearLogExecute(Sender: TObject);
begin
  reLog.Clear;
end;

procedure TfrmDebug.acCopyLogSelectionExecute(Sender: TObject);
begin
  reLog.CopyToClipboard;
end;

procedure TfrmDebug.acSaveLogExecute(Sender: TObject);
var
  plain_text: TStringList;
begin
  if SaveDialog.Execute(Handle) then
  begin
    case SaveDialog.FilterIndex of
      1: reLog.Lines.SaveToFile(ChangeFileExt(SaveDialog.FileName, '.rtf'));
      2: begin
        plain_text := TStringList.Create;
        try
          plain_text.Assign(reLog.Lines);
          plain_text.SaveToFile(ChangeFileExt(SaveDialog.FileName, '.txt'));
        finally
          plain_text.Free;
        end;
      end;
    end;
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

procedure TfrmDebug.acWordWrapExecute(Sender: TObject);
begin
  pmiLogWordWrap.Checked := not pmiLogWordWrap.Checked;
  reLog.Properties.WordWrap := pmiLogWordWrap.Checked;
  if reLog.Properties.WordWrap then
    reLog.Properties.ScrollBars := ssVertical
  else
    reLog.Properties.ScrollBars := ssBoth;
end;


end.


