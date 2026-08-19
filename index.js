// dsh-agora — bundled skill provider for DeepSeek Harness.
//
// Registers the `agora` skill on ctx.skills, mirroring the official
// `@deepseek-ai/dsh-skill-badge` provider pattern: a Cordis plugin whose
// apply() registers one immutable provider. The SKILL.md body and references/
// live in assets/agora/ and are synced verbatim from AgoraIO/skills at a
// pinned release tag (see scripts/sync-deps.sh) — zero rewrite, no drift.
import { readFile } from 'node:fs/promises'
import { fileURLToPath } from 'node:url'
import { BUNDLED_SKILL_RANK } from '@deepseek-ai/dsh-skill'

const PROVIDER_NAME = 'agora'
const SKILL_DIR_URL = new URL('./assets/agora/', import.meta.url)
const SKILL_BODY_URL = new URL('./assets/agora/SKILL.md', import.meta.url)
const RESOURCE_BASE = {
  kind: 'directory',
  path: fileURLToPath(SKILL_DIR_URL),
}

const CANDIDATE = {
  name: 'agora',
  description:
    'Activate when the user wants to build voice AI agents, video or voice calls, live streaming, screen sharing, in-app messaging and presence, recording, token or auth flows, or use the `agora` CLI for login, quickstarts, env setup, diagnostics, introspection, skills, or MCP serving, especially when integrating Agora into an app.',
  invocation: {
    modelInvocable: true,
    userInvocable: true,
  },
  provider: PROVIDER_NAME,
  source: 'bundled',
  resourceBase: RESOURCE_BASE,
  rank: BUNDLED_SKILL_RANK,
  locator: SKILL_BODY_URL,
}

const provider = {
  name: PROVIDER_NAME,
  list: () => Promise.resolve([CANDIDATE]),
  async get(_candidate) {
    return {
      ...CANDIDATE,
      content: await readFile(SKILL_BODY_URL, 'utf8'),
    }
  },
}

/** Cordis plugin name. */
export const name = 'agora-skills'
/** Service required by the bundled provider. */
export const inject = ['skills']
/** Register the bundled `agora` provider on `ctx.skills`. */
export function apply(ctx) {
  ctx.skills.registerProvider(() => provider)
}
