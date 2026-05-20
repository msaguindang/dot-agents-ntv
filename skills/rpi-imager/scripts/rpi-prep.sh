#!/bin/bash
set -euo pipefail

# ============================================================
# N-Compass TV Raspberry Pi Prep Script
# ============================================================
# Run this on the SOURCE Pi BEFORE imaging.
# Cleans up machine-specific data so clones don't conflict.
#
# Usage:
#   ./rpi-prep.sh
#
# Must be run as root (sudo)
# ============================================================

readonly SCRIPT_NAME="$(basename "$0")"

log_info() { echo "[INFO] $*"; }
log_warn() { echo "[WARN] $*" >&2; }
log_error() { echo "[ERROR] $*" >&2; }

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

check_running_on_pi() {
    if [[ ! -d /sys/class/mmc_host ]]; then
        log_warn "This doesn't appear to be a Raspberry Pi. Are you sure?"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

main() {
    check_root
    check_running_on_pi

    log_info "=========================================="
    log_info "  N-Compass TV Raspberry Pi Prep"
    log_info "=========================================="

    log_info "This script will generalize the system for cloning."
    log_info "After running, the Pi will:"
    log_info "  - Forget WiFi credentials"
    log_info "  - Get a new machine ID"
    log_info "  - Regenerate SSH host keys"
    log_info "  - Clear log files and caches"
    echo ""

    read -p "Continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Aborted."
        exit 1
    fi

    # 1. Clear WiFi config
    log_info "Clearing WiFi config..."
    if [[ -f /etc/wpa_supplicant/wpa_supplicant.conf ]]; then
        tee /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null << 'EOF'
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=US
network={
}
EOF
        log_info "  WiFi config cleared"
    else
        log_info "  No WiFi config found, skipping"
    fi

    # 2. Reset machine-id
    log_info "Resetting machine-id..."
    echo "" > /etc/machine-id
    if [[ -f /var/lib/dbus/machine-id ]]; then
        ln -sf /etc/machine-id /var/lib/dbus/machine-id 2>/dev/null || true
    fi
    log_info "  Machine ID reset"

    # 3. Remove SSH host keys
    log_info "Removing SSH host keys..."
    rm -f /etc/ssh/ssh_host_*
    log_info "  SSH host keys removed"

    # 4. Regenerate SSH host keys
    log_info "Generating new SSH host keys..."
    ssh-keygen -A
    log_info "  New SSH host keys generated"

    # 5. Clear DHCP leases
    log_info "Clearing DHCP leases..."
    rm -f /var/lib/dhcp/dhclient.leases 2>/dev/null || true
    rm -f /var/lib/dhcpcd/*.lease 2>/dev/null || true
    log_info "  DHCP leases cleared"

    # 6. Clear log files
    log_info "Clearing log files..."
    journalctl --flush 2>/dev/null || true
    find /var/log -type f -exec truncate -s 0 {} \; 2>/dev/null || true
    log_info "  Log files cleared"

    # 7. Clear temporary files
    log_info "Clearing temp files..."
    rm -rf /tmp/* 2>/dev/null || true
    rm -rf /var/tmp/* 2>/dev/null || true
    log_info "  Temp files cleared"

    # 8. Clear any existing play logs (contains analytics cache)
    if [[ -d /opt/nct-vistar/play_logs ]]; then
        log_info "Clearing play logs..."
        rm -f /opt/nct-vistar/play_logs/* 2>/dev/null || true
        log_info "  Play logs cleared"
    fi

    # 9. Clear any crash reports
    log_info "Clearing crash reports..."
    rm -rf /var/crash/* 2>/dev/null || true
    log_info "  Crash reports cleared"

    echo ""
    log_info "=========================================="
    log_info "  Prep complete!"
    log_info "=========================================="
    echo ""
    log_info "You can now power off and image the SD card."
    echo ""
}

main "$@"
