{ wineUnstable, runCommand }:

runCommand "wine-utils" {} ''
mkdir -pv $out/bin/

cat > $out/bin/cfg <<EOF
#!/bin/sh

for x in {1..5}; do
  WINEPREFIX=\$HOME/.wine-poker\''${x}/ ${wineUnstable}/bin/winecfg &
done
EOF
chmod +x $out/bin/cfg

cat > $out/bin/install <<EOF
#!/bin/sh

for x in {1..5}; do
  WINEPREFIX=\$HOME/.wine-poker\''${x}/ ${wineUnstable}/bin/wine "\$@" &
done
EOF
chmod +x $out/bin/install

cat > $out/bin/run <<EOF
#!/bin/sh

for x in {1..5}; do
  WINEPREFIX=\$HOME/.wine-poker\''${x}/ ${wineUnstable}/bin/wine "\$HOME/.wine-poker\''${x}/drive_c/users/Public/Application Data/Programs/ChipUP Poker/chipuppoker.exe" &
done
EOF
chmod +x $out/bin/run

cat > $out/bin/run1 <<EOF
#!/bin/sh
WINEPREFIX=\$HOME/.wine-poker\''${1}/ ${wineUnstable}/bin/wine "\$HOME/.wine-poker\''${1}/drive_c/users/Public/Application Data/Programs/ChipUP Poker/chipuppoker.exe" &
EOF
chmod +x $out/bin/run1

cat > $out/bin/stop <<EOF
#!/bin/sh
WINEPREFIX=\$HOME/.wine-poker\''${1}/ ${wineUnstable}/bin/wineserver -k
EOF
chmod +x $out/bin/stop
''
