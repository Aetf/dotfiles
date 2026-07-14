# gw-config — UDM-SE (dmse) customization management

Manages all customization on the Ubiquiti UDM-SE gateway (`ssh gw`,
root@dmse.home.arpa), aconfmgr-style: this directory is the source of truth,
fully version-controlled by yadm; `deploy.sh` pushes it to the device.

The UDM cannot be rebuilt declaratively — firmware owns the OS and **firmware
updates wipe everything outside `/data`**. Strategy:

1. all custom state lives in `/data` on the device,
2. `on_boot.d` scripts idempotently reinstall the volatile parts (`/etc`) at
   every boot (udm-boot from unifios-utilities),
3. this repo mirrors the sources of truth and small backups.

## Layout

| Path | Deployed to | Notes |
|---|---|---|
| `on_boot.d/` | `/data/on_boot.d/` | boot-time (re)install scripts |
| `nspawn/` | `/data/gw-config/nspawn/` (mirror) **and** `/etc/systemd/nspawn/` (live) | `0-setup-system.sh` restores live copies from the mirror after firmware updates |
| `caddy/Caddyfile` | `/data/caddy/config/caddy/Caddyfile` | restart caddy container after changes |
| `backups/unifi/` | ← pulled from `/data/unifi/data/backup/autobackup/` | UniFi monthly .unf autobackups (`gw-backup-pull`) |
| `backups/adguard/` | ← pulled from adguard container rootfs | AdGuardHome.yaml snapshot |
| `backups/machines-manifest.txt` | ← generated | container inventory; rootfs NOT in repo (adguard is 13G) |

## Workflow

```bash
# edit files here, then:
./deploy.sh --check       # show drift (also run daily by check-gw.timer)
./deploy.sh               # apply
yadm add ~/.config/gw-config && yadm commit   # every logical step
```

Related homelab-side automation (also yadm-managed):
- `~/.local/bin/gw-backup-pull` + `gw-backup.timer` (weekly) — refresh `backups/`
- `~/.local/bin/check-gw` + `check-gw.timer` (daily) — drift, container health,
  and `*.lan.ucw.phd` cert expiry alerts (mail)

## Containers (systemd-nspawn on the UDM)

- **adguard** (debian 12, 10.0.5.3): DNS for the whole house. Rootfs at
  `/data/custom/machines/adguard`. Config backup: `backups/adguard/`.
- **caddy** (alpine, 10.0.5.180): reverse proxy for `*.lan.ucw.phd`.
  - Wildcard cert via Let's Encrypt DNS-01 (cloudflare).
  - CF API token lives ONLY in `/data/caddy/secrets/cf_token` (0600), read by
    the Caddyfile `{file./data/caddy/secrets/cf_token}` placeholder at parse
    time. To rotate: overwrite that file (no trailing newline), then
    `systemctl restart systemd-nspawn@caddy.service`.
  - ACME propagation check MUST NOT use AdGuard (`resolvers 1.1.1.1`): AdGuard
    rewrites `*.lan.ucw.phd` and eats the `_acme-challenge` TXT lookups. This
    caused the May–July 2026 silent renewal failure.

## Firmware update recovery runbook

1. udm-boot itself may need reinstall after major updates: unifios-utilities
   package; cached debs in `/data/custom/dpkg/`.
2. Once on_boot runs, `0-setup-system.sh` reinstalls systemd-container,
   restores `/etc/systemd/nspawn/` from `/data/gw-config/nspawn/`, links
   machines from `/data/custom/machines/` and starts them.
3. Verify: `machinectl list` shows adguard+caddy; DNS works; then
   `./deploy.sh --check` from the homelab should be clean.
4. Full gateway loss: restore UniFi config on replacement hardware from the
   newest `backups/unifi/*.unf`, then redo steps above (machines rootfs from
   whatever offline copy exists — rootfs is not in this repo).

## Container rebuild recipes (if rootfs is lost)

- caddy: alpine miniroot + `apk add caddy caddy-dns-cloudflare openssh` (or the
  custom build with the cloudflare module), copy `caddy/Caddyfile`, recreate
  `/data/caddy/secrets/cf_token`.
- adguard: debootstrap bookworm + AdGuardHome install script, restore
  `backups/adguard/AdGuardHome.yaml`.
