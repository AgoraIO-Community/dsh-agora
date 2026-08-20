## ⚠️ Region Gate — 先确认区域，再动手

本模块同时覆盖**国内（声网 `console.shengwang.cn`）**与**海外（Agora `console.agora.io`）**两套部署；端点、鉴权与配置在两边不同。

**状态字段（每次 actionable 回复前核对）：**

```yaml
region_gate:
  region: unknown   # cn | global | unknown
```

**阻塞规则：**

- `region == unknown` → 以下动作 **blocked**，唯一允许动作 = 问一句「面向国内（声网）还是海外（Agora）？」：
  - 选端点 / base URL
  - 选账号体系 / 控制台
  - 决定 vendor / 默认管线 / managed·BYOK（如适用）
- `region == cn` → 走本文件英文 route，但进入每个英文 reference 前先查 [`cn.md`](cn.md)（国内差异映射表）。
- `region == global` → 走本文件英文正文；忽略 `cn.md`。

> 核对时机：每次 actionable 回复前先核对 `region`；`unknown` 时只能提问，不得继续选端点 / 选 vendor / 给配置。
