# gw-config — UDM-SE (dmse) customization management

Manages all customization on the Ubiquiti UDM-SE gateway (`ssh gw`,
root@dmse.home.arpa), aconfmgr-style: this directory is the source of truth,
fully version-controlled by yadm; `deploy.sh` pushes it to the device.

The UDM cannot be rebuilt declaratively — firmware owns the OS. The actual
persistence model across firmware updates (verified on this device against
six updates, 2025-12 through 2026-06, via dpkg.log reinstall events and /etc
file mtimes):

| What | Survives firmware updates? |
|---|---|
| `/data` | always (documented) |
| `/etc/systemd` (nspawn units, unit files, wants symlinks) | yes — upstream nspawn-container addon docs state: "When the firmware is updated, /data and /etc/systemd are preserved, but /var and /usr are deleted." Matches all six observed updates. |
| dpkg/apt-installed packages (systemd-container, rsync, …) | **no — wiped every single update** (they live in /usr, /var); `dpkg.log` shows `install … <none>` reinstalls after each one |

(This setup follows the `nspawn-container` addon from
unifi-utilities/unifi-common-addons; written for UniFi OS 4.x, works
unchanged on 5.x as of 5.1.19.)

Strategy:

1. all custom state lives in `/data` on the device,
2. `on_boot.d` scripts idempotently reinstall packages (load-bearing at every
   update) and restore `/etc` bits (insurance for major jumps/factory reset),
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
| `containers/adguard/` | `/data/custom/machines/adguard/` (same subpaths, scoped per-dir rsync) | deliberate in-container config; currently the networkd IPv6-token drop-in |

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
  - IPv6: the container does SLAAC with a static interface token
    (`containers/adguard/…/ipv6-token.conf`, `Token=static:::10.0.5.3`), so its
    v6 addresses are always `<advertised prefix>::a00:503` and follow prefix
    changes automatically. When the ULA/GUA prefix changes, only the UniFi
    `dns-server` DHCPv6 option needs updating — nothing in the container.
  - AdGuard treats a client as "local" (eligible for private-PTR resolution
    via `local_ptr_upstreams`) by *source address* against the default
    private set (RFC1918 + `fc00::/7`). Clients therefore need a ULA to get
    reverse DNS over IPv6 — GUA-only VLANs get NXDOMAIN (bitten 2026-07).
- **caddy** (alpine, 10.0.5.180): reverse proxy for `*.lan.ucw.phd`.
  - Wildcard cert via Let's Encrypt DNS-01 (cloudflare).
  - CF API token lives ONLY in `/data/caddy/secrets/cf_token` (0600), read by
    the Caddyfile `{file./data/caddy/secrets/cf_token}` placeholder at parse
    time. To rotate: overwrite that file (no trailing newline), then
    `systemctl restart systemd-nspawn@caddy.service`.
  - ACME propagation check MUST NOT use AdGuard (`resolvers 1.1.1.1`): AdGuard
    rewrites `*.lan.ucw.phd` and eats the `_acme-challenge` TXT lookups. This
    caused the May–July 2026 silent renewal failure.

## Updating components

Versions are recorded weekly in `backups/machines-manifest.txt` (gw-backup
timer), so version history lives in yadm alongside config history.

- **caddy** (custom binary with the cloudflare DNS module — NOT from apk, do
  not `apk upgrade` it):

  ```bash
  ssh gw 'chroot /data/custom/machines/caddy /usr/bin/caddy upgrade'   # keeps modules
  ssh gw 'systemctl restart systemd-nspawn@caddy.service'
  ```

  (`caddy upgrade` downloads the matching build with the same plugin set from
  caddyserver.com. Fallback: caddyserver.com/api/download?os=linux&arch=arm64&p=github.com/caddy-dns/cloudflare)

- **AdGuardHome** (official /opt install, has a built-in updater — easiest is
  the web UI update button; CLI equivalent):

  ```bash
  ssh gw 'chroot /data/custom/machines/adguard /opt/AdGuardHome/AdGuardHome --update'
  ssh gw 'systemctl restart systemd-nspawn@adguard.service'
  ```

- After either: run `check-gw` (or wait for the daily timer) to verify.

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

These are recipes, not automation: this repo alone cannot recreate the
containers from zero (rootfs is not tracked). Repo + recipe below + the
secrets/keys listed per container should be sufficient.

- caddy: alpine miniroot + `apk add caddy caddy-dns-cloudflare openssh` (or the
  custom build with the cloudflare module), copy `caddy/Caddyfile`, recreate
  `/data/caddy/secrets/cf_token`.
  - not in repo: `/etc/ssh/authorized_keys` (homelab key) + host keys —
    re-add the homelab pubkey after rebuild; host keys regenerate.
- adguard: debootstrap bookworm + AdGuardHome install script, restore
  `backups/adguard/AdGuardHome.yaml`, run `./deploy.sh` to push the
  `containers/adguard/` in-container config (networkd IPv6-token drop-in),
  restart the container.
