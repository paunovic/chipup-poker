unit Poker.Forms.TournamentLobby;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Poker.Interfaces.FormParams,
  Poker.Types, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles,
  dxSkinsCore, dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxBlobEdit, cxTextEdit, cxSpinEdit, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxClasses, cxGridCustomView, cxGrid, cxCurrencyEdit, Vcl.Menus, Vcl.ActnList,
  Vcl.StdCtrls, cxButtons, ChipUpPokerDarkSkin, cxContainer, dxGDIPlusClasses, cxImage,
  cxLabel, Vcl.ExtCtrls, dxBevel, cxNavigator, System.Actions;

type
  TfrmTournamentLobby = class(TForm, IFormParams)
    gridPlayers: TcxGrid;
    gridPlayersTable: TcxGridTableView;
    gridPlayersMongoId: TcxGridColumn;
    gridPlayersName: TcxGridColumn;
    gridPlayersLevel: TcxGridLevel;
    gridPlayersChips: TcxGridColumn;
    StyleRepository: TcxStyleRepository;
    stylePlayersSelf: TcxStyle;
    stylePlayersOther: TcxStyle;
    alTournamentLobby: TActionList;
    acRegister: TAction;
    acUnregister: TAction;
    gridTables: TcxGrid;
    gridTablesTable: TcxGridTableView;
    gridTablesId: TcxGridColumn;
    gridTablesName: TcxGridColumn;
    gridTablesPlayers: TcxGridColumn;
    gridTablesLevel: TcxGridLevel;
    paHeader: TPanel;
    btTournamentRegister: TcxButton;
    lbvHeader: TcxLabel;
    gridTablesSmallestStack: TcxGridColumn;
    gridTablesAverageStack: TcxGridColumn;
    gridTablesLargestStack: TcxGridColumn;
    gridAllPlayers: TcxGrid;
    gridAllPlayersTable: TcxGridTableView;
    gridAllPlayersId: TcxGridColumn;
    gridAllPlayersName: TcxGridColumn;
    gridAllPlayersChips: TcxGridColumn;
    gridAllPlayersLevel: TcxGridLevel;
    gridBlinds: TcxGrid;
    gridBlindsTable: TcxGridTableView;
    gridBlindsTLevel: TcxGridColumn;
    gridBlindsBlinds: TcxGridColumn;
    gridBlindsLevel: TcxGridLevel;
    gridBlindsMinutes: TcxGridColumn;
    lbvSubHeader: TcxLabel;
    tiGUIUpdate: TTimer;
    styleActiveBlindLevel: TcxStyle;
    gridAllPlayersPlace: TcxGridColumn;
    lbvTournamentState: TcxLabel;
    lbsTournamentPlayers: TcxLabel;
    lbsTournamentTables: TcxLabel;
    lbsTournamentBlinds: TcxLabel;
    styleGridRowsNormal: TcxStyle;
    imgHeader: TcxImage;
    stylePlayersFinished: TcxStyle;
    stylePlayersIngame: TcxStyle;
    lbvTournamentInfo: TcxLabel;
    dxBevel1: TdxBevel;
    dxBevel2: TdxBevel;
    lbsPrizes: TcxLabel;
    gridPrizes: TcxGrid;
    gridPrizesTable: TcxGridTableView;
    gridPrizesPlace: TcxGridColumn;
    gridPrizesName: TcxGridColumn;
    gridPrizesLevel: TcxGridLevel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure acRegisterExecute(Sender: TObject);
    procedure acUnregisterExecute(Sender: TObject);
    procedure gridTablesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
    procedure gridTablesTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure tiGUIUpdateTimer(Sender: TObject);
    procedure gridAllPlayersPlaceStylesGetContentStyle(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure gridBlindsTableStylesGetContentStyle(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure gridPlayersTableStylesGetContentStyle(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
  private
    FTournamentId: TMongoId;
    FSelectedTableId: TMongoId;
    FCallbacksId: Integer;

    procedure CSRTournamentDetails(const AMethodId: Integer; const AObject: TObject);
    procedure CSRTournamentReply(const AMethodId: Integer; const AObject: TObject);
    procedure CSETournamentList(const AMethodId: Integer; const AObject: TObject);
    procedure UpdatePlayersGrid;
    procedure UpdateTablesGrid;
    procedure UpdateAllPlayersGrid;
    procedure UpdatePrizesGrid;
    procedure UpdateFormData;
    procedure UpdateBlindsStructureGrid;
    procedure UpdateTournamentLabels;
    procedure RefreshAll;
  protected
    procedure CreateParams(var AParams: TCreateParams); override;
  public
    procedure SetParams(const AParams: array of pointer);

    property TournamentId: TMongoId read FTournamentId;
  end;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Poker.Server.MessageContainer, Poker.Protobufs.Enum.ServerCodes, Poker.Common.FormsContainer, Poker.Server.Socket, Poker.Server.MessageCallbacks,
  Poker.Protobufs.Objects.TournamentInfo, Poker.Tournaments, Poker.Tournaments.Info, Poker.DataModule, Poker.Protobufs.Objects.TournamentCommandParams,
  Poker.Protobufs.Objects.Game, Poker.Protobufs.Objects.TournamentMember, Poker.Tables.TableList, Poker.Protobufs.Objects.GameBlinds,
  Poker.Protobufs.Objects.TournamentList, Poker.Tables.Table, Poker.Protobufs.Objects.TableStatus, System.DateUtils, Poker.Common.Misc,
  Poker.Games.Game, Poker.Forms.Main, Poker.Protobufs.Objects.TournamentPrize, Poker.SoftExceptions;

procedure TfrmTournamentLobby.FormCreate(Sender: TObject);
begin
  FCallbacksId := MessageContainer.AddCallbacks(self.Name, [
                      TServerMessageCallback.Create(srTournamentDetails, CSRTournamentDetails),
                      TServerMessageCallback.Create(seTournamentList, CSETournamentList),
                      TServerMessageCallback.Create(srTournamentReply, CSRTournamentReply)
                  ]);
end;

procedure TfrmTournamentLobby.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.Remove(self);
end;

procedure TfrmTournamentLobby.SetParams(const AParams: array of pointer);
begin
  FTournamentId := AParams[0];
  ServerSocket.OpenTournamentLobby(FTournamentId);
  RefreshAll;
end;

procedure TfrmTournamentLobby.tiGUIUpdateTimer(Sender: TObject);
begin
  UpdateTournamentLabels;
end;

procedure TfrmTournamentLobby.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ServerSocket.CloseTournamentLobby(FTournamentId);
  Action := caFree;
end;

procedure TfrmTournamentLobby.CreateParams(var AParams: TCreateParams);
begin
  inherited;

  AParams.ExStyle := AParams.ExStyle or WS_EX_APPWINDOW;
  AParams.WndParent := 0;
end;

procedure TfrmTournamentLobby.CSETournamentList(const AMethodId: Integer; const AObject: TObject);
var
  proto: TPB_TournamentList;
  tournament_info: TPB_TournamentInfo;
begin
  if not TTypes.TryCast<TPB_TournamentList>(AObject, proto) then
    Exit;

  for tournament_info in proto.Items do
    if tournament_info.MongoId = FTournamentId then
    begin
      RefreshAll;
      Exit;
    end;
end;

procedure TfrmTournamentLobby.CSRTournamentDetails(const AMethodId: Integer; const AObject: TObject);
var
  proto: TPB_TournamentInfo;
begin
  if not TTypes.TryCast<TPB_TournamentInfo>(AObject, proto) then
    Exit;

  Tournaments.Add(proto);
  gridPlayersTable.OptionsView.NoDataToDisplayInfoText := ' ' ;
  gridTablesTable.OptionsView.NoDataToDisplayInfoText := ' ';
  gridAllPlayersTable.OptionsView.NoDataToDisplayInfoText := ' ';
  gridBlindsTable.OptionsView.NoDataToDisplayInfoText := ' ';
  gridPrizesTable.OptionsView.NoDataToDisplayInfoText := ' ';
  alTournamentLobby.State := asNormal;
  tiGUIUpdate.Enabled := TRUE;
  RefreshAll;
end;

procedure TfrmTournamentLobby.UpdateAllPlayersGrid;
var
  c: TcxDataController;
  tournament: TTournamentInfo;
  rec_count: Integer;
  member: TPB_TournamentMember;
begin
  c := gridAllPlayersTable.DataController;
  c.BeginFullUpdate;
  try
    rec_count := 0;
    if Tournaments.GetAndLock(FTournamentId, tournament) then
    try
      for member in tournament.Players do
      begin
        Inc(rec_count);
        if rec_count > c.RecordCount then
          c.SetRecordCount(rec_count);
        c.SetValue(rec_count - 1, gridAllPlayersPlace.Index, member.Position + 1);
        c.SetValue(rec_count - 1, gridAllPlayersId.Index, member.MongoId.ToVariant);
        c.SetValue(rec_count - 1, gridAllPlayersName.Index, member.Displayname);
        c.SetValue(rec_count - 1, gridAllPlayersChips.Index, member.Chips / 100);
      end;
    finally
      Tournaments.Unlock;
    end;
    c.SetRecordCount(rec_count);
  finally
    c.EndFullUpdate;
  end;
end;

procedure TfrmTournamentLobby.UpdateTournamentLabels;
var
  tournament: TTournamentInfo;
  subvisible: Boolean;
  minutes: UINT32;
begin
  subvisible := FALSE;
  if Tournaments.GetAndLock(FTournamentId, tournament) then
  try
    // tournament info
    lbvTournamentInfo.Caption := Format('%s, %d-max', [GameTypeToStr(tournament.Gametype, tournament.Limit, FALSE), tournament.SeatsPerTable]);

    // tournament state
    case tournament.State of
      tnsOpen: begin
        minutes := MinutesBetween(TTimeZone.Local.ToLocalTime(UnixToDateTime(tournament.StartTime)), Now);
        lbvTournamentState.Caption := Format('Open (starts in %s)', [MinutesToString(minutes)]);
        lbvTournamentState.Style.TextColor := frmChipUpMain.styleTournamentOpen.TextColor;

        lbvSubHeader.Caption := Format('Registered players: %d / %d', [tournament.RegisteredPlayers, tournament.Maxplayers]);
        subvisible := TRUE;
      end;
      tnsInProgress: begin
        minutes := MinutesBetween(Now, TTimeZone.Local.ToLocalTime(UnixToDateTime(tournament.StartTime)));
        lbvTournamentState.Caption := Format('Running (%s)', [MinutesToString(minutes)]);
        lbvTournamentState.Style.TextColor := frmChipUpMain.styleTournamentInProgress.TextColor;

        if tournament.CurrentBlindLevel < UINT32(tournament.BlindStructure.Count) then
          if tournament.CurrentBlindLevel = UINT32(tournament.BlindStructure.Count - 1) then
            lbvSubHeader.Caption := Format('Current blinds: %d / %d', [tournament.BlindStructure[tournament.CurrentBlindLevel].Sb, tournament.BlindStructure[tournament.CurrentBlindLevel].Bb])
          else
            lbvSubHeader.Caption := Format('Current blinds: %d / %d (%.2d:%.2d until next level)', [tournament.BlindStructure[tournament.CurrentBlindLevel].Sb,
                tournament.BlindStructure[tournament.CurrentBlindLevel].Bb, tournament.SecondsUntilNextLevel div 60, tournament.SecondsUntilNextLevel mod 60])
        else
        begin
          lbvSubHeader.Caption := '';
          SoftException(Format('Invalid current blind level: %d', [tournament.CurrentBlindLevel]));
        end;
        subvisible := TRUE;
      end;
      tnsCancelled: begin
        lbvTournamentState.Caption := tournament.StateToStr;
        lbvTournamentState.Style.TextColor := frmChipUpMain.styleTournamentCancelled.TextColor;
      end;
      tnsOnBreak: begin
        lbvTournamentState.Caption := Format('Break (%.2d:%.2d left)', [tournament.SecondsUntilNextLevel div 60, tournament.SecondsUntilNextLevel mod 60]);
        lbvTournamentState.Style.TextColor := frmChipUpMain.styleTournamentInProgress.TextColor;
      end;
      tnsStarting: begin
        lbvTournamentState.Caption := tournament.StateToStr;
        lbvTournamentState.Style.TextColor := frmChipUpMain.styleTournamentInProgress.TextColor;
      end;
      tnsFinished: begin
        lbvTournamentState.Caption := tournament.StateToStr;
        lbvTournamentState.Style.TextColor := frmChipUpMain.styleTournamentFinished.TextColor;
      end;
    end;

    // tournament subheader
    lbvSubHeader.Visible := subvisible;
  finally
    Tournaments.Unlock;
  end;
end;

procedure TfrmTournamentLobby.UpdateBlindsStructureGrid;
var
  c: TcxDataController;
  tournament: TTournamentInfo;
  rec_count: Integer;
  C1: Integer;
begin
  c := gridBlindsTable.DataController;
  c.BeginFullUpdate;
  try
    rec_count := 0;
    if Tournaments.GetAndLock(FTournamentId, tournament) then
    try
      for C1 := 0 to tournament.BlindStructure.Count - 1 do
      begin
        Inc(rec_count);
        if rec_count > c.RecordCount then
          c.SetRecordCount(rec_count);
        c.SetValue(rec_count - 1, gridBlindsTLevel.Index, C1 + 1);
        c.SetValue(rec_count - 1, gridBlindsBlinds.Index, Format('%d / %d', [tournament.BlindStructure[C1].Sb, tournament.BlindStructure[C1].Bb]));
        if C1 < tournament.BlindStructure.Count - 1 then
          c.SetValue(rec_count - 1, gridBlindsMinutes.Index, tournament.Timeperlevel)
        else
          c.SetValue(rec_count - 1, gridBlindsMinutes.Index, '');
      end;
    finally
      Tournaments.Unlock;
    end;
    c.SetRecordCount(rec_count);
  finally
    c.EndFullUpdate;
  end;
end;

procedure TfrmTournamentLobby.UpdateFormData;
var
  tournament: TTournamentInfo;
begin
  if Tournaments.GetAndLock(FTournamentId, tournament) then
  try
    lbvHeader.Caption := tournament.Name;
    Caption := Format('Tournament Lobby - %s', [tournament.Name]);
  finally
    Tournaments.Unlock;
  end;
end;

procedure TfrmTournamentLobby.UpdatePlayersGrid;
var
  c: TcxDataController;
  tournament: TTournamentInfo;
  member: TPB_TournamentMember;
  members: TPB_TournamentMemberList;
  game: TPB_Game;
  C1, insert_index: Integer;
begin
  c := gridPlayersTable.DataController;
  c.BeginFullUpdate;
  try
    if (not FSelectedTableId.IsEmpty) and
       (Tournaments.GetAndLockByGame(FSelectedTableId, tournament, game)) then
    try
      members := TPB_TournamentMemberList.Create(FALSE);
      try
        for member in tournament.Players do
          if member.Gameid = game.MongoId then
          begin
            // insertion sort, sort by seats
            insert_index := 0;
            while insert_index < members.Count do
              if members[insert_index].SeatIndex > member.SeatIndex then
                Break
              else
                Inc(insert_index);
            members.Insert(insert_index, member);
          end;

        c.SetRecordCount(members.Count);
        for C1 := 0 to members.Count - 1 do
        begin
          member := members[C1];
          c.SetValue(C1, gridPlayersMongoId.Index, member.MongoId.ToVariant);
          c.SetValue(C1, gridPlayersName.Index, member.Displayname);
          c.SetValue(C1, gridPlayersChips.Index, member.Chips / 100);
        end;
      finally
        members.Free;
      end;
    finally
      Tournaments.Unlock;
    end;
  finally
    c.EndFullUpdate;
  end;
end;

procedure TfrmTournamentLobby.UpdatePrizesGrid;
var
  c: TcxDataController;
  tournament: TTournamentInfo;
  rec_count: Integer;
  C1: Integer;
  prize: TPB_TournamentPrize;
begin
  if Tournaments.GetAndLock(FTournamentId, tournament) then
  try
    c := gridPrizesTable.DataController;
    c.BeginFullUpdate;
    try
      rec_count := 0;
      for C1 := 0 to tournament.Prizes.Count - 1 do
      begin
        prize := tournament.Prizes[C1];
        Inc(rec_count);
        if rec_count > c.RecordCount then
          c.SetRecordCount(rec_count);

        c.SetValue(rec_count - 1, gridPrizesPlace.Index, prize.Place + 1);
        c.SetValue(rec_count - 1, gridPrizesName.Index, prize.Name);
      end;
      c.SetRecordCount(rec_count);
    finally
      c.EndFullUpdate;
    end;
  finally
    Tournaments.Unlock;
  end;
end;

procedure TfrmTournamentLobby.UpdateTablesGrid;
var
  c: TcxDataController;
  tournament: TTournamentInfo;
  rec_count: Integer;
  C1: Integer;
  game: TPB_Game;
  member: TPB_TournamentMember;
  gamenameint: Integer;
  stack_players, total_stack, smallest_stack, avg_stack, largest_stack: UINT32;
begin
  if Tournaments.GetAndLock(FTournamentId, tournament) then
  try
    c := gridTablesTable.DataController;
    c.BeginFullUpdate;
    try
      rec_count := 0;
      for C1 := 0 to tournament.Games.Count - 1 do
      begin
        game := tournament.Games[C1];
        Inc(rec_count);
        if rec_count > c.RecordCount then
          c.SetRecordCount(rec_count);
        c.SetValue(rec_count - 1, gridTablesId.Index, game.MongoId.ToVariant);
        gamenameint := StrToIntDef(game.Gamename, 0);
        if game.FinalTable then
          c.SetValue(rec_count - 1, gridTablesName.Index, 'Final Table')
        else
          c.SetValue(rec_count - 1, gridTablesName.Index, gamenameint);
        c.SetValue(rec_count - 1, gridTablesPlayers.Index, game.Sitting);

        total_stack := 0;
        stack_players := 0;
        smallest_stack := 0;
        largest_stack := 0;
        avg_stack := 0;
        for member in tournament.Players do
          if member.Gameid = game.MongoId then
          begin
            Inc(total_stack, member.Chips);
            if (member.Chips < smallest_stack) or
               (smallest_stack = 0) then
              smallest_stack := member.Chips;
            if member.Chips > largest_stack then
              largest_stack := member.Chips;
            Inc(stack_players);
          end;
        if stack_players > 0 then
          avg_stack := total_stack div stack_players;

        c.SetValue(rec_count - 1, gridTablesSmallestStack.Index, smallest_stack / 100);
        c.SetValue(rec_count - 1, gridTablesAverageStack.Index, avg_stack / 100);
        c.SetValue(rec_count - 1, gridTablesLargestStack.Index, largest_stack / 100);
      end;
      c.SetRecordCount(rec_count);
    finally
      c.EndFullUpdate;
    end;
  finally
    Tournaments.Unlock;
  end;
end;

procedure TfrmTournamentLobby.gridAllPlayersPlaceStylesGetContentStyle(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
var
  chips: Currency;
begin
  chips := ARecord.Values[gridAllPlayersChips.Index];
  if chips = 0 then
    AStyle := stylePlayersFinished
  else
    AStyle := stylePlayersIngame;
end;

procedure TfrmTournamentLobby.gridBlindsTableStylesGetContentStyle(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
var
  level_id: Integer;
  tournament: TTournamentInfo;
begin
  level_id := ARecord.Values[gridBlindsTLevel.Index];

  if Tournaments.GetAndLock(FTournamentId, tournament) then
  try
    if level_id - 1 = Integer(tournament.CurrentBlindLevel) then
      AStyle := styleActiveBlindLevel;
  finally
    Tournaments.Unlock;
  end;
end;

procedure TfrmTournamentLobby.gridPlayersTableStylesGetContentStyle(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
var
  mongoid: TMongoId;
begin
  mongoid := ARecord.Values[gridPlayersMongoId.Index];
  if mongoid = dmMain.SelfInfo.MongoId then
    AStyle := stylePlayersSelf
  else
    AStyle := stylePlayersOther;
end;

procedure TfrmTournamentLobby.gridTablesTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
  tournament: TTournamentInfo;
  game: TPB_Game;
  table: TTable;
begin
  if FSelectedTableId.IsEmpty then
    Exit;

  if Tournaments.GetAndLockByGame(FSelectedTableId, tournament, game) then
  try
    if Tables.GetAndLockTable(game.MongoId, ttTournament, table) then
      table.Show
    else
      Tables.AddTournamentTable(game.MongoId, FALSE, TRUE);
  finally
    Tournaments.Unlock;
  end;
end;

procedure TfrmTournamentLobby.gridTablesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex: Integer;
  tournament: TTournamentInfo;
  game: TPB_Game;
begin
  recIndex := Sender.DataController.GetFocusedRecordIndex;
  if recIndex = -1 then
    FSelectedTableId.Clear
  else
  begin
    FSelectedTableId := Sender.DataController.GetValue(recIndex, gridTablesId.Index);
    if Tournaments.GetAndLockByGame(FSelectedTableId, tournament, game) then
      Tournaments.Unlock
    else
      FSelectedTableId.Clear;
  end;
  UpdatePlayersGrid;
end;

procedure TfrmTournamentLobby.CSRTournamentReply(const AMethodId: Integer; const AObject: TObject);
var
  proto: TPB_TournamentCommandParams;
begin
  if not TTypes.TryCast<TPB_TournamentCommandParams>(AObject, proto) then
    Exit;
  if proto.MongoId <> FTournamentId then
    Exit;
  RefreshAll;
end;

procedure TfrmTournamentLobby.acRegisterExecute(Sender: TObject);
begin
  ServerSocket.TournamentRegister(FTournamentId);
  acRegister.Enabled := FALSE;
end;

procedure TfrmTournamentLobby.acUnregisterExecute(Sender: TObject);
begin
  ServerSocket.TournamentUnregister(FTournamentId);
  acUnregister.Enabled := FALSE;
end;

procedure TfrmTournamentLobby.RefreshAll;
var
  tournament: TTournamentInfo;
begin
  if not Tournaments.GetAndLock(FTournamentId, tournament) then
  begin
    acRegister.Enabled := FALSE;
    acUnregister.Enabled := FALSE;
  end
  else
    try
      acRegister.Enabled := (tournament.State = tnsOpen) and (not dmMain.SelfInfo.RegisteredTournaments.Contains(FTournamentId));
      acUnregister.Enabled := (tournament.State = tnsOpen) and (dmMain.SelfInfo.RegisteredTournaments.Contains(FTournamentId));
    finally
      Tournaments.Unlock;
    end;

  acRegister.Visible := acRegister.Enabled;
  acUnregister.Visible := acUnregister.Enabled;
  if acUnregister.Enabled then
  begin
    btTournamentRegister.Action := acUnregister;
    btTournamentRegister.Colors.HotText := $001111DF;
    btTournamentRegister.Colors.NormalText := $001111BF;
    btTournamentRegister.Colors.PressedText := $001111BF;
  end
  else
    if acRegister.Enabled then
    begin
      btTournamentRegister.Action := acRegister;
      btTournamentRegister.Colors.HotText := $0000E600;
      btTournamentRegister.Colors.NormalText := $0000BF00;
      btTournamentRegister.Colors.PressedText := $0000BF00;
    end;

  UpdateAllPlayersGrid;
  UpdatePlayersGrid;
  UpdateTablesGrid;
  UpdateBlindsStructureGrid;
  UpdatePrizesGrid;
  UpdateFormData;
  UpdateTournamentLabels;
end;



end.
