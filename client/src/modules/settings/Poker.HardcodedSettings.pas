unit Poker.HardcodedSettings;

interface

const
  URL_DOMAIN = 'http://chipuppoker.com';

type
  THardcodedSettings = class
  private
    type
      THardcodedSettingsRec = record
                                VERSION                : String;
                                REVISION               : String;
                                INSTANCE_MUTEX_NAME    : String;
                                SETTINGS_FILENAME      : String;
                                SETTINGS_ENCRYPTION_KEY: String;
                                AVATARS_SUBDIR         : String;
                                TCP_SERVER_ADDRESS     : String;
                                TCP_SERVER_PORT        : Word;
                                TCP_PING_INTERVAL      : Word;
                                TCP_PING_TIMEOUT       : Word;
                                URL                    : record
                                  TOS                 : String;
                                  CASHIER             : String;
                                  GET_AVATAR          : String;
                                  UPLOAD_AVATAR       : String;
                                  LATEST_VERSION      : String;
                                  LATEST_VERSION_DEBUG: String;
                                end;
                              end;
  public
    const
      Hardcoded: THardcodedSettingsRec = (
                                           // version of app
                                           VERSION: '0.01a.0030';
                                           REVISION: {$I revision.inc};

                                           // instance mutex name
                                           INSTANCE_MUTEX_NAME: 'CHIPUPINSTANCEMUTEX';

                                           // filenames
                                           SETTINGS_FILENAME: 'settings.dat';
                                           SETTINGS_ENCRYPTION_KEY: 'kVb5XrH2ntvjAsjY';
                                           AVATARS_SUBDIR: 'avatars';

                                           // socket server
                                           TCP_SERVER_ADDRESS: 'server.chipuppoker.com';
                                           TCP_SERVER_PORT: 12346;
                                           TCP_PING_INTERVAL: 60; // in seconds
                                           TCP_PING_TIMEOUT: 15; // in seconds

                                           // urls
                                           URL : (
                                             TOS                 : URL_DOMAIN + '/tos.html';
                                             CASHIER             : URL_DOMAIN + '/cashier.html';
                                             GET_AVATAR          : URL_DOMAIN + '/getavatar?id=%s';
                                             UPLOAD_AVATAR       : URL_DOMAIN + '/uploadAvatar';
                                             LATEST_VERSION      : URL_DOMAIN + '/install_chipuppoker.exe';
                                             LATEST_VERSION_DEBUG: URL_DOMAIN + '/debug_install_chipuppoker.exe';
                                           )
                                         );
  end;

implementation

end.


