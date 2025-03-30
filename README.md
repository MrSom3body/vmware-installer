# 🚀 VMware Workstation Installer & Patcher

> [!NOTE]
> This script sadly can't download VMware for you anymore as Broadcom has
> stopped providing the `.tar.gz` without an account

Welcome to the **VMware Workstation Installer & Patcher** script! This script helps you install VMware Workstation, fetch necessary dependencies, and patch VMware modules to get your setup working on Linux distributions on Arch, Debian and Fedora.

## ✨ Features

- 💻 **Install VMware Workstation**: Download and install VMware Workstation automatically.
- 🔧 **Patch VMware Modules**: Clone, compile, and patch the required VMware modules.
- 🛠️ **Dry Run Mode**: Preview the commands that will be executed without making any changes.
- 🔗 **Automated Cleanup**: Cleans up temporary files and directories after execution.

## 📦 Installation

To get the script you can just clone the repo and link it to `~/.local/bin`:

```bash
git clone https://github.com/MrSom3body/vmware-installer
cd vmware-installer
chmod +x vmware_installer.sh
ln -sf $PWD/vmware_installer.sh ~/.local/bin/vmware_installer.sh
```

## ⚙️ Usage

```bash
Usage:
  ./vmware_installer.sh [options]

Options:
  -h  Show this help message
  -n  Dry run, only print the commands that would be executed
```

## 🛠️ Prerequisites

Make sure your system has the following dependencies:

- `git`
- `kernel-headers`
- `make`
- `fzf`

## 📦 Supported Linux Distributions

- **Arch**
- **Debian**
- **Fedora**

## 🎨 Colors

- 🟢 Green: Successful actions.
- 🟠 Orange: Informational messages.
- 🔴 Red: Errors or critical issues.
- ⚪ Grey: Dry-run commands (won't be executed unless dry-run mode is turned off).
