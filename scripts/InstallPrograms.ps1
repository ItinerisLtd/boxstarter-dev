choco install -y git --package-parameters="'/GitAndUnixToolsOnPath /WindowsTerminal'"
choco install -y python
choco install -y sysinternals
choco install -y figma
choco install -y microsoftwebdriver
choco install -y powertoys

#--- Editor ---
choco install -y vscode
refreshenv
$extensions = @(
    "aaron-bond.better-comments",
    "bmewburn.vscode-intelephense-client",
    "bradlc.vscode-tailwindcss",
    "dbaeumer.vscode-eslint",
    "eamodio.gitlens",
    "editorconfig.editorconfig",
    "esbenp.prettier-vscode",
    "formulahendry.auto-close-tag",
    "formulahendry.auto-rename-tag",
    "kamikillerto.vscode-colorize",
    "ms-vscode-remote.remote-wsl"
    "msjsdiag.debugger-for-edge"
    "onecentlin.laravel-blade",
    "porifa.laravel-intelephense",
    "sburg.vscode-javascript-booster",
    "shufo.vscode-blade-formatter",
    "streetsidesoftware.code-spell-checker",
    "stylelint.vscode-stylelint",
    "xabikos.javascriptsnippets"
) | SORT
foreach ($extension in $extensions) {
  code --install-extension $extension
}

# Non-Chocolatey programs
Start-BitsTransfer -Source "https://downloads.1password.com/win/1PasswordSetup-latest.exe" -Destination ~/Downloads/1PasswordSetup-latest.exe
Invoke-Expression -Command "~/Downloads/1PasswordSetup-latest.exe"
winget install -e --id Microsoft.Teams
winget install --id Microsoft.Powershell --source winget
