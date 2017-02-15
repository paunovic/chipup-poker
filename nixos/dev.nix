{ pkgs, ... }:

let
  keys = import ./keys.nix;
in {
  imports = [ ./core.nix ./poker.nix ];
  networking = {
    hostName = "dev-server.chipuppoker.com";
    firewall = {
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ 33445 ];
    };
  };
  services = {
    poker.enable = true;
    bind = {
      enable = true;
      zones = [
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
