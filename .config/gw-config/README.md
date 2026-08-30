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
| `/etc/systemd` (nspawn units, unit files, wants symlinks), `/root` | yes — upstream nspawn-container addon docs state: "When the firmware is updated, /data and /etc/systemd are preserved, but /var and /usr are deleted." Matches all observed updates. |
| `/usr` + `/var`: dpkg/apt-installed packages (systemd-container, rsync, …), their dpkg records, apt lists | **no — wiped every single update**; `dpkg.log` shows `install … <none>` reinstalls after each one. An update can also bump base packages (2026-08-28: systemd deb11u7→u8), so anything version-locked to base must be reinstalled at matching versions. |

Strategy:

1. all custom state lives under two `/data` roots: `/data/on_boot.d/` (the
   upstream udm-boot entry point) and `/data/custom/` (everything else —
   rootfs, unit sources, deb cache, keys),
2. `on_boot.d` scripts converge the system every boot: reinstall packages
   (load-bearing after every update) and restore `/etc` bits (insurance for
   major jumps / factory reset),
3. this repo mirrors the sources of truth and small backups.

## Boot chain

`udm-boot.service` (vendored verbatim from
[unifi-utilities/unifi-common](https://github.com/unifi-utilities/unifi-common)
in `units/`, pin commit in the file header) is self-contained: the
run-everything-in-`/data/on_boot.d` logic is inlined in its `ExecStart`, so
the single file in `/etc/systemd/system` is the whole hook — no /usr
dependency, nothing else to install. It runs each script independently
(a failing script does not stop the rest):

| Script | Converges |
|---|---|
| `10-packages.sh` | dpkg set `systemd-container libnss-mymachines rsync` (the first two are version-locked to each other and to base systemd — one transaction). apt first (`apt-get update` — the lists are wiped too); on success refreshes the offline deb cache `/data/custom/dpkg/` from what was just downloaded (exactly the closure missing from the current firmware base); on failure installs from that cache. The cache is only consumed on a post-update boot without working apt, and can't go stale silently — every successful apt install rewrites it. |
| `20-units.sh` | `/data/custom/units/*.service` → `/etc/systemd/system/`, enabled; changed units restarted (udm-boot itself only converged+enabled, never restarted — it is running the script). Retiring a unit is manual: `disable --now` + rm on the device. |
| `30-nspawn-units.sh` | `/data/custom/nspawn/` → `/etc/systemd/nspawn/` as a true mirror (stale `*.nspawn` removed). Runs before machines start so containers never come up without bridge config. |
| `40-machines.sh` | links `/data/custom/machines/<m>` → `/var/lib/machines/`, then converges every machine (skipping `*.old/.new/.failed` rollback copies) to enabled+running via `systemctl … systemd-nspawn@<m>` (equivalent to machinectl enable/start, but systemctl is in the firmware base so linking/enabling works even when 10- failed; machinectl commands remain fully usable). |
| `50-authorized-keys.sh` | `/data/custom/authorized_keys.d/*.pub` appended into `/root/.ssh/authorized_keys` (append-only; hand-added keys untouched). |

`nspawn-bridge-watchdog.service` (unit in `units/`, worker in
`bin/nspawn-bridge-watchdog.sh` → `/data/custom/bin/`) re-attaches `vb-*`
veths that fall off their bridge after a container restart.

## Layout

| Path | Deployed to | Notes |
|---|---|---|
| `on_boot.d/` | `/data/on_boot.d/` | boot-time convergence scripts (see Boot chain) |
| `nspawn/` | `/data/custom/nspawn/` (source) **and** `/etc/systemd/nspawn/` (live) | `30-nspawn-units.sh` mirrors source → live at boot |
| `units/` | `/data/custom/units/` (source) **and** `/etc/systemd/system/` (live, per-file — never `--delete` there) | `20-units.sh` converges at boot; restart `nspawn-bridge-watchdog` after changing it |
| `bin/nspawn-bridge-watchdog.sh` | `/data/custom/bin/` (per-file — the dir also holds hand-placed tools) | watchdog worker |
| `authorized_keys.d/` | `/data/custom/authorized_keys.d/` | restored by `50-authorized-keys.sh` |
| — | `/data/custom/dpkg/` | offline deb cache, auto-refreshed by `10-packages.sh`, not repo-tracked |
| — | `/data/custom/machines/` | container rootfs, deployed by `~/homelab-containers` `just deploy`, not repo-tracked |
| `caddy/Caddyfile` | `/data/caddy/config/caddy/Caddyfile` | restart caddy container after changes |
| `secrets/` | `/data/caddy/secrets/` (per-file pairs) | git-crypt encrypted in yadm; `--check` redacts content |
| `backups/unifi/` | ← pulled from `/data/unifi/data/backup/autobackup/` | UniFi monthly .unf autobackups (`gw-backup-pull`) |
| `backups/adguard-alice/`, `backups/adguard-bob/` | ← pulled from `/data/adguard-<instance>/` | AdGuardHome.yaml snapshots (alice = sync origin / source of truth) |
| `backups/machines-manifest.txt` | ← generated | container inventory; rootfs NOT in repo (both are ~60M image artifacts of `~/homelab-containers` since 2026-08-17) |

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

- **adguard-alice** (10.0.5.3) + **adguard-bob** (10.0.5.4): active-active
  whole-house DNS, one shared image from `~/homelab-containers/adguard`
  (dual-instance split 2026-08-18; alpine cutover 2026-08-17). Instance
  identity is injected ONLY by the `.nspawn` unit env — `IPV4_CIDR`,
  `IPV4_GATEWAY`, `IPV6_TOKEN` — consumed by the image's `net-setup` oneshot
  (static config; no DHCP: the UniFi controller cannot manage reservations
  for clients on the gateway's own bridge, and the veth MAC changes with any
  machine rename). Per-instance state lives in `/data/adguard-<instance>` on
  the host, bind-mounted onto the instance-agnostic container path
  `/data/adguard`. alice is primary: `dns.lan.ucw.phd` points at it and
  adguardhome-sync (homelab quadlet, every 15 min) replicates alice → bob;
  both yamls carry the dedicated `sync` user. Per-instance UIs:
  `dns-alice`/`dns-bob.lan.ucw.phd`. Config backups:
  `backups/adguard-alice/`, `backups/adguard-bob/`.
  - IPv6: SLAAC with a static interface token per instance
    (`::10.0.5.3` / `::10.0.5.4`), so
    v6 addresses are always `<advertised prefix>::a00:503/:504` and follow prefix
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
    `net-setup` (oneshot), `sshd`, and `caddy` — whose `run` script also
    bridges caddy's sd_notify READY=1 to s6 readiness via a background socat
    listener (this is why `socat` is in the apk world).
  - Static addressing, same shape as the AdGuard pair: `net-setup` reads
    `IPV4_CIDR` / `IPV4_GATEWAY` / `IPV6_TOKEN` out of PID 1's environment,
    set by `Environment=` in `nspawn/caddy.nspawn`, and configures `host0`
    itself (`iproute2-minimal`, because busybox `ip` has no `token`). The
    caddy service depends on the oneshot, so a missing value keeps the proxy
    down rather than bringing it up on the wrong address.
  - The image bakes `/etc/resolv.conf` with public resolvers (9.9.9.9,
    1.1.1.1, and their v6 peers), deliberately not the AdGuard instances:
    the proxy stands in front of them, and ACME DNS-01 has to reach the
    Cloudflare API by name across exactly the windows when whole-house DNS
    is down or restarting.
  - caddy itself is NOT an apk package: xcaddy-built `/usr/bin/caddy` with the
    cloudflare DNS + caddy-l4 modules. Caddyfile path comes from
    `XDG_CONFIG_HOME=/data/caddy/config` set in `nspawn/caddy.nspawn`.
  - Wildcard cert via Let's Encrypt DNS-01 (cloudflare).
  - CF API token: source of truth is `secrets/cf_token` here (git-crypt in
    yadm), deployed to `/data/caddy/secrets/cf_token` (0600), read by the
    Caddyfile `{file./data/caddy/secrets/cf_token}` placeholder at parse
    time. To rotate: overwrite the repo file (no trailing newline), commit,
    `./deploy.sh`, then `systemctl restart systemd-nspawn@caddy.service`.
    (Last rotated 2026-08-18, after the old one sat in plaintext in
    homelab-containers' git history.)
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

- **AdGuardHome**: renovate PRs bump `adguard_version` in
  `~/homelab-containers/adguard/Justfile`; merge → autodeploy runs
  `just deploy adguard instance=bob` then (after caddy) `instance=alice`
  (bob is the canary; a failure holds alice on the known-good image; each
  deploy validates + swaps + DNS health check with auto-rollback). Do NOT
  use the web-UI updater or `--update` — in-place binary changes are
  reverted by the next image deploy.

- After either: run `check-gw` (or wait for the daily timer) to verify.

## Firmware update recovery runbook

1. Normal updates: nothing to do — udm-boot survives in `/etc/systemd/system`
   and the on_boot.d chain reconverges everything (packages via apt, cache as
   offline fallback). Check `systemctl status udm-boot` for per-script output.
2. udm-boot hook dead (major jump / factory reset wiping `/etc`), offline-safe
   one-liner (then reboot, or `systemctl start udm-boot`):

   ```bash
   ssh gw 'cp /data/custom/units/udm-boot.service /etc/systemd/system/ &&
           systemctl daemon-reload && systemctl enable --now udm-boot'
   ```
3. Verify: `machinectl list` shows adguard-alice+adguard-bob+caddy; DNS
   works on 10.0.5.3 AND 10.0.5.4; then
   `./deploy.sh --check` from the homelab should be clean.
4. Full gateway loss: restore UniFi config on replacement hardware from the
   newest `backups/unifi/*.unf`, then redo steps above. All rootfs are
   image artifacts of `~/homelab-containers`: `just deploy caddy`,
   `just deploy adguard instance=alice` / `instance=bob` (first bring-up of
   an instance: create `/data/adguard-<instance>/`, restore its
   AdGuardHome.yaml from `backups/adguard-<instance>/`, deploy with
   `health_check=no` only if the other instance is also down).

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
  gw-config's and the backups' job. Image content is deliberately NOT
  duplicated here (a short-lived `containers/caddy/` copy was removed
  2026-08-17); the split is: build repo owns what is inside the image,
  gw-config owns nspawn units, on_boot, runtime config, and backups.
- adguard-alice/-bob: NOT a recipe — build artifacts of
  `~/homelab-containers/adguard`; rebuild = `just deploy adguard
  instance=<x>` there. State: if `/data/adguard-<x>` survived it just
  reattaches; otherwise restore `backups/adguard-<x>/AdGuardHome.yaml`
  into it (stats/query log lost in that case) — or, for bob alone, an
  empty dir + copied alice yaml + one adguardhome-sync run reconverges.
  (`backups/adguard-alice/AdGuardHome.service` is a debian-era relic, kept
  for history.)

## Drift audit (last run 2026-08-16 — both containers clean)

Answers "what was hand-edited in the containers beyond what this repo tracks",
aconfmgr-style: baseline = package manager ownership, everything else is
either repo-tracked, recipe-covered, or noise. Rerun after any ad-hoc ssh
session you are not sure about. Since the 2026-08-17 image cutover both
containers are alpine (use the apk method; the dpkg notes below document the
debian-era adguard audit) and the stronger check is simply diffing the live
rootfs against the build tar in `~/homelab-containers/<target>/build/`.

- adguard (dpkg): `chroot /data/custom/machines/adguard dpkg -V` → empty
  (no packaged file modified). Orphan scan: all files minus
  `/var/lib/dpkg/info/*.list` (normalize usr-merge aliases:
  `sed -E "s,^/(bin|sbin|lib64|lib32|libx32|lib)/,/usr/\1/,"`), pruning
  var/cache var/log var/lib/{apt,dpkg,systemd} tmp run opt/AdGuardHome →
  only debootstrap/postinst noise + the two known files (ipv6-token.conf,
  AdGuardHome.service).
- caddy (apk): `chroot ... /sbin/apk audit` + orphan scan against
  `awk -F: '/^F:/{d=$2} /^R:/{print "/"d"/"$2}' lib/apk/db/installed` →
  everything accounted for: s6-overlay + s6-rc.d tree and custom caddy
  binary (all from the homelab-containers build), ssh keys/drop-in,
  `U etc/shadow`. For an image-built container, drift audit simplifies to
  diffing live rootfs against the build tarball.
