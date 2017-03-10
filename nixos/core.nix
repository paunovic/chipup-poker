{ pkgs, ... }:

let
  keys = import ./keys.nix;
in {
  imports = [ ./vim.nix ];
  programs = {
    screen = {
      screenrc = ''
        caption always
        defscrollback 5000
      '';
    };
    ssh.knownHosts = [
      { hostNames = [ "github.com" ]; publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=="; }
      { hostNames = [ "dev-server.chipuppoker.com" ]; publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEv7A+5gPmp0d5qDk++Cvb0c4Nv6ammceaQZxHRacjhy"; }
      { hostNames = [ "192.168.123.11" ]; publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJhJRINrY5cFcqZ76GsAK7FU+wQhErlS6APdOIm7xcnW"; }
    ];
  };
  services = {
    openssh.enable = true;
  };
  users = {
    extraUsers = {
      root.openssh.authorizedKeys.keys = [ keys.clever.desktop ];
      builder = {
        uid = 1001;
        isNormalUser = true;
        openssh.authorizedKeys.keys = with keys; [ clever.hydra clever.amdDistro ];
      };
    };
  };
  environment.systemPackages = with pkgs; [ nix-repl screen socat gitAndTools.gitFull ncdu ];
  nixpkgs.config = import ./config.nix;
  system.extraSystemBuilderCmds = ''
    ln -sv ${./.} $out/nixcfg
  '';
}
