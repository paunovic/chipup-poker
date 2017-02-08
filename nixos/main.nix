{ pkgs, ... }:

let
  keys = import ./keys.nix;
in {
  imports = [ ./vim.nix ];
  services = {
    bind.enable = true;
    openssh.enable = true;
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
      virtualHosts."chipuppoker.com" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://127.0.0.1:3000/";
      };
    };
    dovecot2.enable = false;
    exim = {
      enable = true;
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
  users.extraUsers = {
    root.openssh.authorizedKeys.keys = [ keys.clever.desktop ];
    poker = {
      openssh.authorizedKeys.keys = [ keys.clever.desktop ];
      isNormalUser = true;
      uid = 1000;
    };
  };
  environment.systemPackages = with pkgs; [ nix-repl screen socat gitAndTools.gitFull ];
  nixpkgs.config.packageOverrides = pkgs: rec {
    toxvpn = pkgs.callPackage ./toxvpn.nix {};
    poker = (pkgs.callPackage /home/poker/chipuppoker/server/default.nix {}).package;
  };
  networking.firewall.allowedTCPPorts = [ 25 80 443 12346 ];
  systemd.services.poker = {
    description = "main poker process";
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.poker ];
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
