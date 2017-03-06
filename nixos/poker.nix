{ pkgs, config, lib, ... }:

with lib;

let
  keys = import ./keys.nix;
  cfg = config.services.poker;
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
    installers = "/home/poker/rawinstallers";
    diffs = "/home/poker/diffs";
    autoConfirm = cfg.autoConfirm;
  };
  genkeyscript = ''
    if [ ! -f ${poker_config.certpath} ]; then
      ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:2048 -keyout ${poker_config.keypath} -out ${poker_config.certpath} -days 3650 -nodes -subj "/CN=localhost"
    fi
  '';
  mkBool = description: default: mkOption { inherit default description; example = !default; };
in {
  imports = [ ./snmpd.nix ];
  options = {
    services.poker = {
      enable = mkEnableOption "enable poker service";
      autoSelfSigned = mkOption {
        default = false;
        example = true;
        type = types.bool;
        description = "autogenerate self-signed keys if they are missing";
      };
      autoConfirm = mkBool "auto-confirm all accounts" false;
      testingEnv = mkBool "testing environment" false;
    };
  };
  config = mkIf config.services.poker.enable {
    networking.firewall = {
      allowedTCPPorts = [ 12346 80 443 ];
    };
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
            forceSSL = ! cfg.testingEnv;
            enableACME = ! cfg.testingEnv;
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
      path = with pkgs; [ poker innoextract bsdiff ];
      enable = true;
      environment = {
        CONFIG_FILE = pkgs.writeText "poker.json" (builtins.toJSON poker_config);
      };
      script = ''
        chmod 701 /home/poker
        mkdir -pv /home/poker/chipuppoker/{server/assets,installers} ${poker_config.upload_dir} ${poker_config.log_dir} ${poker_config.unpacked}/objects ${poker_config.installers} ${poker_config.diffs}
        cd /home/poker/chipuppoker
        ${if config.services.poker.autoSelfSigned then genkeyscript else ""}
        ${pkgs.poker}/bin/poker-master
      '';
      serviceConfig = {
        User = "poker";
        Restart = "on-failure";
      };
      requires = [ "mongodb.service" "nginx.service" ];
      after = [ "mongodb.service" "nginx.service" ];
    };
  };
}
