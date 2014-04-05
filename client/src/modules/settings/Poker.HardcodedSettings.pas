unit Poker.HardcodedSettings;

interface

{$I defines.inc}

const
  URL_DOMAIN = 'http://chipuppoker.com';
  DEV_URL_DOMAIN = 'http://dev-server.chippuppoker.com';

type
  THardcodedSettings = class
  private
    type
      THardcodedSettingsRec = record
        VERSION: String;
        REVISION: String;
        INSTANCE_MUTEX_NAME: String;
        SETTINGS_FILENAME: String;
        SETTINGS_ENCRYPTION_KEY: String;
        DATABASE_FILENAME: String;
        TCP_SERVER_ADDRESS: String;
        TCP_DEV_SERVER_ADDRESS: String;
        TCP_SERVER_PORT: Word;
        TCP_PING_INTERVAL: Word;
        TCP_PING_TIMEOUT: Word;
        URL: record
          TOS: String;
          CASHIER: String;
          GET_AVATAR_DEV: String;
          UPLOAD_AVATAR_DEV: String;
          LATEST_VERSION_DEV: String;
          LATEST_VERSION_DEBUG_DEV: String;
          GET_AVATAR: String;
          UPLOAD_AVATAR: String;
          LATEST_VERSION: String;
          LATEST_VERSION_DEBUG: String;
        end;
      end;
  public
    const
      Hardcoded: THardcodedSettingsRec = (
        // version of app
        VERSION: '0.01a.0042';
        REVISION: {$I revision.inc};

        // instance mutex name
        INSTANCE_MUTEX_NAME: 'CHIPUPINSTANCEMUTEX';

        // filenames
        SETTINGS_FILENAME: 'settings.dat';
        SETTINGS_ENCRYPTION_KEY: 'kVb5XrH2ntvjAsjY';
        DATABASE_FILENAME: 'database.sqlite';

        // socket server
        TCP_SERVER_ADDRESS: 'server.chipuppoker.com';
        TCP_DEV_SERVER_ADDRESS: 'dev-server.chipuppoker.com';
        TCP_SERVER_PORT: 12346;
        TCP_PING_INTERVAL: 60; // in seconds
        TCP_PING_TIMEOUT: 15; // in seconds

        // urls
        URL : (
          TOS: URL_DOMAIN + '/tos.html';
          CASHIER: URL_DOMAIN + '/cashier.html';

          GET_AVATAR_DEV: DEV_URL_DOMAIN + '/getavatar?id=%s';
          UPLOAD_AVATAR_DEV: DEV_URL_DOMAIN + '/uploadAvatar';
          LATEST_VERSION_DEV: DEV_URL_DOMAIN + '/install_chipuppoker.exe';
          LATEST_VERSION_DEBUG_DEV: DEV_URL_DOMAIN + '/debug_install_chipuppoker.exe';

          GET_AVATAR: URL_DOMAIN + '/getavatar?id=%s';
          UPLOAD_AVATAR: URL_DOMAIN + '/uploadAvatar';
          LATEST_VERSION: URL_DOMAIN + '/install_chipuppoker.exe';
          LATEST_VERSION_DEBUG: URL_DOMAIN + '/debug_install_chipuppoker.exe';
        )
      );
  end;

implementation

end.


