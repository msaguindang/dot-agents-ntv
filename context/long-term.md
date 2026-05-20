# Domain Knowledge: NTV System

## v1 Ecosystem (Legacy)
- **Repos**: `$NTV_DIR/` (player-server, player-ui)
- **Target**: RPi 3/4, Buster OS, Node 12, pm2 (ecosystem.config.js), nginx
- **player-server** (`$NTV_DIR/player-server`):
  - **Stack**: Node 12, Express, TypeScript, SQLite (`pm2` process manager)
  - **Architecture**: Acts as system controller for Raspberry Pi, utilizing `src/bin/*.sh` scripts to manage Chromium, AnyDesk, Python agents, and OS-level operations. Assets are at `/var/www/html/assets`.
  - **Integration**: Express router pattern. Cloud socket/API comms. Manages external processes via local shell scripts.
  - **Deployment**: Custom Gulp sequence (`npm run build:upload`) bundles, connects over SSH using `sshConfig.js`, uploads via SFTP, and restarts `pm2`.
  - **Constraints**:
    - Relies on local tarball `nct-vistar-1.0.1.tgz`; do not remove or fetch from npm.
    - Highly coupled to Raspberry Pi OS-level operations; do not assume standard cloud environment behaviors.
- **player-ui**: Angular app hosted on nginx at `/var/www/html/ui`. Plays ads from `/var/www/html/assets`. (Clarify Angular version — may differ from v2)
  - **Verification Mandate**: Before modifying any build, packaging, or updater script logic, always download and inspect the latest production artifact from S3 (`<NTV_PROD_BUCKET>`).
  - **Remote Script Testing**: All Pi-bound shell scripts must be validated using an automated SSH wrapper with state assertions, not manual human testing.
- **api-v1**: .NET 2.2 backend API
- **dashboard-v1**: Angular 8 + Node 14 web interface

## v2 Ecosystem (Active)
- **Repos**: `$NTV_DIR/player-ui-v2`
- **Target**: RPi/Linux ARM64, outputs `.deb` via electron-builder, deploys to EC2 via Aptly
- **player-ui-v2**: Electron + Angular 18. Two compile targets: Electron main (`src/server/`) + Angular renderer (`src/app/`) — must not bleed. IPC bridge (`src/server/services/core/preload.ts`) is only legal comms path between layers.
- **Deploy**: Pre-push pipeline triggers on `forgejo` remote, `dev-deploy-environment`/`main` branches only. Requires `.runner/.env` + `.runner/ec2_key.pem`.
