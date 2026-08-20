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

# --- China-mainland (国内/声网) delta injection ---------------------------------
# 1) Copy CN deltas (committed in assets/agora-cn/) to each product dir as an
#    independent cn.md difference map — English references stay verbatim.
# 2) Inject a structured region gate right after each README's H1 title, so the
#    model must confirm cn/global before routing. rsync --delete above resets
#    first, so this regenerates cleanly every time.
CN_SRC="$REPO_ROOT/assets/agora-cn"

install_cn() {
  local seg="$1" target="$2"
  if [[ -f "$seg" ]]; then
    cp "$seg" "$target"
    echo "dsh-agora: installed CN map -> ${target#"$DEST"/}"
  else
    echo "dsh-agora: WARN — CN map ($seg) missing; skipping" >&2
  fi
}
install_cn "$CN_SRC/rtc.md"               "$DEST/references/rtc/cn.md"
install_cn "$CN_SRC/rtm.md"               "$DEST/references/rtm/cn.md"
install_cn "$CN_SRC/cloud-recording.md"   "$DEST/references/cloud-recording/cn.md"
install_cn "$CN_SRC/server.md"            "$DEST/references/server/cn.md"
install_cn "$CN_SRC/cli.md"               "$DEST/references/cli/cn.md"
install_cn "$CN_SRC/conversational-ai.md" "$DEST/references/conversational-ai/cn.md"

prepend_region_gate() {
  local gate="$1" target="$2"
  if [[ -f "$gate" && -f "$target" ]]; then
    local tmp
    tmp="$(mktemp)"
    awk -v gatefile="$gate" '
      !inserted && /^# / {
        print
        print ""
        while ((getline line < gatefile) > 0) print line
        close(gatefile)
        inserted = 1
        next
      }
      { print }
    ' "$target" > "$tmp"
    mv "$tmp" "$target"
    echo "dsh-agora: injected region gate -> ${target#"$DEST"/}"
  else
    echo "dsh-agora: WARN — region gate ($gate) or target ($target) missing; skipping" >&2
  fi
}
GATE="$CN_SRC/_region-gate.md"
prepend_region_gate "$GATE" "$DEST/references/rtc/README.md"
prepend_region_gate "$GATE" "$DEST/references/rtm/README.md"
prepend_region_gate "$GATE" "$DEST/references/cloud-recording/README.md"
prepend_region_gate "$GATE" "$DEST/references/server/README.md"
prepend_region_gate "$GATE" "$DEST/references/cli/README.md"
prepend_region_gate "$GATE" "$DEST/references/conversational-ai/README.md"

echo "dsh-agora: synced $(find "$DEST" -type f | wc -l | tr -d ' ') files from ${TAG} -> assets/agora/"
