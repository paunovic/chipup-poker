unit Poker.Tables.Table;

interface

uses
  Winapi.Windows, System.SysUtils, Poker.Games.Game, Poker.HandHistory.Playback, Poker.Clubs.Club, Vcl.Forms,
  Poker.Avatars.AvatarList, Poker.HandHistory.Items, Poker.Tables.Renderer, Poker.Avatars.Avatar;

type
  TTable = class
  private
    {$IFDEF DEBUG} FDebugId: Integer; {$ENDIF}
    FTableType: TTableType;
    FForm: TForm;
    FSeatIndex: Integer;
    FGameId: TBytes;
    FClubId: TBytes;
    FHandId: UINT;
    FLeaveNotify: Boolean;
    FHandHistoryPlayback: THandHistoryPlayback;
    FSwapChainIndex: Integer;
    FRenderer: TTableRenderer;
    FInternalId: Integer;

  public
    constructor Create(const AInternalId: Integer);
    destructor Destroy; override;

    function AcquireSwapChainElement: Boolean;

    function SetupLiveTable(const AGameId: TBytes; const ASendJoinCommand: Boolean): Boolean;
    procedure SetupHandHistoryTable(const AHandHistoryItems: THandHistoryItems; const AHandHistoryItem: THandHistoryItem);

    function IsSitting: Boolean;

    procedure UpdateAvatars(const AAvatar: TAvatar);

    function GetObjectCopy(out AGame: TGameInfo): Boolean; overload;
    function GetObjectCopy(out AClub: TClubInfo; out AGame: TGameInfo): Boolean; overload;

    procedure BringToFront;

    property InternalId: Integer read FInternalId;
    property GameId: TBytes read FGameId;
    property ClubId: TBytes read FClubId;
    property HandId: UINT read FHandId;
    property Form: TForm read FForm;
    property SeatIndex: Integer read FSeatIndex write FSeatIndex;
    property SwapChainIndex: Integer read FSwapChainIndex;
    property TableType: TTableType read FTableType;
    property Renderer: TTableRenderer read FRenderer;
    property HandHistoryPlayback: THandHistoryPlayback read FHandHistoryPlayback;
    property LeaveNotify: Boolean read FLeaveNotify write FLeaveNotify;
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
  DXCore.ReleaseSwapChainElement(FSwapChainIndex);

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

function TTable.AcquireSwapChainElement: Boolean;
begin
  result := DXCore.AcquireSwapChainElement(0, FSwapChainIndex);
end;

function TTable.SetupLiveTable(const AGameId: TBytes; const ASendJoinCommand: Boolean): Boolean;
var
  form: TfrmTable;
  game: TGameInfo;
  club: TClubInfo;
begin
  FTableType := ttLiveGame;
  FSeatIndex := -1;
  FGameId := AGameId;
  if not dmMain.SelfInfo.Clubs.FindGame(FGameId, club, game) then
    Exit(FALSE);
  FClubId := club.MongoId;
  FRenderer := TTableRenderer.Create(FSwapChainIndex, FInternalId);
  form := TfrmTable.Create(FInternalId);
  FRenderer.SetRenderTarget(form.Handle);
  FForm := form;
  FLeaveNotify := TRUE;
  DXCore.ModifySwapChainElement(FSwapChainIndex, FForm.Handle);
  if ASendJoinCommand then
    ServerSocket.JoinTable(AGameId);
  FRenderer.UpdateDXAreaSize;
  Exit(TRUE);
end;

procedure TTable.SetupHandHistoryTable(const AHandHistoryItems: THandHistoryItems; const AHandHistoryItem: THandHistoryItem);
var
  form: TfrmTable;
begin
  FTableType := ttHandPlayback;
  FSeatIndex := -1;
  FGameId := AHandHistoryItems.FGameId;
  FHandId := AHandHistoryItem.HandId;
  FHandHistoryPlayback := THandHistoryPlayback.Create(AHandHistoryItems, AHandHistoryItem);
  FRenderer := TTableRenderer.Create(FSwapChainIndex, FInternalId);
  form := TfrmTable.Create(FInternalId);
  FRenderer.SetRenderTarget(form.Handle);
  FForm := form;
  FLeaveNotify := FALSE;
  DXCore.ModifySwapChainElement(FSwapChainIndex, FForm.Handle);
  FRenderer.UpdateDXAreaSize;
end;

function TTable.IsSitting: Boolean;
begin
  result := FSeatIndex <> -1;
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
