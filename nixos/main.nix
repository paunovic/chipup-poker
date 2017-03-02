{ pkgs, lib, ... }:

let
  keys = import ./keys.nix;
in {
  imports = [ ./core.nix ./poker.nix ];
  services = {
    hydra = {
      enable = true;
      hydraURL = "https://hydra.chipuppoker.com";
      notificationSender = "clever@chipuppoker.com";
      port = 3001;
      listenHost = "localhost";
    };
    fail2ban = {
      enable = true;
    };
    poker.enable = true;
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
      passwordAuthentication = false;
    };
    toxvpn = {
      enable = true;
      localip = "192.168.144.1";
    };
    zfs.autoSnapshot.enable = true;
    nginx = {
      enable = true;
      virtualHosts = {
        "chipuppoker.com" = {
          serverAliases = [ "www.chipuppoker.com" ];
        };
        "hydra.chipuppoker.com" = {
          enableACME = true;
          forceSSL = true;
          basicAuth.buildbot = "keD1Wu2f";
          locations."/".extraConfig = ''
            proxy_pass http://localhost:3001;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header  X-Real-IP         $remote_addr;
            proxy_set_header  X-Forwarded-For   $proxy_add_x_forwarded_for;
          '';
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
        extraGroups = [ "sslkeys" ];
      };
    };
    extraGroups.sslkeys.gid = 500;
  };
  nix.buildMachines = [
    { hostName = "dev-server.chipuppoker.com"; maxJobs = 1; speedFactor = 1; sshKey = "/var/lib/hydra/queue-runner/.ssh/id_rsa"; sshUser = "builder"; system = "x86_64-linux"; }
  ];
  networking.firewall = {
    allowedTCPPorts = [ 25 12346 9989 53 ];
    allowedUDPPorts = [ 33445 53 ]; # toxvpn, dns
  };
}
