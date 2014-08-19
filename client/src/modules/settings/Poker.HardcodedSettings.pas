unit Poker.HardcodedSettings;

interface

{$I defines.inc}

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
        TCP_PING_INTERVAL: Byte;
        TCP_INACTIVITY_PING_INTERVAL: Byte;
        TCP_PING_TIMEOUT: Byte;
        HAND_HISTORY_HAND_LIMIT_PER_TABLE: Word;
        DIRECTX_SWAPCHAIN_COUNT: Byte;
        TABLE_CHAT_SCROLLBACK_LINES: Word;

        SERVER_CONFIG: array[0..2] of record
          TCPAddress: String;
          TCPPort: Word;
          URL: String;
        end;

        ASSETS: record
          DIRECTORY: String;
          DIRECTX_MEDIA: String;
        end;

        UPDATE_FILES: array[0..7] of record
          Path: String;
          RequiresReboot: Boolean;
        end;

        ANIMATION_METRICS: record
          DEALING_INITIAL_DELAY: Single;
          DEALING_CARD_SPEED: Single;
          DEALING_CARD_DELAY: Single;

          POTS_INITIAL_DELAY: Single;
          POTS_INBETWEEN_DELAY: Single;
          POTS_END_DELAY: Single;

          BETS_SPEED: Single;
          BETS_START_DELAY: Single;
        end;

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
        VERSION: '0.01a';
        REVISION: {$I revision.inc};

        INSTANCE_MUTEX_NAME: 'CHIPUPINSTANCEMUTEX';

        SETTINGS_FILENAME: 'settings.dat';
        SETTINGS_ENCRYPTION_KEY: 'kVb5XrH2ntvjAsjY';
        DATABASE_FILENAME: 'database.sqlite';

        TCP_PING_INTERVAL: 60; // send ping once these xx seconds, no matter what
        TCP_INACTIVITY_PING_INTERVAL: 5; // send ping after this much seconds of inactivity (no command received or sent)
        TCP_PING_TIMEOUT: 15; // in seconds

        HAND_HISTORY_HAND_LIMIT_PER_TABLE: 1000; // amount of hands to store per table
        DIRECTX_SWAPCHAIN_COUNT: 64; // directx swapchain count
        TABLE_CHAT_SCROLLBACK_LINES: 200; // amount of chat lines to store per table

        // server configs
        SERVER_CONFIG: (
          (TCPAddress: 'server.chipuppoker.com'; TCPPort: 12346; URL: 'https://www.chipuppoker.com'),
          (TCPAddress: 'dev-server.chipuppoker.com'; TCPPort: 12346; URL: 'https://dev-server.chipuppoker.com'),
          (TCPAddress: 'localchipup'; TCPPort: 12346; URL: 'http://localchipup')
        );

        // assets paths
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

        // animation metrics. times are in seconds
        ANIMATION_METRICS: (
          DEALING_INITIAL_DELAY: 1.5;
          DEALING_CARD_SPEED: 0.22;
          DEALING_CARD_DELAY: 0.05;

          POTS_INITIAL_DELAY: 0.3;
          POTS_INBETWEEN_DELAY: 0.5;
          POTS_END_DELAY: 0.5;

          BETS_SPEED: 0.3;
          BETS_START_DELAY: 0.2;
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


