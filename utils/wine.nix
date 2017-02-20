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
''
