# terminal-setup

My Windows Terminal + PowerShell 7 look, reproducible in one command.

- Gradient hostname banner on start (`figlet -f slant`, pink → cyan)
- `skat` oh-my-posh prompt: OS icon, Python env, user, host, full path
- Font: **FiraCode Nerd Font Mono**, size 8
- PowerShell 7 as the default Windows Terminal profile, started with `-NoLogo`

## Install

In any PowerShell window (Windows PowerShell 5.1 is fine):

```powershell
irm https://raw.githubusercontent.com/vladgohn/terminal-setup/main/install.ps1 | iex
```

The installer:

1. Installs PowerShell 7, Git, oh-my-posh (winget), scoop + figlet, FiraCode Nerd Font
2. Clones this repo to `~\.terminal-setup`
3. Replaces `Documents\PowerShell\Microsoft.PowerShell_profile.ps1` with a one-line stub that loads `profile\profile.ps1` from the repo (old profile is backed up as `.bak-<timestamp>`)
4. Patches Windows Terminal `settings.json` (backed up first): font, `-NoLogo`, PowerShell 7 as default

Re-running it is safe and pulls the latest version.

## Change the look

Edit files in `~\.terminal-setup`, then commit and push:

- `theme\skat.omp.json` — prompt segments and colors
- `profile\profile.ps1` — banner and startup logic

On other machines: `git -C ~\.terminal-setup pull`.
