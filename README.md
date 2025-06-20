# Ubuntu Autoinstall ISO Creator

This repository contains scripts to create custom Ubuntu ISO images with automated installation capabilities. The tool supports both minimal and full installations with enterprise-grade features including LUKS encryption, automated software deployment, and system management integration.


> [!WARNING]  
> Ubuntu Desktop 24.04 has a bug that will crash the installer when using an autoinstall file. The workaround is to close the installer, open a terminal and run the command `sudo snap refresh`. After this, the installer should work if launched again. This operation requires internet connection, making impossible to perform air-gapped installs with this image.

## Overview

The script downloads an official Ubuntu ISO, customizes it with your autoinstall configuration, and creates a new ISO that can perform unattended installations. This is particularly useful for:

- Enterprise workstation deployment
- Standardized system configurations
- Automated provisioning with encryption
- Integration with management platforms (JumpCloud, Landscape)

## Files Structure

```
├── make-image.sh           # Main script to create custom ISOs
├── autoinstall.yaml        # Minimal installation configuration
├── late-commands.yaml      # Custom commands to be run after install
├── LICENSE                 # The license for this repo
└── README.md               # This documentation
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
  --lang en \
  --luks-password "YourSecurePassword123" \
  --keyboard-layout us \
  --locale "en_US.UTF-8" \
  --company-name "YourCompany" \
  --ubuntu-version "24.04.2" \
  --late-commands \
  --timezone "America/New_York"
```

## Configuration Options

| Parameter | Description | Default | Options |
|-----------|-------------|---------|---------|
| `--lang` | Language | `en` | `en`, `es` |
| `--luks-password` | LUKS encryption password | `mysupersecret` | Any string |
| `--keyboard-layout` | Keyboard layout | `en` | Standard layouts (us, es, fr, etc.) |
| `--locale` | System locale | `en_US.UTF-8` | Standard locales |
| `--company-name` | Company/Organization name | `MyCompany` | Any string |
| `--ubuntu-version` | Ubuntu version to use | `24.04.2` | Available Ubuntu versions |
| `--timezone` | System timezone | `Europe/London` | TZ database timezones |
| `--arch` | Architecture | `amd64` | `amd64`, `arm64`, `ppc64el` |
| `--edition` | Ubuntu edition | `desktop` | `desktop`, `server` |
| `--late-commands` | Include late commands | - | - |

## Installation Types

### Minimal Installation (`autoinstall.yaml`)

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

### Full Installation (`autoinstall.yaml` + `late-commands.yaml`)

- Same packages as minimal installation
- Additional software installed via late-commands.
- A late-commands example is provided, feel free to customize it to suit your needs.

## Output

The script will generate a custom ISO file named:
`ubuntu-{UBUNTU_VERSION}-{COMPANY_NAME_LOWERCASE}-{TYPE}-{LANG}-amd64.iso`

Where `{UBUNTU_VERSION}` is the specified Ubuntu version, `{COMPANY_NAME_LOWERCASE}` is the company name converted to lowercase, `{TYPE}` is either `minimal` or `full`, and `{LANG}` is either `es` or `en`.

## Notes

- The script downloads the specified Ubuntu desktop ISO if not already present
- The original ISO file is preserved; only a custom version is created
- Temporary files are cleaned up automatically after the build process
- The installation includes LVM with LUKS encryption by default
- Supported Ubuntu version formats: XX.YY (e.g., 24.04) or XX.YY.Z (e.g., 24.04.2)
- The download URL follows Ubuntu's standard release structure: `https://releases.ubuntu.com/{RELEASE}/{ISO_FILENAME}`

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
