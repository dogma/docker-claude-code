FROM node:20-slim

LABEL org.opencontainers.image.title="claude-docker" \
      org.opencontainers.image.description="Isolated Claude Code instance — no sensitive data baked in"

# Environment setup for Bun and GH CLI
ENV DEBIAN_FRONTEND=noninteractive
ENV BUN_INSTALL=/root/.bun
ENV PATH=$BUN_INSTALL/bin:$PATH

# Signal to scripts/hooks that we're running inside Docker
ENV CLAUDE_DOCKER=1

# 1. Install system dependencies, GitHub CLI, and Bun
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    git \
    gnupg \
    unzip \
    jq \
    openssh-client \
    && mkdir -p -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh \
    && curl -fsSL https://bun.sh/install | bash \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code

# 3. Project directory — mount your host project here at runtime
WORKDIR /project

# Authentication and Claude config are NEVER baked into this image.
# Mount them at runtime:
#   -v /host/.claude:/root/.claude
#   -e ANTHROPIC_API_KEY=...
#
# Keep container alive so you can exec into it or attach a shell.
CMD ["sleep", "infinity"]

exec tmux new-session -s claude "claude --dangerously-skip-permissions"
