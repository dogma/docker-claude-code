FROM node:20-slim

# Environment setup for Bun and GH CLI
ENV DEBIAN_FRONTEND=noninteractive
ENV BUN_INSTALL=/root/.bun
ENV PATH=$BUN_INSTALL/bin:$PATH

# 1. Install dependencies, GitHub CLI (Official Repo), and Bun
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    git \
    gnupg \
    unzip \
    && mkdir -p -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh git \
    && curl -fsSL https://bun.sh/install | bash \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

# 3. Set custom working directory
WORKDIR /project

# Keep container alive for TrueNAS shell
CMD ["sleep", "infinity"]
