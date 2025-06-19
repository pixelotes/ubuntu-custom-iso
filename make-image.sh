#!/usr/bin/env bash

command -v xorriso >/dev/null 2>&1 || { echo >&2 "Please install 'xorriso' first.  Aborting."; exit 1; }
command -v patch >/dev/null 2>&1 || { echo >&2 "Please install 'patch' first.  Aborting."; exit 1; }
command -v wget >/dev/null 2>&1 || { echo >&2 "Please install 'wget' first.  Aborting."; exit 1; }

set -e

# Default values
TYPE="minimal"
LANG="en"
LUKS_PASSWORD="mysupersecret"
KEYBOARD_LAYOUT="en"
LOCALE="en_US.UTF-8"
COMPANY_NAME="MyCompany"
UBUNTU_VERSION="24.04.2"
TIMEZONE="Europe/London"
ARCH="amd64"
EDITION="desktop"

# Help function
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo "Create a custom Ubuntu ISO with specified options."
    echo
    echo "Options:"
    echo "  --type TYPE              Set the installation type (minimal or full). Default: minimal"
    echo "  --lang LANG              Set the language (es or en). Default: en"
    echo "  --luks-password PASSWORD Set the LUKS encryption password. Default: mysupersecret"
    echo "  --keyboard-layout LAYOUT Set the keyboard layout. Default: en"
    echo "  --locale LOCALE          Set the locale. Default: en_US.UTF-8"
    echo "  --company-name NAME      Set the company name. Default: MyCompany"
    echo "  --ubuntu-version VERSION Set the Ubuntu version (e.g., 24.04.2, 22.04.3). Default: 24.04.2"
    echo "  --timezone TIMEZONE      Set the timezone. Default: Europe/London"
    echo "  --arch ARCH              Set the architecture. Default: amd64"
    echo "  --edition EDITION        Set the edition (desktop or server). Default: desktop"
    echo "  --late-commands          Adds the contents of \"late-commands.yaml\" to the autoinstall file"
    echo "  --help                   Display this help message and exit"
    echo
    echo "Example:"
    echo "  $0 --type full --lang es --luks-password mypassword --keyboard-layout es --locale es_ES.UTF-8 --timezone \"Europe/London\" --company-name Acme --ubuntu-version 22.04.3"
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --lang) LANG="$2"; shift ;;
        --luks-password) LUKS_PASSWORD="$2"; shift ;;
        --keyboard-layout) KEYBOARD_LAYOUT="$2"; shift ;;
        --locale) LOCALE="$2"; shift ;;
        --company-name) COMPANY_NAME="$2"; shift ;;
        --ubuntu-version) UBUNTU_VERSION="$2"; shift ;;
        --timezone) TIMEZONE="$2"; shift ;;
        --arch) ARCH="$2"; shift ;;
	--late-commands) TYPE="full"; shift ;;
        --help) show_help; exit 0 ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Validate input
if [[ ! "$EDITION" =~ ^(desktop|server)$ ]]; then
    echo "Invalid edition. Must be 'desktop' or 'server'."
    exit 1
fi

if [[ ! "$ARCH" =~ ^(amd64|arm64|ppc64el)$ ]]; then
    echo "Invalid architecture. Must be 'amd64', 'arm64' or 'ppc64el'. Note that other architectures such as risc-v or s390x are not publicly available."
    exit 1
fi

set -x

# Basic parameters
DEVICE="${COMPANY_NAME,,}"  # Convert to lowercase
# Parse version components
if [[ "$UBUNTU_VERSION" =~ ^([0-9]+\.[0-9]+)(\.[0-9]+)?$ ]]; then
    UBUNTU_RELEASE="${BASH_REMATCH[1]}"
    UBUNTU_POINT_RELEASE="${BASH_REMATCH[2]:-}"
else
    echo "Invalid Ubuntu version format. Expected format: XX.YY or XX.YY.Z (e.g., 24.04 or 24.04.2)"
    exit 1
fi
RELEASE_ISO_FILENAME="ubuntu-${UBUNTU_VERSION}-${EDITION}-${ARCH}.iso"
CUSTOM_ISO_FILENAME="ubuntu-${UBUNTU_VERSION}-${DEVICE}-${TYPE}-${LANG}-${ARCH}.iso"
DOWNLOAD_URL="https://releases.ubuntu.com/${UBUNTU_RELEASE}/${RELEASE_ISO_FILENAME}"
GENISO_BOOTIMG="boot/grub/i386-pc/eltorito.img"
GENISO_BOOTCATALOG="/boot.catalog"
GENISO_START_SECTOR="$(LANG=C fdisk -l ${RELEASE_ISO_FILENAME} |grep iso2 | cut -d' ' -f2)"
GENISO_END_SECTOR="$(LANG=C fdisk -l ${RELEASE_ISO_FILENAME} |grep iso2 | cut -d' ' -f3)"

UNPACKED_IMAGE_PATH="./unpacked-iso/"
# Check if the Ubuntu release exists before downloading
if ! wget --spider -q "${DOWNLOAD_URL}"; then
    echo "Error: The specified Ubuntu release does not exist at ${DOWNLOAD_URL}"
    exit 1
fi

if [ ! -f "${RELEASE_ISO_FILENAME}" ]; then
        wget -q ${DOWNLOAD_URL} -O ${RELEASE_ISO_FILENAME}
fi

xorriso -osirrox on -indev  "${RELEASE_ISO_FILENAME}" -- -extract / "${UNPACKED_IMAGE_PATH}"
chmod -R u+w ${UNPACKED_IMAGE_PATH}

sed -i "s/Ubuntu/${COMPANY_NAME} OEM/g" ${UNPACKED_IMAGE_PATH}boot/grub/grub.cfg

# Select the appropriate autoinstall content based on type
if [[ "$TYPE" == "full" ]]; then
    AUTOINSTALL_CONTENT=$(cat autoinstall.yaml late-commands.yaml)
else
    AUTOINSTALL_CONTENT=$(cat autoinstall.yaml)
fi

# Generate autoinstall.yaml with variable substitution
echo "$AUTOINSTALL_CONTENT" | sed -e "s/{{LUKS_PASSWORD}}/${LUKS_PASSWORD}/g" \
    -e "s/{{KEYBOARD_LAYOUT}}/${KEYBOARD_LAYOUT}/g" \
    -e "s/{{LOCALE}}/${LOCALE}/g" \
    -e "s/{{COMPANY_NAME}}/${COMPANY_NAME}/g" \
    -e "s|{{TIMEZONE}}|${TIMEZONE}|g" > "${UNPACKED_IMAGE_PATH}autoinstall.yaml"

# Fix for the timezone, as it contains forward slashes
#sed -e "s|{{TIMEZONE}}|\"${TIMEZONE}\"|g" "${UNPACKED_IMAGE_PATH}autoinstall.yaml" > "${UNPACKED_IMAGE_PATH}autoinstall2.yaml"

# https://github.com/YasuhiroABE/ub-autoinstall-iso/blob/main/Makefile
LANG=C xorriso -as mkisofs  \
	-V "${COMPANY_NAME} OEM Ubuntu Install" \
	-output "$CUSTOM_ISO_FILENAME"  \
	-eltorito-boot "${GENISO_BOOTIMG}" \
	-eltorito-catalog "${GENISO_BOOTCATALOG}" -no-emul-boot \
	-boot-load-size 4 -boot-info-table -eltorito-alt-boot \
	-no-emul-boot -isohybrid-gpt-basdat \
	-append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b --interval:local_fs:${GENISO_START_SECTOR}d-${GENISO_END_SECTOR}d::"${RELEASE_ISO_FILENAME}" \
	-e '--interval:appended_partition_2_start_1782357s_size_8496d:all::' \
	--grub2-mbr --interval:local_fs:0s-15s:zero_mbrpt,zero_gpt:"${RELEASE_ISO_FILENAME}" \
	"${UNPACKED_IMAGE_PATH}"

# Cleanup
rm -r ./unpacked-iso
