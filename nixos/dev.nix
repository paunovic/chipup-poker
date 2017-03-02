{ pkgs, ... }:

let
  keys = import ./keys.nix;
in {
  imports = [ ./core.nix ./poker.nix ];
  networking = {
    hostName = "dev-server.chipuppoker.com";
    firewall = {
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ 33445 53 ];
    };
  };
  nix.trustedUsers = [ "builder" ];
  services = {
    postfix = {
      enable = true;
    };
    poker.enable = true;
    bind = {
      enable = true;
      zones = [
        {
          name = "chipuppoker.com";
          master = false;
          masters = [ "190.124.250.110" ];
          file = "/tmp/chipuppoker.zone";
        }
      ];
    };
    toxvpn = {
      enable = true;
      localip = "192.168.144.2";
    };
    zfs.autoSnapshot.enable = true;
    mongodb = {
      enable = true;
    };
  };
}
