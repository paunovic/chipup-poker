unit uServerCodes;

interface

const
  SR_OLD_MESSAGE                          = 100;
  SR_NOT_IMPLEMENTED                      = 000;
  SR_HELLO                                = 001;
  SR_LOGIN_OK                             = 002;
  SR_INVALID_LOGIN                        = 003;
  SR_LOGOUT                               = 004;
  SR_REGISTER_OK                          = 005;
  SR_REGISTER_DUPLICATE_MAIL              = 006;
  SR_REGISTER_DUPLICATE_USERNAME          = 007;
  SR_REGISTER_INVALID_MAIL                = 008;
  SR_LIST_CLUBS                           = 009;
  SR_STATUS                               = 010;
  SR_CREATECLUB_OK                        = 011;
  SR_CREATECLUB_NAME_EXISTS               = 012;
  SR_CREATECLUB_INVALID_NAME              = 013;
  SR_CREATECLUB_INVALID_CODE              = 014;
  SR_JOINCLUB_OK                          = 015;
  SR_JOINCLUB_INVALID_ID                  = 016;
  SR_JOINCLUB_INVALID_CODE                = 017;
  SR_JOINCLUB_ALREADY_MEMBER              = 018;
  SR_LEAVECLUB_OK                         = 019;
  SR_LEAVECLUB_INVALID_ID                 = 020;
  SR_KICKPLAYER_OK                        = 021;
  SR_KICKPLAYER_INVALID_CLUB_ID           = 022;
  SR_KICKPLAYER_INVALID_PLAYER_ID         = 023;
  SR_OWNERSHIP_GIVEAWAY_NOT_OWNER         = 024;
  SR_OWNERSHIP_GIVEAWAY_INVALID_PLAYER_ID = 025;
  SR_OWNERSHIP_GIVEAWAY_INVALID_CLUB_ID   = 026;
  SR_OWNERSHIP_GIVEAWAY_OK                = 027;
  SR_CLUB_DETAILS_CHANGE_OK               = 028;
  SR_CLUB_DETAILS_CLUBNAME_EXISTS         = 029;
  SR_CLUB_DISBAND_OK                      = 030;
  SR_CLUB_TRANFER_CHIPS_OK                = 031;
  SR_CLUB_TRANFER_CHIPS_INVALID_AMOUNT    = 032;
  SR_CREATECLUB_NO_GOLD                   = 033;
  SR_CLUB_DETAILS_CHANGE_NO_GOLD          = 034;
  SR_CHANGE_MAIL_OK                       = 035;
  SR_CHANGE_MAIL_INVALID_MAIL             = 036;
  SR_CHANGE_MAIL_DUPLICATE_MAIL           = 037;
  SR_CHANGE_PASSWORD_OK                   = 038;
  SR_CHANGE_PASSWORD_INVALID_PASSWORD     = 039;
  SR_CHANGE_AVATAR_OK                     = 040;
  SR_CHANGE_AVATAR_INVALID_ID             = 041;
  SR_CREATE_GAME_OK                       = 042;
  SR_DELETE_GAME_OK                       = 043;
  SR_EDIT_GAME_OK                         = 044;
  SR_SECONDARY_LOGIN_DETECTED             = 045;
  SR_DECKREPLY                            = 46;

  CMD_LOGIN                               = 501;
  CMD_STATUS                              = 502;
  CMD_REGISTER                            = 503;
  CMD_FORGOT_PASSWORD                     = 504;
  CMD_LOGOUT                              = 505;
  CMD_GETDECK                             = 506;


implementation

end.
