#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# publish.sh — Build and push the claude-docker image to ghcr.io
# ---------------------------------------------------------------------------
# Usage:
#   ./publish.sh              # builds with tag 'latest'
#   ./publish.sh 1.2.3        # builds with tags '1.2.3' and 'latest'
# ---------------------------------------------------------------------------

OWNER="dogma"
REPO="docker-claude-code"
IMAGE="ghcr.io/${OWNER}/${REPO}"
TAG="${1:-latest}"

# 1. Authenticate Docker with ghcr.io via the gh CLI token
echo "Authenticating with ghcr.io..."
gh auth token | docker login ghcr.io -u "$(gh api user --jq .login)" --password-stdin

# 2. Build the image
echo "Building ${IMAGE}:${TAG}..."
docker build --platform linux/amd64 -t "${IMAGE}:${TAG}" .

# 3. Also tag as 'latest' when a specific version is given
if [ "${TAG}" != "latest" ]; then
  docker tag "${IMAGE}:${TAG}" "${IMAGE}:latest"
fi

# 4. Push all tags
echo "Pushing ${IMAGE}:${TAG}..."
docker push "${IMAGE}:${TAG}"

if [ "${TAG}" != "latest" ]; then
  echo "Pushing ${IMAGE}:latest..."
  docker push "${IMAGE}:latest"
fi

echo ""
echo "Done. Image available at:"
echo "  ghcr.io/${OWNER}/${REPO}:${TAG}"
[ "${TAG}" != "latest" ] && echo "  ghcr.io/${OWNER}/${REPO}:latest"
