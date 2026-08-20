<!-- CN-REGION 触发条件：仅当用户目标是国内/声网/China/CN/大陆时适用本段；若用户未说明 region，先问"国内还是海外"再决定；海外（global/console.agora.io）场景跳过本段。 -->

# 国内 CLI 命令与版本

验证基线：与上游 `agora` skill 一致 —— CLI `0.2.1`。

## 国内命令面（0.2.1）

- 选 CN 区域：`agora project create <name> --region cn`（`--region global|cn`）
- RTM 数据中心：`agora project create <name> --rtm-data-center CN`（flag 在 0.2.1 已有；官方示例只列 `EU`/`AP`，`CN` 为国内数据中心）
- 一键脚手架：`agora init <name> --template <t> --region cn`

## 说明

- 登录：`agora login`（0.2.1 无 region 参数；区域在创建/选择项目时用 `--region` 指定）。
- 版本漂移：较新 CLI（如 0.2.8）把 `--region` 从 `project create` 挪到了 `login`。若本机 CLI 比 0.2.1 新，按上游 `agora` skill 规则用 `agora introspect --json` 现查当前命令面。

## 待验证

- `agora project create --region cn` 端到端创建国内项目（需声网账号实测）。
