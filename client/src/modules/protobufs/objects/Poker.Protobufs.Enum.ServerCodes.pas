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
    srKickPlayerReply = 11,
    srSetAvatarReply = 12,
    srChangeMailReply = 13,
    srGetPlayers = 14,
    srSubscriptionPlanChange = 15,
    srOwnershipGiveAwayNotOwner = 16,
    srOwnershipGiveAwayInvalidPlayerId = 17,
    srOwnershipGiveAwayInvalidClubId = 18,
    srOwnershipGiveAwayOk = 19,
    srClubDisbandOk = 20,
    srTournamentOpenTable = 21,
    srChangePasswordOk = 23,
    srCreateGameOk = 24,
    srDeleteGameOk = 25,
    srTableSitOk = 27,
    srTableSitSeatTaken = 28,
    srTableStandUpOk = 29,
    srPong = 30,
    srSuspendPlayerOk = 31,
    srReinstatePlayerOk = 32,
    srTableAddonOk = 33,
    srTableAddonOverLimit = 34,
    srTableStatsReply = 35,
    srContactUsOk = 36,
    srTableBuyinLessThanCashout = 37,
    srInvalidTableBuyin = 38,
    srPlayerLimitOk = 39,
    srResetPlayerBalanceOk = 40,
    srClubBalanceReached = 41,
    srHandHistoryMsg = 42,
    srQueryAssetsReply = 43,
    srNotSitting = 44,
    srTournamentReply = 45,
    srTournamentDetails = 46,
    seChat = 50,
    seSecondaryLoginDetected = 51,
    seAccountConfirmed = 52,
    seClubChange = 53,
    seClubDeleted = 54,
    seGameChange = 55,
    seGameCreate = 56,
    seGameDelete = 57,
    seTableStatus = 58,
    seTournamentList = 59,
    seUserChange = 60,
    seTournamentPlayerFinished = 61,
    seTournamentPlayerTransfer = 62,
    sePlayerClubStatus = 63,
    seReservedSeatFree = 64,
    scHello = 70,
    scLogin = 71,
    scTournamentRegister = 72,
    scRegister = 73,
    scForgotPassword = 74,
    scLogout = 75,
    scCreateClub = 76,
    scJoinClub = 77,
    scKickPlayer = 78,
    scLeaveClub = 79,
    scGiveClubOwnership = 80,
    scChangeClubDetails = 81,
    scDeleteClub = 82,
    scSubscriptionPlanChange = 83,
    scChangeEmail = 84,
    scChangePassword = 85,
    scSetAvatar = 86,
    scCreateGame = 87,
    scCloseGame = 88,
    scTableJoin = 89,
    scTableLeave = 90,
    scTableSit = 91,
    scTableStandUp = 92,
    scPing = 93,
    scSuspendPlayer = 94,
    scGetPlayers = 95,
    scFold = 96,
    scPutChips = 97,
    scTableAddOn = 98,
    scTablePlayNow = 99,
    scTableSitOutNextHand = 100,
    scTableSitOutNextBB = 101,
    scResendVerificationMail = 102,
    scShowCards = 103,
    scQueryTableStats = 104,
    scContactUs = 105,
    scSetPlayerLimit = 106,
    scResetPlayerBalance = 107,
    scQueryAssets = 108,
    scTournamentUnregister = 109,
    scTournamentLobbyOpen = 110,
    scTournamentLobbyClose = 111,
    scTournamentQueryInfo = 112,
    scTableSitOpen = 113,
    scResetPlayerBalances = 114,
    scDeleteTableStats = 115,
    scMutePlayer = 116,
    scChangePlayerManagerState = 117,
    scSplitTableCards = 118,
    scSoftException = 119
  );

{$IFDEF DEBUG}
function TranslateCode(const ACode: Integer): String;
{$ENDIF DEBUG}

implementation

{$IFDEF DEBUG}
uses System.SysUtils;

function TranslateCode(const ACode: Integer): String;
var
  sc: TServerCodes;
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
    Exit(Format('UNKNOWN CODE [%d]', [ACode]));

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
    srKickPlayerReply: result := 'srKickPlayerReply';
    srSetAvatarReply: result := 'srSetAvatarReply';
    srChangeMailReply: result := 'srChangeMailReply';
    srGetPlayers: result := 'srGetPlayers';
    srSubscriptionPlanChange: result := 'srSubscriptionPlanChange';
    srOwnershipGiveAwayNotOwner: result := 'srOwnershipGiveAwayNotOwner';
    srOwnershipGiveAwayInvalidPlayerId: result := 'srOwnershipGiveAwayInvalidPlayerId';
    srOwnershipGiveAwayInvalidClubId: result := 'srOwnershipGiveAwayInvalidClubId';
    srOwnershipGiveAwayOk: result := 'srOwnershipGiveAwayOk';
    srClubDisbandOk: result := 'srClubDisbandOk';
    srTournamentOpenTable: result := 'srTournamentOpenTable';
    srChangePasswordOk: result := 'srChangePasswordOk';
    srCreateGameOk: result := 'srCreateGameOk';
    srDeleteGameOk: result := 'srDeleteGameOk';
    srTableSitOk: result := 'srTableSitOk';
    srTableSitSeatTaken: result := 'srTableSitSeatTaken';
    srTableStandUpOk: result := 'srTableStandUpOk';
    srPong: result := 'srPong';
    srSuspendPlayerOk: result := 'srSuspendPlayerOk';
    srReinstatePlayerOk: result := 'srReinstatePlayerOk';
    srTableAddonOk: result := 'srTableAddonOk';
    srTableAddonOverLimit: result := 'srTableAddonOverLimit';
    srTableStatsReply: result := 'srTableStatsReply';
    srContactUsOk: result := 'srContactUsOk';
    srTableBuyinLessThanCashout: result := 'srTableBuyinLessThanCashout';
    srInvalidTableBuyin: result := 'srInvalidTableBuyin';
    srPlayerLimitOk: result := 'srPlayerLimitOk';
    srResetPlayerBalanceOk: result := 'srResetPlayerBalanceOk';
    srClubBalanceReached: result := 'srClubBalanceReached';
    srHandHistoryMsg: result := 'srHandHistoryMsg';
    srQueryAssetsReply: result := 'srQueryAssetsReply';
    srNotSitting: result := 'srNotSitting';
    srTournamentReply: result := 'srTournamentReply';
    srTournamentDetails: result := 'srTournamentDetails';
    seChat: result := 'seChat';
    seSecondaryLoginDetected: result := 'seSecondaryLoginDetected';
    seAccountConfirmed: result := 'seAccountConfirmed';
    seClubChange: result := 'seClubChange';
    seClubDeleted: result := 'seClubDeleted';
    seGameChange: result := 'seGameChange';
    seGameCreate: result := 'seGameCreate';
    seGameDelete: result := 'seGameDelete';
    seTableStatus: result := 'seTableStatus';
    seTournamentList: result := 'seTournamentList';
    seUserChange: result := 'seUserChange';
    seTournamentPlayerFinished: result := 'seTournamentPlayerFinished';
    seTournamentPlayerTransfer: result := 'seTournamentPlayerTransfer';
    sePlayerClubStatus: result := 'sePlayerClubStatus';
    seReservedSeatFree: result := 'seReservedSeatFree';
    scHello: result := 'scHello';
    scLogin: result := 'scLogin';
    scTournamentRegister: result := 'scTournamentRegister';
    scRegister: result := 'scRegister';
    scForgotPassword: result := 'scForgotPassword';
    scLogout: result := 'scLogout';
    scCreateClub: result := 'scCreateClub';
    scJoinClub: result := 'scJoinClub';
    scKickPlayer: result := 'scKickPlayer';
    scLeaveClub: result := 'scLeaveClub';
    scGiveClubOwnership: result := 'scGiveClubOwnership';
    scChangeClubDetails: result := 'scChangeClubDetails';
    scDeleteClub: result := 'scDeleteClub';
    scSubscriptionPlanChange: result := 'scSubscriptionPlanChange';
    scChangeEmail: result := 'scChangeEmail';
    scChangePassword: result := 'scChangePassword';
    scSetAvatar: result := 'scSetAvatar';
    scCreateGame: result := 'scCreateGame';
    scCloseGame: result := 'scCloseGame';
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
    scShowCards: result := 'scShowCards';
    scQueryTableStats: result := 'scQueryTableStats';
    scContactUs: result := 'scContactUs';
    scSetPlayerLimit: result := 'scSetPlayerLimit';
    scResetPlayerBalance: result := 'scResetPlayerBalance';
    scQueryAssets: result := 'scQueryAssets';
    scTournamentUnregister: result := 'scTournamentUnregister';
    scTournamentLobbyOpen: result := 'scTournamentLobbyOpen';
    scTournamentLobbyClose: result := 'scTournamentLobbyClose';
    scTournamentQueryInfo: result := 'scTournamentQueryInfo';
    scTableSitOpen: result := 'scTableSitOpen';
    scResetPlayerBalances: result := 'scResetPlayerBalances';
    scDeleteTableStats: result := 'scDeleteTableStats';
    scMutePlayer: result := 'scMutePlayer';
    scChangePlayerManagerState: result := 'scChangePlayerManagerState';
    scSplitTableCards: result := 'scSplitTableCards';
    scSoftException: result := 'scSoftException';
  end;
end;
{$ENDIF DEBUG}

end.