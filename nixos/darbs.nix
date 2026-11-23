{ config, lib, pkgs, ... }:
let
  src = ../.local/src;
  freetypeInc = "FREETYPEINC=${pkgs.freetype.dev}/include/freetype2";

  dwm = pkgs.dwm.overrideAttrs (old: {
    src = src + "/dwm";
    preBuild = "make clean\n" + (old.preBuild or "");
    buildInputs = old.buildInputs ++ [ pkgs.libxcb ];
    makeFlags = (old.makeFlags or [ ]) ++ [ freetypeInc ];
  });
  st = pkgs.st.overrideAttrs (old: {
    src = src + "/st";
    preBuild = "make clean\n" + (old.preBuild or "");
    buildInputs = old.buildInputs ++ [ pkgs.harfbuzz ];
  });
  dmenu = pkgs.dmenu.overrideAttrs (old: {
    src = src + "/dmenu";
    preBuild = "make clean\n" + (old.preBuild or "");
    makeFlags = (old.makeFlags or [ ]) ++ [ freetypeInc ];
  });
  dwmblocks = pkgs.dwmblocks.overrideAttrs (old: {
    src = src + "/dwmblocks";
    preBuild = "make clean\n" + (old.preBuild or "");
    postPatch = "";
  });
  slock = pkgs.slock.overrideAttrs (old: {
    src = src + "/slock";
    preBuild = "make clean\n" + (old.preBuild or "");
    postPatch = ''
      sed -i '/chmod u+s/d' Makefile
      sed -i 's/group = "nobody"/group = "nogroup"/' config.h
    '';
  });
in
{
  options.darbs.user = lib.mkOption {
    type = lib.types.str;
    description = "The user who runs dwm.";
  };

  config = {
    services.xserver = {
      enable = true;
      displayManager.startx.enable = true;
    };

    programs.slock = { enable = true; package = slock; };
    programs.dconf.enable = true;
    programs.thunar.enable = true;
    environment.sessionVariables.XDG_DATA_DIRS = [
      (pkgs.glib.getSchemaDataDirPath pkgs.gsettings-desktop-schemas)
    ];

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;
    };
    security.rtkit.enable = true;
    networking.networkmanager.enable = true;
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = "*";
    };

    fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono noto-fonts noto-fonts-color-emoji ];

    environment.systemPackages = [ dwm st dmenu dwmblocks ] ++ (with pkgs; [
      xsetroot xset xrandr xrdb
      xss-lock xwallpaper unclutter dunst libnotify xcompmgr
      networkmanagerapplet lxqt.lxqt-policykit glib
      wireplumber pulseaudio
      maim slop xclip xdotool xdg-user-dirs xdg-utils brightnessctl playerctl
      psmisc bc file ffmpeg adwaita-icon-theme
      neovim htop pulsemixer pass librewolf
    ]);

    users.users.${config.darbs.user}.extraGroups = [ "networkmanager" "video" ];
  };
}
