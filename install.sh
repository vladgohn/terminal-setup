#!/usr/bin/env bash
# Terminal setup installer for Linux (Debian/Ubuntu/Mint).
#   curl -fsSL https://raw.githubusercontent.com/vladgohn/terminal-setup/main/install.sh | bash
# Safe to re-run: it updates what is already there.

set -euo pipefail

REPO_URL='https://github.com/vladgohn/terminal-setup.git'
INSTALL_DIR="$HOME/.terminal-setup"
FONT='FiraCode Nerd Font Mono 8'
BG='#0C0C0C'
FG='#CCCCCC'
# Windows Terminal "Campbell" palette
PALETTE=('#0C0C0C' '#C50F1F' '#13A10E' '#C19C00' '#0037DA' '#881798' '#3A96DD' '#CCCCCC'
         '#767676' '#E74856' '#16C60C' '#F9F1A5' '#3B78FF' '#B4009E' '#61D6D6' '#F2F2F2')

step() { printf '\e[36m==> %s\e[0m\n' "$1"; }

export PATH="$HOME/.local/bin:$PATH"

# gsettings needs the desktop session bus; also works when run over SSH
if [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" && -S "/run/user/$(id -u)/bus" ]]; then
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
fi

# 1. Tools
step 'Installing git, curl, unzip, figlet, fontconfig'
sudo apt-get update -qq
sudo apt-get install -y -qq git curl unzip figlet fontconfig >/dev/null

step 'Installing oh-my-posh'
mkdir -p "$HOME/.local/bin"
curl -fsSL https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin" >/dev/null

step 'Installing font: FiraCode Nerd Font'
if fc-list | grep -q 'FiraCode Nerd Font Mono'; then
    echo '    already installed'
else
    oh-my-posh font install FiraCode
    fc-cache -f >/dev/null
fi

# 2. Repo
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
if [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/profile/profile.sh" ]]; then
    REPO_DIR="$SCRIPT_DIR"
    step "Using local repo: $REPO_DIR"
elif [[ -d "$INSTALL_DIR/.git" ]]; then
    REPO_DIR="$INSTALL_DIR"
    step "Updating $REPO_DIR"
    git -C "$REPO_DIR" pull --ff-only
else
    REPO_DIR="$INSTALL_DIR"
    step "Cloning into $REPO_DIR"
    git clone -q "$REPO_URL" "$REPO_DIR"
fi

# 3. ~/.bashrc hook
step 'Hooking profile into ~/.bashrc'
MARK_BEGIN='# >>> terminal-setup >>>'
MARK_END='# <<< terminal-setup <<<'
if grep -qF "$MARK_BEGIN" "$HOME/.bashrc" 2>/dev/null; then
    echo '    already hooked'
else
    cp "$HOME/.bashrc" "$HOME/.bashrc.bak-$(date +%Y%m%d-%H%M%S)"
    printf '\n%s\n. "%s/profile/profile.sh"\n%s\n' "$MARK_BEGIN" "$REPO_DIR" "$MARK_END" >> "$HOME/.bashrc"
fi

# 4. Terminal emulators: font and colors
palette_colon=$(IFS=:; echo "${PALETTE[*]}")
palette_list="[$(printf "'%s', " "${PALETTE[@]}" | sed 's/, $//')]"

if command -v mate-terminal >/dev/null && command -v gsettings >/dev/null; then
    step 'Configuring mate-terminal'
    p='org.mate.terminal.profile:/org/mate/terminal/profiles/default/'
    gsettings set $p use-system-font false
    gsettings set $p font "$FONT"
    gsettings set $p use-theme-colors false
    gsettings set $p background-color "$BG"
    gsettings set $p foreground-color "$FG"
    gsettings set $p palette "$palette_colon"
fi

if command -v gnome-terminal >/dev/null && command -v gsettings >/dev/null; then
    step 'Configuring gnome-terminal'
    id=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
    p="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$id/"
    gsettings set "$p" use-system-font false
    gsettings set "$p" font "$FONT"
    gsettings set "$p" use-theme-colors false
    gsettings set "$p" background-color "$BG"
    gsettings set "$p" foreground-color "$FG"
    gsettings set "$p" palette "$palette_list"
fi

step 'Done. Open a new terminal window.'
