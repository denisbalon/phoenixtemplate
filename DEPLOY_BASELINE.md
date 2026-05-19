# Deploy Baseline (VPS + CI/CD + Credentials)

VPS deploy procedure, the CI pipeline shape, and the credential-handling rules. Extracted from `PROJECT_STARTER.md` in v1.22.0 as part of the doc split (Codex Phase 4 #2). Read this when you're deploying to a Linux VPS, configuring CI, or handling secrets.

---

## VPS deploy baseline

For projects deploying to a Linux VPS (Hetzner / OVH / DigitalOcean / similar). Skip if using PaaS or serverless.

Adapt to your VPS specifics. The procedure assumes Debian/Ubuntu/CentOS-family; commands like `useradd` / `firewall-cmd` are RHEL-family — translate as needed.

### DNS

In your DNS provider (Cloudflare / Route 53 / etc.):
- Add an `A` record: `<subdomain>` → `<vps-ipv4>`
- Proxy/CDN setting depends on the use case:
  - **DNS-only ("gray cloud" in Cloudflare)** for webhook receivers and other endpoints where an upstream is sensitive to TLS termination or header rewriting at the CDN edge (a frequent issue for some bot/notification platforms — verify with your upstream's docs)
  - **Proxied ("orange cloud")** for general web traffic that benefits from CDN/DDoS

Verify propagation: `dig <subdomain>.<domain> +short` should return the VPS IP.

### TLS

Pick one:
- **Caddy** — auto-issues + auto-renews via Let's Encrypt. Easiest. `caddy run` on the host, point at your service.
- **Let's Encrypt via certbot** — `certbot --nginx -d <subdomain>` once, cron-renews.
- **Existing reverse proxy** (e.g., another control panel) — use its TLS issuance flow.

### Reverse proxy

If you already have nginx / Caddy fronting other services, add a vhost for the new subdomain that proxies to your service's loopback port:

```nginx
# /etc/nginx/conf.d/<subdomain>.conf
server {
    server_name <subdomain>.<domain>;
    listen 443 ssl;
    # ssl_certificate / ssl_certificate_key as issued in TLS section above

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $remote_addr;
    }
}
```

If the VPS is fresh, install Caddy as the simplest option — `Caddyfile` syntax handles TLS + proxy in 3 lines.

### Service user (optional)

If running the service as a dedicated user (not root):

```sh
useradd -m -s /bin/bash <service-user>
loginctl enable-linger <service-user>   # for systemd --user services to persist
```

If running as root, skip this step.

### systemd unit

```ini
# /etc/systemd/system/<project-name>.service        (system unit, runs as root)
# OR ~/.config/systemd/user/<project-name>.service  (user unit)
[Unit]
Description=<Project description>
After=network.target

[Service]
Type=simple
WorkingDirectory=/root/<project-name>
EnvironmentFile=/root/<project-name>/.env
ExecStart=/root/.local/bin/uv run uvicorn <package_name>.app:app --host 127.0.0.1 --port 8080
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target   # for system units
# WantedBy=default.target    # for user units
```

Install + enable:

```sh
systemctl daemon-reload
systemctl enable --now <project-name>
journalctl -u <project-name> -n 50 -f   # tail logs
```

### Firewall

For RHEL-family with firewalld:

```sh
firewall-cmd --list-all   # check current
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --reload
```

For Debian/Ubuntu with ufw:

```sh
ufw allow 80/tcp
ufw allow 443/tcp
```

---

## CI/CD baseline

GitHub Actions, three gates per PR. Configure these to pass before allowing merge by ticking "Require status checks to pass" in branch protection (see `PROJECT_STARTER.md §1.6`) once the workflow exists.

`.github/workflows/ci.yml` template — adapt the tools to your stack:

```yaml
name: ci
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v3
      - run: uv run ruff check .

  typecheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v3
      - run: uv run mypy src

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v3
      - run: uv run pytest
```

Auto-deploy: leave for a separate workflow once staging exists. Manual deploy via `make deploy` from a clean `main` is fine for v1.

---

## Credential handling

### Never paste credentials in chat

The chat transcript is logged. Once a token / password / secret appears in a message, assume it must be rotated. Get values into `.env` via the bootstrap script's interactive prompts, which write directly to disk without echoing through chat output.

### When a credential leaks into chat

1. **Flag the leak once**, with the recommended action (revoke + regenerate at the source service). Be specific about *where* the user revokes — point at the exact admin UI path. *Example:* "<provider> admin console → Settings → API keys → revoke + create new".
2. **Do not repeat the warning** in subsequent messages of the same session. The user manages rotation on their own schedule. Repeated reminders erode trust without improving security.
3. If a *different* credential leaks, that's a new incident — flag it once.
4. Continue normal work; the user's response to credential leaks is their call alone.

### Setting sensitive `.env` values via tool path

If the user explicitly authorizes setting a sensitive value into `.env` from chat content (e.g., "copy the X token from the spec doc to my .env for me"), use the **Read + Edit tool path** — the value travels through tool I/O, not chat output. Confirm via masked summary (`(set, N chars, ends …xyz)`); never echo the cleartext back. The Edit tool's old/new strings are part of the transcript but they don't appear as visible chat output.

### Sensitive-value masking pattern

When displaying values matching `TOKEN | SECRET | KEY | DSN | PASSWORD` (case-insensitive) in any tool output, log, or chat message, mask them: `(set, N chars, ends …xyz)`. Never echo cleartext. The bootstrap script implements this pattern; replicate it in any internal logging the project does.

### Don't ask for credentials in chat

When walking the user through `bootstrap.sh` or any setup that needs a token, instruct them to paste the value **into the script's prompt**, never into the conversation. Phrasing: "Run `./scripts/bootstrap.sh` and paste the token into prompt N when it asks." Never: "Paste your token here so I can put it in `.env`."
