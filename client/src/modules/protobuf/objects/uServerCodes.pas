unit uServerCodes;

interface

type
  TServerCodes = (
    srNotImplemented = 0,
    srHello = 1,
    srLoginOk = 2,
    srInvalidLogin = 3,
    srLogout = 4,
    srRegisterOk = 5,
    srRegisterDuplicateMail = 6,
    srRegisterDuplicateUsername = 7,
    srRegisterInvalidMail = 8,
    srListClubs = 9,
    srStatus = 10,
    srCreateClubOk = 11,
    srCreateClubNameExists = 12,
    srCreateClubInvalidName = 13,
    srCreateClubInvalidCode = 14,
    srJoinClubOk = 15,
    srJoinClubInvalidId = 16,
    srJoinClubInvalidCode = 17,
    srJoinClubAlreadyMember = 18,
    srLeaveClubOk = 19,
    srLeaveClubInvalidId = 20,
    srKickPlayerOk = 21,
    srKickPlayerInvalidClubId = 22,
    srKickPlayerInvalidPlayerId = 23,
    srOwnershipGiveAwayNotOwner = 24,
    srOwnershipGiveAwayInvalidPlayerId = 25,
    srOwnershipGiveAwayInvalidClubId = 26,
    srOwnershipGiveAwayOk = 27,
    srClubDetailsChangeOk = 28,
    srClubDetailsClubnameExists = 29,
    srClubDisbandOk = 30,
    srClubTransferChipsOk = 31,
    srClubTransferChipsInvalidAmount = 32,
    srCreateClubNoTokens = 33,
    srClubDetailsChangeNoTokens = 34,
    srChangeMailOk = 35,
    srChangeMailInvalidMail = 36,
    srChangeMailDuplicateMail = 37,
    srChangePasswordOk = 38,
    srChangePasswordInvalidPassword = 39,
    srChangeAvatarOk = 40,
    srChangeAvatarInvalidId = 41,
    srCreateGameOk = 42,
    srDeleteGameOk = 43,
    srEditGameOk = 44,
    srTableStatus = 45,
    srTableSitOk = 46,
    srTableSitSeatTaken = 47,
    srTableStandUpOk = 48,
    srPong = 49,
    srSuspendPlayerOk = 50,
    srReinstatePlayerOk = 51,
    seChat = 200,
    seSecondaryLoginDetected = 201,
    seAccountConfirmed = 202,
    seClubChange = 203,
    seClubDeleted = 204,
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
    scDeleteGame = 519,
    scEditGame = 520,
    scTableJoin = 521,
    scTableLeave = 522,
    scTableSit = 523,
    scTableStandUp = 524,
    scPing = 525,
    scSuspendPlayer = 526
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
    srLoginOk: result := 'srLoginOk';
    srInvalidLogin: result := 'srInvalidLogin';
    srLogout: result := 'srLogout';
    srRegisterOk: result := 'srRegisterOk';
    srRegisterDuplicateMail: result := 'srRegisterDuplicateMail';
    srRegisterDuplicateUsername: result := 'srRegisterDuplicateUsername';
    srRegisterInvalidMail: result := 'srRegisterInvalidMail';
    srListClubs: result := 'srListClubs';
    srStatus: result := 'srStatus';
    srCreateClubOk: result := 'srCreateClubOk';
    srCreateClubNameExists: result := 'srCreateClubNameExists';
    srCreateClubInvalidName: result := 'srCreateClubInvalidName';
    srCreateClubInvalidCode: result := 'srCreateClubInvalidCode';
    srJoinClubOk: result := 'srJoinClubOk';
    srJoinClubInvalidId: result := 'srJoinClubInvalidId';
    srJoinClubInvalidCode: result := 'srJoinClubInvalidCode';
    srJoinClubAlreadyMember: result := 'srJoinClubAlreadyMember';
    srLeaveClubOk: result := 'srLeaveClubOk';
    srLeaveClubInvalidId: result := 'srLeaveClubInvalidId';
    srKickPlayerOk: result := 'srKickPlayerOk';
    srKickPlayerInvalidClubId: result := 'srKickPlayerInvalidClubId';
    srKickPlayerInvalidPlayerId: result := 'srKickPlayerInvalidPlayerId';
    srOwnershipGiveAwayNotOwner: result := 'srOwnershipGiveAwayNotOwner';
    srOwnershipGiveAwayInvalidPlayerId: result := 'srOwnershipGiveAwayInvalidPlayerId';
    srOwnershipGiveAwayInvalidClubId: result := 'srOwnershipGiveAwayInvalidClubId';
    srOwnershipGiveAwayOk: result := 'srOwnershipGiveAwayOk';
    srClubDetailsChangeOk: result := 'srClubDetailsChangeOk';
    srClubDetailsClubnameExists: result := 'srClubDetailsClubnameExists';
    srClubDisbandOk: result := 'srClubDisbandOk';
    srClubTransferChipsOk: result := 'srClubTransferChipsOk';
    srClubTransferChipsInvalidAmount: result := 'srClubTransferChipsInvalidAmount';
    srCreateClubNoTokens: result := 'srCreateClubNoTokens';
    srClubDetailsChangeNoTokens: result := 'srClubDetailsChangeNoTokens';
    srChangeMailOk: result := 'srChangeMailOk';
    srChangeMailInvalidMail: result := 'srChangeMailInvalidMail';
    srChangeMailDuplicateMail: result := 'srChangeMailDuplicateMail';
    srChangePasswordOk: result := 'srChangePasswordOk';
    srChangePasswordInvalidPassword: result := 'srChangePasswordInvalidPassword';
    srChangeAvatarOk: result := 'srChangeAvatarOk';
    srChangeAvatarInvalidId: result := 'srChangeAvatarInvalidId';
    srCreateGameOk: result := 'srCreateGameOk';
    srDeleteGameOk: result := 'srDeleteGameOk';
    srEditGameOk: result := 'srEditGameOk';
    srTableStatus: result := 'srTableStatus';
    srTableSitOk: result := 'srTableSitOk';
    srTableSitSeatTaken: result := 'srTableSitSeatTaken';
    srTableStandUpOk: result := 'srTableStandUpOk';
    srPong: result := 'srPong';
    srSuspendPlayerOk: result := 'srSuspendPlayerOk';
    srReinstatePlayerOk: result := 'srReinstatePlayerOk';
    seChat: result := 'seChat';
    seSecondaryLoginDetected: result := 'seSecondaryLoginDetected';
    seAccountConfirmed: result := 'seAccountConfirmed';
    seClubChange: result := 'seClubChange';
    seClubDeleted: result := 'seClubDeleted';
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
    scDeleteGame: result := 'scDeleteGame';
    scEditGame: result := 'scEditGame';
    scTableJoin: result := 'scTableJoin';
    scTableLeave: result := 'scTableLeave';
    scTableSit: result := 'scTableSit';
    scTableStandUp: result := 'scTableStandUp';
    scPing: result := 'scPing';
    scSuspendPlayer: result := 'scSuspendPlayer';
  end;
end;
{$ENDIF DEBUG}

end.