#!/usr/bin/env bash
# dsh-agora — sync skills content from AgoraIO/skills at a pinned release tag.
#
# Runs from the `prepack` hook on `npm publish` (and manually for local dev).
# Design: D-01 (single source of truth, zero rewrite) + D-02 (pin release tag).
#
# Resolution order for the tag:
#   1. $TAG environment variable (explicit pin, e.g. when releasing)
#   2. latest release tag from GitHub API
#   3. hardcoded fallback (keeps local dev working when API is rate-limited)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$REPO_ROOT/assets/agora"
FALLBACK_TAG="v1.8.1"

TAG="${TAG:-}"
if [[ -z "$TAG" ]]; then
  TAG="$(curl -fsSL --max-time 15 https://api.github.com/repos/AgoraIO/skills/releases/latest \
    | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' || true)"
fi
TAG="${TAG:-$FALLBACK_TAG}"

echo "dsh-agora: syncing skills content from AgoraIO/skills@${TAG}"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

curl -fsSL "https://github.com/AgoraIO/skills/archive/refs/tags/${TAG}.tar.gz" \
  | tar xz -C "$TMP"

SRC="$TMP/skills-${TAG#v}/skills/agora"
if [[ ! -d "$SRC" ]]; then
  echo "error: skills/agora not found in AgoraIO/skills@${TAG}" >&2
  exit 1
fi

mkdir -p "$DEST"
# --delete: removed files in the source disappear here too — no drift, ever.
rsync -a --delete "$SRC/" "$DEST/"

echo "dsh-agora: synced $(find "$DEST" -type f | wc -l | tr -d ' ') files from ${TAG} -> assets/agora/"
