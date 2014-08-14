
unit Poker.Forms.HandHistory;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Poker.Types, Vcl.Controls, Vcl.Forms, cxEdit, cxLabel, cxDropDownEdit,
  cxButtons, Vcl.ActnList, Poker.Interfaces.FormParams, System.Generics.Collections, RVScroll, RichView, RVStyle, Vcl.ExtCtrls, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, dxSkinsCore, ChipUpPokerDarkSkin, Vcl.Menus, Vcl.StdCtrls, cxTextEdit, cxMaskEdit;

type
  TfrmHandHistory = class(TForm, IFormParams)
    cbTable: TcxComboBox;
    lbsTable: TcxLabel;
    btCancel: TcxButton;
    alHandHistory: TActionList;
    acClose: TAction;
    cbHand: TcxComboBox;
    lbsHand: TcxLabel;
    rvHandHistory: TRichView;
    RVStyle: TRVStyle;
    btCopyToClipboard: TcxButton;
    acCopyToClipboard: TAction;
    tiCopyHideTimer: TTimer;
    btReplayHand: TcxButton;
    acReplayHand: TAction;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure acCloseExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cbTablePropertiesChange(Sender: TObject);
    procedure cbHandPropertiesChange(Sender: TObject);
    procedure acCopyToClipboardExecute(Sender: TObject);
    procedure tiCopyHideTimerTimer(Sender: TObject);
    procedure acReplayHandExecute(Sender: TObject);
  private
    FSelectedTableId: TMongoId;
    FSelectedHandId: UINT;
    FCallbacksId: Integer;

    procedure CSRHandHistoryMsg(const AMethodId: Integer; const AObject: TObject);

    procedure ShowHand;
    procedure AddRVLine(const ALine: String; const AParaStyle: Integer);
    procedure AddRVPart(const AString: String; const AStyleNo, AParaNo: Integer);
    function GetStyleNo(const ACommandChar: Char; const AColor: TColor; const AStyleNo: Integer): Integer;
    procedure RefreshTableList;
    procedure RefreshHandList;
  protected
    procedure CreateParams(var AParams: TCreateParams); override;
  public
    procedure SetParams(const AParams: array of pointer);

    procedure SetSelectedHandId(const AGameId: TMongoId; const AHandId: UINT);
  end;

implementation

{$R *.dfm}

uses
  Poker.Common.FormsContainer, Poker.HandHistory.Core, Poker.HandHistory.Items, Poker.Clubs.Club, Poker.Games.Game,
  Poker.Common.Misc, Poker.Server.MessageCallbacks, Poker.Server.MessageContainer, Poker.Protobufs.Enum.ServerCodes,
  Poker.Tables.TableList;

{ TfrmHandHistory }

procedure TfrmHandHistory.FormCreate(Sender: TObject);
begin
  FCallbacksId := MessageContainer.AddCallbacks([
                      TServerMessageCallback.Create(srHandHistoryMsg, CSRHandHistoryMsg)
                  ]);

  FSelectedHandId := 0;
  FSelectedHandId := 0;
end;

procedure TfrmHandHistory.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.Remove(self);
end;

procedure TfrmHandHistory.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    acClose.Execute;
end;

procedure TfrmHandHistory.CreateParams(var AParams: TCreateParams);
begin
  inherited;

  AParams.ExStyle := AParams.ExStyle or WS_EX_APPWINDOW;
  AParams.WndParent := 0;
end;

procedure TfrmHandHistory.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmHandHistory.acCloseExecute(Sender: TObject);
begin
  ModalResult := mrClose;
  Close;
end;

procedure TfrmHandHistory.SetParams(const AParams: array of pointer);
var
  game_id: TMongoId;
  handid: UINT;
begin
  if not Assigned(AParams[0]) then
    SetSelectedHandId(nil, 0)
  else
  begin
    game_id := AParams[0];
    handid := PUINT(AParams[1])^;
    SetSelectedHandId(game_id, handid);
  end;
end;

procedure TfrmHandHistory.SetSelectedHandId(const AGameId: TMongoId; const AHandId: UINT);
begin
  if AGameId = nil then
    FSelectedTableId.Clear
  else
    FSelectedTableId := AGameId;
  FSelectedHandId := AHandId;
  RefreshTableList;
  ShowHand;
end;

function TfrmHandHistory.GetStyleNo(const ACommandChar: Char; const AColor: TColor; const AStyleNo: Integer): Integer;
var
  fi: TFontInfo;
begin
  fi := TFontInfo.Create(nil);
  try
    fi.Assign(RVStyle.TextStyles[AStyleNo]);
    case ACommandChar of
      'b': fi.Style := fi.Style + [fsBold];
      'i': fi.Style := fi.Style + [fsItalic];
      'u': fi.Style := fi.Style + [fsUnderline];
      'c': fi.Color := AColor;
    end;
    result := RVStyle.TextStyles.FindSuchStyle(AStyleNo, fi, RVAllFontInfoProperties);
    if result < 0 then
    begin
      RVStyle.TextStyles.Add;
      result := RVStyle.TextStyles.Count - 1;
      RVStyle.TextStyles[result].Assign(fi);
      RVStyle.TextStyles[result].Standard := FALSE;
    end;
  finally
    fi.Free;
  end;
end;

procedure TfrmHandHistory.AddRVPart(const AString: String; const AStyleNo, AParaNo: Integer);
begin
  rvHandHistory.AddNL(AString, AStyleNo, AParaNo);
end;

procedure TfrmHandHistory.AddRVLine(const ALine: String; const AParaStyle: Integer);
var
  StyleNo: Integer;
  C1: Integer;
  part: String;
  line_len: Integer;
  start_index: Integer;
  ch: Char;
  color: TColor;
  code_found: Boolean;
  ParaNo: Integer;
begin
  StyleNo := 0;
  ParaNo := AParaStyle;
  part := '';
  line_len := Length(ALine);
  start_index := 1;
  C1 := 1;

  if line_len = 0 then
    rvHandHistory.AddNL('', StyleNo, ParaNo)
  else
  begin
    while C1 < line_len do
    begin
      code_found := FALSE;
      while (ALine[C1] = '\') and
            (C1 < line_len) do
      begin
        part := Copy(ALine, start_index, C1 - start_index);
        if part <> '' then
        begin
          AddRVPart(part, StyleNo, ParaNo);
          StyleNo := 0;
          ParaNo := -1;
        end;

        code_found := TRUE;
        Inc(C1);
        ch := ALine[C1];
        case ch of
          'b', 'i', 'u': begin
            StyleNo := GetStyleNo(ch, clNone, StyleNo);
          end;
          'c': if C1 < line_len - 5 then
          begin
            color := RGB(StrToInt('$' + Copy(ALine, C1 + 1, 2)),
                         StrToInt('$' + Copy(ALine, C1 + 3, 2)),
                         StrToInt('$' + Copy(ALine, C1 + 5, 2)));
            StyleNo := GetStyleNo(ch, color, StyleNo);
            Inc(C1, 6);
          end;
        end;
        Inc(C1);
        start_index := C1;
      end;

      if not code_found then
        Inc(C1);
    end;

    part := Copy(ALine, start_index, C1 - start_index + 1);
    if part <> '' then
      AddRVPart(part, StyleNo, ParaNo);
  end;

  rvHandHistory.FormatTail;
end;

procedure TfrmHandHistory.RefreshTableList;
var
  item_index: Integer;
  table_name: String;
  hhis: THandHistoryItems;
  C1: Integer;
begin
  item_index := -1;
  cbTable.Properties.BeginUpdate;
  try
    C1 := 0;
    for hhis in HandHistory.Values do
    begin
      table_name := Format('%s (%d-max) - %s', [hhis.Game.Gamename, hhis.Game.Seats, hhis.Club.Name]);
      if C1 >= cbTable.Properties.Items.Count then
        cbTable.Properties.Items.Add(table_name)
      else
        if cbTable.Properties.Items[C1] <> table_name then
          cbTable.Properties.Items[C1] := table_name;
      if FSelectedTableId = hhis.FGameId then
        item_index := C1;
      Inc(C1);
    end;

    while cbTable.Properties.Items.Count > HandHistory.Count do
      cbTable.Properties.Items.Delete(cbTable.Properties.Items.Count - 1);

    cbTable.ItemIndex := item_index;
  finally
    cbTable.Properties.EndUpdate(TRUE);
  end;
end;

procedure TfrmHandHistory.RefreshHandList;
var
  hhis: THandHistoryItems;
  hhi: THandHistoryItem;
  hand_name: String;
  C1: Integer;
  item_index: Integer;
begin
  if not HandHistory.TryGetValue(FSelectedTableId, hhis) then
  begin
    cbHand.ItemIndex := -1;
    cbHand.Properties.Items.Clear;
    Exit;
  end;

  item_index := -1;
  cbHand.Properties.BeginUpdate;
  try
    C1 := 0;
    for hhi in hhis do
    begin
      hand_name := Format('#%d: %s (%s/%s) - %s', [hhi.HandId, TGameInfo.GameTypeToStr(hhi.CurrentGame, hhis.Game.GameLimit, FALSE),
         ChipsToStr(hhis.Game.SmallBlind), ChipsToStr(hhis.Game.BigBlind), hhi.StartTimeStr]);

      if C1 >= cbHand.Properties.Items.Count then
        cbHand.Properties.Items.Add(hand_name)
      else
        if cbHand.Properties.Items[C1] <> hand_name then
          cbHand.Properties.Items[C1] := hand_name;

      if hhi.HandId = FSelectedHandId then
        item_index := C1;

      Inc(C1);
    end;

    while cbHand.Properties.Items.Count > hhis.Count do
      cbHand.Properties.Items.Delete(cbHand.Properties.Items.Count - 1);

    if (item_index = -1) and
       (cbHand.Properties.Items.Count > 0) then
      item_index := cbHand.Properties.Items.Count - 1;

    cbHand.ItemIndex := item_index;
  finally
    cbHand.Properties.EndUpdate(TRUE);
  end;
end;

procedure TfrmHandHistory.ShowHand;
var
  hhi: THandHistoryItem;
  C1: Integer;
  hand_id: UINT;
  item_index: Integer;
  hhis: THandHistoryItems;
begin
  rvHandHistory.ClearAll;
  acCopyToClipboard.Enabled := FALSE;
  acReplayHand.Enabled := FALSE;

  HandHistory.Lock;
  try
    if not HandHistory.TryGetValue(FSelectedTableId, hhis) then
      Exit;

    if hhis.GetAndLockHand(FSelectedHandId, hhi) then
    try
      // select appropriate hand in combobox
      item_index := cbHand.Properties.Items.Count - 1;
      for C1 := 0 to cbHand.Properties.Items.Count - 1 do
      begin
        hand_id := StrToIntDef(Copy(cbHand.Properties.Items[C1], 2, Pos(':', cbHand.Properties.Items[C1]) - 2), -1);
        if hand_id = FSelectedHandId then
        begin
          item_index := C1;
          Break;
        end;
      end;
      cbHand.ItemIndex := item_index;

      if hhi.RVLines.Count = 0 then
        hhi.MakeLines;

      // add first two lines with ParaNo = 1, so they're centered
      // a bit dirty fix, ideally there should be \p%d parameter
      for C1 := 0 to hhi.RVLines.Count - 1 do
        if C1 < 2 then
          AddRVLine(hhi.RVLines[C1], 1)
        else
          AddRVLine(hhi.RVLines[C1], 0);

      rvHandHistory.ScrollTo(0);

      acCopyToClipboard.Enabled := TRUE;
      acReplayHand.Enabled := TRUE;
    finally
      hhis.Unlock;
    end;
  finally
    HandHistory.Unlock;
  end;
end;

procedure TfrmHandHistory.tiCopyHideTimerTimer(Sender: TObject);
begin
  btCopyToClipboard.Caption := acCopyToClipboard.Caption;
  acCopyToClipboard.Enabled := TRUE;
  tiCopyHideTimer.Enabled := FALSE;
end;

procedure TfrmHandHistory.cbHandPropertiesChange(Sender: TObject);
var
  hand_id: UINT;
begin
  if cbHand.ItemIndex = -1 then
    hand_id := 0
  else
    hand_id := StrToIntDef(Copy(cbHand.Properties.Items[cbHand.ItemIndex], 2, Pos(':', cbHand.Properties.Items[cbHand.ItemIndex]) - 2), 0);

  FSelectedHandId := hand_id;
  ShowHand;
end;

procedure TfrmHandHistory.cbTablePropertiesChange(Sender: TObject);
begin
  if cbTable.ItemIndex = -1 then
    FSelectedTableId.Clear
  else
    FSelectedTableId := HandHistory.Keys.ToArray[cbTable.ItemIndex];

  RefreshHandList;
end;

procedure TfrmHandHistory.acCopyToClipboardExecute(Sender: TObject);
begin
  rvHandHistory.SelectAll;
  rvHandHistory.CopyText;
  acCopyToClipboard.Enabled := FALSE;
  btCopyToClipboard.Caption := 'COPIED';
  tiCopyHideTimer.Enabled := TRUE;
end;

procedure TfrmHandHistory.acReplayHandExecute(Sender: TObject);
begin
  Tables.AddHandPlaybackTable(FSelectedTableId, FSelectedHandId);
end;

procedure TfrmHandHistory.CSRHandHistoryMsg(const AMethodId: Integer; const AObject: TObject);
begin
  RefreshTableList;
  RefreshHandList;
end;


end.
