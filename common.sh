# Steps shared by auto-rice.sh, auto-rice-artix.sh and move-config-files.sh.
# Those scripts set REPO_DIR and source this file; it is not run on its own.

# The dotfiles, sources and login snippet go to the user who runs the script,
# so it must be the user who will use dwm. The scripts use sudo for the parts
# that need root.
if [ "$(id -u)" -eq 0 ]; then
    echo "Run this as the user who will use dwm, not as root. It uses sudo where it needs root." >&2
    exit 1
fi

BACKUP_DIR="$HOME/.config/darbs-backup-$(date +%Y%m%d-%H%M%S)"

# The suckless programs in .local/src, built and installed to /usr/local
SUCKLESS=(dwm st dmenu slock dwmblocks)

# Packages for Arch and Artix. Artix has all of them in its own repos except
# xss-lock, which comes from Arch's [extra]. pipewire-jack answers pacman's
# question which JACK to use; its default, jack2, would sit next to PipeWire
# instead of using it.
ARCH_PACKAGES=(
    base-devel libx11 libxft libxinerama libxrandr libxext libxres libxcb freetype2 fontconfig harfbuzz
    xorg-server xorg-xinit xorg-xsetroot xorg-xset xorg-xrandr xorg-xrdb xf86-input-libinput
    xss-lock xwallpaper unclutter dunst libnotify xcompmgr
    pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber libpulse
    xdg-desktop-portal-gtk lxqt-policykit
    networkmanager network-manager-applet bluez bluez-utils blueman
    maim slop xclip xdotool xdg-user-dirs xdg-utils brightnessctl playerctl psmisc bc file ffmpeg
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji
    adwaita-icon-theme adwaita-cursors dconf
    neovim htop pulsemixer thunar librewolf
)

# Vulkan and hardware video decoding (VA-API) drivers for the GPUs in this
# machine, by PCI vendor ID. AMD's VA-API driver is part of mesa, which Xorg
# pulls in. NVIDIA is left to the user: the right driver depends on the card.
detect_gpu_packages() {
    local file vendor seen=" "
    GPU_PACKAGES=()
    for file in /sys/class/drm/card*/device/vendor; do
        [ -r "$file" ] || continue
        read -r vendor < "$file"
        case $seen in *" $vendor "*) continue ;; esac
        seen+="$vendor "
        case $vendor in
            0x8086) GPU_PACKAGES+=(vulkan-intel intel-media-driver) ;;
            0x1002) GPU_PACKAGES+=(vulkan-radeon) ;;
            0x10de) command -v nvidia-smi > /dev/null \
                || echo "NVIDIA GPU found: install its driver yourself, see https://wiki.archlinux.org/title/NVIDIA" >&2 ;;
        esac
    done
}

# Copy a file or folder into the backup folder
backup() {
    mkdir -p "$BACKUP_DIR"
    cp -a "$1" "$BACKUP_DIR/"
}

# Back up the configs, scripts and sources this theme replaces, then copy the
# dotfiles into ~/.config, ~/.local/bin, ~/.local/share and ~/.local/src
install_dotfiles() {
    for dir in x11 dunst gtk-3.0 nvim helix; do
        if [ -e "$HOME/.config/$dir" ]; then
            backup "$HOME/.config/$dir"
        fi
    done
    mkdir -p "$HOME/.config"
    cp -a "$REPO_DIR/.config/." "$HOME/.config/"

    for script in "$REPO_DIR"/.local/bin/*; do
        if [ -e "$HOME/.local/bin/$(basename "$script")" ]; then
            backup "$HOME/.local/bin/$(basename "$script")"
        fi
    done
    mkdir -p "$HOME/.local/bin"
    cp -a "$REPO_DIR/.local/bin/." "$HOME/.local/bin/"

    # setbg sets the wallpaper that ~/.local/share/bg links to. Keep a
    # wallpaper you already chose with setbg.
    mkdir -p "$HOME/.local/share"
    cp -a "$REPO_DIR/.local/share/wallpaper.jpg" "$HOME/.local/share/"
    if [ ! -e "$HOME/.local/share/bg" ]; then
        ln -sf "$HOME/.local/share/wallpaper.jpg" "$HOME/.local/share/bg"
    fi

    mkdir -p "$HOME/.local/src"
    for prog in "${SUCKLESS[@]}"; do
        if [ -e "$HOME/.local/src/$prog" ]; then
            mkdir -p "$BACKUP_DIR/src"
            mv "$HOME/.local/src/$prog" "$BACKUP_DIR/src/"
        fi
        cp -a "$REPO_DIR/.local/src/$prog" "$HOME/.local/src/"
    done

    fc-cache -f
}

# Build dwm, st, dmenu, slock and dwmblocks in ~/.local/src and install them to
# /usr/local. Building as the user keeps the build files yours, so you can
# change config.h and rebuild without sudo.
build_suckless() {
    for prog in "${SUCKLESS[@]}"; do
        echo "Building $prog"
        make -C "$HOME/.local/src/$prog" clean > /dev/null
        make -C "$HOME/.local/src/$prog"
        sudo make -C "$HOME/.local/src/$prog" install
    done
}

# Print the login profile of the user's shell, or nothing for shells other
# than bash and zsh
login_profile() {
    case "$(basename "${SHELL:-}")" in
        bash)
            # bash reads only the first of these that exists, so use that one
            for file in "$HOME/.bash_profile" "$HOME/.bash_login" "$HOME/.profile"; do
                if [ -e "$file" ]; then
                    echo "$file"
                    return
                fi
            done
            echo "$HOME/.bash_profile"
            ;;
        zsh)
            echo "${ZDOTDIR:-$HOME}/.zprofile"
            ;;
    esac
}

# Start dwm on TTY1 from the login profile, as the Arch Wiki recommends.
# startx runs ~/.config/x11/xinitrc, which starts dwm, dwmblocks, dunst and
# the rest.
add_tty_login() {
    local snippet='if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
    exec startx "$HOME/.config/x11/xinitrc"
fi'
    local profile
    profile="$(login_profile)"

    if [ -z "$profile" ]; then
        echo "Your login shell ($(basename "${SHELL:-}")) is not bash or zsh. See the README to start dwm on login."
        return
    fi
    if grep -qs "exec startx" "$profile"; then
        echo "$profile already starts X"
        return
    fi
    [ -e "$profile" ] && backup "$profile"
    printf '\n# Start dwm on TTY1 (added by DARBS)\n%s\n' "$snippet" >> "$profile"
    echo "Added dwm to $profile"
}

# Link a dinit service into boot.d (Artix), or enable a systemd unit
enable_boot_service() {
    if command -v dinitctl > /dev/null; then
        [ -e "/etc/dinit.d/boot.d/$1" ] || sudo ln -s "/etc/dinit.d/$1" "/etc/dinit.d/boot.d/$1"
    else
        sudo systemctl enable "$1"
    fi
}

# The display manager that already starts on boot, if any
current_display_manager() {
    local dm
    if command -v dinitctl > /dev/null; then
        for dm in lightdm sddm gdm lxdm ly greetd; do
            if [ -e "/etc/dinit.d/boot.d/$dm" ]; then
                echo "$dm"
                return
            fi
        done
    elif [ -L /etc/systemd/system/display-manager.service ]; then
        basename "$(readlink /etc/systemd/system/display-manager.service)" .service
    fi
}

# LightDM with a minimal greeter: the wallpaper, a login box in dark
# Adwaita and a panel with only the host name, clock and power menu
add_display_manager() {
    local current
    echo "Installing LightDM with a minimal greeter"
    if grep -qs '^ID=artix' /etc/os-release; then
        sudo pacman -S --needed --noconfirm lightdm lightdm-gtk-greeter lightdm-dinit gnome-themes-extra
    elif command -v pacman > /dev/null; then
        sudo pacman -S --needed --noconfirm lightdm lightdm-gtk-greeter gnome-themes-extra
    else
        sudo dnf install lightdm lightdm-gtk gnome-themes-extra
    fi

    # The dwm session: dwm.desktop runs dwm-session, which runs your xinitrc
    # like startx does
    printf '#!/bin/sh\n# Started by the display manager (dwm.desktop): the same session as startx\nexec sh "$HOME/.config/x11/xinitrc"\n' \
        | sudo tee /usr/local/bin/dwm-session > /dev/null
    sudo chmod 755 /usr/local/bin/dwm-session
    sudo mkdir -p /usr/share/xsessions
    printf '[Desktop Entry]\nName=dwm\nComment=Dynamic window manager (DARBS)\nExec=/usr/local/bin/dwm-session\nType=Application\nDesktopNames=dwm\n' \
        | sudo tee /usr/share/xsessions/dwm.desktop > /dev/null

    # The greeter runs as the lightdm user, which can't read your home folder
    sudo install -Dm644 "$REPO_DIR/.local/share/wallpaper.jpg" /usr/share/backgrounds/darbs/wallpaper.jpg
    if [ -e /etc/lightdm/lightdm-gtk-greeter.conf ]; then
        backup /etc/lightdm/lightdm-gtk-greeter.conf
    fi
    sudo tee /etc/lightdm/lightdm-gtk-greeter.conf > /dev/null << 'EOF'
# Minimal greeter (DARBS)
[greeter]
background = /usr/share/backgrounds/darbs/wallpaper.jpg
user-background = false
transition-type = none
theme-name = Adwaita-dark
icon-theme-name = Adwaita
cursor-theme-name = Adwaita
font-name = JetBrainsMono Nerd Font 11
hide-user-image = true
indicators = ~host;~spacer;~clock;~spacer;~power
clock-format = %a %d %b  %H:%M
EOF
    sudo mkdir -p /etc/lightdm/lightdm.conf.d
    printf '# DARBS\n[Seat:*]\ngreeter-session=lightdm-gtk-greeter\nuser-session=dwm\n' \
        | sudo tee /etc/lightdm/lightdm.conf.d/50-darbs.conf > /dev/null

    # Two display managers would fight over the screen
    current="$(current_display_manager)"
    if [ -n "$current" ] && [ "$current" != lightdm ]; then
        echo "$current already starts on boot, so LightDM is not enabled. Disable $current and enable lightdm to use it."
    else
        enable_boot_service lightdm
        echo "LightDM starts on boot; choose the dwm session there"
    fi
}

# How dwm starts: RICE_LOGIN=tty|dm|none skips the question
offer_login() {
    local answer="${RICE_LOGIN:-}"
    if [ -z "$answer" ]; then
        echo "How do you want to start dwm?"
        echo "  1) Automatically when you log in on TTY1 (startx, no display manager)"
        echo "  2) From a graphical login screen (LightDM with a minimal greeter)"
        echo "  3) Neither, I'll start it myself"
        read -r -p "Choice [3]: " answer || true
    fi
    case "$answer" in
        1|tty) add_tty_login ;;
        2|dm)  add_display_manager ;;
        *)     echo "dwm doesn't start by itself; see the README to start it" ;;
    esac
}

report_backup() {
    if [ -d "$BACKUP_DIR" ]; then
        echo "Your previous configs were backed up to $BACKUP_DIR"
    fi
}
