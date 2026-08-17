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
| `backups/caddy/` | ← pulled from caddy container rootfs | apk `world` + `repositories` snapshot (rebuild reference) |
| `backups/machines-manifest.txt` | ← generated | container inventory; rootfs NOT in repo (adguard is 15G, but 14G of that is AdGuardHome query-log/stats data + journal) |
| `containers/adguard/` | `/data/custom/machines/adguard/` (same subpaths, scoped per-dir rsync) | deliberate in-container config; currently the networkd IPv6-token drop-in |
| `containers/caddy/` | `/data/custom/machines/caddy/` (same subpaths, scoped per-dir rsync) | s6-rc.d service definitions, sshd drop-in, network/interfaces |

## Workflow

```bash
# edit files here, then:
./deploy.sh --check       # show drift (also run daily by check-gw.timer)
./deploy.sh               # apply
yadm add ~/.config/gw-config && yadm commit   # every logical step
```

Related homelab-side automation (scripts live in the separate
[homelab-ops](https://github.com/Aetf/homelab-ops) repo, installed via
mise shims; the timers are yadm-managed `##h` alternates):
- `gw-backup-pull` + `gw-backup.timer` (weekly) — refresh `backups/`
- `check-gw` + `check-gw.timer` (daily) — drift, container health,
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
  - Built from `~/homelab-containers/caddy` (see rebuild section below). Init
    inside the container is **s6-overlay** (3.2.1.0; NOT openrc, NOT from
    apk). Services are s6-rc.d definitions from the build repo's `rootfs/`:
    `ifup` (oneshot), `sshd`, and `caddy` — whose `run` script also bridges
    caddy's sd_notify READY=1 to s6 readiness via a background socat listener
    (this is why `socat` is in the apk world).
  - caddy itself is NOT an apk package: xcaddy-built `/usr/bin/caddy` with the
    cloudflare DNS + caddy-l4 modules. Caddyfile path comes from
    `XDG_CONFIG_HOME=/data/caddy/config` set in `nspawn/caddy.nspawn`.
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

- **caddy**: bump the caddy builder image tag in
  `~/homelab-containers/caddy/Containerfile`, then `just deploy` there.
  Do NOT `chroot ... caddy upgrade` in place — the running binary would
  silently diverge from the build definition and be reverted by the next
  deploy.

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

- caddy: NOT a recipe — the container is a build artifact of
  `~/homelab-containers/caddy` (Containerfile: xcaddy with cloudflare +
  caddy-l4 modules, s6-overlay, `rootfs/` overlay; `just deploy` builds the
  rootfs tar via `podman build --output type=tar` and does
  stop/wipe/extract/start on gw). Rebuild = `just deploy` there.
  Only `/data/caddy/*` (state, secrets, Caddyfile) survives a deploy; that is
  gw-config's and the backups' job.
  NOTE (2026-08-17): `containers/caddy/` here duplicates
  `homelab-containers/caddy/rootfs/` (added before realizing the build repo
  covers it) — pending consolidation, the build repo is canonical for image
  content; keep only runtime config here.
- adguard: debootstrap bookworm + AdGuardHome install script (installer
  creates `/etc/systemd/system/AdGuardHome.service` — reference copy in
  `backups/adguard/`, and enables it), restore
  `backups/adguard/AdGuardHome.yaml`, run `./deploy.sh` to push the
  `containers/adguard/` in-container config (networkd IPv6-token drop-in),
  restart the container.

## Drift audit (last run 2026-08-16 — both containers clean)

Answers "what was hand-edited in the containers beyond what this repo tracks",
aconfmgr-style: baseline = package manager ownership, everything else is
either repo-tracked, recipe-covered, or noise. Rerun after any ad-hoc ssh
session you are not sure about.

- adguard (dpkg): `chroot /data/custom/machines/adguard dpkg -V` → empty
  (no packaged file modified). Orphan scan: all files minus
  `/var/lib/dpkg/info/*.list` (normalize usr-merge aliases:
  `sed -E "s,^/(bin|sbin|lib64|lib32|libx32|lib)/,/usr/\1/,"`), pruning
  var/cache var/log var/lib/{apt,dpkg,systemd} tmp run opt/AdGuardHome →
  only debootstrap/postinst noise + the two known files (ipv6-token.conf,
  AdGuardHome.service).
- caddy (apk): `chroot ... /sbin/apk audit` + orphan scan against
  `awk -F: '/^F:/{d=$2} /^R:/{print "/"d"/"$2}' lib/apk/db/installed` →
  everything accounted for: s6-overlay install (+ its s6-rc.d tree, now
  tracked), custom caddy binary, ssh keys/drop-in, `U etc/shadow`.
