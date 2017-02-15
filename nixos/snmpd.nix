{ pkgs, lib, ... }:

with lib;
{
  systemd.services.snmpd = let
    snmpconfig = pkgs.writeTextFile {
      name = "snmpd.conf";
      text = ''
        rocommunity BioQu6Lu
        disk / 10000
        extend cputemp ${pkgs.stdenv.shell} -c "${pkgs.acpi}/bin/acpi -t|egrep -o '[0-9\.]{3,}'"
      '';
    };
  in {
    description = "net-snmp daemon";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.net_snmp}/bin/snmpd -f -c ${snmpconfig}";
      KillMode = "process";
      Restart = "always";
    };
  };
  networking.firewall.extraCommands = mkMerge [ (mkAfter ''
    iptables -w -t filter -A nixos-fw -i tox_master0 -p udp --dport 161 -j nixos-fw-accept
  '') ];
}
