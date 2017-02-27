unit Poker.HardcodedSettings;

interface

{$I defines.inc}

type
  THardcodedSettings = class
  private
    type
      THardcodedSettingsRec = record
        VERSION: String;
        PROJECT_INSTANCE_MUTEX: String;
        PROJECT_CAPTION: String;
        INSTALLER_FILENAME: String;
        REVISION: String;
        SETTINGS_FILENAME: String;
        SETTINGS_ENCRYPTION_KEY: String;
        DATABASE_FILENAME: String;
        DATABASE_PASSWORD: String;
        SERVER_PING_INTERVAL: Byte;
        SERVER_INACTIVITY_PING_INTERVAL: Byte;
        SERVER_PING_TIMEOUT: Byte;
        SERVER_CONNECT_TIMEOUT: Byte;
        DIRECTX_SWAPCHAIN_COUNT: Byte;
        TABLE_HAND_HISTORY_LIMIT: Word;
        TABLE_CHAT_SCROLLBACK_LINES: Word;

        SERVER_LIST: array[0..1] of record
          Address: String;
          Port: Word;
          URL: String;
          SSLEnabled: Boolean;
          SSLCertificate: String;
        end;

        ASSETS: record
          DIRECTORY: String;
          DIRECTX_MEDIA: String;
        end;

        RESOURCES: record
          ABOUT_BACKGROUND: String;
          RETRIEVING_AVATAR: String;
          CASHIER_NORMAL: String;
          CASHIER_PRESSED: String;
        end;

        UPDATE_FILES: array[0..6] of record
          Path: String;
          RequiresRestart: Boolean;
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
        PROJECT_INSTANCE_MUTEX: 'CHIPUPINSTANCEMUTEX';
        PROJECT_CAPTION: 'ChipUP Poker';
        INSTALLER_FILENAME: 'install_chipuppoker.exe';
        REVISION: {$I revision.inc};

        SETTINGS_FILENAME: 'settings.dat';
        SETTINGS_ENCRYPTION_KEY: 'kVb5XrH2ntvjAsjY';
        DATABASE_FILENAME: 'database.sqlite';
        DATABASE_PASSWORD: 'UhpGVY5Cx0I40QKl';

        SERVER_PING_INTERVAL: 60; // send ping once these xx seconds, no matter what
        SERVER_INACTIVITY_PING_INTERVAL: 5; // send ping after this much seconds of inactivity (no command received or sent)
        SERVER_PING_TIMEOUT: 15; // in seconds
        SERVER_CONNECT_TIMEOUT: 10; // in seconds

        DIRECTX_SWAPCHAIN_COUNT: 64; // directx swapchain count

        TABLE_HAND_HISTORY_LIMIT: 1000; // amount of hands to store per table
        TABLE_CHAT_SCROLLBACK_LINES: 200; // amount of chat lines to store per table

        // server list
        SERVER_LIST: (
          (
           Address: 'server.chipuppoker.com';
           Port: 12346;
           URL: 'https://www.chipuppoker.com';
           SSLEnabled: TRUE;
           SSLCertificate: 'OfficialServerCertificate'
          ),

          (
           Address: 'dev-server.chipuppoker.com';
           Port: 12346;
           URL: 'https://dev-server.chipuppoker.com';
           SSLEnabled: TRUE;
           SSLCertificate: 'DevServerCertificate'
          )
        );

        // assets paths
        ASSETS: (
          DIRECTORY: 'assets\';
          DIRECTX_MEDIA: 'dxmedia.cpa';
        );

        // resource names
        RESOURCES: (
          ABOUT_BACKGROUND: 'AboutBackground';
          RETRIEVING_AVATAR: 'RetrievingAvatar';
          CASHIER_NORMAL: 'CashierNormal';
          CASHIER_PRESSED: 'CashierPressed';
        );

        // check these files for update
        UPDATE_FILES: (
          (Path: 'bspatch.exe'; RequiresRestart: TRUE),
          (Path: 'chipuppoker.exe'; RequiresRestart: TRUE),
          (Path: 'libeay32.dll'; RequiresRestart: TRUE),
          (Path: 'ssleay32.dll'; RequiresRestart: TRUE),
          (Path: 'VclStylesInno.dll'; RequiresRestart: FALSE),
          (Path: 'Carbon.vsf'; RequiresRestart: FALSE),
          (Path: 'assets\dxmedia.cpa'; RequiresRestart: FALSE)
        );

        // animation metrics, times are in seconds
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


