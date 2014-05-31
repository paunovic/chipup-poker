unit Poker.Forms.HandHistory;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  ChipUpPokerDarkSkin, cxLabel, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxMemo, Vcl.Menus, Vcl.StdCtrls, cxButtons, Vcl.ActnList,
  Poker.Interfaces.FormParams, System.Generics.Collections, RVScroll, RichView, RVStyle;

type
  TTableItem = class
  private
    FClubId: TBytes;
    FGameId: TBytes;
    FHands: TList<UINT>;
  public
    constructor Create(const AClubId, AGameId: TBytes);
    destructor Destroy; override;

    function Matches(const ATableItem: TTableItem): Boolean;
    procedure UpdateHands;

    property ClubId: TBytes read FClubId;
    property GameId: TBytes read FGameId;
    property Hands: TList<UINT> read FHands;
  end;

  TTableItems = class(TObjectList<TTableItem>)
  public
    function ContainsGameId(const AGameId: TBytes): Boolean;
    function IndexOfGameId(const AGameId: TBytes): Integer;
  end;

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
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure acCloseExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cbTablePropertiesChange(Sender: TObject);
    procedure cbHandPropertiesChange(Sender: TObject);
  private
    FSelectedHandId: UINT;
    FCallbacksId: Integer;
    FTables: TTableItems;

    procedure CSRHandHistoryMsg(const AMethodId: Integer; const AObject: TObject);

    procedure ShowHand;
    procedure AddRVLine(const ALine: String; const AParaStyle: Integer);
    procedure AddRVPart(const AString: String; const AStyleNo, AParaNo: Integer);
    function GetStyleNo(const ACommandChar: Char; const AColor: TColor; const AStyleNo: Integer): Integer;
    procedure SelectTableFromHandId;
    procedure RefreshTableList;
    procedure RefreshHandList;
  protected
    procedure CreateParams(var AParams: TCreateParams); override;
  public
    procedure SetParams(const AParams: array of pointer);
  end;

implementation

{$R *.dfm}

uses
  Poker.Common.FormsContainer, Poker.HandHistory.Core, Poker.HandHistory.HandHistoryItem, Poker.Objects.ClubInfo, Poker.Objects.GameInfo,
  Poker.DataModule, Poker.Common.Misc, Poker.Server.MessageCallbacks, Poker.Server.MessageContainer, Poker.Protobufs.Enum.ServerCodes;


procedure TfrmHandHistory.FormCreate(Sender: TObject);
begin
  FTables := TTableItems.Create;

  FCallbacksId := MessageContainer.AddCallbacks([
                      TServerMessageCallback.Create(srHandHistoryMsg, CSRHandHistoryMsg)
                  ]);

  FSelectedHandId := 0;
end;

procedure TfrmHandHistory.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FTables.Free;
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

procedure TfrmHandHistory.SelectTableFromHandId;
var
  hhi: THandHistoryItem;
  item_index: Integer;
begin
  if HandHistory.Find(FSelectedHandId, hhi) then
  begin
    item_index := FTables.IndexOfGameId(hhi.GameId);
    cbTable.ItemIndex := item_index;
  end;
end;

procedure TfrmHandHistory.SetParams(const AParams: array of pointer);
begin
  if not Assigned(AParams[0]) then
    FSelectedHandId := 0
  else
    FSelectedHandId := PUINT(AParams[0])^;

  RefreshTableList;
  SelectTableFromHandId;
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

procedure TfrmHandHistory.CSRHandHistoryMsg(const AMethodId: Integer; const AObject: TObject);
begin
  RefreshTableList;
  SelectTableFromHandId;
  RefreshHandList;
end;

procedure TfrmHandHistory.RefreshHandList;
var
  C1: Integer;
  table_item: TTableItem;
  hand_name: String;
  hhi: THandHistoryItem;
begin
  if cbTable.ItemIndex = -1 then
  begin
    cbHand.ItemIndex := -1;
    cbHand.Properties.Items.Clear;
    Exit;
  end;

  table_item := FTables.Items[cbTable.ItemIndex];
  for C1 := 0 to table_item.Hands.Count - 1 do
    if HandHistory.Find(table_item.Hands[C1], hhi) then
    begin
      hand_name := Format('#%d: %s (%s/%s) - %s', [hhi.HandId, TGameInfo.GameTypeToStr(hhi.CurrentGame, hhi.Game.Limit, FALSE),
         ChipsToStr(hhi.Game.SmallBlind), ChipsToStr(hhi.Game.BigBlind), hhi.StartTimeStr]);

      if C1 >= cbHand.Properties.Items.Count then
        cbHand.Properties.Items.Add(hand_name)
      else
        if cbHand.Properties.Items[C1] <> hand_name then
          cbHand.Properties.Items[C1] := hand_name;
    end;

  while cbHand.Properties.Items.Count > table_item.Hands.Count do
    cbHand.Properties.Items.Delete(cbHand.Properties.Items.Count - 1);

  if (cbHand.ItemIndex = -1) and
     (cbHand.Properties.Items.Count > 0) then
    cbHand.ItemIndex := cbHand.Properties.Items.Count - 1;
end;

procedure TfrmHandHistory.RefreshTableList;
var
  hhi: THandHistoryItem;
  tables: TTableItems;
  C1, C2: Integer;
  selected_game: TBytes;
  table_name: String;
  club: TClubInfo;
  game: TGameInfo;
begin
  // save selected table combobox
  SetLength(selected_game, 0);
  if cbTable.ItemIndex > -1 then
    selected_game := FTables[cbTable.ItemIndex].GameId;

  tables := TTableItems.Create;
  try
    // populate new list with tables
    for hhi in HandHistory.Items do
      if not tables.ContainsGameId(hhi.GameId) then
        tables.Add(TTableItem.Create(hhi.ClubId, hhi.GameId));

    // start comparing elements in both lists, break once mismatch is found
    C1 := 0;
    while (C1 < FTables.Count) and
          (C1 < tables.Count) and
          (FTables[C1].Matches(tables[C1])) do
    begin
      FTables[C1].UpdateHands;
      Inc(C1);
    end;

    // if there are leftover elements that have to be processed
    if C1 < tables.Count then
    begin
      // delete leftover elements in real list first
      if C1 < FTables.Count then
        FTables.DeleteRange(C1, FTables.Count - C1);

      // add new leftover elements to real list
      for C2 := C1 to tables.Count - 1 do
      begin
        FTables.Add(TTableItem.Create(tables[C2].ClubId, tables[C2].GameId));
        FTables.Last.UpdateHands;
      end;

      // add tables to combobox
      for C2 := C1 to FTables.Count - 1 do
      begin
        table_name := 'Unknown Table';
        club := nil;
        game := nil;
        for hhi in HandHistory.Items do
          if CompareBytes(hhi.GameId, FTables[C1].GameId) then
          begin
            club := hhi.Club;
            game := hhi.Game;
            Break;
          end;

        if (Assigned(club)) and (Assigned(Game)) then
          table_name := Format('%s (%d-max) - %s', [game.Name, game.Seats, club.Name]);

        if C2 >= cbTable.Properties.Items.Count then
          cbTable.Properties.Items.Add(table_name)
        else
          if cbTable.Properties.Items[C2] <> table_name then
            cbTable.Properties.Items[C2] := table_name;
      end;
    end;
  finally
    tables.Free;
  end;

  // restore selected table combobox item index
  if Length(selected_game) > 0 then
    cbTable.ItemIndex := FTables.IndexOfGameId(selected_game);
end;

procedure TfrmHandHistory.ShowHand;
var
  hhi: THandHistoryItem;
  C1: Integer;
  hand_id: UINT;
  item_index: Integer;
begin
  rvHandHistory.ClearAll;
  if not HandHistory.Find(FSelectedHandId, hhi) then
    Exit;

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

  // add first two lines with ParaNo = 1, so they're centered
  // a bit dirty fix, ideally there should be \p%d parameter
  for C1 := 0 to hhi.RVLines.Count - 1 do
    if C1 < 2 then
      AddRVLine(hhi.RVLines[C1], 1)
    else
      AddRVLine(hhi.RVLines[C1], 0);

  rvHandHistory.ScrollTo(0);
end;

procedure TfrmHandHistory.cbHandPropertiesChange(Sender: TObject);
var
  hand_id: UINT;
begin
  hand_id := 0;
  if cbHand.ItemIndex > -1 then
    hand_id := StrToIntDef(Copy(cbHand.Properties.Items[cbHand.ItemIndex], 2, Pos(':', cbHand.Properties.Items[cbHand.ItemIndex]) - 2), 0);
  FSelectedHandId := hand_id;
  ShowHand;
end;

procedure TfrmHandHistory.cbTablePropertiesChange(Sender: TObject);
begin
  RefreshHandList;
end;



{ TTableItem }

constructor TTableItem.Create(const AClubId, AGameId: TBytes);
begin
  FClubId := AClubId;
  FGameId := AGameId;

  FHands := TList<UINT>.Create;
end;

destructor TTableItem.Destroy;
begin
  FHands.Free;
  inherited;
end;

function TTableItem.Matches(const ATableItem: TTableItem): Boolean;
begin
  result := (CompareBytes(ATableItem.ClubId, FClubId)) and
            (CompareBytes(ATableItem.GameId, FGameId));
end;

procedure TTableItem.UpdateHands;
var
  hhi: THandHistoryItem;
begin
  FHands.Clear;
  for hhi in HandHistory.Items do
    if CompareBytes(hhi.GameId, FGameId) then
      FHands.Add(hhi.HandId);
end;

{ TTableItems }

function TTableItems.ContainsGameId(const AGameId: TBytes): Boolean;
var
  item: TTableItem;
begin
  for item in ToArray do
    if CompareBytes(item.GameId, AGameId) then
      Exit(TRUE);
  Exit(FALSE);
end;

function TTableItems.IndexOfGameId(const AGameId: TBytes): Integer;
var
  C1: Integer;
begin
  for C1 := 0 to Length(ToArray) - 1 do
    if CompareBytes(ToArray[C1].GameId, AGameId) then
      Exit(C1);
  Exit(-1);
end;

end.
