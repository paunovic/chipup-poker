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
    seReservedSeatTimeout = 65,
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
    scSoftException = 119,
    scTableSitClose = 120
  );


function TranslateCode(const ACode: Integer): String;


implementation


uses System.SysUtils;

function TranslateCode(const ACode: Integer): String;
begin
  case ACode of
    Integer(srNotImplemented): result := 'srNotImplemented';
    Integer(srHello): result := 'srHello';
    Integer(srLoginReply): result := 'srLoginReply';
    Integer(srRegisterReply): result := 'srRegisterReply';
    Integer(srCreateClubReply): result := 'srCreateClubReply';
    Integer(srJoinClubReply): result := 'srJoinClubReply';
    Integer(srLeaveClubReply): result := 'srLeaveClubReply';
    Integer(srChangeClubDetailsReply): result := 'srChangeClubDetailsReply';
    Integer(srLogout): result := 'srLogout';
    Integer(srKickPlayerReply): result := 'srKickPlayerReply';
    Integer(srSetAvatarReply): result := 'srSetAvatarReply';
    Integer(srChangeMailReply): result := 'srChangeMailReply';
    Integer(srGetPlayers): result := 'srGetPlayers';
    Integer(srSubscriptionPlanChange): result := 'srSubscriptionPlanChange';
    Integer(srOwnershipGiveAwayNotOwner): result := 'srOwnershipGiveAwayNotOwner';
    Integer(srOwnershipGiveAwayInvalidPlayerId): result := 'srOwnershipGiveAwayInvalidPlayerId';
    Integer(srOwnershipGiveAwayInvalidClubId): result := 'srOwnershipGiveAwayInvalidClubId';
    Integer(srOwnershipGiveAwayOk): result := 'srOwnershipGiveAwayOk';
    Integer(srClubDisbandOk): result := 'srClubDisbandOk';
    Integer(srTournamentOpenTable): result := 'srTournamentOpenTable';
    Integer(srChangePasswordOk): result := 'srChangePasswordOk';
    Integer(srCreateGameOk): result := 'srCreateGameOk';
    Integer(srDeleteGameOk): result := 'srDeleteGameOk';
    Integer(srTableSitOk): result := 'srTableSitOk';
    Integer(srTableSitSeatTaken): result := 'srTableSitSeatTaken';
    Integer(srTableStandUpOk): result := 'srTableStandUpOk';
    Integer(srPong): result := 'srPong';
    Integer(srSuspendPlayerOk): result := 'srSuspendPlayerOk';
    Integer(srReinstatePlayerOk): result := 'srReinstatePlayerOk';
    Integer(srTableAddonOk): result := 'srTableAddonOk';
    Integer(srTableAddonOverLimit): result := 'srTableAddonOverLimit';
    Integer(srTableStatsReply): result := 'srTableStatsReply';
    Integer(srContactUsOk): result := 'srContactUsOk';
    Integer(srTableBuyinLessThanCashout): result := 'srTableBuyinLessThanCashout';
    Integer(srInvalidTableBuyin): result := 'srInvalidTableBuyin';
    Integer(srPlayerLimitOk): result := 'srPlayerLimitOk';
    Integer(srResetPlayerBalanceOk): result := 'srResetPlayerBalanceOk';
    Integer(srClubBalanceReached): result := 'srClubBalanceReached';
    Integer(srHandHistoryMsg): result := 'srHandHistoryMsg';
    Integer(srQueryAssetsReply): result := 'srQueryAssetsReply';
    Integer(srNotSitting): result := 'srNotSitting';
    Integer(srTournamentReply): result := 'srTournamentReply';
    Integer(srTournamentDetails): result := 'srTournamentDetails';
    Integer(seChat): result := 'seChat';
    Integer(seSecondaryLoginDetected): result := 'seSecondaryLoginDetected';
    Integer(seAccountConfirmed): result := 'seAccountConfirmed';
    Integer(seClubChange): result := 'seClubChange';
    Integer(seClubDeleted): result := 'seClubDeleted';
    Integer(seGameChange): result := 'seGameChange';
    Integer(seGameCreate): result := 'seGameCreate';
    Integer(seGameDelete): result := 'seGameDelete';
    Integer(seTableStatus): result := 'seTableStatus';
    Integer(seTournamentList): result := 'seTournamentList';
    Integer(seUserChange): result := 'seUserChange';
    Integer(seTournamentPlayerFinished): result := 'seTournamentPlayerFinished';
    Integer(seTournamentPlayerTransfer): result := 'seTournamentPlayerTransfer';
    Integer(sePlayerClubStatus): result := 'sePlayerClubStatus';
    Integer(seReservedSeatFree): result := 'seReservedSeatFree';
    Integer(seReservedSeatTimeout): result := 'seReservedSeatTimeout';
    Integer(scHello): result := 'scHello';
    Integer(scLogin): result := 'scLogin';
    Integer(scTournamentRegister): result := 'scTournamentRegister';
    Integer(scRegister): result := 'scRegister';
    Integer(scForgotPassword): result := 'scForgotPassword';
    Integer(scLogout): result := 'scLogout';
    Integer(scCreateClub): result := 'scCreateClub';
    Integer(scJoinClub): result := 'scJoinClub';
    Integer(scKickPlayer): result := 'scKickPlayer';
    Integer(scLeaveClub): result := 'scLeaveClub';
    Integer(scGiveClubOwnership): result := 'scGiveClubOwnership';
    Integer(scChangeClubDetails): result := 'scChangeClubDetails';
    Integer(scDeleteClub): result := 'scDeleteClub';
    Integer(scSubscriptionPlanChange): result := 'scSubscriptionPlanChange';
    Integer(scChangeEmail): result := 'scChangeEmail';
    Integer(scChangePassword): result := 'scChangePassword';
    Integer(scSetAvatar): result := 'scSetAvatar';
    Integer(scCreateGame): result := 'scCreateGame';
    Integer(scCloseGame): result := 'scCloseGame';
    Integer(scTableJoin): result := 'scTableJoin';
    Integer(scTableLeave): result := 'scTableLeave';
    Integer(scTableSit): result := 'scTableSit';
    Integer(scTableStandUp): result := 'scTableStandUp';
    Integer(scPing): result := 'scPing';
    Integer(scSuspendPlayer): result := 'scSuspendPlayer';
    Integer(scGetPlayers): result := 'scGetPlayers';
    Integer(scFold): result := 'scFold';
    Integer(scPutChips): result := 'scPutChips';
    Integer(scTableAddOn): result := 'scTableAddOn';
    Integer(scTablePlayNow): result := 'scTablePlayNow';
    Integer(scTableSitOutNextHand): result := 'scTableSitOutNextHand';
    Integer(scTableSitOutNextBB): result := 'scTableSitOutNextBB';
    Integer(scResendVerificationMail): result := 'scResendVerificationMail';
    Integer(scShowCards): result := 'scShowCards';
    Integer(scQueryTableStats): result := 'scQueryTableStats';
    Integer(scContactUs): result := 'scContactUs';
    Integer(scSetPlayerLimit): result := 'scSetPlayerLimit';
    Integer(scResetPlayerBalance): result := 'scResetPlayerBalance';
    Integer(scQueryAssets): result := 'scQueryAssets';
    Integer(scTournamentUnregister): result := 'scTournamentUnregister';
    Integer(scTournamentLobbyOpen): result := 'scTournamentLobbyOpen';
    Integer(scTournamentLobbyClose): result := 'scTournamentLobbyClose';
    Integer(scTournamentQueryInfo): result := 'scTournamentQueryInfo';
    Integer(scTableSitOpen): result := 'scTableSitOpen';
    Integer(scResetPlayerBalances): result := 'scResetPlayerBalances';
    Integer(scDeleteTableStats): result := 'scDeleteTableStats';
    Integer(scMutePlayer): result := 'scMutePlayer';
    Integer(scChangePlayerManagerState): result := 'scChangePlayerManagerState';
    Integer(scSplitTableCards): result := 'scSplitTableCards';
    Integer(scSoftException): result := 'scSoftException';
    Integer(scTableSitClose): result := 'scTableSitClose';
  else
    result := Format('%d', [ACode]);
  end;
end;


end.