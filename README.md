# dot-agents-ntv

NTV360 context vault for the pi coding agent. Gives new and existing NTV360 developers immediate context for the player ecosystem.

## What this is

This repo is cloned to `~/.agents` and provides the pi agent with:
- NTV v1 and v2 ecosystem knowledge (player-ui, player-server, api-v1, dashboard-v1)
- NTV-specific agents: `devops` (RPi deployment), `qa` (spec + bug review)
- NTV-specific skills: worktree manager, RPi deployer, RPi doctor, RPi imager
- Code style standards

## Setup

### 1. Install pi
```bash
npm install -g @earendil-works/pi-coding-agent
```

### 2. Clone pi harness config
```bash
git clone https://github.com/msaguindang/dot-pi.git ~/.pi/agent
```

### 3. Clone this repo
```bash
git clone https://github.com/msaguindang/dot-agents-ntv.git ~/.agents
```

### 4. Fill in your details
Edit these files with your personal info:
- `~/.agents/context/identity.md` — your role and principles
- `~/.agents/context/environment.md` — your machine paths and device IPs

### 5. Authenticate
```bash
pi auth login
```

### 6. Verify
```bash
pi "hello"
```

## NTV Ecosystem Quick Reference

| Component | Stack | Deploy target |
|---|---|---|
| player-ui | Angular, nginx | RPi `/var/www/html/ui` |
| player-server | Node 12, Express, pm2 | RPi (pm2 process) |
| api-v1 | .NET 2.2 | Cloud |
| dashboard-v1 | Angular 8 + Node 14 | Cloud |

## Available Agents

| Agent | Purpose |
|---|---|
| `devops` | SSH to RPi, pm2 ops, SFTP deploy |
| `qa` | Spec violation + bug hunt (two-gate) |

## Available Skills

| Skill | Purpose |
|---|---|
| `ntv-worktree-manager` | Create/manage git worktrees inside each NTV repo (`.worktrees/`) |
| `rpi-deploy` | Build player-ui + player-server and deploy to test RPi via SSH/SFTP |
| `rpi-doctor` | Diagnose RPi symptoms (laggy, crashed, out of space) via SSH |
| `rpi-imager` | Prep a fresh RPi for NTV setup; backup SD card to `.img.xz` |
