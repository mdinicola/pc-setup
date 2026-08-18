# PC Setup

Bootstrap scripts for configuring a fresh Windows or Linux developer installation with common applications, development tools, and system settings.

This repository is intended to make rebuilding a workstation quick and repeatable. It reflects my preferred workstation setup and is not intended to be universal, but rather a starting point.

Review the files for your platform and adjust the applications, tools, and preferences to suit your environment.

---

> **[IMPORTANT]**
> These scripts install software and modify system and application settings.  Review them before running and make sure you understand the changes they will make.

## Supported Platforms

- Fedora KDE Plasma
- Linux Mint
- Windows

## Usage

Clone the repository and run the bootstrap script for your operating system.

### Fedora KDE Plasma

```bash
sudo dnf install git -y
git clone https://github.com/mdinicola/pc-setup.git
cd pc-setup/linux/fedora_kde_plasma
chmod +x bootstrap.sh
./bootstrap.sh
```

Enter your password when prompted.

### Linux Mint

```bash
sudo apt install git -y
git clone https://github.com/mdinicola/pc-setup.git
cd pc-setup/linux/linux_mint
chmod +x bootstrap.sh
./bootstrap.sh
```

Enter your password when prompted.

### Windows

Run from PowerShell:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
winget install Git.Git --accept-package-agreements --accept-source-agreements
git clone https://github.com/mdinicola/pc-setup.git
cd pc-setup/windows
./bootstrap.ps1
```

#### Logging

Logs are written to `C:\temp\logs\pc-setup\{dated_folder}`

Example: `C:\temp\logs\pc-setup\20260818_001604`

Log folder contents:
- bootstrap.txt contains logs for the bootstrap process as well as each non-admin task
    - non-admin tasks are also written to their own log file as described below
- each task contains its own log file.  For example:
    - apps_winget.txt
    - apps_scoop.txt
    - settings_registry.txt
    - settings_git.txt

## What Gets Configured

The bootstrap scripts install applications and development tooling and apply a number of system and application preferences.

The examples below are representative rather than exhaustive. The playbooks and scripts are the source of truth for exactly what is installed and configured on each platform.

### Applications

Examples include:

- Brave
- VLC
- Visual Studio Code
- Flameshot
- Bruno
- DBeaver Community Edition
- Docker Engine

Platform-specific applications include tools such as Notepad++, WinDirStat, Kate, QDirStat, and Kopia.

### Development Tools

Examples include:

- Git
- Python
- Node.js
- uv
- OpenTofu
- AWS CLI
- AWS SAM CLI
- OpenAI Codex

### CLI and System Utilities

Common tools and system utilities are also installed, including:

- ffmpeg
- jq

Additional utilities may be installed depending on the operating system.

## System and Application Preferences

The scripts also configure a number of preferences and settings to create a consistent environment across machines.

Examples include:

### Git

- Set the default branch to `main`

### Visual Studio Code

- Disable Copilot features
- Set indentation to 2 spaces

### Linux Mint

- Enable ufw firewall

### Fedora KDE Plasma

- Disable clipboard history
- Enable browsing inside ZIP archives

### Windows

- Configure Brave preferences
    - Disable unwanted Brave AI, cryptocurrency, wallet, and telemetry features

## Notes

Elevated privileges are required while installing packages or changing system settings. You may be prompted for your password or administrator approval during execution.