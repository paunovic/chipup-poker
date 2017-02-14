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
  };
  services = {
    openssh.enable = true;
  };
  users = {
    extraUsers = {
      root.openssh.authorizedKeys.keys = [ keys.clever.desktop ];
    };
  };
  environment.systemPackages = with pkgs; [ nix-repl screen socat gitAndTools.gitFull ncdu ];
  nixpkgs.config = import ./config.nix;
  system.extraSystemBuilderCmds = ''
    ln -sv ${./.} $out/nixcfg
  '';
}
