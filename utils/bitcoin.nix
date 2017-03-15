let
  pkgs = import <nixpkgs> { config = {}; };
  gen = pkgs.writeScriptBin "gen-cfg" ''
    #!/bin/sh
    mkdir ~/.bitcoin/
    cat > ~/.bitcoin/bitcoin.conf <<EOF
    rpcuser=$(pwgen)
    rpcpass=$(pwgen)
    EOF
  '';
  nety = hostname: { pkgs, ... }:
  {
    virtualisation.graphics = false;
    networking.hostName = hostname;
    environment.systemPackages = [ pkgs.bitcoin gen pkgs.pwgen ];
    services.mingetty.autologinUser = "root";
    virtualisation.diskSize = 15 * 1024;
    virtualisation.memorySize = 2048;
  };
  chilly = hostname: { pkgs, ... }:
  {
    virtualisation.graphics = false;
    networking.hostName = hostname;
    environment.systemPackages = [ pkgs.bitcoin gen pkgs.pwgen ];
    virtualisation.qemu.networkingOptions = [ "-net none" ];
    services.mingetty.autologinUser = "root";
    virtualisation.diskSize = 15 * 1024;
    virtualisation.memorySize = 2048;
  };
  thunk = import <nixpkgs/nixos>;
  makeVm = cfg: (thunk { configuration = cfg; }).vm;
in
rec {
  vm1 = makeVm (chilly "vm1");
  vm2 = makeVm (nety "vm2");
  vm3 = makeVm (nety "vm3");
  all = pkgs.runCommand "all" {} ''
    mkdir $out
    cd $out
    ln -sv ${vm1}/bin/run-vm1-vm vm1
    ln -sv ${vm2}/bin/run-vm2-vm vm2
    ln -sv ${vm3}/bin/run-vm3-vm vm3
  '';
}
