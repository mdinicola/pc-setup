Bootstrap post-installation setup of select operating systems including Windows and Linux.  

It installs common applications, developement tools, and some configurations to help make customizing your OS easier.

# Running the script

## Linux

### Fedora KDE Plasma

```
sudo dnf install git -y
git clone https://github.com/mdinicola/pc-setup.git
cd pc-setup/linux/fedora_kde_plasma
chmod +x bootstrap.sh
./bootstrap.sh
```

Enter your password when prompted

### Linux Mint

```
sudo apt install git -y
git clone https://github.com/mdinicola/pc-setup.git
cd pc-setup/linux/linux_mint
chmod +x bootstrap.sh
./bootstrap.sh
```

## Windows

Run from Powershell

```
winget install Git.Git
git clone https://github.com/mdinicola/pc-setup.git
cd pc-setup/windows
./bootstrap.ps1
```

---
# What does it include?

These are some of the applications, tools, and configurations I find helpful on a new OS install.  It is not meant to be an exhaustive list.

## Applications

- Brave Browser (Windows)
- Brave Origin (Linux)
- VLC
- VS Code
- Flameshot
- Bruno
- DBeaver Community Edition
- Docker Engine
- Notepad++ (Windows)
- WinDirStat (Windows)
- kate (Linux KDE)
- qdirstat (Linux)
- Kopia (Linux)

## Tools and Languages

- ffmpeg
- git
- jq
- python
- node.js
- uv
- OpenTofu
- AWS CLI
- AWS SAM CLI
- OpenAI Codex
- dbmate
- supabase

## Configurations

- Disable clipboard history (Linux KDE)
- Show full dates instead of relative time in Dolphin (Linux KDE)
- Debloat Brave (Windows)
    - disables AI, Crypto, Wallet, Telemetry options
