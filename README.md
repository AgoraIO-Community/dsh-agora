# dsh-agora

**A DeepSeek Harness (DSH) plugin that adds the official Agora skill — with Shengwang support baked in — to your agent.** One install gives you voice AI agents, RTC video/voice calls, RTM chat & signaling, Cloud Recording, Agora CLI acceleration, and server-side token generation — driven from natural language.

The skill is synced verbatim from the official [AgoraIO/skills](https://github.com/AgoraIO/skills) repository, so it always matches the Agora docs and quickstarts.

## Prerequisites

- DeepSeek Harness (DSH) installed and running
- An [Agora](https://console.agora.io) account (for tokens/App ID when you build a real app)

## Install

```sh
dsh plugin --profile web add dsh-agora
```

> **Note**: with pnpm ≥ 8.15 (e.g. 9.15) the profile workspace root rejects a
> bare `add` with `ERR_PNPM_ADDING_TO_ROOT`. If you hit that, pass `-w`:
>
> ```sh
> dsh plugin --profile web add -w dsh-agora
> ```

Restart the web profile, and the `agora` skill appears in the skill catalog.

## What the skill covers

| Area | What you can do |
|---|---|
| **Voice AI agents** (ConvoAI) | Build voice agents / voicebots |
| **RTC** | Video & voice calls, live streaming, screen sharing |
| **RTM** | Chat, presence, signaling |
| **Cloud Recording** | Record calls and streams |
| **Server** | Generate tokens & App IDs server-side |
| **Server Gateway** | Cross-product server coordination |
| **Agora CLI** | CLI acceleration (auto-detected if installed) |

## Shengwang support

The same `agora` skill covers the Shengwang region (`console.shengwang.cn`). At release time, the plugin appends a per-product CN delta to each product reference, so the model picks the right section based on the user's intent (China vs global):

| Product | CN delta |
|---|---|
| RTC | CN region (`setArea({ areaCode: "CHINA" })` / `AREA_CODE_CN`) + `sd-rtn.com` + cloud proxy |
| RTM | CN region (`setArea({ areaCodes: ["CHINA"] })` / `RtmAreaCode.CN`) + CN data center |
| Cloud Recording | `api.sd-rtn.com` + `clientRequest.region="CN"` + mainland storage |
| Server (token) | token algorithm unchanged; CN REST domain + credential menu path |
| Agora CLI | `agora project create --region cn` / `--rtm-data-center CN` |
| ConvoAI | endpoint (`Area.CN`) + CN vendor catalog + managed/BYOK — **recorded as current status; end-to-end not yet verified** |

The official skill content stays verbatim; the CN deltas are injected at build time (see `scripts/sync-deps.sh`), so there is still a single `agora` skill — no separate companion skill.

## Using the skill

Describe what you want in natural language — e.g. *"set up a voice AI agent with Agora"* or *"build an RTC video call app"*. The skill routes to the official quickstarts and guides you through setup, including auth and token flows.

## FAQ

**Does this repo contain the skill itself?** The official `agora` content is synced verbatim from the AgoraIO/skills repo at each release (not committed). The Shengwang deltas are maintained in this repo under `assets/agora-cn/` and injected into the product references at build time.

**Do I need the Agora CLI installed?** No. It's optional; if it's on your `PATH`, the skill uses it for faster workflows.

## License

MIT
