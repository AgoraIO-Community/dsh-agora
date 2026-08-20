---
name: agora-cn-cli
description: |
  China-mainland Agora CLI commands: login/console region, CN RTM data center,
  webhook delivery region, and the version requirement for CN flags. Use for
  国内 CLI, agora login --region cn, or --rtm-data-center CN.
license: MIT
metadata:
  author: agora
  version: '0.1.0'
---

# 国内 CLI 命令与版本

验证基线：CLI `0.2.8`（`agora introspect --json` 实测）。

> 注意版本漂移：`agora` skill 内容基线是 CLI `0.2.1`，其中 `agora project create --region global|cn`
> 在 `0.2.8` 已**不存在**——国内 flag 已经搬家到 login / data-center。

## 国内命令面（0.2.8 实测）

- 登录国内控制台：`agora login --region cn`（等价 `agora auth login --region cn`；默认 `global`）
- RTM 数据中心：`agora project create ... --rtm-data-center CN`（可选 `CN|NA|EU|AP`，默认 `NA`）
- 一键脚手架：`agora init <name> --template <t> --rtm-data-center CN`
- Webhook 投递区域：`agora project webhook create ... --delivery-region cn`（可选 `cn|sea|na|eu`）

## 版本要求

- CN 入口（`login --region cn`、`--rtm-data-center CN`）比 `agora` skill 的验证基线 `0.2.1` 新。
- **确切引入版本待钉**：本机 `0.2.8` 已实测具备这两个 flag；低于该版本的 CLI 没有它们。
- 落地建议：国内路径要求 CLI 至少为实测具备 CN flag 的版本（当前以 `0.2.8` 为参照下界）。

## 端点相关环境变量（`agora env-help --json` 实测）

- `AGORA_CONSOLE_URL` — 覆盖 `agora open --target console` 的 URL
- `AGORA_API_BASE_URL`（默认 `https://agora-cli.agora.io`）
- `AGORA_OAUTH_BASE_URL`（默认 `https://sso2.agora.io`）

## 待验证

- `agora login --region cn` 的 OAuth 流程端到端（需声网账号实测）。
