{ srcs
, pickedSrcs
}:
self: super:
{
  imx-usb-loader = self.callPackage ./pkgs/development/tools/misc/imx-usb-loader {};
}
