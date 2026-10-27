# PC Setup

Bootstrap scripts for configuring a fresh Linux or Windows developer installation with common applications, development tools, and system settings.

This repository is intended to make rebuilding a workstation quick and repeatable. It reflects my preferred workstation setup and is not intended to be universal, but rather a starting point.

Review the files for your platform and adjust the applications, tools, and preferences to suit your environment.

---

> [!WARNING]
> These scripts install software and modify system and application settings.  Review them before running and make sure you understand the changes they will make.

# Supported Platforms

- Fedora KDE Plasma
- Fedora GNOME
- Linux Mint
- Windows

# Usage

Clone the repository and run the bootstrap script for your operating system.

## Fedora KDE Plasma

```bash
sudo dnf install git -y

git clone https://github.com/mdinicola/pc-setup.git

cd pc-setup/linux/fedora_kde_plasma

./bootstrap.sh
```

Enter your password when prompted.

### Installing GNOME on KDE

GNOME can be installed on top of KDE.  This allows you to choose which desktop environment to use on the login screen.

> [!NOTE]
> Note: This will result in duplicate applications being installed such as Dolphin (KDE) and Files (GNOME).  It should generally not be an issue though some user settings may conflict.

```
sudo dnf install git -y

git clone https://github.com/mdinicola/pc-setup.git

cd pc-setup/linux/fedora_kde_plasma

./install_gnome.sh
```

## Fedora GNOME

```bash
sudo dnf install git -y

git clone https://github.com/mdinicola/pc-setup.git

cd pc-setup/linux/fedora_gnome

./bootstrap.sh
```

Enter your password when prompted.

### Installing KDE Plasma on GNOME

KDE Plasma can be installed on top of GNOME.  This allows you to choose which desktop environment to use on the login screen.

> [!NOTE]
> Note: This will result in duplicate applications being installed such as Dolphin (KDE) and Files (GNOME).  It should generally not be an issue though some user settings may conflict.

```
sudo dnf install git -y

git clone https://github.com/mdinicola/pc-setup.git

cd pc-setup/linux/fedora_gnome

./install_kde_plasma.sh
```

## Linux Mint

```bash
sudo apt install git -y

git clone https://github.com/mdinicola/pc-setup.git

cd pc-setup/linux/linux_mint

./bootstrap.sh
```

Enter your password when prompted.

## Windows

Run from PowerShell:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force

winget install Git.Git --accept-package-agreements --accept-source-agreements

git clone https://github.com/mdinicola/pc-setup.git

cd pc-setup/windows

.\bootstrap.ps1
```

### Logging

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

---

# Post-Bootstrap Steps

## Disk Encryption Automatic Boot

If you chose to encrypt your drive while installing Fedora (either KDE or GNOME), you'll need to enter the disk encryption password during every bootup.

If your machine has TPM 2.0 support, you can configure it so that the disk is decrypted automatically on bootup instead of entering the password every time.

> [!IMPORTANT]
> Security Notice: Enabling automatic decryption during bootup adds a potential security risk.  Your drive will remain encrypted which adds protection for the drive itself being stolen.  However, if your machine such as a laptop is stolen, others will be able to load into the OS.

### Fedora

#### Verify TPM and Secure Boot is available

1. Run

    ```
    systemd-analyze has-tpm2
    ```

    It should return output similar to:

    ```
    yes
    +firmware
    +driver
    +system
    +subsystem
    +libraries
        +libtss2-esys.so.0
        +libtss2-rc.so.0
        +libtss2-mu.so.0
    ```

    **yes** is the most important, meaning that the machine has TPM 2.0 support

1. Run 

    ```
    mokutil --sb-state
    ```

    It should return `SecureBoot enabled`.  If it doesn't, you should enable Secure Boot in your BIOS settings if your machine supports it

#### Find your encrypted partition

Run

```
lsblk -f
```

It should return output similar to:

```
NAME                       FSTYPE      FSVER LABEL  UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
sda
├─sda1                     vfat        FAT32        55CE-9BAB                             578.7M     3% /boot/efi
├─sda2                     ext4        1.0          6dceed6c-08eb-4892-99e3-6c34bcfd2326    1.4G    22% /boot
└─sda3                     crypto_LUKS 2            9ff9d9b7-dc2a-4fe4-8761-ab64d2eadd44
  └─luks-9ff9d9b7-dc2a-4fe4-8761-ab64d2eadd44
                           btrfs             fedora d157f328-67c9-4047-8197-c135539a392d   22.4G    39% /home
                                                                                                        /
sr0
zram0                      swap        1     zram0  1dc5eae9-929c-4584-ab12-ba51da5d6ce3                [SWAP]
```

The partition with `crypto_LUKS` is your encrypted partition.

> [!IMPORTANT]
> **The following steps assume the encrypted LUKS partition is /dev/sda3.  Replace with your actual partition if necessary.**

#### Back up the LUKS header

1. 
    ```
    sudo cryptsetup luksHeaderBackup /dev/sda3 \
    --header-backup-file /root/luks-sda3-header.img
    ```
2. Copy the `/root/luks-sda3-header.img` file to a secure external storage location such as an external drive or NAS.  It will be used in case of disaster recovery.

#### Set up automatic decryption with TPM

> [!CAUTION]
> **The commands in this section have the potential to break your system.  Make sure you understand each command before running.**

1. ```
    sudo systemd-cryptenroll \
        --tpm2-device=auto \
        --tpm2-pcrs=7 \
        /dev/sda3
    ```
    1. Enter your disk encryption password when prompted
1. ```
    sudo systemd-cryptenroll /dev/sda3
   ```
    1. The output should show a tpm2 entry alongside your existing password entry
1. ```
    sudo cp /etc/crypttab /etc/crypttab.bak
    ```
1. ```
    sudo nano /etc/crypttab
    ```
    1. Add `,x-initrd.attach,tpm2-device=auto` to the end of the line and save
1. ```
    dracut --list-modules | grep -E 'tpm2|systemd-cryptsetup'
    ```
    1. If tmp2-tss is listed
    1. ```
        echo 'add_dracutmodules+=" tpm2-tss "' | \
            sudo tee /etc/dracut.conf.d/tpm2.conf
        ```
1. ```
    sudo dracut --force
    ```
1. If all commands complete successfully, reboot your machine.  You should not be prompted for your disk encryption password on boot up and it should load your OS successfully

### Linux Mint

#### Verify TPM and Secure Boot is available

1. Run

    ```
    systemd-creds has-tpm2
    ```

    It should return output similar to:

    ```
    yes
    +firmware
    +driver
    +system
    +subsystem
    +libraries
    ```

    **yes** is the most important, meaning that the machine has TPM 2.0 support

1. Run 

    ```
    mokutil --sb-state
    ```

    It should return `SecureBoot enabled`.  If it doesn't, you should enable Secure Boot in your BIOS settings if your machine supports it

#### Find your encrypted partition

Run

```
lsblk -f
```

It should return output similar to:

```
NAME                       FSTYPE      FSVER LABEL  UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
sda
├─sda1                     vfat        FAT32        55CE-9BAB                             578.7M     3% /boot/efi
├─sda2                     ext4        1.0          6dceed6c-08eb-4892-99e3-6c34bcfd2326    1.4G    22% /boot
└─sda3                     crypto_LUKS 2            9ff9d9b7-dc2a-4fe4-8761-ab64d2eadd44
  └─luks-9ff9d9b7-dc2a-4fe4-8761-ab64d2eadd44
                           btrfs             fedora d157f328-67c9-4047-8197-c135539a392d   22.4G    39% /home
                                                                                                        /
sr0
zram0                      swap        1     zram0  1dc5eae9-929c-4584-ab12-ba51da5d6ce3                [SWAP]
```

The partition with `crypto_LUKS` is your encrypted partition.

> [!IMPORTANT]
> **The following steps assume the encrypted LUKS partition is /dev/sda3.  Replace with your actual partition if necessary.**

#### Back up the LUKS header

1. 
    ```
    sudo cryptsetup luksHeaderBackup /dev/sda3 \
    --header-backup-file /root/luks-sda3-header.img
    ```
2. Copy the `/root/luks-sda3-header.img` file to a secure external storage location such as an external drive or NAS.  It will be used in case of disaster recovery.

#### Set up automatic decryption with TPM

> [!CAUTION]
> **The commands in this section have the potential to break your system.  Make sure you understand each command before running.**

1. ```
    sudo clevis luks bind -d /dev/sda3 \
        tpm2 '{"pcr_bank":"sha256","pcr_ids":"7"}'
    ```
    1. Enter your disk encryption password when prompted

1. ```
    sudo clevis luks list -d /dev/sda3
   ```
    1. The output should show a tpm2 entry similar to:
        ```
        1: tpm2 '{"hash":"sha256","key":"ecc","pcr_bank":"sha256","pcr_ids":"7"}'
        ```

1. ```
    sudo update-initramfs -u -k all
    ```
1. ```
    lsinitramfs /boot/initrd.img-$(uname -r) | grep clevis
    ```
    1. You should see Clevis scripts and executables similar to:
        ```
        scripts/local-bottom/clevis
        scripts/local-top/clevis
        usr/bin/clevis
        usr/bin/clevis-decrypt
        usr/bin/clevis-decrypt-null
        usr/bin/clevis-decrypt-sss
        usr/bin/clevis-decrypt-tang
        usr/bin/clevis-decrypt-tpm2
        usr/bin/clevis-luks-common-functions
        usr/bin/clevis-luks-list
        usr/bin/clevis-luks-unlock
        ```
1. If all commands complete successfully, reboot your machine.  You should not be prompted for your disk encryption password on boot up and it should load your OS successfully

## GNOME Extensions

ExtensionManager is installed as part of the GNOME bootstrap process but installing the extensions themselves still is a manual step.

Some suggestions that I find helpful:

- Tiling Shell - improves window tiling especially for vertical monitors
- Blur My Shell - adds transparency to make windows look a little nicer
- Notifications Alert - changes the colour of the clock bar when there's an unread notification.  Set blink rate to 0 to disable blinking
- Dash to Dock - adds a traditional dock

---

# What Gets Configured

The bootstrap scripts install applications, development tooling, and apply a number of system and application preferences.

The examples below are representative rather than exhaustive. The playbooks and scripts are the source of truth for exactly what is installed and configured on each platform.

## Applications

Examples include:

- Brave
- VLC
- Visual Studio Code
- Flameshot
- Bruno
- DBeaver Community Edition
- Docker Engine

Platform-specific applications include tools such as Notepad++, WinDirStat, Kate, QDirStat, and Kopia.

## Development Tools

Examples include:

- Git
- Python
- Node.js
- uv
- OpenTofu
- AWS CLI
- AWS SAM CLI
- OpenAI Codex

## CLI and System Utilities

Common tools and system utilities are also installed, including:

- ffmpeg
- jq

### Fedora GNOME

- gnome-tweaks
- ExtensionManager (flatpak)

Additional utilities may be installed depending on the operating system.

## System and Application Preferences

The scripts also configure a number of preferences and settings to create a consistent environment across machines.

Examples include:

### Git

- Set the default branch to `main`

### Visual Studio Code

- Disable Copilot features
- Set indentation to 2 spaces

### Fedora KDE Plasma

- Disable clipboard history
- Enable browsing inside ZIP archives

### Fedora GNOME

- Set time to 12h format
- Display day of week in the clock bar

### Linux Mint

- Enable ufw firewall

### Windows

- Debloat Windows
    - Remove telemetry, AI features

# Notes

Elevated privileges are required while installing packages or changing system settings. You may be prompted for your password or administrator approval during execution.