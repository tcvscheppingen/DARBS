#!/bin/bash
# Script to move the dotfiles to the config folders and build the suckless
# programs, without installing any packages.
set -e

REPO_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
. "$REPO_DIR/common.sh"

echo "Moving dwm dotfiles to Home directory"
install_dotfiles
build_suckless

report_backup
echo "Installed Gruvbox dotfiles successfully"
echo "Restart dwm with sysact (mod + Backspace, renew dwm), or log in again"
