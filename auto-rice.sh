#!/bin/bash
#
# dwm Auto Rice - Gruvbox Theme
# For Arch and Arch based distributions (EndeavourOS, CachyOS, ...) and Fedora.
# Always check the contents of a script before running it.

set -e

REPO_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
. "$REPO_DIR/common.sh"

# Artix has pacman too, but no systemd, so it has its own script
if grep -qs '^ID=artix' /etc/os-release; then
    echo "This is Artix. Run ./auto-rice-artix.sh instead." >&2
    exit 1
fi

install_arch() {
    sudo pacman -S --needed "${ARCH_PACKAGES[@]}"
}

install_fedora() {
    # LibreWolf is not in the Fedora repos, so add its official repo
    if [ ! -e /etc/yum.repos.d/librewolf.repo ]; then
        curl -fsSL https://repo.librewolf.net/librewolf.repo \
            | sudo tee /etc/yum.repos.d/librewolf.repo > /dev/null
    fi

    # pactl comes from pulseaudio-utils and nmtui from NetworkManager-tui on
    # Fedora. The -devel packages are for building the suckless programs and
    # xwallpaper.
    sudo dnf install \
        gcc make pkgconf-pkg-config \
        libX11-devel libXft-devel libXinerama-devel libXrandr-devel libXext-devel \
        libXres-devel libxcb-devel libXrender-devel freetype-devel fontconfig-devel harfbuzz-devel libxcrypt-devel \
        xcb-util-devel xcb-util-image-devel pixman-devel libjpeg-turbo-devel libpng-devel \
        libXpm-devel libseccomp-devel \
        xorg-x11-server-Xorg xorg-x11-xinit xsetroot xset xrandr xrdb xorg-x11-drv-libinput \
        xss-lock unclutter dunst libnotify xcompmgr \
        pipewire pipewire-pulseaudio pipewire-alsa wireplumber pulseaudio-utils \
        xdg-desktop-portal-gtk lxqt-policykit \
        NetworkManager NetworkManager-tui bluez blueman \
        maim slop xclip xdotool xdg-user-dirs xdg-utils brightnessctl playerctl psmisc bc file /usr/bin/ffmpeg \
        google-noto-sans-fonts google-noto-color-emoji-fonts \
        adwaita-icon-theme adwaita-cursor-theme dconf \
        neovim Thunar librewolf curl tar xz

    # Fedora only packages the plain JetBrains Mono, so get the Nerd Font
    # from the nerd-fonts releases
    if ! fc-list | grep -q "JetBrainsMono Nerd Font"; then
        font_dir="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
        mkdir -p "$font_dir"
        curl -fL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz \
            | tar -xJ -C "$font_dir"
    fi

    # setbg sets the wallpaper with xwallpaper, which Fedora does not package,
    # so build it from its release
    if ! command -v xwallpaper > /dev/null; then
        build_dir="$(mktemp -d)"
        curl -fL https://github.com/stoeckmann/xwallpaper/releases/download/v0.7.6/xwallpaper-0.7.6.tar.xz \
            | tar -xJ -C "$build_dir"
        (cd "$build_dir/xwallpaper-0.7.6" && ./configure --prefix=/usr/local && make)
        sudo make -C "$build_dir/xwallpaper-0.7.6" install
        rm -rf "$build_dir"
    fi
}

# Start NetworkManager and Bluetooth on boot. Not with --now, so the
# network doesn't drop while the script is running.
enable_services_systemd() {
    # NetworkManager would fight with systemd-networkd over the network,
    # so leave a working networkd setup alone
    if systemctl is-enabled --quiet systemd-networkd 2> /dev/null; then
        echo "systemd-networkd manages your network, so NetworkManager is not enabled."
        echo "Disable systemd-networkd and enable NetworkManager to use nmtui (mod + shift + w)."
    else
        sudo systemctl enable NetworkManager
    fi
    sudo systemctl enable bluetooth
}

echo "Installing Xorg, PipeWire, dunst, fonts and what dwm, st, dmenu, slock and slstatus need to build"
if command -v pacman > /dev/null; then
    install_arch
elif command -v dnf > /dev/null; then
    install_fedora
else
    echo "No pacman or dnf found. Install the packages from the README yourself." >&2
    exit 1
fi
enable_services_systemd

xdg-user-dirs-update

install_dotfiles
build_suckless

offer_dwm_autostart

report_backup
echo "Installed Gruvbox dotfiles successfully"
echo "Reboot, or log out and log in again, so PipeWire, NetworkManager and Bluetooth start"
