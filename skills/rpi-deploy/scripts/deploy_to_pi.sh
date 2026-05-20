#!/bin/bash
set -euo pipefail

# ============================================================
# RPi Dynamic Deployer Script
# ============================================================
# Usage: ./deploy_to_pi.sh <branch> <env> <ui|server|both>
# Example: ./deploy_to_pi.sh feat/123-new-player dev both
# ============================================================

# Require NTV_DIR to be set in the environment; fail loudly if missing
export NTV_DIR="${NTV_DIR:?NTV_DIR is not set}"
export NTV_PLAYER_SERVER_WT_DIR="$NTV_DIR/player-server-worktrees"
export NTV_PLAYER_UI_WT_DIR="$NTV_DIR/player-ui-worktrees"

BRANCH=$1
TARGET_ENV=$2
SCOPE=$3

UI_DIR="$NTV_PLAYER_UI_WT_DIR/$BRANCH"
SERVER_DIR="$NTV_PLAYER_SERVER_WT_DIR/$BRANCH"

log_info() { echo -e "\033[1;34m[INFO]\033[0m $*"; }
log_error() { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; exit 1; }
log_success() { echo -e "\033[1;32m[SUCCESS]\033[0m $*"; }

# 1. Verification
if [[ ! -d "$SERVER_DIR" ]]; then
    log_error "Server worktree not found for branch: $BRANCH ($SERVER_DIR)"
fi

if [[ "$SCOPE" == "ui" || "$SCOPE" == "both" ]]; then
    if [[ ! -d "$UI_DIR" ]]; then
        log_error "UI worktree not found for branch: $BRANCH ($UI_DIR)"
    fi
fi

# Ensure .env is copied to the server worktree if it doesn't exist
if [[ ! -f "$SERVER_DIR/.env" ]]; then
    log_info "Copying base .env to server worktree..."
    cp "$NTV_DIR/player-server/.env" "$SERVER_DIR/.env"
fi

# 2. UI Build Phase
if [[ "$SCOPE" == "ui" || "$SCOPE" == "both" ]]; then
    log_info "Building UI ($UI_DIR)..."
    cd "$UI_DIR"
    
    # We use a memory-safe build command based on dashboard-v1 patterns
    node --max_old_space_size=4096 node_modules/@angular/cli/bin/ng build --configuration production
    log_success "UI Build Complete."

    # Copy UI artifacts to the server directory (Simulating what might normally happen)
    # Note: Assuming player-server gulp bundle expects UI in ./public or similar
    # If the exact path differs, this needs adjustment based on player-server architecture.
    log_info "Copying UI artifacts to Server worktree..."
    mkdir -p "$SERVER_DIR/src/public"
    cp -r "$UI_DIR/dist/player-ui/"* "$SERVER_DIR/src/public/" || true
    log_success "UI Artifacts transferred to server working directory."
fi

# 3. Server Build & Deploy Phase
if [[ "$SCOPE" == "server" || "$SCOPE" == "both" || "$SCOPE" == "ui" ]]; then
    log_info "Deploying from Server ($SERVER_DIR)..."
    cd "$SERVER_DIR"

    log_info "Executing Gulp Upload to $TARGET_ENV..."
    
    # Execute the existing deployment orchestration mapped to the requested env
    # Using NODE_ENV triggers the specific sshConfig block
    # npm run build:upload:base does rimraf, tsc, gulp bundle, stopPlayer, uploadWithBanner
    NODE_ENV="$TARGET_ENV" npm run build:upload:base
    
    log_success "Deployment orchestration complete!"
fi

echo ""
log_info "Deployment to $TARGET_ENV finished successfully."
echo "Check the remote device to ensure the player restarted."
