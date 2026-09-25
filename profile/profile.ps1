# Loaded from $PROFILE by a one-line stub written by install.ps1.
# $PSScriptRoot is <repo>\profile.

$TerminalSetupRoot = Split-Path $PSScriptRoot -Parent

function Write-Gradient {
    param(
        [string]$Text,
        [int[]]$From = @(255, 0, 200),
        [int[]]$To   = @(0, 220, 255)
    )
    foreach ($line in ($Text -split "`n")) {
        $len = [Math]::Max($line.Length, 1)
        for ($i = 0; $i -lt $line.Length; $i++) {
            $t = $i / [Math]::Max($len - 1, 1)
            $r = [int]($From[0] + ($To[0] - $From[0]) * $t)
            $g = [int]($From[1] + ($To[1] - $From[1]) * $t)
            $b = [int]($From[2] + ($To[2] - $From[2]) * $t)
            Write-Host -NoNewline ("`e[38;2;{0};{1};{2}m{3}" -f $r, $g, $b, $line[$i])
        }
        Write-Host "`e[0m"
    }
}

if (Get-Command figlet -ErrorAction SilentlyContinue) {
    Write-Gradient ((figlet -f slant $env:COMPUTERNAME) -join "`n")
}

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config (Join-Path $TerminalSetupRoot 'theme\skat.omp.json') | Invoke-Expression
}
