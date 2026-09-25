# Terminal setup installer.
# Works from Windows PowerShell 5.1 on a clean machine:
#   irm https://raw.githubusercontent.com/vladgohn/terminal-setup/main/install.ps1 | iex
# Safe to re-run: it updates what is already there.

$ErrorActionPreference = 'Stop'

$RepoUrl     = 'https://github.com/vladgohn/terminal-setup.git'
$InstallDir  = Join-Path $HOME '.terminal-setup'
$FontFace    = 'FiraCode Nerd Font Mono'
$FontSize    = 8

function Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }

function Update-SessionPath {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User')
}

function Install-WingetPackage($id, $command) {
    if ($command -and (Get-Command $command -ErrorAction SilentlyContinue)) {
        Write-Host "    $id already installed"
        return
    }
    winget install --id $id --exact --silent --accept-source-agreements --accept-package-agreements
    Update-SessionPath
}

# 1. Tools
Step 'Installing PowerShell 7, Git, oh-my-posh'
Install-WingetPackage 'Microsoft.PowerShell'     'pwsh'
Install-WingetPackage 'Git.Git'                  'git'
Install-WingetPackage 'JanDeDobbeleer.OhMyPosh'  'oh-my-posh'

Step 'Installing figlet via scoop'
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Invoke-RestMethod https://get.scoop.sh | Invoke-Expression
    Update-SessionPath
}
if (-not (Get-Command figlet -ErrorAction SilentlyContinue)) {
    scoop install figlet
}

Step "Installing font: $FontFace"
$fontInstalled = @("$env:LOCALAPPDATA\Microsoft\Windows\Fonts", "$env:WINDIR\Fonts") |
    Where-Object { Test-Path (Join-Path $_ 'FiraCodeNerdFontMono-Regular.ttf') }
if ($fontInstalled) {
    Write-Host '    already installed'
} else {
    oh-my-posh font install FiraCode
}

# 2. Repo
$localRepo = if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot 'profile\profile.ps1'))) { $PSScriptRoot }
if ($localRepo) {
    $RepoDir = $localRepo
    Step "Using local repo: $RepoDir"
} elseif (Test-Path (Join-Path $InstallDir '.git')) {
    $RepoDir = $InstallDir
    Step "Updating $RepoDir"
    git -C $RepoDir pull --ff-only
} else {
    $RepoDir = $InstallDir
    Step "Cloning into $RepoDir"
    git clone $RepoUrl $RepoDir
}

# 3. PowerShell 7 profile stub
$profilePath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell\Microsoft.PowerShell_profile.ps1'
$stub = ". `"$(Join-Path $RepoDir 'profile\profile.ps1')`""
Step "Writing profile stub: $profilePath"
New-Item -ItemType Directory -Force (Split-Path $profilePath) | Out-Null
if ((Test-Path $profilePath) -and ((Get-Content $profilePath -Raw).Trim() -ne $stub)) {
    $backup = "$profilePath.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
    Copy-Item $profilePath $backup
    Write-Host "    old profile saved to $backup"
}
Set-Content -Path $profilePath -Value $stub -Encoding UTF8

# 4. Windows Terminal: font, -NoLogo, PowerShell 7 as default
$wtSettingsFiles = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
) | Where-Object { Test-Path $_ }

if (-not $wtSettingsFiles) {
    Write-Host '    Windows Terminal settings.json not found. Open Windows Terminal once and re-run this script.' -ForegroundColor Yellow
}

foreach ($file in $wtSettingsFiles) {
    Step "Patching $file"
    Copy-Item $file "$file.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
    $settings = Get-Content $file -Raw | ConvertFrom-Json

    $pwshProfile = $settings.profiles.list |
        Where-Object { $_.source -eq 'Windows.Terminal.PowershellCore' -and $_.name -eq 'PowerShell' } |
        Select-Object -First 1

    if (-not $pwshProfile) {
        $pwshProfile = [pscustomobject]@{
            guid = '{3f1c9a52-7d4e-4b8a-9c2f-6e1d0b5a7c34}'
            name = 'PowerShell'
        }
        $settings.profiles.list += $pwshProfile
    }

    $pwshProfile | Add-Member -Force NoteProperty commandline 'pwsh.exe -NoLogo'
    $pwshProfile | Add-Member -Force NoteProperty font ([pscustomobject]@{ face = $FontFace; size = $FontSize })
    $pwshProfile | Add-Member -Force NoteProperty hidden $false
    $settings | Add-Member -Force NoteProperty defaultProfile $pwshProfile.guid

    $settings | ConvertTo-Json -Depth 32 | Set-Content -Path $file -Encoding UTF8
}

Step 'Done. Open a new PowerShell tab in Windows Terminal.'
