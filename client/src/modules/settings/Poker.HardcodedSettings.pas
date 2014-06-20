unit Poker.HardcodedSettings;

interface

{$I defines.inc}

const
  URL_DOMAIN = 'http://www.chipuppoker.com';
  DEV_URL_DOMAIN = 'http://dev-server.chipuppoker.com';

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
        TCP_PING_INTERVAL: Byte;
        TCP_INACTIVITY_PING_INTERVAL: Byte;
        TCP_PING_TIMEOUT: Byte;
        HAND_HISTORY_HAND_LIMIT_PER_TABLE: Word;
        DIRECTX_SWAPCHAIN_COUNT: Byte;
        TABLE_CHAT_SCROLLBACK_LINES: Word;

        RESOURCES: record
          DIRECTORY: String;
          DIRECTX_MEDIA: String;
        end;

        UPDATE_FILES: array[0..7] of String;

        URL: record
          TERMS_AND_CONDITIONS: String;
          CASHIER: String;
          GET_AVATAR: String;
          UPLOAD_AVATAR: String;
          LATEST_VERSION: String;
        end;
      end;
  public
    const
      Hardcoded: THardcodedSettingsRec = (
        VERSION: '0.01a.0140';
        REVISION: {$I revision.inc};

        INSTANCE_MUTEX_NAME: 'CHIPUPINSTANCEMUTEX';

        SETTINGS_FILENAME: 'settings.dat';
        SETTINGS_ENCRYPTION_KEY: 'kVb5XrH2ntvjAsjY';
        DATABASE_FILENAME: 'database.sqlite';

        TCP_SERVER_ADDRESS: 'server.chipuppoker.com';
        TCP_DEV_SERVER_ADDRESS: 'dev-server.chipuppoker.com';
        TCP_SERVER_PORT: 12346;
        TCP_PING_INTERVAL: 60; // send ping once these xx seconds, no matter what
        TCP_INACTIVITY_PING_INTERVAL: 5; // send ping after this much seconds of inactivity
        TCP_PING_TIMEOUT: 15; // in seconds

        HAND_HISTORY_HAND_LIMIT_PER_TABLE: 1000; // 1000 hands per table
        DIRECTX_SWAPCHAIN_COUNT: 64; // directx swapchain count
        TABLE_CHAT_SCROLLBACK_LINES: 200; // table chat scrollback lines

        // resources
        RESOURCES: (
          DIRECTORY: 'resources\';
          DIRECTX_MEDIA: 'dxmedia.dat';
        );

        // check these files for update
        UPDATE_FILES: ('chipuppoker.exe', 'libeay32.dll', 'ssleay32.dll', 'VclStylesInno.dll', 'Carbon.vsf',
           'bspatch.exe', 'sqlite3.dll', 'resources\dxmedia.dat');

        // urls
        URL: (
          TERMS_AND_CONDITIONS: URL_DOMAIN + '/termsandconditions.html';
          CASHIER: URL_DOMAIN + '/cashier.html';
          GET_AVATAR: '/getavatar?id=%s';
          UPLOAD_AVATAR: '/uploadAvatar';
          LATEST_VERSION: '/install_chipuppoker.exe';
        );
      );
  end;

implementation

end.


