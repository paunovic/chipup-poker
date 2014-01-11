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
                                TCP_SERVER_ADDRESS : String;
                                TCP_SERVER_PORT    : Word;
                                URL                : record
                                  TOS       : String;
                                  BUY_TOKENS: String;
                                  BUY_CHIPS : String;
                                  GET_AVATAR: String;
                                end;
                              end;
  public
    const
      Hardcoded: THardcodedSettingsRec = (
                                           // version of app
                                           VERSION: '0.01a';

                                           // instance mutex name
                                           INSTANCE_MUTEX_NAME: 'CHIPUPINSTANCEMUTEX';

                                           // settings filename
                                           SETTINGS_FILENAME: 'settings.dat';

                                           // socket server
                                           TCP_SERVER_ADDRESS: 'ext.earthtools.ca';
                                           TCP_SERVER_PORT: 12345;

                                           // urls
                                           URL : (
                                             TOS       : URL_DOMAIN + '/tos.html';
                                             BUY_TOKENS: URL_DOMAIN + '/buy-tokens.html';
                                             BUY_CHIPS : URL_DOMAIN + '/buy-chips.html';
                                             GET_AVATAR: URL_DOMAIN + '/getavatar?id=%s';
                                           )
                                         );
  end;

implementation

end.


