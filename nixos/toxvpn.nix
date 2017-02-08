{ stdenv, fetchFromGitHub, libtoxcore, cmake, jsoncpp, lib, stdenvAdapters, libsodium, systemd, enableDebugging, libcap, zeromq }:

with lib;

let
  libtoxcoreLocked = stdenv.lib.overrideDerivation libtoxcore (oldAttrs: {
    name = "libtoxcore-20160907";
    src = fetchFromGitHub {
      owner = "cleverca22";
      repo = "toxcore";
      rev = "e4cc8c9";
      sha256 = "01i1cm5rwga7qfhjfyf6k4k410splyrgnd8icr3sldykyma3f85w";
    };
    NIX_CFLAGS_COMPILE = [ "-DMIN_LOGGER_LEVEL=LOG_TRACE" "-ggdb -Og" ];
    configureFlags = oldAttrs.configureFlags ++ [ "--enable-debug" ];

    dontStrip = true;
  });

in stdenv.mkDerivation {
  name = "toxvpn-20160909";

  src2 = fetchFromGitHub {
    owner  = "cleverca22";
    repo   = "toxvpn";
    rev    = "6e188f26fff8bddc1014ee3cc7a7423f9f344a09";
    sha256 = "1bshc6pzk7z7q7g17cwx9gmlcyzn4szqvdiy0ihbk2xmx9k31c6p";
  };
  src = /root/toxvpn;

  dontStrip = true;

  NIX_CFLAGS_COMPILE = [ "-ggdb -Og" ];

  buildInputs = [ cmake libtoxcoreLocked jsoncpp libsodium libcap zeromq ] ++ optional (systemd != null) systemd;

  cmakeFlags = (optional (systemd != null) [ "-DSYSTEMD=1" ]) ++
    [ ''-DBOOTSTRAP_PATH=''${out}/share/toxvpn/bootstrap.json'' ];

  postInstall = ''
    mkdir -pv ''${out}/share/toxvpn
    cp -vi ../bootstrap.json ''${out}/share/toxvpn/bootstrap.json
  '';

  meta = with stdenv.lib; {
    description = "A powerful tool that allows one to make tunneled point to point connections over Tox";
    homepage    = https://github.com/cleverca22/toxvpn;
    license     = licenses.gpl3;
    maintainers = with maintainers; [ cleverca22 obadz ];
    platforms   = platforms.linux;
  };
}
