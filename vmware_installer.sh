#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

VMWARE_HOST_MODULES_URL="https://github.com/philipl/vmware-host-modules"

VERSION="17.6.1"
BUILD="24319023"
BASE_URL="https://softwareupdate.vmware.com/cds/vmw-desktop/ws/${VERSION}/${BUILD}/linux"
URL="${BASE_URL}/core/VMware-Workstation-${VERSION}-${BUILD}.x86_64.bundle.tar"

OLD_DIR=$(pwd)
TEMP_DIR=$(mktemp -d)

DRY_RUN=0

RED="\033[0;31m"
ORANGE="\033[0;33m"
GREEN="\033[0;32m"
GREY="\033[0;90m"
NC="\033[0;m"

echo() {
  command echo -e "$@"
}

echo "${URL}"

dry_run() {
  if [ $DRY_RUN -eq 1 ]; then
    echo "${GREY}" "$@" "${NC}"
    return 0
  fi

  eval "$@"
}

clean_up() {
  echo "${GREEN}Cleaning up${NC}"
  rm -rf "$TEMP_DIR"
  cd "$OLD_DIR"
}

clean_up_failed() {
  echo "${RED}Something went wrong${NC}"
  clean_up
}

help() {
  echo "Usage:"
  echo "  $0 [options]"
  echo
  echo "Options:"
  echo "  -h  Show this help message"
  echo "  -n  Dry run, only print the commands that would be executed"
}

greeting() {
  echo -n "$GREEN"
  cat <<'EOF'
__     ____  ____        __
\ \   / /  \/  \ \      / /_ _ _ __ ___
 \ \ / /| |\/| |\ \ /\ / / _` | '__/ _ \
  \ V / | |  | | \ V  V / (_| | | |  __/
 __\_/  |_|  |_|  \_/\_/_\__,_|_|  \___|
|_ _|_ __  ___| |_ __ _| | | ___ _ __
 | || '_ \/ __| __/ _` | | |/ _ \ '__|
 | || | | \__ \ || (_| | | |  __/ |
|___|_| |_|___/\__\__,_|_|_|\___|_|
by MrSom3body

EOF
  echo -n "$NC"
}

get_deps() {
  if which pacman &>/dev/null; then
    echo "${ORANGE}Detected Arch, installing required packages.${NC}"
    dry_run sudo pacman -Syu
    dry_run sudo pacman -S base-devel linux-headers git fzf
  elif which apt &>/dev/null; then
    echo "${ORANGE}Detected Debian, installing required packages.${NC}"
    dry_run sudo apt update
    dry_run sudo apt upgrade
    dry_run sudo apt install build-essential linux-headers-"$(uname -r)" git fzf
  elif which dnf &>/dev/null; then
    echo "${ORANGE}Detected Fedora, installing required packages.${NC}"
    dry_run sudo dnf update
    dry_run sudo dnf install kernel-devel git fzf
  else
    echo "${RED}Didn't detect distribution, please install git, kernel-headers, make, and fzf yourself${NC}"
  fi
}

install_vmware() {
  echo "${GREEN}Installing VMWare Workstation${NC}"
  cd "$TEMP_DIR"
  echo "${ORANGE}Downloading VMWare Workstation${NC}"
  curl -L "$URL" -o "$TEMP_DIR/vmware-workstation.tar"
  echo "${ORANGE}Extracting VMWare Workstation${NC}"
  tar -xf "$TEMP_DIR/vmware-workstation.tar" -C "$TEMP_DIR"
  echo "${ORANGE}Installing VMWare Workstation${NC}"
  dry_run sudo bash "$TEMP_DIR/VMware-Workstation-${VERSION}-${BUILD}.x86_64.bundle" --eulas-agreed --deferred-gtk
  echo "${GREEN}VMWare Workstation installed successfully!${NC}"
  echo
}

fix_vmware_modules() {
  echo "${GREEN}Fixing VMWare modules${NC}"
  cd "$TEMP_DIR"
  git clone "$VMWARE_HOST_MODULES_URL"
  cd vmware-host-modules
  echo "VMWare version: ${GREEN}$(vmware -v)${NC}"
  echo "${ORANGE}Select the branch matching your VMWare version (if there is none use the first one and hope for the best):${NC}"
  dry_run git checkout --track "$(git branch -r | fzf --height 10 --tac | xargs)"

  echo "${ORANGE}Patching vmware modules${NC}"
  dry_run "make >/dev/null"
  dry_run "sudo make install >/dev/null"
  echo "${ORANGE}Starting vmware services${NC}"
  dry_run sudo systemctl start vmware

  echo "${GREEN}VMWare modules patched successfully!${NC}"
  echo
}

trap clean_up 1
trap clean_up_failed 2 3 6

while getopts "hn" opt; do
  case $opt in
  n)
    DRY_RUN=1
    ;;
  h)
    help
    exit 0
    ;;
  *)
    echo "${RED}Invalid option: ${OPTARG}${NC}"
    help
    exit 1
    ;;
  esac
done

greeting
get_deps
if ! which vmware &>/dev/null; then
  echo "${RED}VMWare Workstation is not installed${NC}"
  install_vmware
fi
fix_vmware_modules
clean_up
