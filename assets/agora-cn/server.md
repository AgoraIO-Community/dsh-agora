# 国内 Server（token / 鉴权）差异映射（region == cn 时使用）

> 本文件是英文 reference 的 CN 差异对照，不是独立教程。region == cn 时，走英文 route，
> 进入对应英文 ref 前按本文件替换 CN 差异点。基础机制见同目录英文 `README.md`。

## 已确认的国内 delta

### 1. 服务端 REST 域名（直接调服务端 API 时）

CN 主域名 `sd-rtn.com`，但**不是所有服务端产品都换域名**：

| 服务端产品 | CN 域名 | 海外域名 |
|---|---|---|
| 云端录制 REST | `https://api.sd-rtn.com` | `https://api.sd-rtn.com`（canonical 已统一；`api.agora.io` 仅残留于 quickstart 示例） |
| RTC 服务端 RESTful（频道管理/踢人规则等） | `https://api.sd-rtn.com` | `https://api.agora.io` |

> 云端录制 base URL 已在海外/国内两套文档里统一为 `api.sd-rtn.com`、且无 `/cn/` 前缀；
> 其真正的国内差异是「控制台换成声网 + `clientRequest.region="CN"`」。

### 2. Basic Auth 的客户 ID / 密钥获取位置不同

鉴权 Header 完全一致：`Authorization: Basic base64(customerID:customerSecret)`。
但**菜单路径不同**：

- **CN（声网）**：`console.shengwang.cn` → 设置 (Settings) → **RESTful API** → 添加密钥。
- **海外**：`console.agora.io` → **Developer Toolkit** → RESTful API → Add a secret。

（即：CN 走"设置 → RESTful API"，海外走"Developer Toolkit → RESTful API"。）

### 3. CN 专属 token 服务器 Docker 镜像

声网文档给的 Docker 部署镜像名是 `agoracn/token:0.1.2023053011`（`agoracn` 命名空间）。
部署层面小贴士：可用 `goproxy.cn` 加速 `go get`。

## 与海外一致（无 delta）

### Token 算法 / 输入完全一致，无 region 参数（确认）

- 同一开源仓库 `AgoraIO/Tools` 的 `DynamicKey/AgoraDynamicKey`，算法 HMAC-SHA256（AccessToken2）。
- 同一函数签名、同样输入（App ID + App Certificate + channel + UID/account + role + 过期时间），**无 region 参数**：
  - RTC：`BuildTokenWithUid(...)` / `RtcTokenBuilder.buildTokenWithUid(...)` / `buildTokenWithRtm(...)` / `buildTokenWithUserAccount(...)`
  - RTM：`RtmTokenBuilder2.BuildToken(appId, appCertificate, userId, expire)`
- **结论**：token builder 是 region-agnostic 的；region 内嵌于 App ID / App Certificate（CN 项目与海外项目是两套不同的 App ID + 证书）。因此**同一个 `agora-token` / `buildTokenWithRtm` 直接用于 CN 项目**，无需 CN 变体或额外参数。

### 无 CN 版 token 库 / npm 包

CN 文档指向的仍是同一个 `AgoraDynamicKey` 仓库；`agora-token`（npm）全球同一包，CN 直接复用。
唯一的 CN 专属产物是上述 Docker 镜像 `agoracn/token`（部署层，非库/算法层）。

### 其余一致

- token 约束：24h 最长有效期、过期前 30s `token-privilege-will-expire`、UID 范围 1..(2³²-1)——CN 与海外相同。

## 来源

- 声网 token 生成：https://doc.shengwang.cn/doc/rtc/javascript/basic-features/token-authentication
- 声网 RTM token：https://doc.shengwang.cn/doc/rtm2/javascript/user-guide/token/token-generation
- 声网云录制 REST 快速开始：https://doc.shengwang.cn/doc/cloud-recording/restful/get-started/quick-start
- 声网 RTC 服务端 REST：https://doc.shengwang.cn/doc/rtc/restful/get-started/call-api
- 海外对照：https://docs-md.agora.io/en/video-calling/token-authentication/deploy-token-server.md
