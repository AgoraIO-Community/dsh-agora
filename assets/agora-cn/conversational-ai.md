<!-- CN-REGION 触发条件：仅当用户目标是国内/声网/China/CN/大陆时适用本段；若用户未说明 region，先问"国内还是海外"再决定；海外（global/console.agora.io）场景跳过本段。 -->


# 国内 ConvoAI：现状 + 端点 / vendor

> **现状说明（先读）**：国内 ConvoAI 的**端点路由 + CN vendor 清单 + managed/BYOK 矩阵已从 SDK 源码确认**
> （下面这些是可信事实）；但"像海外那样只填 App ID / App Certificate 就一键启动"的体验
> **尚未端到端跑通**——国内 LLM/TTS 的免-key（托管）面更窄，且整条链路未经运行时验证。
> 因此本文是**现状记录**，不是"照着就能跑通"的承诺；动手前按"待验证"清单实测。

验证基线：SDK `agora-agents` 2.6.0（TypeScript 与 Python 一致）。

## 账号与控制台

- 国内控制台：`https://console.shengwang.cn`（声网）；ConvoAI 入口
  `https://console.shengwang.cn/product/ConversationAI?tab=Playground`。
- **开通服务（enable-service）**：国内需先在声网控制台开通 ConvoAI 服务（海外没有这个独立步骤）。
- 海外控制台是 `console.agora.io`；两者账号/项目体系不同，国内用声网账号。

## CN 端点（Area.CN）

`Area` 枚举（`agora-agents` 2.6.0）：

```text
US = 1, EU = 2, AP = 3, CN = 4   # CN = "eastern and northern regions of Chinese mainland"
```

`Area.CN` 时 SDK 自动路由（DNS 解析选择）：

- 区域前缀：`api-cn-east-1`、`api-cn-north-1`
- 主域名：`sd-rtn.com`（回退 `agora.io`）
- 路径：`/cn/api/conversational-ai-agent`（海外是 `/api/conversational-ai-agent`）

即完整端点形如：

```text
https://api-cn-east-1.sd-rtn.com/cn/api/conversational-ai-agent/v2/projects/{appid}/join
https://api-cn-north-1.sd-rtn.com/cn/api/conversational-ai-agent/v2/projects/{appid}/join
```

> 说明：声网文档示例里也出现过 `https://api.agora.io/cn/api/conversational-ai-agent/v2/projects/...`
> 这种写法（`api.agora.io` + `/cn/` 路径）。以 SDK 2.6.0 的实际运行时为准：设置 `Area.CN` 后
> 走 `api-cn-*.sd-rtn.com` + `/cn/` 路径。

## 区域绑定方式

- 客户端：`AgoraClient({ area: Area.CN, ... })`（TS）/ `AsyncAgora(area=Area.CN, ...)`（Python）。
- SDK 提供 CN 专属类：`CNAgora` / `CNAsyncAgora`（Python，预绑定 `Area.CN`）。
- `Agent(client=...)` 在 `area_scope == "cn"` 时返回 `CNAgent`。

## CN vendor 目录（`agentkit/vendors/cn.py`）

`area_scope == "cn"` 时切换到 CN vendor 命名空间，可选厂商与海外不同：

| 类别 | CN 可选厂商 |
|---|---|
| ASR | fengming, tencent, microsoft, xfyun, xfyun_bigmodel, xfyun_dialect |
| TTS | minimax, tencent, bytedance, microsoft, cosyvoice, bytedance_duplex, stepfun, generic |
| LLM | aliyun, bytedance, deepseek, tencent |
| MLLM | qwen_omni |
| Avatar | sensetime, spatius |

## managed / BYOK 矩阵（源码级确认）

概念：**managed（免 key）** = 不填 vendor key、Agora 托管（常见 vendor 的表达式是"省略 api_key"）；
**BYOK** = 填 vendor 自己的 key（LLM 还需 base_url）。没有统一的顶层 `credential_mode` 开关——
`credential_mode: "managed"|"byok"` 字面量**只存在于 `RimeTTS`** 单个 vendor。

| 环节 | 免 key（managed） | 需 BYOK |
|---|---|---|
| ASR | `fengming`（风鸣，无 key 字段，纯托管） | `tencent`（key/app_id/secret 必填）、`microsoft`；`xfyun` 系列 api_key 等可选（BYOK 时填） |
| LLM | 仅白名单 `gpt-4o-mini` / `gpt-4.1-mini` / `gpt-5-nano` / `gpt-5-mini`（托管） | `deepseek` / `aliyun` / `bytedance` / `tencent` 必须 api_key + base_url |
| TTS | （见"待验证"） | CN `minimax` 通常要 key（官方说明 "not Agora-managed in the same way and typically includes key"）；`tencent` / `bytedance` / `cosyvoice` / `stepfun` |
| MLLM | 无 | `qwen_omni`（api_key 必填） |
| Avatar | 无 | `sensetime` / `spatius`（BYOK） |

要点：

- CN 原生 LLM（DeepSeek/阿里/字节/腾讯）**没有免 key 托管**——托管白名单仍是 OpenAI 的
  `gpt-4o-mini` 等几个模型（`_OPENAI_MANAGED_MODELS`）。
- SDK 默认 ASR：`area_scope == "cn"` 且未显式传 STT 时，默认 `fengming`（否则 `ares`）。

## 已知组合（待验证，勿当作"可用配方"）

以下组合基于上面的矩阵推导，**均未端到端跑通**：

1. **免 key 最小组合（理论）**：ASR `fengming` + LLM `gpt-4o-mini`（托管白名单）+ TTS（⚠️ 是否有免 key 项未知）
2. **国内原生组合（需 BYOK）**：ASR `fengming` + LLM `deepseek`（api_key + base_url）+ TTS `minimax`（key）

## 不支持的边界

- `properties.geofence.area` 可选值只有 `GLOBAL / NORTH_AMERICA / EUROPE / ASIA / INDIA / JAPAN`，
  **没有 `CHINA`**。即无法用 `geofence` 强制 agent 引擎只在大陆运行（`ASIA` 是最近的一档，不等于大陆）。

## 待验证 / 未知

- 免 key 组合是否端到端跑通（尤其 TTS 环节）。
- 国内是否存在一款完全托管的 TTS（源码里 CN MiniMax 的 `key` 为可选，但官方说明"通常要 key"）。
- "只把 `Area.US` 改成 `Area.CN`、vendor 仍用海外类（Deepgram/OpenAI/MiniMax）"能否在 CN 端点跑通——未实测，不要默认可行。
- ConvoAI 直接 REST 在 CN 的官方推荐 host：`api.agora.io/cn/...` 还是 `api-cn-*.sd-rtn.com/cn/...`（未实测）。
