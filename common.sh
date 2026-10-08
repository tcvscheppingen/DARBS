# Steps shared by auto-rice.sh, auto-rice-artix.sh and move-config-files.sh.
# Those scripts set REPO_DIR and source this file; it is not run on its own.

# The dotfiles, sources and login snippet go to the user who runs the script,
# so it must be the user who will use dwm. The scripts use sudo for the parts
# that need root.
if [ "$(id -u)" -eq 0 ]; then
    echo "Run this as the user who will use dwm, not as root. It uses sudo where it needs root." >&2
    exit 1
fi

BACKUP_DIR="$HOME/.config/gruvbox-rice-backup-$(date +%Y%m%d-%H%M%S)"

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

# Copy a file or folder into the backup folder
backup() {
    mkdir -p "$BACKUP_DIR"
    cp -a "$1" "$BACKUP_DIR/"
}

# Back up the configs, scripts and sources this theme replaces, then copy the
# dotfiles into ~/.config, ~/.local/bin, ~/.local/share and ~/.local/src
install_dotfiles() {
    for dir in x11 dunst gtk-3.0 nvim; do
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

# Offer to start dwm on TTY1 from the login profile, as the Arch Wiki
# recommends. startx runs ~/.config/x11/xinitrc, which starts dwm, dwmblocks,
# dunst and the rest.
offer_dwm_autostart() {
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

    read -r -p "Start dwm automatically when you log in on TTY1 (adds it to $profile)? [y/N] " answer || true
    case "$answer" in
        [yY]*)
            [ -e "$profile" ] && backup "$profile"
            printf '\n# Start dwm on TTY1 (added by the Gruvbox dwm rice)\n%s\n' "$snippet" >> "$profile"
            echo "Added dwm to $profile"
            ;;
    esac
}

report_backup() {
    if [ -d "$BACKUP_DIR" ]; then
        echo "Your previous configs were backed up to $BACKUP_DIR"
    fi
}
