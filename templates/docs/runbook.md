# Runbook — operations, deploy, recovery

## First-time deploy

Prereqs: SSH key on the target, DNS in place, `.env` populated locally.

1. **DNS:** add A record `<subdomain>.<domain>` → `<IP>`.
2. **TLS:** issue cert via `<CMD>`.
3. **Reverse proxy:** install vhost / Caddy config.
4. **Service user (optional):** create + enable lingering.
5. **Copy code + install deps:** `rsync` + `uv sync`.
6. **Copy `.env`** (`scp`, chmod 600).
7. **Install systemd unit:** copy + `daemon-reload` + `enable --now`.
8. **Verify:** `curl /healthz`.

## Updating the running service

```bash
make deploy   # see scripts/deploy.sh
```

## Logs

```bash
ssh <HOST> 'journalctl -u <project-name> -n 200 -f'
```

## Rotating credentials

| Credential | How |
|---|---|
| `<NAME>` | <procedure> |

## Rollback

```bash
git revert HEAD
make deploy
```

## Backups

`<DB_PATH>` is the stateful asset. Daily `.backup` to `<backup-dir>`, retain 14 days. <PROJECT_SPECIFIC: off-site target if any>.

## Incident: <common problem>

Investigation order:
1. <step 1>
2. <step 2>
