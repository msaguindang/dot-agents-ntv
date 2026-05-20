#!/bin/bash
set -euo pipefail

# ============================================================
# N-Compass TV Worktree Manager Script
# ============================================================
# Usage: ./manage_worktrees.sh <type> <id> <description> <repos...>
# Example: ./manage_worktrees.sh feat 123 add-button api ui
# ============================================================

# Source NTV paths from .bashrc subset
# This is safe because these lines are outside the 'if [interactive]' block
export NTV_DIR="${NTV_DIR:-$HOME/Projects/work/ntv}"
export NTV_API_DIR="$NTV_DIR/api-v1"
export NTV_UI_DIR="$NTV_DIR/dashboard-v1"
export NTV_UI_WT_DIR="$NTV_DIR/dashboard-v1-worktrees"
export NTV_API_WT_DIR="$NTV_DIR/api-v1-worktrees"
export NTV_PLAYER_SERVER_DIR="$NTV_DIR/player-server"
export NTV_PLAYER_SERVER_WT_DIR="$NTV_DIR/player-server-worktrees"
export NTV_PLAYER_UI_DIR="$NTV_DIR/player-ui" 
export NTV_PLAYER_UI_WT_DIR="$NTV_DIR/player-ui-worktrees"

TYPE=$1
ID=$2
DESC=$3
shift 3
REPOS=("$@")

BRANCH_NAME="${TYPE}/${ID}-${DESC}"
log_info "Creating branch: $BRANCH_NAME"

for repo in "${REPOS[@]}"; do
    case "$repo" in
        api)
            BASE_DIR="$NTV_API_DIR"
            WT_ROOT="$NTV_API_WT_DIR"
            ;;
        dash)
            BASE_DIR="$NTV_UI_DIR"
            WT_ROOT="$NTV_UI_WT_DIR"
            ;;
        server)
            BASE_DIR="$NTV_PLAYER_SERVER_DIR"
            WT_ROOT="$NTV_PLAYER_SERVER_WT_DIR"
            ;;
        ui)
            BASE_DIR="$NTV_PLAYER_UI_DIR"
            WT_ROOT="$NTV_PLAYER_UI_WT_DIR"
            ;;
        *)
            echo "Unknown repo: $repo"
            continue
            ;;
    esac

    log_info "Processing $repo..."
    cd "$BASE_DIR"
    git fetch origin

    if [ -d "$WT_ROOT/$BRANCH_NAME" ]; then
        log_warn "Worktree already exists: $WT_ROOT/$BRANCH_NAME"
    else
        log_info "Adding worktree..."
        git worktree add "$WT_ROOT/$BRANCH_NAME" -b "$BRANCH_NAME" origin/main
        # Run setup here if needed
        # cd "$WT_ROOT/$BRANCH_NAME" && npm ci
    fi
done

log_info "Done!"
EOF
