# Environment: NTV360 Developer

## Key Paths
- `$NTV_DIR` (default: `~/Projects/work/ntv`) — NTV ecosystem root
  - `api-v1/` — .NET 2.2 backend API
  - `dashboard-v1/` — Angular 8 + Node 14 web interface
  - `player-server/` — RPi system controller (Node 12, Express, TypeScript)
  - `player-ui/` — Angular app served via nginx on RPi

## Active Technologies
- Core: Node.js, TypeScript, bash, git worktrees
- Deployment: SFTP + pm2 to Raspberry Pi fleet
- Infrastructure: RPi 3/4, Buster OS, nginx, pm2

## Device Topology
- **Raspberry Pi Fleet**: [FILL_IN — your device IPs or aliases]
- **Test Pi**: [FILL_IN — your test device IP]

## Notes
- Obsidian Vault: [FILL_IN if applicable]
- SSH Keys: [FILL_IN — your key names]

---

## TEMPLATE SECTION — Fill in for your machine (delete this header when done)

### Your Workstation
- **OS**: [Linux distro / macOS version / Windows + WSL2]
- **Terminal**: [WezTerm / Alacritty / iTerm2 / etc.]
- **Shell**: [bash / zsh / fish]
- **Window Manager**: [i3 / Hyprland / GlazeWM / none — macOS default / etc.]
- **Key project paths**: [e.g. ~/Projects/work/ntv]

### Sync & Devices (if applicable)
- **Additional devices**: [list any laptops, remote machines, tablets]
- **Sync mechanism**: [Syncthing / rsync / Dropbox / none]

### pi Setup
- **Installed**: `npm install -g @earendil-works/pi-coding-agent`
- **Config location**: `~/.config/opencode/` or `~/.config/pi/`
