unit uHardcodedSettings;

interface

const
  URL_DOMAIN = 'http://chipuppoker.com';

type
  THardcodedSettings = class
  private
    type
      THardcodedSettingsRec = record
                                VERSION            : String;
                                INSTANCE_MUTEX_NAME: String;
                                SETTINGS_FILENAME  : String;
                                AVATARS_SUBDIR     : String;
                                TCP_SERVER_ADDRESS : String;
                                TCP_SERVER_PORT    : Word;
                                TCP_PING_INTERVAL  : Word;
                                TCP_PING_TIMEOUT   : Word;
                                URL                : record
                                  TOS          : String;
                                  BUY_CHIPS    : String;
                                  GET_AVATAR   : String;
                                  UPLOAD_AVATAR: String;
                                end;
                              end;
  public
    const
      Hardcoded: THardcodedSettingsRec = (
                                           // version of app
                                           VERSION: '0.01a';

                                           // instance mutex name
                                           INSTANCE_MUTEX_NAME: 'CHIPUPINSTANCEMUTEX';

                                           // filenames
                                           SETTINGS_FILENAME: 'settings.dat';
                                           AVATARS_SUBDIR: 'avatars';

                                           // socket server
                                           TCP_SERVER_ADDRESS: 'server.chipuppoker.com';
                                           TCP_SERVER_PORT: 12346;
                                           TCP_PING_INTERVAL: 300; // in seconds
                                           TCP_PING_TIMEOUT: 15; // in seconds

                                           // urls
                                           URL : (
                                             TOS          : URL_DOMAIN + '/tos.html';
                                             BUY_CHIPS    : URL_DOMAIN + '/buy-chips.html';
                                             GET_AVATAR   : URL_DOMAIN + '/getavatar?id=%s';
                                             UPLOAD_AVATAR: URL_DOMAIN + '/uploadAvatar';
                                           )
                                         );
  end;

implementation

end.


