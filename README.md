# terminal-setup

My terminal look on Windows and Linux, reproducible in one command.

- Gradient hostname banner on start (`figlet -f slant`, pink → cyan)
- `skat` oh-my-posh prompt: OS icon, Python env, user, host, full path
- Font: **FiraCode Nerd Font Mono**, size 8
- Colors: Windows Terminal "Campbell" (black background)

## Install — Windows

In any PowerShell window (Windows PowerShell 5.1 is fine):

```powershell
irm https://raw.githubusercontent.com/vladgohn/terminal-setup/main/install.ps1 | iex
```

1. Installs PowerShell 7, Git, oh-my-posh (winget), scoop + figlet, FiraCode Nerd Font
2. Clones this repo to `~\.terminal-setup`
3. Replaces `Documents\PowerShell\Microsoft.PowerShell_profile.ps1` with a one-line stub that loads `profile\profile.ps1` (old profile backed up as `.bak-<timestamp>`)
4. Patches Windows Terminal `settings.json` (backed up first): font, `-NoLogo`, PowerShell 7 as default

## Install — Linux (Debian / Ubuntu / Mint)

```bash
curl -fsSL https://raw.githubusercontent.com/vladgohn/terminal-setup/main/install.sh | bash
```

1. Installs git, figlet (apt), oh-my-posh (`~/.local/bin`), FiraCode Nerd Font
2. Clones this repo to `~/.terminal-setup`
3. Appends a marked block to `~/.bashrc` that sources `profile/profile.sh` (old `.bashrc` backed up)
4. Sets font and colors in mate-terminal and gnome-terminal default profiles

Both installers are safe to re-run and pull the latest version.

## Change the look

Edit files in `~/.terminal-setup`, then commit and push:

- `theme/skat.omp.json` — prompt segments and colors (shared by both OSes)
- `profile/profile.ps1`, `profile/profile.sh` — banner and startup logic

On other machines: `git -C ~/.terminal-setup pull`.
