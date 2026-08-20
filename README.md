# dsh-agora

**A DeepSeek Harness (DSH) plugin that adds the official Agora skill — plus a China-mainland (国内/声网) companion skill — to your agent.** One install gives you voice AI agents, RTC video/voice calls, RTM chat & signaling, Cloud Recording, Agora CLI acceleration, and server-side token generation — driven from natural language.

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

Restart the web profile, and the `agora` skill appears in the skill catalog, alongside the `agora-cn` companion.

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

## China-mainland (国内/声网) support

The plugin also ships a companion skill, **`agora-cn`**, that documents only the delta between the global (overseas) path and the China-mainland (国内 / 声网 / `console.shengwang.cn`) path — per product:

| Product | CN delta |
|---|---|
| RTC | CN region (`setArea({ areaCode: "CHINA" })` / `AREA_CODE_CN`) + `sd-rtn.com` + cloud proxy |
| RTM | CN region (`setArea({ areaCodes: ["CHINA"] })` / `RtmAreaCode.CN`) + CN data center |
| Cloud Recording | `api.sd-rtn.com` + `clientRequest.region="CN"` + mainland storage |
| Server (token) | token algorithm unchanged; CN REST domain + credential menu path |
| Agora CLI | `agora login --region cn` / `--rtm-data-center CN` |
| ConvoAI | endpoint (`Area.CN`) + CN vendor catalog + managed/BYOK — **recorded as current status; end-to-end not yet verified** |

`agora-cn` supplements `agora` without rewriting it: the official skill stays verbatim, and `agora-cn` only adds the China-region differences. For a domestic (国内/声网) deployment, load `agora-cn`; otherwise use `agora`.

## Using the skill

Describe what you want in natural language — e.g. *"set up a voice AI agent with Agora"* or *"build an RTC video call app"*. The skill routes to the official quickstarts and guides you through setup, including auth and token flows.

## FAQ

**Does this repo contain the skill itself?** The official `agora` skill is synced verbatim from the AgoraIO/skills repo at each release (not committed); the `agora-cn` companion is maintained in this repo under `assets/agora-cn/`.

**Do I need the Agora CLI installed?** No. It's optional; if it's on your `PATH`, the skill uses it for faster workflows.

## License

MIT
