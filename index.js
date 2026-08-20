// dsh-agora — bundled skill providers for DeepSeek Harness.
//
// Registers two skills on ctx.skills, mirroring the official
// `@deepseek-ai/dsh-skill-badge` provider pattern:
//   - `agora`    — the official Agora skill, synced verbatim from
//                  AgoraIO/skills at a pinned release tag (zero rewrite).
//                  The SKILL.md body and references/ live in assets/agora/.
//   - `agora-cn` — a shell-maintained companion documenting only the
//                  China-mainland (国内/声网) delta. It lives in
//                  assets/agora-cn/, which scripts/sync-deps.sh never touches.
import { readFile } from 'node:fs/promises'
import { fileURLToPath } from 'node:url'
import { BUNDLED_SKILL_RANK } from '@deepseek-ai/dsh-skill'

const PROVIDER_NAME = 'agora'

const AGORA_DIR_URL = new URL('./assets/agora/', import.meta.url)
const AGORA_BODY_URL = new URL('./assets/agora/SKILL.md', import.meta.url)

const CN_DIR_URL = new URL('./assets/agora-cn/', import.meta.url)
const CN_BODY_URL = new URL('./assets/agora-cn/SKILL.md', import.meta.url)

const CANDIDATE = {
  name: 'agora',
  description:
    'Activate when the user wants to build voice AI agents, video or voice calls, live streaming, screen sharing, in-app messaging and presence, recording, token or auth flows, or use the `agora` CLI for login, quickstarts, env setup, diagnostics, introspection, skills, or MCP serving, especially when integrating Agora into an app. For China-mainland (国内/声网) deployment, load the `agora-cn` skill instead.',
  invocation: {
    modelInvocable: true,
    userInvocable: true,
  },
  provider: PROVIDER_NAME,
  source: 'bundled',
  resourceBase: {
    kind: 'directory',
    path: fileURLToPath(AGORA_DIR_URL),
  },
  rank: BUNDLED_SKILL_RANK,
  locator: AGORA_BODY_URL,
}

const CN_CANDIDATE = {
  name: 'agora-cn',
  description:
    'Activate for China-mainland (国内/声网) Agora deployment: console.shengwang.cn control plane, CN endpoints on the sd-rtn.com domain, `agora login --region cn` + CN data center, ConvoAI (Area.CN → api-cn-*.sd-rtn.com/cn + CN vendor/BYOK), and CN region selection for RTC (setArea CHINA / AREA_CODE_CN), RTM (setArea areaCodes / RtmAreaCode.CN), and Cloud Recording (clientRequest.region). Use when the user wants domestic deployment, 声网, China region (CN), or mainland data residency. Supplements the `agora` skill.',
  whenToUse:
    'Use when the user wants China-mainland (国内/声网) or CN-region deployment. Load the `agora` skill alongside it for the baseline mechanics.',
  invocation: {
    modelInvocable: true,
    userInvocable: true,
  },
  provider: PROVIDER_NAME,
  source: 'bundled',
  resourceBase: {
    kind: 'directory',
    path: fileURLToPath(CN_DIR_URL),
  },
  rank: BUNDLED_SKILL_RANK,
  locator: CN_BODY_URL,
}

const BODY_BY_NAME = {
  agora: AGORA_BODY_URL,
  'agora-cn': CN_BODY_URL,
}

const provider = {
  name: PROVIDER_NAME,
  list: () => Promise.resolve([CANDIDATE, CN_CANDIDATE]),
  async get(candidate) {
    const bodyUrl = BODY_BY_NAME[candidate.name]
    return {
      ...candidate,
      content: bodyUrl ? await readFile(bodyUrl, 'utf8') : '',
    }
  },
}

/** Cordis plugin name. */
export const name = 'agora-skills'
/** Service required by the bundled provider. */
export const inject = ['skills']
/** Register the bundled `agora` providers on `ctx.skills`. */
export function apply(ctx) {
  ctx.skills.registerProvider(() => provider)
}
