# 国内 CLI 差异映射（region == cn 时使用）

> 本文件是英文 reference 的 CN 差异对照，不是独立教程。region == cn 时，走英文 route，
> 进入对应英文 ref 前按本文件替换 CN 差异点。命令面细节见同目录英文 `README.md`。

## 国内命令面（0.2.1）

- 选 CN 区域：`agora project create <name> --region cn`（`--region global|cn`）
- RTM 数据中心：`agora project create <name> --rtm-data-center CN`（flag 在 0.2.1 已有；官方示例只列 `EU`/`AP`，`CN` 为国内数据中心）
- 一键脚手架：`agora init <name> --template <t> --region cn`

## 说明

- 登录：`agora login`（0.2.1 无 region 参数；区域在创建/选择项目时用 `--region` 指定）。
- 版本漂移：较新 CLI（如 0.2.8）把 `--region` 从 `project create` 挪到了 `login`。若本机 CLI 比 0.2.1 新，按上游 `agora` skill 规则用 `agora introspect --json` 现查当前命令面。


