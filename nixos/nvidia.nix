# NVIDIA PRIME offload for an Intel + NVIDIA hybrid laptop.
# The Intel iGPU drives the display; run programs on the NVIDIA GPU with:
#   nvidia-offload <program>
#
# Usage: add ./nvidia.nix to `imports` in configuration.nix.
{ config, pkgs, ... }:
{
  hardware.graphics.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;

    # true  = open kernel module, for RTX 20xx / GTX 16xx and newer (Turing+)
    # false = proprietary module, required for GTX 10xx and older
    # Check the model with: lspci -s 01:00.0
    open = true;

    # If the module fails to build on a very new kernel, try
    # nvidiaPackages.beta, or use the LTS kernel:
    #   boot.kernelPackages = pkgs.linuxPackages;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    nvidiaSettings = true;

    powerManagement.enable = false;
    # Turns the dGPU off when idle (Turing+ only); enable once things work.
    powerManagement.finegrained = false;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # From lshw/lspci (hex) converted to decimal: 00:02.0 and 01:00.0
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
