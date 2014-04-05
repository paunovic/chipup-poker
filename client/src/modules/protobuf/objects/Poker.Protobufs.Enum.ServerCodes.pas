unit Poker.Protobufs.Enum.ServerCodes;

interface

type
  TServerCodes = (
    srNotImplemented = 0,
    srHello = 1,
    srLoginReply = 2,
    srRegisterReply = 3,
    srCreateClubReply = 4,
    srJoinClubReply = 5,
    srLeaveClubReply = 6,
    srChangeClubDetailsReply = 7,
    srLogout = 8,
    srListClubs = 9,
    srStatus = 10,
    srKickPlayerReply = 11,
    srSetAvatarReply = 12,
    srChangeMailReply = 13,
    srGetPlayers = 14,
    srTableSitNoChips = 15,
    srOwnershipGiveAwayNotOwner = 24,
    srOwnershipGiveAwayInvalidPlayerId = 25,
    srOwnershipGiveAwayInvalidClubId = 26,
    srOwnershipGiveAwayOk = 27,
    srClubDisbandOk = 30,
    srTransferChipsOk = 31,
    srTransferChipsInvalidAmount = 32,
    srChangePasswordOk = 38,
    srCreateGameOk = 42,
    srDeleteGameOk = 43,
    srEditGameOk = 44,
    srTableSitOk = 45,
    srTableSitSeatTaken = 46,
    srTableStandUpOk = 47,
    srPong = 48,
    srSuspendPlayerOk = 49,
    srReinstatePlayerOk = 50,
    srTableAddonOk = 51,
    srTableAddonOverLimit = 52,
    srTableStatsReply = 53,
    seChat = 200,
    seSecondaryLoginDetected = 201,
    seAccountConfirmed = 202,
    seClubChange = 203,
    seClubDeleted = 204,
    seGameChange = 205,
    seGameCreate = 206,
    seGameDelete = 207,
    seTableStatus = 209,
    seTransferChips = 210,
    scLogin = 501,
    scStatus = 502,
    scRegister = 503,
    scForgotPassword = 504,
    scLogout = 505,
    scListPublicClubs = 506,
    scCreateClub = 507,
    scJoinClub = 508,
    scKickPlayer = 509,
    scLeaveClub = 510,
    scGiveClubOwnership = 511,
    scChangeClubDetails = 512,
    scDeleteClub = 513,
    scTransferChips = 514,
    scChangeEmail = 515,
    scChangePassword = 516,
    scSetAvatar = 517,
    scCreateGame = 518,
    scCloseGame = 519,
    scEditGame = 520,
    scTableJoin = 521,
    scTableLeave = 522,
    scTableSit = 523,
    scTableStandUp = 524,
    scPing = 525,
    scSuspendPlayer = 526,
    scGetPlayers = 527,
    scFold = 528,
    scPutChips = 529,
    scTableAddOn = 530,
    scTablePlayNow = 531,
    scTableSitOutNextHand = 532,
    scTableSitOutNextBB = 533,
    scResendVerificationMail = 534,
    scShowLosingCards = 535,
    seUserChange = 536,
    scQueryTableStats = 537
  );

{$IFDEF DEBUG}
function TranslateServerCode(const ACode: Integer): String;
{$ENDIF DEBUG}

implementation

{$IFDEF DEBUG}
uses System.SysUtils;

function TranslateServerCode(const ACode: Integer): String;
var
  sc      : TServerCodes;
  sc_valid: Boolean;
begin
  sc_valid := FALSE;
  for sc := Low(TServerCodes) to High(TServerCodes) do
    if Integer(sc) = ACode then
    begin
      sc_valid := TRUE;
      Break;
    end;

  if not sc_valid then
  begin
    result := Format('UNKNOWN CODE [%d]', [ACode]);
  end;

  case TServerCodes(ACode) of
    srNotImplemented: result := 'srNotImplemented';
    srHello: result := 'srHello';
    srLoginReply: result := 'srLoginReply';
    srRegisterReply: result := 'srRegisterReply';
    srCreateClubReply: result := 'srCreateClubReply';
    srJoinClubReply: result := 'srJoinClubReply';
    srLeaveClubReply: result := 'srLeaveClubReply';
    srChangeClubDetailsReply: result := 'srChangeClubDetailsReply';
    srLogout: result := 'srLogout';
    srListClubs: result := 'srListClubs';
    srStatus: result := 'srStatus';
    srKickPlayerReply: result := 'srKickPlayerReply';
    srSetAvatarReply: result := 'srSetAvatarReply';
    srChangeMailReply: result := 'srChangeMailReply';
    srGetPlayers: result := 'srGetPlayers';
    srTableSitNoChips: result := 'srTableSitNoChips';
    srOwnershipGiveAwayNotOwner: result := 'srOwnershipGiveAwayNotOwner';
    srOwnershipGiveAwayInvalidPlayerId: result := 'srOwnershipGiveAwayInvalidPlayerId';
    srOwnershipGiveAwayInvalidClubId: result := 'srOwnershipGiveAwayInvalidClubId';
    srOwnershipGiveAwayOk: result := 'srOwnershipGiveAwayOk';
    srClubDisbandOk: result := 'srClubDisbandOk';
    srTransferChipsOk: result := 'srTransferChipsOk';
    srTransferChipsInvalidAmount: result := 'srTransferChipsInvalidAmount';
    srChangePasswordOk: result := 'srChangePasswordOk';
    srCreateGameOk: result := 'srCreateGameOk';
    srDeleteGameOk: result := 'srDeleteGameOk';
    srEditGameOk: result := 'srEditGameOk';
    srTableSitOk: result := 'srTableSitOk';
    srTableSitSeatTaken: result := 'srTableSitSeatTaken';
    srTableStandUpOk: result := 'srTableStandUpOk';
    srPong: result := 'srPong';
    srSuspendPlayerOk: result := 'srSuspendPlayerOk';
    srReinstatePlayerOk: result := 'srReinstatePlayerOk';
    srTableAddonOk: result := 'srTableAddonOk';
    srTableAddonOverLimit: result := 'srTableAddonOverLimit';
    srTableStatsReply: result := 'srTableStatsReply';
    seChat: result := 'seChat';
    seSecondaryLoginDetected: result := 'seSecondaryLoginDetected';
    seAccountConfirmed: result := 'seAccountConfirmed';
    seClubChange: result := 'seClubChange';
    seClubDeleted: result := 'seClubDeleted';
    seGameChange: result := 'seGameChange';
    seGameCreate: result := 'seGameCreate';
    seGameDelete: result := 'seGameDelete';
    seTableStatus: result := 'seTableStatus';
    seTransferChips: result := 'seTransferChips';
    scLogin: result := 'scLogin';
    scStatus: result := 'scStatus';
    scRegister: result := 'scRegister';
    scForgotPassword: result := 'scForgotPassword';
    scLogout: result := 'scLogout';
    scListPublicClubs: result := 'scListPublicClubs';
    scCreateClub: result := 'scCreateClub';
    scJoinClub: result := 'scJoinClub';
    scKickPlayer: result := 'scKickPlayer';
    scLeaveClub: result := 'scLeaveClub';
    scGiveClubOwnership: result := 'scGiveClubOwnership';
    scChangeClubDetails: result := 'scChangeClubDetails';
    scDeleteClub: result := 'scDeleteClub';
    scTransferChips: result := 'scTransferChips';
    scChangeEmail: result := 'scChangeEmail';
    scChangePassword: result := 'scChangePassword';
    scSetAvatar: result := 'scSetAvatar';
    scCreateGame: result := 'scCreateGame';
    scCloseGame: result := 'scCloseGame';
    scEditGame: result := 'scEditGame';
    scTableJoin: result := 'scTableJoin';
    scTableLeave: result := 'scTableLeave';
    scTableSit: result := 'scTableSit';
    scTableStandUp: result := 'scTableStandUp';
    scPing: result := 'scPing';
    scSuspendPlayer: result := 'scSuspendPlayer';
    scGetPlayers: result := 'scGetPlayers';
    scFold: result := 'scFold';
    scPutChips: result := 'scPutChips';
    scTableAddOn: result := 'scTableAddOn';
    scTablePlayNow: result := 'scTablePlayNow';
    scTableSitOutNextHand: result := 'scTableSitOutNextHand';
    scTableSitOutNextBB: result := 'scTableSitOutNextBB';
    scResendVerificationMail: result := 'scResendVerificationMail';
    scShowLosingCards: result := 'scShowLosingCards';
    seUserChange: result := 'seUserChange';
    scQueryTableStats: result := 'scQueryTableStats';
  end;
end;
{$ENDIF DEBUG}

end.