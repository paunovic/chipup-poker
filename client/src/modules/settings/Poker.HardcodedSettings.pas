unit Poker.HardcodedSettings;

interface

{$I defines.inc}

type
  THardcodedSettings = class
  private
    type
      TUpdateFile = record
        Path: String;
        RequiresReboot: Boolean;
      end;

      TServerConfig = record
        TCPAddress: String;
        TCPPort: Word;
        URL: String;
      end;

      THardcodedSettingsRec = record
        VERSION: String;
        REVISION: String;
        INSTANCE_MUTEX_NAME: String;
        SETTINGS_FILENAME: String;
        SETTINGS_ENCRYPTION_KEY: String;
        DATABASE_FILENAME: String;
        SERVER_CONFIG: array[0..2] of TServerConfig;
        TCP_PING_INTERVAL: Byte;
        TCP_INACTIVITY_PING_INTERVAL: Byte;
        TCP_PING_TIMEOUT: Byte;
        HAND_HISTORY_HAND_LIMIT_PER_TABLE: Word;
        DIRECTX_SWAPCHAIN_COUNT: Byte;
        TABLE_CHAT_SCROLLBACK_LINES: Word;

        ASSETS: record
          DIRECTORY: String;
          DIRECTX_MEDIA: String;
        end;

        UPDATE_FILES: array[0..7] of TUpdateFile;

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
        VERSION: '0.01a.0145';
        REVISION: {$I revision.inc};

        INSTANCE_MUTEX_NAME: 'CHIPUPINSTANCEMUTEX';

        SETTINGS_FILENAME: 'settings.dat';
        SETTINGS_ENCRYPTION_KEY: 'kVb5XrH2ntvjAsjY';
        DATABASE_FILENAME: 'database.sqlite';

        SERVER_CONFIG: (
          (TCPAddress: 'server.chipuppoker.com'; TCPPort: 12346; URL: 'http://server.chipuppoker.com'),
          (TCPAddress: 'dev-server.chipuppoker.com'; TCPPort: 12346; URL: 'http://dev-server.chipuppoker.com'),
          (TCPAddress: 'localchipup'; TCPPort: 12346; URL: 'http://localchipup')
        );

        TCP_PING_INTERVAL: 60; // send ping once these xx seconds, no matter what
        TCP_INACTIVITY_PING_INTERVAL: 5; // send ping after this much seconds of inactivity
        TCP_PING_TIMEOUT: 15; // in seconds

        HAND_HISTORY_HAND_LIMIT_PER_TABLE: 1000; // 1000 hands per table
        DIRECTX_SWAPCHAIN_COUNT: 64; // directx swapchain count
        TABLE_CHAT_SCROLLBACK_LINES: 200; // table chat scrollback lines

        // resources
        ASSETS: (
          DIRECTORY: 'assets\';
          DIRECTX_MEDIA: 'dxmedia.dat';
        );

        // check these files for update
        UPDATE_FILES: (
          (Path: 'bspatch.exe'; RequiresReboot: TRUE),
          (Path: 'chipuppoker.exe'; RequiresReboot: TRUE),
          (Path: 'libeay32.dll'; RequiresReboot: TRUE),
          (Path: 'ssleay32.dll'; RequiresReboot: TRUE),
          (Path: 'sqlite3.dll'; RequiresReboot: TRUE),
          (Path: 'VclStylesInno.dll'; RequiresReboot: FALSE),
          (Path: 'Carbon.vsf'; RequiresReboot: FALSE),
          (Path: 'assets\dxmedia.dat'; RequiresReboot: FALSE)
        );

        // urls
        URL: (
          TERMS_AND_CONDITIONS: '/termsandconditions.html';
          CASHIER: '/cashier.html';
          GET_AVATAR: '/getavatar?id=%s';
          UPLOAD_AVATAR: '/uploadAvatar';
          LATEST_VERSION: '/install_chipuppoker.exe';
        );
      );
  end;

implementation

end.


