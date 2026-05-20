#!/bin/bash
set -euo pipefail

# ============================================================
# N-Compass TV Raspberry Pi Image Creator
# ============================================================
# Run this on your PC to create a master image from an SD card.
#
# BEFORE CREATING IMAGE:
#   1. Run rpi-prep.sh on the SOURCE Pi first (see that script)
#   2. Shutdown the Pi and remove its SD card
#   3. Insert the SD card into your PC
#
# USAGE:
#   ./rpi-backup.sh <sd_device> [output_path]
#
# Examples:
#   ./rpi-backup.sh /dev/sda                       # Creates: TVBox-$(date +%Y%m%d).img.xz
#   ./rpi-backup.sh /dev/sda ./my-image.img.xz    # Creates: my-image.img.xz
#
# Notes:
#   - SD device should be the whole disk (e.g., /dev/sdX, NOT /dev/sdX1)
#   - Output is xz compressed (Raspberry Pi Imager compatible)
#   - Must be run as root (sudo)
# ============================================================

readonly SCRIPT_NAME="$(basename "$0")"

show_usage() {
    cat << EOF
Usage: $SCRIPT_NAME <sd_device> [output_path]

Arguments:
  sd_device     SD card device (e.g., /dev/sda) - use whole disk
  output_path   Output file path (optional, default: TVBox-YYYYMMDD.img.xz)

Examples:
  $SCRIPT_NAME /dev/sda                       # Creates TVBox-20260327.img.xz
  $SCRIPT_NAME /dev/sda ./my-image.img.xz     # Creates my-image.img.xz

EOF
    exit 1
}

log_info() { echo "[INFO] $*"; }
log_warn() { echo "[WARN] $*" >&2; }
log_error() { echo "[ERROR] $*" >&2; }

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

validate_args() {
    local sd_device="$1"
    local output_path="${2:-}"

    if [[ ! -b "$sd_device" ]]; then
        log_error "SD device not found or not a block device: $sd_device"
        log_error "Use whole disk (e.g., /dev/sdX), not partition (e.g., /dev/sdX1)"
        exit 1
    fi

    # Generate default output path if not provided
    if [[ -z "$output_path" ]]; then
        local date_str
        date_str="$(date +%Y%m%d)"
        output_path="$(pwd)/TVBox-${date_str}.img.xz"
    fi

    # Check if output file already exists
    if [[ -f "$output_path" ]]; then
        log_error "Output file already exists: $output_path"
        read -p "Overwrite? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    # Device verification: Ensure it's not mounted and looks like an SD/USB device
    local device_info
    device_info=$(lsblk -no NAME,SIZE,TYPE,MOUNTPOINT,VENDOR,MODEL "$sd_device" | head -n 1)
    log_info "Verifying device: $device_info"

    if [[ -n "$(lsblk -no MOUNTPOINT "$sd_device" | grep -v '^$')" ]]; then
        log_error "Device appears to be mounted! Unmount all partitions first."
        exit 1
    fi

    read -p "Are you ABSOLUTELY sure this is the correct SD card? (YES/no) " -r
    if [[ ! $REPLY == "YES" ]]; then
        log_info "Aborted."
        exit 1
    fi

    echo "$output_path"
}

create_image() {
    local sd_device="$1"
    local output_path="$2"

    log_info "Creating compressed image..."
    log_info "  Source: $sd_device"
    log_info "  Output: $output_path"
    log_info "This may take several minutes (xz compression is slow)..."
    log_info "Tip: A 32GB card typically compresses to 2-5GB"

    # Create image with dd and pipe through xz (Raspberry Pi Imager compatible)
    dd if="$sd_device" bs=4M status=progress | xz -c > "$output_path"

    sync
    log_info "Image created successfully!"

    # Show final size
    local size
    size="$(du -h "$output_path" | cut -f1)"
    log_info "  Size: $size"
}

main() {
    local sd_device="${1:-}"
    local output_path="${2:-}"

    if [[ $# -lt 1 ]]; then
        show_usage
    fi

    check_root
    output_path="$(validate_args "$sd_device" "$output_path")"

    log_info "=========================================="
    log_info "  N-Compass TV Image Creator"
    log_info "=========================================="

    create_image "$sd_device" "$output_path"

    echo ""
    log_info "=========================================="
    log_info "  Done! Image is ready."
    log_info "=========================================="
    echo ""
    echo "Next steps:"
    echo "  1. Use Raspberry Pi Imager to flash this image"
    echo "  2. Or use rpi-clone.sh to flash from command line"
    echo ""
}

main "$@"
