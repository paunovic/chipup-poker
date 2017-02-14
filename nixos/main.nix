{ pkgs, ... }:

let
  keys = import ./keys.nix;
in {
  imports = [ ./vim.nix ];
  services = {
    fail2ban = {
      enable = true;
    };
    bind = {
      enable = true;
      blockedNetworks = [ "130.211.31.137" "110.68.84.72" "110.165.126.148" "111.250.82.160" "64.62.138.21" ];
      zones = [
        {
          name = "chipuppoker.com";
          slaves = [ "190.124.250.111" ];
          file = ./chipuppoker.zone;
        }
      ];
    };
    openssh = {
      enable = true;
      passwordAuthentication = false;
    };
    toxvpn = {
      enable = true;
      localip = "192.168.144.1";
    };
    zfs.autoSnapshot.enable = true;
    mongodb = {
      enable = true;
    };
    nginx = {
      enable = true;
      virtualHosts = {
        "chipuppoker.com" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/".proxyPass = "http://127.0.0.1:3000/";
            #"/contactPost".proxyPass = "http://127.0.0.1:3000/";
            #"/" = {
            #root = /home/poker/chipuppoker/server/files;
            #};
            "/unpacked".root = "/home/poker/";
            "/diffs".root = "/home/poker/";
            "/rawinstallers".root = "/home/poker/";
          };
          serverAliases = [ "www.chipuppoker.com" ];
        };
        "server.chipuppoker.com" = {
          enableACME = true;
          forceSSL = true;
        };
        "buildbot.chipuppoker.com" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/".proxyPass = "http://127.0.0.1:8010/";
            "/ws" = {
              proxyPass = "http://127.0.0.1:8010/ws";
              extraConfig = ''
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";
                proxy_read_timeout 6000s;
              '';
            };
          };
        };
      };
    };
    dovecot2.enable = false;
    postfix = {
      enable = true;
      relayDomains = [ "chipuppoker.com" ];
      #domain = "test.earthtools.ca";
    };
    exim = {
      enable = false;
      config = ''
        domainlist local_domains = chipuppoker.com
        domainlist relay_to_domains =
        hostlist   relay_from_hosts = 127.0.0.1

        acl_smtp_rcpt = acl_check_rcpt
        acl_smtp_data = acl_check_data

        never_users = root

        host_lookup = *

        rfc1413_hosts = *
        rfc1413_query_timeout = 0s

        prdr_enable = true

        ignore_bounce_errors_after = 2d
        timeout_frozen_after = 7d

        begin acl

        acl_check_rcpt:
        accept  hosts = :

        deny    message       = Restricted characters in address
                domains       = +local_domains
                local_parts   = ^[.] : ^.*[@%!/|]

        deny    message       = Restricted characters in address
                domains       = !+local_domains
                local_parts   = ^[./|] : ^.*[@%!] : ^.*/\\.\\./

        accept  local_parts   = postmaster
                domains       = +local_domains

        require verify        = sender

        accept  hosts         = +relay_from_hosts
                control       = submission

        accept  authenticated = *
                control       = submission

        require message = relay not permitted
                domains = +local_domains : +relay_to_domains

        require verify = recipient

        accept

        acl_check_data:
        accept
      '';
    };
  };
  users = {
    extraUsers = {
      root.openssh.authorizedKeys.keys = [ keys.clever.desktop ];
      poker = {
        openssh.authorizedKeys.keys = [ keys.clever.desktop ];
        isNormalUser = true;
        uid = 1000;
        extraGroups = [ "sslkeys" ];
      };
    };
    extraGroups.sslkeys.gid = 500;
  };
  environment.systemPackages = with pkgs; [ nix-repl screen socat gitAndTools.gitFull ncdu ];
  nixpkgs.config = import ./config.nix;
  networking.firewall = {
    allowedTCPPorts = [ 25 80 443 12346 9989 53 ];
    allowedUDPPorts = [ 33445 53 ]; # toxvpn, dns
  };
  systemd.services.poker = {
    description = "main poker process";
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ poker innoextract ];
    enable = true;
    environment = {
      CONFIG_FILE = "/home/poker/chipuppoker/config.json";
    };
    script = ''
      cd /home/poker/chipuppoker
      ${pkgs.poker}/bin/poker-master
    '';
    serviceConfig = {
      User = "poker";
    };
    requires = [ "mongodb.service" "nginx.service" ];
    after = [ "mongodb.service" "nginx.service" ];
  };
}
