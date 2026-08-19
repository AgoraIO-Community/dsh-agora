# dsh-agora

DSH (DeepSeek Harness) skill plugin: a **thin shell** that ships the Agora
skill — RTC, RTM, ConvoAI, CLI, Cloud Recording, Server, Server Gateway,
tokens — synced **verbatim** from
[`AgoraIO/skills`](https://github.com/AgoraIO/skills) at a pinned release tag.

The plugin registers one bundled skill, `agora`, into DSH's skill registry —
the same name and content as the Claude Code / Cursor ecosystems.

## Install

```sh
dsh plugin --profile web add dsh-agora
```

Then restart the web profile. The `agora` skill appears in the skill catalog.

From a local checkout (development):

```sh
dsh plugin --profile web add /path/to/dsh-agora
```

> **pnpm workspace-root gotcha**: with pnpm ≥ 8.15 the profile's workspace
> root rejects a bare `add` (`ERR_PNPM_ADDING_TO_ROOT`). Add `-w`:
> `dsh plugin --profile web add -w <pkg>`.
>
> **link: dev mode**: the profile must resolve the runtime peer
> `@deepseek-ai/dsh-skill`. Install it in the repo checkout first
> (`pnpm install`); otherwise `index.js` fails with
> `ERR_MODULE_NOT_FOUND` at load time (decision D-09).

## What it contains

```
dsh-agora/
├── package.json            # dsh.bundle.patch declaration (bundle form)
├── cordis.patch.yml        # inserts the provider row into the profile tree
├── index.js                # Cordis entry: registers the bundled agora provider
├── scripts/sync-deps.sh    # ★ the only automation: tag-sync from AgoraIO/skills
└── assets/agora/           # synced output (gitignored, not committed)
    ├── SKILL.md            # upstream verbatim, zero rewrite
    └── references/         # full reference set (54 files)
```

## How content stays in sync

`npm publish` runs `prepack` → `scripts/sync-deps.sh`, which:

1. resolves the release tag (`$TAG` env → GitHub latest release → pinned
   fallback `v1.8.1`),
2. pulls the `AgoraIO/skills` tarball for that tag,
3. `rsync -a --delete`s `skills/agora/` → `assets/agora/` — **zero rewrite**,
   so the two copies can never drift.

The repo keeps no permanent copy of the skill content; `assets/` is
gitignored and rebuilt at release time. Run it manually with
`npm run sync:deps`.

## Skill: `agora`

Upstream routing: RTC (video/voice calls), RTM (chat/signaling), ConvoAI
(voice AI agents), Agora CLI, Cloud Recording, Server (tokens), Server
Gateway, and cross-product coordination. ConvoAI follows the upstream
"proven baseline first" rule (run the official quickstart before scaffolding
from memory); CLI acceleration is runtime-detected (`agora` on `PATH`), never
bundled.

Design rules and decisions (D-01…D-10) and the ROADMAP are kept local-only
under `docs/` — not committed to this public repo.

## Verify locally

```sh
dsh --profile web --dump-config --patch ./cordis.patch.yml   # row composes
```

For a real mount test, install into a throwaway profile:

```sh
dsh plugin --profile agoratest add .
dsh --profile agoratest --dump-config | grep agora-skills
```

## License

MIT
