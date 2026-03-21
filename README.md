# claude-docker

An isolated Docker container running [Claude Code](https://github.com/anthropics/claude-code), designed to be dropped onto any host (e.g. TrueNAS, a VPS, or a local machine) with a project and credentials mounted in at runtime.

**The image never contains sensitive data.** Authentication and project files are always supplied via volume mounts or environment variables at runtime.

---

## What's inside the image

- `node:20-slim` base
- Claude Code (`@anthropic-ai/claude-code`) installed globally via npm
- GitHub CLI (`gh`)
- Bun runtime
- `git`, `openssh-client`, `jq`, `curl`

---

## Prerequisites

- Docker (and optionally Docker Compose)
- A Claude API key **or** an existing `~/.claude` directory with valid credentials from a prior `claude` login

---

## Build

```bash
docker build -t claude-docker .
```

---

## Usage

### Option A — Docker Compose (recommended)

1. Edit `docker-compose.yml` and set the two volume paths:
   - `/path/to/your/project` → your host project directory
   - `/path/to/your/.claude` → your host `.claude` config/auth directory

2. Start the container:
   ```bash
   docker compose up -d
   ```

3. Shell in and run Claude:
   ```bash
   docker compose exec claude-code bash
   claude
   ```

### Option B — `docker run`

```bash
docker run -it --rm \
  -v /path/to/your/project:/project \
  -v /path/to/your/.claude:/root/.claude \
  claude-docker \
  bash
```

Then inside the container:
```bash
claude
```

### Option C — API key via environment variable

If you don't have a `.claude` directory, pass your API key directly:

```bash
docker run -it --rm \
  -v /path/to/your/project:/project \
  -e ANTHROPIC_API_KEY=sk-ant-... \
  claude-docker \
  bash
```

---

## Authentication

Two supported approaches — pick one:

| Method | How |
|--------|-----|
| Mount `.claude` directory | `-v /host/.claude:/root/.claude` — uses existing credentials |
| Environment variable | `-e ANTHROPIC_API_KEY=sk-ant-...` — pass key directly |

> The image does **not** and must **never** contain an API key, credentials file, or any other secret. Do not `COPY` or `ADD` sensitive files in the Dockerfile.

---

## Volume mounts reference

| Mount | Purpose | Required |
|-------|---------|----------|
| `/project` | Your project source code | Yes |
| `/root/.claude` | Claude config + auth credentials | Yes (or use `ANTHROPIC_API_KEY`) |
| `/root/.ssh` | SSH keys for git over SSH | No |

---

## TrueNAS / persistent deployment

For a long-running instance (e.g. on TrueNAS Scale):

1. Create a dataset for your `.claude` config directory so it persists across container restarts.
2. Map your project dataset to `/project`.
3. The container runs `sleep infinity` by default — it stays alive and you can shell in at any time via the TrueNAS shell or `docker exec`.

```bash
# Attach to a running container
docker exec -it <container-name> bash
claude
```

---

## Security notes

- The container runs as `root` by default (required for Claude Code tooling). Do not expose it to untrusted networks.
- Never commit `.env` files, `.claude/` directories, or SSH keys — all are in `.gitignore` and `.dockerignore`.
- The `CLAUDE_DOCKER=1` environment variable is set inside the container so hooks or scripts can detect they're running in Docker.
