# Local Port Registry

Last updated: 2026-09-18
Host: scott-mac
Purpose: single source of truth for local dev port allocation across all projects.

## Rules

1) Every long-lived local service gets a reserved port here before implementation.
2) Avoid ad-hoc use of 3000 for new apps (legacy/default conflicts).
3) Prefer project ranges, then service-type ranges.
4) If a service is temporary, mark it `ephemeral` with owner + expiry note.
5) Keep both this file (human-readable) and `ports.yaml` (machine-readable) in sync.

## Range plan

- 3000-3099: Frontend UIs
- 3100-3199: Observability UIs / dashboards
- 3200-3299: Internal tools
- 4000-4099: Internal APIs + monitors
- 50000-50999: gRPC / special infra (high ports)
- 5400-5499: Postgres instances
- 6300-6399: Redis instances
- 7700-7799: Search engines
- 8000-8199: App APIs
- 8600-8699: Agent backends / gateways
- 8700-8799: Mocks / twins / sandboxes
- 9000-9099: Object storage / aux infra

## Allocations

| Port | Proto | Status | Owner/Project | Service | Notes |
|---:|:---:|:---|:---|:---|:---|
| 3000 | tcp | allocated | baseball | mlb_fantasy_web dev UI | Existing primary web UI |
| 3002 | tcp | allocated | baseball | grafana UI | grafana-loki stack |
| 3004 | tcp | allocated | baseball | langfuse UI | langfuse web |
| 3010 | tcp | allocated | mission-control | mission-control UI/API | Homebrew service: `scott/services/mission-control` |
| 3011 | tcp | allocated | hermes-workspace | hermes-workspace UI | Homebrew service: `scott/services/hermes-workspace` |
| 3100 | tcp | allocated | baseball | loki | grafana-loki stack |
| 3199 | tcp | allocated | baseball | beads dashboard | legacy/dev tool |
| 3201 | tcp | allocated | docs | course preview | Background server managed by `make up`/`make down` |
| 3202 | tcp | allocated | skill-cabinet | skill catalog UI | Homebrew service; `cabinet` alias for interactive launch |
| 37777 | tcp | ephemeral | claude-mem | worker-service | detected listener; verify owner |
| 3847 | tcp | ephemeral | paperclip | bun server | detected listener; verify owner |
| 4001 | tcp | allocated | baseball | observability server | obs API |
| 4002 | tcp | allocated | baseball | observability dashboard | obs UI |
| 4040 | tcp | allocated | baseball | ngrok local API | tunnel inspector |
| 5173 | tcp | allocated | baseball | admin web dev | vite dev |
| 5432 | tcp | allocated | local infra | postgres (host) | local postgres daemon |
| 5433 | tcp | allocated | baseball | api postgres | container-mapped |
| 5434 | tcp | allocated | baseball | langfuse postgres | loopback-mapped |
| 5435 | tcp | reserved | baseball | zitadel postgres | `${ZITADEL_DB_PORT:-5435}` |
| 5555 | tcp | allocated | baseball | celery flower | jobs monitor |
| 6378 | tcp | allocated | baseball | jobs redis | mapped to container 6379 |
| 6379 | tcp | allocated | baseball | api redis | local redis also uses 6379 |
| 6380 | tcp | allocated | baseball | langfuse redis | loopback-mapped |
| 7265 | tcp | system | raycast | raycast local service | system app |
| 7483 | tcp | allocated | zeno | zeno backend | uvicorn, bound to 127.0.0.1 |
| 7700 | tcp | allocated | baseball | meilisearch | search engine |
| 8000 | tcp | allocated | baseball | mlb_fantasy_api | fastapi |
| 8001 | tcp | allocated | baseball | mlb_fantasy_jobs api | jobs api |
| 8090 | tcp | allocated | baseball | admin web prod | container port 80 |
| 8091 | tcp | allocated | baseball | glitchtip web | error tracking |
| 8123 | tcp | allocated | baseball | clickhouse | langfuse backend |
| 8642 | tcp | allocated | hermes-agent | hermes webapi backend | Homebrew service: `scott/services/hermes-webapi` |
| 8765 | tcp | allocated | baseball | yahoo fantasy twin | mock API |
| 8787 | tcp | allocated | smb-ai-search-monitor | API server | detected running node process |
| 8791 | tcp | allocated | unknown-node-service | API server | detected running node dist server |
| 9000 | tcp | allocated | baseball | langfuse object store internal | minio S3 API (loopback) |
| 9002 | tcp | allocated | baseball | minio API | langfuse exposed API |
| 9003 | tcp | allocated | baseball | minio console | langfuse admin UI |
| 9119 | tcp | allocated | hermes | hermes dashboard | launchd `ai.hermes.dashboard`; listens on all interfaces (by design) |
| 9999 | tcp | allocated | nixonnote | note | PID 34121: `/Volumes/qwiizlab/projects/nixonnote/target/release/note` |
| 11434 | tcp | allocated | local ai | ollama | local model serving |
| 50051 | tcp | allocated | baseball | zitadel grpc | zitadel service |
| 3020 | tcp | allocated | field-guide | field-guide web | vite dev, `make up`/`make down` |
| 8010 | tcp | allocated | field-guide | field-guide api | uvicorn --reload, `make up`/`make down` |

## Newly requested app plan

- mission-control: `PORT=3010`
- hermes-workspace frontend: `--port 3011`
- hermes-agent webapi backend: `--port 8642`

This avoids collisions with baseball web on 3000 and keeps agent tooling grouped.

## Suggested startup config snippets

Mission Control:

```bash
PORT=3010 pnpm dev
# or
PORT=3010 pnpm start
```

Hermes Workspace:

```bash
pnpm dev -- --port 3011
# and in .env:
HERMES_API_URL=http://127.0.0.1:8642
```

Hermes Agent WebAPI:

```bash
hermes webapi --host 127.0.0.1 --port 8642
```

## Audit commands

Registry + live collision audit:

```bash
ports-check
```

Quick check for candidate ports:

```bash
ports-check --free 3010 3011 8642
```

Raw listeners:

```bash
lsof -nP -iTCP -sTCP:LISTEN
```

## Chezmoi workflow

Source file:
- `~/.local/share/chezmoi/dot_config/ports/PORTS.md`
- `~/.local/share/chezmoi/dot_config/ports/ports.yaml`

Apply to machine:

```bash
chezmoi apply
```

If you edit live file instead, import back into chezmoi:

```bash
chezmoi add ~/.config/ports/PORTS.md
chezmoi add ~/.config/ports/ports.yaml
```