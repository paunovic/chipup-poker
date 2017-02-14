{ pkgs, config, lib, ... }:

with lib;

let
  keys = import ./keys.nix;
  poker_config = {
    keypath = "/home/poker/chipuppoker/key.pem";
    certpath = "/home/poker/chipuppoker/cert.pem";
    hostname = config.networking.hostName;
    staticserver = config.networking.hostName; # deprecated
    diffserver = true;
    syncpassword = "Aim8Aevu";
    upload_dir = "/home/poker/upload";
    log_dir = "/home/poker/logs";
    unpacked = "/home/poker/unpacked";
  };
in {
  options = {
    services.poker = {
      enable = mkEnableOption "enable poker service";
    };
  };
  config = mkIf config.services.poker.enable {
    users = {
      extraUsers = {
        poker = {
          openssh.authorizedKeys.keys = [ keys.clever.desktop ];
          isNormalUser = true;
          uid = 1000;
        };
      };
    };
    services = {
      mongodb = {
        enable = true;
      };
      nginx = {
        enable = true;
        virtualHosts = {
          ${config.networking.hostName} = {
            forceSSL = true;
            enableACME = true;
            locations = {
              "/".proxyPass = "http://127.0.0.1:3000/";
              "/unpacked".root = "/home/poker/";
              "/diffs".root = "/home/poker/";
              "/rawinstallers".root = "/home/poker/";
            };
            #serverAliases = [ "www.chipuppoker.com" ];
          };
        };
      };
    };
    systemd.services.poker = {
      description = "main poker process";
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ poker innoextract ];
      enable = true;
      environment = {
        CONFIG_FILE = pkgs.writeText "poker.json" (builtins.toJSON poker_config);
      };
      script = ''
        mkdir -pv /home/poker/chipuppoker/server/assets/ ${poker_config.upload_dir} ${poker_config.log_dir} ${poker_config.unpacked}
        cd /home/poker/chipuppoker
        ${pkgs.poker}/bin/poker-master
      '';
      serviceConfig = {
        User = "poker";
      };
      requires = [ "mongodb.service" "nginx.service" ];
      after = [ "mongodb.service" "nginx.service" ];
    };
  };
}
