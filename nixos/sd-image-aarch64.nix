{ config, lib, pkgs, ... }:

let
  extlinux-conf-builder =
    import <nixpkgs/nixos/modules/system/boot/loader/generic-extlinux-compatible/extlinux-conf-builder.nix> {
      pkgs = pkgs.buildPackages;
    };
in
{
  imports = [
    ./sd-image.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.consoleLogLevel = lib.mkDefault 7;

  boot.kernelParams = [
    "cma=32M"
    #"console=ttyS0,115200n8" "console=ttyAMA0,115200n8" "console=tty0"
    "console=ttyS2,1500000n8" "earlycon=uart8250,mmio32,0xff1a0000" "earlyprintk"
  ];

  boot.initrd.availableKernelModules = [
  ];

  sdImage = {
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${extlinux-conf-builder} -t 3 -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };

  # the installation media is also the installation target,
  # so we don't want to provide the installation configuration.nix.
  installer.cloneConfig = false;
}
