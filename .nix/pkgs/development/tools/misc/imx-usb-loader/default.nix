{ lib, stdenv
, fetchFromGitHub
, pkg-config
, libusb1
}:

stdenv.mkDerivation rec {
  pname = "imx-usb-loader-unstable";
  version = "2020-01-03";

  src = fetchFromGitHub {
    owner = "boundarydevices";
    repo = "imx_usb_loader";
    # Matches as much as possible revision from
    # `ide/meta-freescale/recipes-devtools/imx-usb-loader/imx-usb-loader_git.bb`.
    rev = "30b43d69770cd69e84c045dc9dcabb1f3e9d975a";
    sha256 = "1jdxbg63qascyl8x32njs9k9gzy86g209q7hc0jp74qyh0i6fwwc";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ libusb1 ];

  makeFlags = [ "prefix=$(out)" ];

  meta = with lib; {
    description = "i.MX/Vybrid recovery utility";
    longDescription = ''
      This utility allows to download and execute code on Freescale
      i.MX5/i.MX6/i.MX7 and Vybrid SoCs through the Serial Download Protocol (SDP).
      Depending on the board, there is usually some kind of recovery button to bring
      the SoC into serial download boot mode, check documentation of your hardware.

      The utility support USB and UART as serial link.
    '';
    homepage = "https://github.com/boundarydevices/imx_usb_loader";
    license = licenses.lgpl21;
    maintainers = [ maintainers.jraygauthier ];
    platforms = platforms.all;
  };
}
