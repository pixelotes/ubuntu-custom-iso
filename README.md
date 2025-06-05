# Ubuntu Autoinstall ISO Creator

This repository contains scripts to create custom Ubuntu ISO images with automated installation capabilities. The tool supports both minimal and full installations with enterprise-grade features including LUKS encryption, automated software deployment, and system management integration.

## Overview

The script downloads an official Ubuntu ISO, customizes it with your autoinstall configuration, and creates a new ISO that can perform unattended installations. This is particularly useful for:

- Enterprise workstation deployment
- Standardized system configurations
- Automated provisioning with encryption
- Integration with management platforms (JumpCloud, Landscape)

## Files Structure

```
├── make-image.sh           # Main script to create custom ISOs
├── autoinstall-full.yaml   # Full installation with post-install automation
├── autoinstall-mini.yaml   # Minimal installation configuration
└── README.md              # This documentation
```

## Quick Start

### Prerequisites

Install required dependencies:

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install xorriso patch wget

# RHEL/CentOS/Fedora
sudo dnf install xorriso patch wget
```

### Basic Usage

Create a minimal custom ISO:
```bash
./make-image.sh
```

Create a full enterprise ISO with custom settings:
```bash
./make-image.sh \
  --type full \
  --lang en \
  --luks-password "YourSecurePassword123" \
  --keyboard-layout us \
  --locale "en_US.UTF-8" \
  --company-name "YourCompany" \
  --ubuntu-version "24.04.2" \
  --timezone "America/New_York"
```

## Configuration Options

| Parameter | Description | Default | Options |
|-----------|-------------|---------|---------|
| `--type` | Installation type | `minimal` | `minimal`, `full` |
| `--lang` | Language | `en` | `en`, `es` |
| `--luks-password` | LUKS encryption password | `mysupersecret` | Any string |
| `--keyboard-layout` | Keyboard layout | `en` | Standard layouts (us, es, fr, etc.) |
| `--locale` | System locale | `en_US.UTF-8` | Standard locales |
| `--company-name` | Company/Organization name | `MyCompany` | Any string |
| `--ubuntu-version` | Ubuntu version to use | `24.04.2` | Available Ubuntu versions |
| `--timezone` | System timezone | `Europe/London` | TZ database timezones |
| `--arch` | Architecture | `amd64` | `amd64`, `arm64`, `ppc64el` |
| `--edition` | Ubuntu edition | `desktop` | `desktop`, `server` |

## Installation Types

### Minimal Installation (`autoinstall-mini.yaml`)

The minimal installation provides:
- Base Ubuntu system with desktop environment
- LUKS full-disk encryption
- Essential codecs and drivers
- Security updates only
- Clean shutdown after installation

**Use cases:**
- Basic workstation deployment
- Systems requiring manual post-install configuration
- Testing and development environments

### Full Installation (`autoinstall-full.yaml`)

# Ubuntu Custom ISO Builder

This script creates a custom Ubuntu ISO with automated installation configuration.

## Prerequisites

Before running the script, ensure you have the following tools installed:

- `xorriso` - for ISO manipulation
- `patch` - for applying patches
- `wget` - for downloading files

On Ubuntu/Debian systems, you can install these with:
```bash
sudo apt update
sudo apt install xorriso patch wget
```

## Files

- `make-image.sh` - Main script to build the custom ISO
- `autoinstall-full.yaml` - Template for full installation with additional software
- `autoinstall-mini.yaml` - Template for minimal installation without late-commands

## Usage

```bash
./make-image.sh [OPTIONS]
```

### Options

- `--type TYPE` - Set the installation type (`minimal` or `full`). Default: `minimal`
- `--lang LANG` - Set the language. Default: `en`
- `--luks-password PASSWORD` - Set the LUKS encryption password. Default: `mysupersecret`
- `--keyboard-layout LAYOUT` - Set the keyboard layout. Default: `en`
- `--locale LOCALE` - Set the system locale. Default: `en_US.UTF-8`
- `--company-name NAME` - Set the company name for branding. Default: `MyCompany`
- `--ubuntu-version` - Set the Ubuntu version to customize. Default: `24.04.2`
- `--timezone` - Set the timezone. Default: `Europe/London`
- `--arch`- Set the architecture of the Ubuntu iso. Default: `amd64`
- `--ubuntu-version VERSION` - Set the Ubuntu version (e.g., 24.04.2, 22.04.3). Default: `24.04.2`
- `--help` - Display help message and exit

### Examples

Basic usage with default settings:
```bash
./make-image.sh
```

Create a full installation ISO with Spanish settings:
```bash
./make-image.sh --type full --lang es --keyboard-layout es --locale es_ES.UTF-8 --company-name Acme
```

Create a minimal installation with custom LUKS password and company name:
```bash
./make-image.sh --type minimal --luks-password myCustomPassword123 --company-name TechCorp
```

Create a full installation with Ubuntu 22.04.3:
```bash
./make-image.sh --type full --ubuntu-version 22.04.3 --company-name "My Company"
```

Create a full installation with all custom settings:
```bash
./make-image.sh --type full --lang en --luks-password securePassword --keyboard-layout gb --locale en_GB.UTF-8 --company-name "My Company" --ubuntu-version 24.04.2
```

## Installation Types

### Minimal Installation
- Basic package set with development tools
- No additional software installation via late-commands
- Faster installation process

### Full Installation
- Same packages as minimal installation
- Additional software installed via late-commands:
  - Flathub repository setup
  - Google Chrome
  - GitHub Desktop
- Longer installation process due to additional downloads

## Output

The script will generate a custom ISO file named:
`ubuntu-{UBUNTU_VERSION}-{COMPANY_NAME_LOWERCASE}-{TYPE}-{LANG}-amd64.iso`

Where `{UBUNTU_VERSION}` is the specified Ubuntu version, `{COMPANY_NAME_LOWERCASE}` is the company name converted to lowercase, `{TYPE}` is either `minimal` or `full`, and `{LANG}` is either `es` or `en`.

## Configuration

The script uses template files (`autoinstall-full.yaml` and `autoinstall-mini.yaml`) with placeholders that are replaced during the build process:

- `{{LUKS_PASSWORD}}` - Replaced with the LUKS encryption password
- `{{KEYBOARD_LAYOUT}}` - Replaced with the keyboard layout
- `{{LOCALE}}` - Replaced with the system locale
- `{{COMPANY_NAME}}` - Replaced with the company name for branding

The generated `autoinstall.yaml` file is embedded into the ISO for automated installation.

## Notes

- The script downloads the specified Ubuntu desktop ISO if not already present
- The original ISO file is preserved; only a custom version is created
- Temporary files are cleaned up automatically after the build process
- The installation includes LVM with LUKS encryption by default
- Supported Ubuntu version formats: XX.YY (e.g., 24.04) or XX.YY.Z (e.g., 24.04.2)
- The download URL follows Ubuntu's standard release structure: `https://releases.ubuntu.com/{RELEASE}/{ISO_FILENAME}`

The full installation includes everything from minimal plus:
- **Automated Software Installation:**
  - Google Chrome with extensions
  - Visual Studio Code
  - Slack Desktop
- **Enterprise Integration:**
  - JumpCloud agent for identity management (requires token)
  - Ubuntu Pro subscription activation (requires token)
  - Landscape client for system management (requires several setup parameters)
- **Security Configuration:**
  - Unattended security updates
  - ESM (Extended Security Maintenance)
  - Canonical Livepatch
- **System Optimization:**
  - Removal of unnecessary snap packages (Firefox, Thunderbird)
  - First-boot automation service

## Full Installation Deep Dive

### Post-Installation Automation Flow

The setup creates the following files on the target filesystem:
```
├── /etc
  └── /systemd
     └── /system
        └── first-boot.service     # Runs first_boot.sh once it detects internet connection
├── /opt
  └── /setup
     └── first_boot.sh             # Installs ansible and runs the playbook, then disables first-boot.service
  └── /ansible
     └── setup_playbook.yml        # Main source of customization
```

The process is as follows:
1. **System Boot**: After installation, the system reboots and triggers the first-boot service
2. **Connectivity Check**: Verifies internet connection before proceeding. Retries every 10 seconds until it detects internet connection.
3. **User Notification**: Displays desktop notifications about setup progress
4. **Package Updates**: Updates system packages and installs required tools
5. **Ansible Execution**: Runs comprehensive system configuration playbook
6. **Service Cleanup**: Disables first-boot service to prevent re-running
7. **Completion Notification**: Notifies user when setup is complete

### Automated Software Deployment

The full installation automatically installs and configures:

#### **Google Chrome**
- Downloads and installs the latest stable version
- Configures enterprise extensions directory
- Adds extension for automatic updates

#### **Development Tools**
- **Visual Studio Code**: Latest stable release
- **Ansible**: For configuration management
- **curl**: For API interactions

#### **Communication Tools**
- **Slack Desktop**: Installed via snap with classic confinement

#### **System Cleanup**
- Removes Firefox snap (replaced with Chrome)
- Removes Thunderbird snap (enterprise email typically handled elsewhere)

### Enterprise Integration

#### **JumpCloud Integration**
```yaml
- name: Download and run JumpCloud install script
  shell: |
    curl --tlsv1.2 --silent --show-error --header 'x-connect-key: <JUMPCLOUD_TOKEN>' https://kickstart.jumpcloud.com/Kickstart | bash
```
**Configuration Required:** Replace `<JUMPCLOUD_TOKEN>` with your actual JumpCloud connect key.

#### **Ubuntu Pro Subscription**
```yaml
- name: Attach Ubuntu to Ubuntu Pro
  shell: |
    pro attach <UBUNTU_PRO_TOKEN>
```
**Configuration Required:** Replace `<UBUNTU_PRO_TOKEN>` with your Ubuntu Pro token.

**Enabled Services:**
- `esm-infra`: Extended Security Maintenance for infrastructure
- `esm-apps`: Extended Security Maintenance for applications
- `livepatch`: Kernel security updates without reboots

#### **Landscape Management**
```yaml
- name: Configure and register Landscape client
  command: >
    landscape-config
    --computer-title "<COMPUTER_TITLE>"
    --account-name "<LANDSCAPE_ACCOUNT_NAME>"
    --url <LANDSCAPE_URL>
    --ping-url <LANDSCAPE_URL>/ping
    --silent
```
**Configuration Required:** Replace placeholders with your Landscape server details.

### Security Features

#### **LUKS Full-Disk Encryption**
- Encrypts entire system using LVM
- Password configured via `--luks-password` parameter
- Protects data at rest

#### **Automatic Security Updates**
- Configures `unattended-upgrades` for security patches
- Enables Ubuntu Pro security services
- Implements Canonical Livepatch for kernel updates

#### **System Hardening**
- Removes unnecessary applications
- Configures secure defaults
- Enables enterprise security features

### Environment-Specific Configuration

Before using in production, update these placeholders in `autoinstall-full.yaml`:

| Placeholder | Location | Description |
|-------------|----------|-------------|
| `<JUMPCLOUD_TOKEN>` | JumpCloud task | Your organization's JumpCloud connect key |
| `<UBUNTU_PRO_TOKEN>` | Ubuntu Pro task | Your Ubuntu Pro subscription token |
| `<COMPUTER_TITLE>` | Landscape task | Template for computer naming |
| `<LANDSCAPE_ACCOUNT_NAME>` | Landscape task | Your Landscape account name |
| `<LANDSCAPE_URL>` | Landscape task | Your Landscape server URL |

## Usage Examples

### Development Environment
```bash
./make-image.sh \
  --type minimal \
  --company-name "DevCorp" \
  --luks-password "dev123"
```

### Production Enterprise Deployment
```bash
./make-image.sh \
  --type full \
  --company-name "Enterprise Corp" \
  --luks-password "SecureEnterprisePassword2024!" \
  --timezone "America/New_York" \
  --locale "en_US.UTF-8" \
  --ubuntu-version "24.04.2"
```

## Troubleshooting

### Common Issues

**ISO Creation Fails:**
- Verify all dependencies are installed
- Check internet connection for Ubuntu ISO download
- Ensure sufficient disk space (>8GB free)

**Autoinstall Hangs:**
- Verify YAML syntax in autoinstall files
- Check network connectivity during installation
- Review installation logs in `/var/log/installer/`

**First-Boot Service Fails:**
- Check logs in `/var/log/first-boot.log`
- Verify internet connectivity
- Ensure all placeholders are replaced with actual values

### Log Files

- **Installation:** `/var/log/installer/autoinstall-user-data`
- **First Boot:** `/var/log/first-boot.log`
- **Ansible:** Included in first-boot log
- **System:** `/var/log/syslog`

## Security Considerations

- **Change default LUKS password** before production use
- **Edit the yaml templates** to suit your requirements
- **Replace all placeholder tokens** with actual values
- **Audit installed software** for your security requirements
- **Test in isolated environment** before production deployment
- **Secure the generated ISO** as it contains configuration secrets

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with both minimal and full installation types
5. Submit a pull request

## License

This project is licensed under the MIT License. See LICENSE file for details.

---

**Note:** This tool creates production-ready ISO images. Always test in a controlled environment before deploying to production systems.
