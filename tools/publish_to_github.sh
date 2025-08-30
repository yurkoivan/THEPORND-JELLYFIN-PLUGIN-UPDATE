#!/usr/bin/env bash
set -euo pipefail

# Publishes this repo to GitHub under a specified account and creates a release
# Requires environment variables:
#   GITHUB_TOKEN - GitHub Personal Access Token with 'repo' scope
# Optional:
#   GITHUB_USER  - GitHub username (default: 'yurkoivan')
#   REPO_NAME    - Repository name (default: 'Jellyfin.Plugin.ThePornDB')

GITHUB_USER=${GITHUB_USER:-yurkoivan}
REPO_NAME=${REPO_NAME:-Jellyfin.Plugin.ThePornDB}
TAG=${TAG:-v1.6.0.0}
ZIP_PATH="Jellyfin.Plugin.ThePornDB/bin/Release/Jellyfin.Plugin.ThePornDB.zip"

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  echo "ERROR: GITHUB_TOKEN not set." >&2
  exit 1
fi

echo "Ensuring repo https://github.com/${GITHUB_USER}/${REPO_NAME} exists..."

# Check if repo exists
if ! curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
     -H "Accept: application/vnd.github+json" \
     "https://api.github.com/repos/${GITHUB_USER}/${REPO_NAME}" | jq -e .id >/dev/null; then
  echo "Creating repository ${REPO_NAME} under ${GITHUB_USER}..."
  curl -s -X POST -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github+json" \
    https://api.github.com/user/repos \
    -d "{\"name\":\"${REPO_NAME}\",\"private\":false,\"description\":\"Jellyfin 10.10 compatible ThePornDB plugin\"}"
fi

echo "Configuring local git..."
git init -q
git config user.name "Codex CLI"
git config user.email "codex@example.com"
git add .
git commit -q -m "feat: Jellyfin 10.10 compatibility (v1.6.0.0)"

git branch -M main
git remote remove origin 2>/dev/null || true
git remote add origin "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git"
git push -q -u origin main

echo "Creating annotated tag ${TAG}..."
git tag -a "${TAG}" -m "Release ${TAG}" || true
git push -q origin "${TAG}" || true

echo "Creating GitHub release ${TAG}..."
RELEASE_JSON=$(curl -s -X POST -H "Authorization: token ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/${GITHUB_USER}/${REPO_NAME}/releases" \
  -d "{\"tag_name\":\"${TAG}\",\"name\":\"${TAG}\",\"prerelease\":false,\"draft\":false}")

UPLOAD_URL=$(echo "$RELEASE_JSON" | jq -r .upload_url | sed 's/{?name,label}//')

if [[ ! -f "$ZIP_PATH" ]]; then
  echo "ERROR: zip not found at $ZIP_PATH. Build Release first." >&2
  exit 1
fi

ASSET_NAME=$(basename "$ZIP_PATH")
echo "Uploading asset $ASSET_NAME..."

curl -s -X POST -H "Authorization: token ${GITHUB_TOKEN}" \
  -H "Content-Type: application/zip" \
  --data-binary @"$ZIP_PATH" \
  "${UPLOAD_URL}?name=${ASSET_NAME}" >/dev/null

echo "Done. Repo: https://github.com/${GITHUB_USER}/${REPO_NAME}"
echo "Release: https://github.com/${GITHUB_USER}/${REPO_NAME}/releases/tag/${TAG}"

