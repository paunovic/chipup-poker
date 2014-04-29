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
    srOwnershipGiveAwayNotOwner = 16,
    srOwnershipGiveAwayInvalidPlayerId = 17,
    srOwnershipGiveAwayInvalidClubId = 18,
    srOwnershipGiveAwayOk = 19,
    srClubDisbandOk = 20,
    srTransferChipsOk = 21,
    srTransferChipsInvalidAmount = 22,
    srChangePasswordOk = 23,
    srCreateGameOk = 24,
    srDeleteGameOk = 25,
    srEditGameOk = 26,
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
    seChat = 50,
    seSecondaryLoginDetected = 51,
    seAccountConfirmed = 52,
    seClubChange = 53,
    seClubDeleted = 54,
    seGameChange = 55,
    seGameCreate = 56,
    seGameDelete = 57,
    seTableStatus = 58,
    seTransferChips = 59,
    scLogin = 70,
    scStatus = 71,
    scRegister = 72,
    scForgotPassword = 73,
    scLogout = 74,
    scCreateClub = 75,
    scJoinClub = 76,
    scKickPlayer = 77,
    scLeaveClub = 78,
    scGiveClubOwnership = 79,
    scChangeClubDetails = 80,
    scDeleteClub = 81,
    scTransferChips = 82,
    scChangeEmail = 83,
    scChangePassword = 84,
    scSetAvatar = 85,
    scCreateGame = 86,
    scCloseGame = 87,
    scTableJoin = 88,
    scTableLeave = 89,
    scTableSit = 90,
    scTableStandUp = 91,
    scPing = 92,
    scSuspendPlayer = 93,
    scGetPlayers = 94,
    scFold = 95,
    scPutChips = 96,
    scTableAddOn = 97,
    scTablePlayNow = 98,
    scTableSitOutNextHand = 99,
    scTableSitOutNextBB = 100,
    scResendVerificationMail = 101,
    scShowLosingCards = 102,
    seUserChange = 103,
    scQueryTableStats = 104,
    scContactUs = 105
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
    srContactUsOk: result := 'srContactUsOk';
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
    scContactUs: result := 'scContactUs';
  end;
end;
{$ENDIF DEBUG}

end.