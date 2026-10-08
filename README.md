# dwm Auto Rice Bootstrapping Script (DARBS)

This repo contains my dotfiles for dwm, st, dmenu, slock, slstatus, dunst and a Neovim color theme, all using the [gruvbox](https://github.com/morhetz/gruvbox) dark palette. It is the X11 and suckless version of my [Sway rice (SARBS)](https://github.com/tcvscheppingen/SARBS), with the same look: 3px yellow borders, the same gaps, the same wallpaper and a plain text bar in the style of dwm.

Every part of the Sway rice is replaced by its suckless equivalent:

| Sway rice | This rice |
|---|---|
| Sway | [dwm](https://dwm.suckless.org) 6.8 with the vanitygaps, swallow and stacker patches |
| Foot | [st](https://st.suckless.org) |
| wmenu | [dmenu](https://tools.suckless.org/dmenu) |
| swaylock | [slock](https://tools.suckless.org/slock) |
| Waybar | [slstatus](https://tools.suckless.org/slstatus) |
| swayidle | `xset` and xss-lock |
| swaybg | xwallpaper, through `setbg` |
| mako | dunst (suckless has no notification daemon) |
| grim, slurp and wf-recorder | maim, slop and ffmpeg |

The key bindings are the ones from [Luke Smith's dwm](https://github.com/LukeSmithxyz/dwm), limited to what dwm, vanitygaps, swallow and stacker can do (see [Key bindings](#key-bindings)). The `sysact`, `displayselect`, `dmenurecord`, `maimpick` and `setbg` scripts are Luke's own, from [voidrice](https://github.com/LukeSmithxyz/voidrice).

The installation scripts are intended for Arch and Arch based distributions such as EndeavourOS and CachyOS, Fedora, and Artix with dinit, but the dotfiles can be used without them.

## Requirements
- Xorg and xinit (`startx`)
- The libraries and compiler to build dwm, st, dmenu, slock and slstatus
- dunst, xwallpaper, xss-lock and unclutter
- JetBrains Mono Nerd Font and Noto Color Emoji
- Arch, an Arch based distribution, Fedora or Artix with dinit (to install everything with the scripts)
- LibreWolf and Thunar (optional, for the browser and file manager shortcuts)

## Patches

The patched dwm source is in `.local/src/dwm`. The patch files are in `.local/src/dwm/patches`.

- [vanitygaps](https://dwm.suckless.org/patches/vanitygaps/) (`dwm-vanitygaps-6.2.diff`): gaps between windows and at the screen edges, in every layout. It also adds the bstack, spiral, dwindle, deck, centered master and other layouts. The gaps are the same as the Sway rice: 10px between windows, 30px at the left and right edges and 10px at the top and bottom.
- [swallow](https://dwm.suckless.org/patches/swallow/) (`dwm-swallow-6.3.diff`): a graphical program started from st takes the place of the terminal until it closes, so the terminal doesn't take up space doing nothing.
- [stacker](https://dwm.suckless.org/patches/stacker/) (`dwm-stacker-6.6.diff`): move windows up and down the stack with the keyboard (`mod + shift + j/k`), and jump to or move a window to the top of the stack (`mod + v`, `mod + shift + v`). A fullscreen window keeps the focus, as in stock dwm, and the stacker keys do nothing on an empty tag.

None of the patches applied cleanly to dwm 6.8, so a few hunks were applied by hand.

**unclutter** is not a dwm patch but a small program, the same one Luke Smith uses. It hides the mouse cursor when it hasn't moved for a moment. `~/.config/x11/xinitrc` starts it.

## What the script does
**Always check the contents of a script before running it**

`auto-rice.sh` does the following:
- Installs everything a minimal install needs for a working desktop. Packages you already have are skipped.
  - X: Xorg, xinit, `xsetroot`, `xset`, `xrandr`, `xrdb` and the libinput driver
  - What dwm, st, dmenu, slock and slstatus need to build: a compiler, make, and the X11, Xft, Xinerama, XRes and xcb libraries
  - Around dwm: dunst for notifications, xwallpaper, xss-lock for locking the screen, and unclutter
  - Sound: PipeWire with its PulseAudio and ALSA replacements and WirePlumber, plus `pactl` and `wpctl` for the volume keys
  - Desktop plumbing: the GTK portal (for file pickers), an LXQt polkit agent (for password prompts), NetworkManager (with `nmtui`), Bluetooth (bluez and blueman) and xdg-user-dirs
  - Tools for Luke's scripts: maim, slop, xclip and xdotool for screenshots, ffmpeg for recording, psmisc (`pstree`, for `sysact`), bc and file, plus brightnessctl and playerctl
  - Fonts and themes: the JetBrains Mono Nerd Font, Noto fonts and emoji (so websites and Luke's menus don't show empty boxes), and the Adwaita icons and cursor
  - Apps: Neovim, Thunar and LibreWolf
  - On Arch it uses `pacman`.
  - On Fedora it uses `dnf`. It adds the [official LibreWolf repo](https://librewolf.net/installation/rhel/) to `/etc/yum.repos.d/librewolf.repo`, downloads the JetBrains Mono Nerd Font from the [nerd-fonts releases](https://github.com/ryanoasis/nerd-fonts/releases) to `~/.local/share/fonts/`, and builds [xwallpaper](https://github.com/stoeckmann/xwallpaper) from its release into `/usr/local`, because Fedora packages neither.
- Backs up your existing `x11`, `dunst`, `gtk-3.0` and `nvim` configs, the scripts it replaces in `~/.local/bin`, and the dwm, st, dmenu, slock and slstatus sources in `~/.local/src` to `~/.config/gruvbox-rice-backup-<date>/`.
- Enables NetworkManager and Bluetooth on boot. NetworkManager is skipped if `systemd-networkd` manages your network, because the two would conflict.
- Creates `~/Pictures` and the other user folders.
- Copies the dotfiles into `~/.config`, the scripts into `~/.local/bin`, the wallpaper into `~/.local/share` (with `~/.local/share/bg` linking to it, unless you already have one), and the suckless sources into `~/.local/src`.
- Builds dwm, st, dmenu, slock and slstatus in `~/.local/src` and installs them to `/usr/local`.
- Asks whether dwm should start when you log in on TTY1. If you say yes, it adds this to your login shell's profile and backs up the old profile first (see [Starting dwm on login](#starting-dwm-on-login)).

### Artix

`auto-rice-artix.sh` does the same for Artix with dinit (`auto-rice.sh` refuses to run on Artix). The differences:
- Updates `artix-keyring` and `archlinux-keyring` first, so packages signed with newer keys don't fail with signature errors on an install that hasn't been updated for a while.
- Adds Arch's `[extra]` repo to `/etc/pacman.conf` with `artix-archlinux-support`, the same way [LARBS](https://github.com/LukeSmithxyz/LARBS) does, because xss-lock is not in the Artix repos. Everything else comes from the Artix repos.
- Installs the dinit services for elogind, D-Bus, NetworkManager and Bluetooth, and links them into `/etc/dinit.d/boot.d/` so they start on boot. NetworkManager is skipped if connman manages your network.
- Installs turnstile, which runs your own dinit with PipeWire, PipeWire's PulseAudio replacement, WirePlumber and the D-Bus session bus when you log in. They are linked into `~/.config/dinit.d/boot.d/`.
- Adds you to the `video` group, because Artix's brightnessctl changes the backlight through that group.

## Installation with auto rice script

1. Clone the repo:
```bash
git clone https://github.com/tcvscheppingen/DARBS.git
```
2. Make the auto rice script executable:
```bash
cd DARBS
chmod +x auto-rice.sh
```
3. Run the installation script as the user who will use dwm, not as root; it asks for your password through `sudo` when it needs root (on Artix, `chmod +x auto-rice-artix.sh` and run `./auto-rice-artix.sh` instead):
```bash
./auto-rice.sh
```
4. Reboot, so PipeWire, NetworkManager and Bluetooth start

If you prefer to install the packages manually, you can use `move-config-files.sh` to move the config files to your home directory and build the suckless programs without installing any packages. It does not set up [starting dwm on login](#starting-dwm-on-login).

## Manual installation

1. Clone the repo:
```bash
git clone https://github.com/tcvscheppingen/DARBS.git
```

2. Install the packages.

   Arch:
```bash
sudo pacman -S --needed base-devel libx11 libxft libxinerama libxrandr libxext libxres libxcb freetype2 fontconfig \
    xorg-server xorg-xinit xorg-xsetroot xorg-xset xorg-xrandr xorg-xrdb xf86-input-libinput \
    xss-lock xwallpaper unclutter dunst libnotify \
    pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber libpulse \
    xdg-desktop-portal-gtk lxqt-policykit \
    networkmanager bluez bluez-utils blueman \
    maim slop xclip xdotool xdg-user-dirs brightnessctl playerctl psmisc bc file ffmpeg \
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji \
    adwaita-icon-theme adwaita-cursors dconf \
    neovim thunar librewolf
sudo systemctl enable NetworkManager bluetooth
xdg-user-dirs-update
```

   Fedora (LibreWolf needs [its own repo](https://librewolf.net/installation/rhel/), the JetBrains Mono Nerd Font comes from the [nerd-fonts releases](https://github.com/ryanoasis/nerd-fonts/releases), and xwallpaper is built from [its release](https://github.com/stoeckmann/xwallpaper/releases)):
```bash
curl -fsSL https://repo.librewolf.net/librewolf.repo | sudo tee /etc/yum.repos.d/librewolf.repo
sudo dnf install gcc make pkgconf-pkg-config \
    libX11-devel libXft-devel libXinerama-devel libXrandr-devel libXext-devel \
    libXres-devel libxcb-devel freetype-devel fontconfig-devel libxcrypt-devel \
    xcb-util-devel xcb-util-image-devel pixman-devel libjpeg-turbo-devel libpng-devel \
    libXpm-devel libseccomp-devel \
    xorg-x11-server-Xorg xorg-x11-xinit xsetroot xset xrandr xrdb xorg-x11-drv-libinput \
    xss-lock unclutter dunst libnotify \
    pipewire pipewire-pulseaudio pipewire-alsa wireplumber pulseaudio-utils \
    xdg-desktop-portal-gtk lxqt-policykit \
    NetworkManager NetworkManager-tui bluez blueman \
    maim slop xclip xdotool xdg-user-dirs brightnessctl playerctl psmisc bc file /usr/bin/ffmpeg \
    google-noto-sans-fonts google-noto-color-emoji-fonts \
    adwaita-icon-theme adwaita-cursor-theme dconf \
    neovim Thunar librewolf
sudo systemctl enable NetworkManager bluetooth
xdg-user-dirs-update
mkdir -p ~/.local/share/fonts/JetBrainsMonoNerdFont
curl -fL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz | tar -xJ -C ~/.local/share/fonts/JetBrainsMonoNerdFont
fc-cache -f
curl -fL https://github.com/stoeckmann/xwallpaper/releases/download/v0.7.6/xwallpaper-0.7.6.tar.xz | tar -xJ
(cd xwallpaper-0.7.6 && ./configure --prefix=/usr/local && make && sudo make install)
```

3. Move the dotfiles into your home folder:
```bash
cd DARBS # Or wherever you cloned the repo
mkdir -p ~/.config ~/.local/bin ~/.local/share ~/.local/src
cp -a .config/. ~/.config/
cp -a .local/bin/. ~/.local/bin/
cp -a .local/src/. ~/.local/src/
cp .local/share/wallpaper.jpg ~/.local/share/
ln -s ~/.local/share/wallpaper.jpg ~/.local/share/bg
```

4. Build and install dwm, st, dmenu, slock and slstatus:
```bash
for prog in dwm st dmenu slock slstatus; do
    make -C ~/.local/src/$prog && sudo make -C ~/.local/src/$prog install
done
```

5. Optionally, [start dwm on login](#starting-dwm-on-login).

## Starting dwm on login

Without a display manager, you can start X from your login shell's profile when you log in on TTY1, [as the Arch Wiki recommends](https://wiki.archlinux.org/title/Xinit#Autostart_X_at_login). `startx` runs `~/.config/x11/xinitrc`, which sets the wallpaper and starts slstatus, dunst, unclutter, xss-lock and the polkit agent, and then dwm.

Add this to the end of your profile:
```bash
# Start dwm on TTY1
if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
    exec startx "$HOME/.config/x11/xinitrc"
fi
```

Which file is your profile depends on your login shell (`echo $SHELL`):
- **bash**: `~/.bash_profile`. If you don't have that file but do have `~/.bash_login` or `~/.profile`, use that one instead. bash reads only the first of these it finds, so creating `~/.bash_profile` would stop it from reading `~/.profile`.
- **zsh**: `~/.zprofile` (or `$ZDOTDIR/.zprofile` if you set `ZDOTDIR`).

`auto-rice.sh` finds the right file for bash and zsh by itself. For other shells, add the equivalent to that shell's login config. For example, in fish, `~/.config/fish/config.fish`:
```fish
if status is-login; and test -z "$DISPLAY"; and test "$XDG_VTNR" = 1
    exec startx "$HOME/.config/x11/xinitrc"
end
```

Other TTYs still give you a normal shell, so if X fails to start you can switch to TTY2 (`ctrl + alt + F2`) to fix it.

If you use a display manager (such as LightDM or SDDM), it needs a session that runs `~/.config/x11/xinitrc` rather than dwm itself, or the wallpaper, status bar and the rest won't start.

## Key bindings

These are the bindings from [Luke Smith's dwm](https://github.com/LukeSmithxyz/dwm), limited to what dwm, vanitygaps, swallow and stacker can do. `mod` is the Super (Windows) key.

| Keys | Action |
|---|---|
| `mod + Return` | Open a terminal (st) |
| `mod + d` | Run a program (dmenu) |
| `mod + w` | Open the browser (LibreWolf) |
| `mod + shift + w` | Network settings (`nmtui`) |
| `mod + r` | Open the file manager (Thunar) |
| `mod + q` | Close the focused window |
| `mod + j` / `mod + k` | Focus the next / previous window |
| `mod + shift + j` / `mod + shift + k` | Move the focused window down / up the stack |
| `mod + v` | Focus the window at the top of the stack (the master) |
| `mod + shift + v` | Move the focused window to the top of the stack |
| `mod + space` | Move the focused window to the master area, or swap it with the master |
| `mod + h` / `mod + l` | Shrink / grow the master area |
| `mod + o` / `mod + shift + o` | One more / one less window in the master area |
| `mod + t` / `mod + shift + t` | Tile layout / master on top (bstack) |
| `mod + y` / `mod + shift + y` | Spiral / dwindle layout |
| `mod + u` / `mod + shift + u` | Deck / monocle layout |
| `mod + i` / `mod + shift + i` | Centered master / centered floating master layout |
| `mod + shift + f` | Floating layout |
| `mod + shift + space` | Make the focused window floating or tiled |
| `mod + 1`…`9` | Go to a tag |
| `mod + shift + 1`…`9` | Move the focused window to a tag |
| `mod + ctrl + 1`…`9` | Also show a tag |
| `mod + ctrl + shift + 1`…`9` | Also put the focused window on a tag |
| `mod + 0` / `mod + shift + 0` | Show all tags / put the focused window on all tags |
| `mod + Tab` or `mod + \` | Go back to the previous tag |
| `mod + Left` / `mod + Right` | Focus the previous / next display |
| `mod + shift + Left` / `mod + shift + Right` | Move the focused window to the previous / next display |
| `mod + a` / `mod + shift + a` | Turn the gaps off and on / reset them |
| `mod + z` / `mod + x` | Grow / shrink the gaps |
| `mod + b` | Hide or show the bar |
| `mod + minus` / `mod + equal` | Volume down / up 5% (with `shift`: 15%) |
| `mod + shift + m` | Mute |
| `mod + Backspace`, `mod + shift + Backspace` or `mod + shift + q` | System menu: lock, leave or renew dwm, hibernate, reboot, shutdown, sleep, display off (`sysact`) |
| `mod + F3` | Display menu: use one display, mirror them, or place them side by side (`displayselect`) |
| `Print` | Screenshot of the whole screen, saved to your home folder |
| `shift + Print` | Screenshot menu: a selected area, the focused window or the whole screen, saved or copied (`maimpick`) |
| `mod + Print` | Recording menu: screen with or without microphone, a selected area, audio only, or the webcam (`dmenurecord`). Recordings go to your home folder |
| `mod + shift + Print` / `mod + Delete` | Stop the recording |
| Volume, mute, microphone mute and brightness keys | Change the volume and brightness |
| Play, next and previous keys | Control music and video players (playerctl) |

With the mouse:

| Mouse | Action |
|---|---|
| `mod` + drag with the left button | Move a window (it becomes floating) |
| `mod` + drag with the right button | Resize a window (it becomes floating) |
| `mod` + middle click | Reset the gaps |
| `mod` + scroll | Grow / shrink the gaps |
| Click a tag / right click a tag | Go to the tag / also show the tag |
| `mod` + click a tag | Move the focused window to the tag |
| Middle click the desktop | Hide or show the bar |

Luke's other bindings are left out, because they need patches this dwm doesn't have (true fullscreen on `mod + f`, sticky windows, scratchpads, cycling tags, reloading Xresources colors and the clickable status bar) or programs this rice doesn't include (neomutt, newsboat, ncmpcpp with mpd, lf and the other LARBS scripts).

## Changing dwm, st, dmenu, slock or slstatus

The suckless programs are configured in their source code. Edit `config.h` in `~/.local/src/<program>`, then rebuild and install it:
```bash
cd ~/.local/src/dwm
make && sudo make install
```

For dwm, choose "renew dwm" in `sysact` (`mod + Backspace`) to start the new build without closing your windows. `~/.config/x11/xinitrc` starts dwm again when it exits after "renew dwm".

## Screen locking

xss-lock locks the screen with slock after 5 minutes without input and before the computer goes to sleep, and the displays turn off 5 minutes later. Change the times in the `xset` lines of `~/.config/x11/xinitrc`. slock shows a dark screen that turns yellow while you type and red after a wrong password; type your password and press Enter to unlock.

## Look of other apps

`~/.config/x11/xinitrc` sets the Adwaita cursor, and sets GTK 4 apps to dark mode with `gsettings`. GTK 3 apps such as Thunar and LibreWolf's dialogs read the same settings from `~/.config/gtk-3.0/settings.ini`. Qt apps, such as the LXQt password prompt, keep their default look.

## Notifications

dunst shows notifications in the top right corner, with a yellow border, or a red one for critical notifications. They disappear after 5 seconds; critical ones stay until you dismiss them. Click a notification to dismiss it, or right click to dismiss all of them. The config is in `~/.config/dunst/dunstrc`. Restart dunst after changing it (`killall dunst; dunst &`).

## Status bar

slstatus shows the same blocks as the Waybar of the Sway rice, split by `|`: the network connection, a recording icon while `dmenurecord` is recording, the volume, the battery (on laptops), memory use, the date and the current time (`HH:MM:SS`). The network, recording, volume and battery blocks are small scripts in `~/.local/bin/statusbar`; the blocks and their order are in `~/.local/src/slstatus/config.h`.

dwm has no system tray, so there are no wifi and Bluetooth tray icons. Use `nmtui` (`mod + shift + w`) for the network and `blueman-manager` for Bluetooth.

## Palette

| Role | Color |
|---|---|
| Background (hard) | `#1D2021` |
| Background | `#282828` |
| Background 1 | `#3C3836` |
| Background 2 | `#504945` |
| Foreground | `#EBDBB2` |
| Gray | `#928374` |
| Red | `#FB4934` |
| Green | `#B8BB26` |
| Yellow | `#FABD2F` |
| Blue | `#83A598` |
| Purple | `#D3869B` |
| Aqua | `#8EC07C` |
| Orange | `#FE8019` |

## Credits
- Wallpaper [gruvbox wallpapers](https://gruvbox-wallpapers.pages.dev/)
- Gruvbox palette: [morhetz/gruvbox](https://github.com/morhetz/gruvbox)
- dwm, st, dmenu, slock and slstatus: [suckless.org](https://suckless.org)
- The vanitygaps, swallow and stacker patches: [dwm patches](https://dwm.suckless.org/patches/)
- Key bindings: Luke Smith's [dwm](https://github.com/LukeSmithxyz/dwm)
- `sysact`, `displayselect`, `dmenurecord`, `maimpick` and `setbg`: Luke Smith's [voidrice](https://github.com/LukeSmithxyz/voidrice) (from [LARBS](https://larbs.xyz))
