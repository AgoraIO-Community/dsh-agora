---
name: agora-cn
description: >-
  Activate for China-mainland (国内/声网) Agora deployment: console.shengwang.cn
  control plane, CN endpoints on the sd-rtn.com domain, `agora login --region
  cn` + CN data center, ConvoAI (Area.CN → api-cn-*.sd-rtn.com/cn + CN vendor/
  BYOK), and CN region selection for RTC (setArea CHINA / AREA_CODE_CN), RTM
  (setArea areaCodes / RtmAreaCode.CN), and Cloud Recording (clientRequest.
  region). Use when the user wants domestic deployment, 声网, China region (CN),
  or mainland data residency. Supplements the `agora` skill.
metadata:
  author: agora
  version: '0.1.0'
---

# Agora 国内区域（声网 / CN Region）

> 本 skill 是 `agora` 的**国内补充**：只覆盖"大陆 / 声网 / CN 区域"与海外版的差异。
> 基础机制（quickstart、token flow、生命周期）仍以 `agora` skill 为准。
> 验证基线：CLI `0.2.8`（本机 `introspect --json` 实测）+ 声网/海外官方文档对照（各产品 SDK 版本见各 reference）。

## 何时用本 skill

用户目标是**国内/大陆部署**、`声网`、`console.shengwang.cn`、`CN 区域`、或国内数据合规时使用。
否则仍走 `agora`。

## 国内 vs 海外：四件套差异

1. **账号**：国内控制台是 `console.shengwang.cn`（声网），且需在控制台**开通对应服务**（海外没有这个独立步骤）。
2. **CLI**：`agora login --region cn`；`agora init --rtm-data-center CN`。
3. **端点**：各产品 CN 端点以 `sd-rtn.com` 为主域名（详见各产品 reference）。
4. **vendor**：ConvoAI 需换 CN vendor 目录，并按 managed/BYOK 矩阵填 key（详见 `conversational-ai.md`）。

## Routing（按产品，与 `agora` 同构）

| 产品 | 国内 delta | 读这里 |
|---|---|---|
| **RTC** | area code / CN 域名 / 云代理 | [references/rtc.md](references/rtc.md) ✅ |
| **RTM** | region / 数据中心 | [references/rtm.md](references/rtm.md) ✅ |
| **Cloud Recording** | CN 端点 / `clientRequest.region` / 存储 | [references/cloud-recording.md](references/cloud-recording.md) ✅ |
| **Server（token）** | token 不变 / CN 域名 / 菜单路径 | [references/server.md](references/server.md) ✅ |
| **CLI** | 国内命令 / 版本要求 | [references/cli.md](references/cli.md) ✅ |
| **ConvoAI** | 端点 + CN vendor + managed/BYOK | [references/conversational-ai.md](references/conversational-ai.md) 📋 现状已记录（端到端待验证） |

## 状态标注（诚实边界）

| 状态 | 内容 |
|---|---|
| ✅ 已确认（源码/文档级） | RTC/RTM/Cloud Recording/Server/CLI 国内 delta 已填实（各文件内仍有"待验证"小节） |
| 📋 ConvoAI 现状 | 端点 + CN vendor + managed/BYOK 已源码确认；但**免-key 直接启动体验未端到端验证**，不承诺与海外一致 |
| ⚠️ 待运行时验证 | 原生 RTC/RTM 精确信令 host、`clientRequest.region` 是否需显式传、迁移期 `api.agora.io` 可用性、ConvoAI 免-key 组合等（见各文件"待验证"） |

## Guardrails

1. **本 skill 只补差异**；quickstart 克隆 / 生命周期 / token / baseline-first 约束沿用 `agora` skill。
2. **区域取值别混用**：Web SDK 用 `"CHINA"`、原生 SDK 用 `CN`（RTC/RTM 一致）；RTM Web 是复数 `areaCodes`、RTC Web 是单数 `areaCode`。
3. **ConvoAI 别断言"改一行 `Area` 就国内跑通"**：`Area.CN` 只解决端点路由，vendor 仍需换 CN 类并处理 key；国内免-key 体验未验证。
4. 未在本 skill 标注为"已确认"的能力，不要凭记忆承诺；必要时回落到声网官方文档（`doc.shengwang.cn`）现查。
