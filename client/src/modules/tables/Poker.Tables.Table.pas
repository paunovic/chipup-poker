unit Poker.Tables.Table;

interface

uses
  Winapi.Windows, System.SysUtils, Poker.Games.Game, Poker.HandHistory.Playback, Poker.Clubs.Club, Vcl.Forms,
  Poker.Avatars.AvatarList, Poker.HandHistory.Items, Poker.Tables.Renderer, Poker.Avatars.Avatar;

type
  TTable = class
  private
    {$IFDEF DEBUG} FDebugId: Integer; {$ENDIF}
    FInternalId: Integer;
    FTableType: TTableType;
    FGameId: TBytes;
    FClubId: TBytes;
    FForm: TForm;
    FRenderer: TTableRenderer;
    FLeaveNotify: Boolean;
    FHandHistoryHandId: UINT;
    FHandHistoryPlayback: THandHistoryPlayback;

  public
    constructor Create(const AInternalId: Integer);
    destructor Destroy; override;

    function SetupLiveTable(const AGameId: TBytes; const ASendJoinCommand: Boolean): Boolean;
    function SetupHandHistoryTable(const AHandHistoryItems: THandHistoryItems; const AHandHistoryItem: THandHistoryItem): Boolean;

    procedure UpdateAvatars(const AAvatar: TAvatar);

    function GetObjectCopy(out AGame: TGameInfo): Boolean; overload;
    function GetObjectCopy(out AClub: TClubInfo; out AGame: TGameInfo): Boolean; overload;

    procedure BringToFront;

    property InternalId: Integer read FInternalId;
    property TableType: TTableType read FTableType;
    property GameId: TBytes read FGameId;
    property ClubId: TBytes read FClubId;
    property Form: TForm read FForm;
    property Renderer: TTableRenderer read FRenderer;
    property LeaveNotify: Boolean read FLeaveNotify write FLeaveNotify;
    property HandHistoryHandId: UINT read FHandHistoryHandId;
    property HandHistoryPlayback: THandHistoryPlayback read FHandHistoryPlayback;
  end;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Vcl.Controls, Poker.Forms.Table, Poker.Common.Misc, Poker.Server.Socket.Commands, Poker.DirectX.Core, Vectors2px, Poker.DataModule,
  Poker.HandHistory.Core, Poker.Tables.Status;


{ TTable }

constructor TTable.Create(const AInternalId: Integer);
begin
  {$IFDEF DEBUG} FDebugId := RegisterDebugObject(Format('Table #%d', [AInternalId])); {$ENDIF}
  FInternalId := AInternalId;
end;

destructor TTable.Destroy;
begin
  FRenderer.SetRenderTarget(0);
  if FLeaveNotify then
    ServerSocket.LeaveTable(FGameId);
  FreeAndNil(FForm);
  FreeAndNil(FRenderer);
  FreeAndNil(FHandHistoryPlayback);

  {$IFDEF DEBUG} UnregisterDebugObject(FDebugId); {$ENDIF}

  inherited;
end;

function TTable.GetObjectCopy(out AGame: TGameInfo): Boolean;
var
  club: TClubInfo;
  game: TGameInfo;
begin
  if dmMain.SelfInfo.Clubs.FindGame(FGameId, club, game) then
  begin
    AGame := TGameInfo.Create;
    AGame.Assign(game);
    result := TRUE;
  end
  else
    result := FALSE;
end;

function TTable.GetObjectCopy(out AClub: TClubInfo; out AGame: TGameInfo): Boolean;
var
  club: TClubInfo;
  game: TGameInfo;
begin
  if dmMain.SelfInfo.Clubs.FindGame(FGameId, club, game) then
  begin
    AClub := TClubInfo.Create;
    AClub.Assign(club);
    AGame := TGameInfo.Create;
    AGame.Assign(game);
    result := TRUE;
  end
  else
    result := FALSE;
end;

function TTable.SetupLiveTable(const AGameId: TBytes; const ASendJoinCommand: Boolean): Boolean;
var
  form: TfrmTable;
  game: TGameInfo;
  club: TClubInfo;
begin
  FTableType := ttLiveGame;
  FGameId := AGameId;
  if not dmMain.SelfInfo.Clubs.FindGame(FGameId, club, game) then
    Exit(FALSE);
  FClubId := club.MongoId;
  FRenderer := TTableRenderer.Create(FInternalId, FTableType);
  if not FRenderer.AcquireSwapChainElement then
  begin
    FreeAndNil(FRenderer);
    Exit(FALSE);
  end;
  form := TfrmTable.Create(FInternalId);
  FRenderer.SetRenderTarget(form.Handle);
  FForm := form;
  FLeaveNotify := TRUE;
  DXCore.ModifySwapChainElement(FRenderer.SwapChainIndex, FForm.Handle);
  if ASendJoinCommand then
    ServerSocket.JoinTable(AGameId);
  FRenderer.UpdateDXAreaSize;
  Exit(TRUE);
end;

function TTable.SetupHandHistoryTable(const AHandHistoryItems: THandHistoryItems; const AHandHistoryItem: THandHistoryItem): Boolean;
var
  form: TfrmTable;
begin
  FTableType := ttHandPlayback;
  FGameId := AHandHistoryItems.FGameId;
  FHandHistoryHandId := AHandHistoryItem.HandId;
  FHandHistoryPlayback := THandHistoryPlayback.Create(AHandHistoryItems, AHandHistoryItem);
  FRenderer := TTableRenderer.Create(FInternalId, FTableType);
  if not FRenderer.AcquireSwapChainElement then
  begin
    FreeAndNil(FRenderer);
    Exit(FALSE);
  end;
  form := TfrmTable.Create(FInternalId);
  FRenderer.SetRenderTarget(form.Handle);
  FForm := form;
  FLeaveNotify := FALSE;
  DXCore.ModifySwapChainElement(FRenderer.SwapChainIndex, FForm.Handle);
  FRenderer.UpdateDXAreaSize;
  Exit(TRUE);
end;

procedure TTable.BringToFront;
begin
  if IsIconic(FForm.Handle) then
    ShowWindow(FForm.Handle, SW_RESTORE);
  FForm.Show;
end;

procedure TTable.UpdateAvatars(const AAvatar: TAvatar);
begin
  TSyncRenderer.Render(FRenderer);
end;

end.
