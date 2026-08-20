---
name: agora-cn-rtc
description: |
  China-mainland (国内/声网) delta for Agora RTC (video/voice calling, live
  streaming, screen share, join/publish/subscribe): CN region selection
  (Web setArea / native areaCode), CN signaling domain (sd-rtn.com), and the
  cloud-proxy / firewall setup for mainland restricted networks. Use for 国内
  RTC, 声网 RTC, AREA_CODE_CN, setArea CHINA, or 云代理 questions.
license: MIT
metadata:
  author: agora
  version: '0.1.0'
---

# 国内 RTC 差异（声网 / CN Region）

> 本页只记录国内（大陆 / 声网 / CN 区域）与海外 RTC 的差异。
> 基础机制（join / publish / subscribe / token / channel profile）仍以 `agora` skill 的
> `references/rtc/*` 为准。海外基线里**完全没有** region/area/domain 内容，本页补齐。

验证基线：Web SDK `agora-rtc-sdk-ng` 4.24.7（`rtc-sdk_en.d.ts` 实测）；原生 SDK 4.x 声网文档
（`doc.shengwang.cn` + `docs-md.agora.io`）。

---

## 已确认的国内 delta

### 1. Web SDK（`agora-rtc-sdk-ng`）选择 CN 区域

**正确 API 是 `AgoraRTC.setArea`，值是大写 `"CHINA"`，不是 `"CN"`。**

```js
// 只连国内服务器
AgoraRTC.setArea({ areaCode: "CHINA" });

// 或：全球里排除中国大陆
AgoraRTC.setArea({ areaCode: "GLOBAL", excludedArea: "CHINA" });
```

- 枚举：`AREAS.CHINA = "CHINA"`（`ASIA / NORTH_AMERICA / EUROPE / JAPAN / INDIA / GLOBAL` 等并列）。
- TS 签名（4.24.7）：`setArea(area: AREAS[] | { areaCode: AREAS[]; excludedArea?: AREAS })`，自 4.2.0 起。
- ⚠️ **不是** `AgoraRTC.createClient({ areaCode: "CN" })`：4.x 的 `ClientConfig` 里没有 `areaCode` 字段
  （`createClient` 只接受 `mode/codec/role/clientRoleOptions` 等）。
- ⚠️ **没有**静态 `AgoraRTC.setCloudProxy`（这个猜测不存在于当前 Web SDK）。

来源：
- `https://cdn.jsdelivr.net/npm/agora-rtc-sdk-ng@4.24.7/rtc-sdk_en.d.ts`（`AREAS` 枚举 + `setArea` 签名 + `ClientConfig`）
- `https://registry.npmjs.org/agora-rtc-sdk-ng`（latest = 4.24.7）
- `https://doc.shengwang.cn/doc/rtc/javascript/advanced-features/region`

### 2. Web SDK 云代理（受限网络）

云代理是 **client 实例方法**，不是全局静态方法；需先向声网申请开通。

```js
const client = AgoraRTC.createClient({ mode: "rtc", codec: "vp8" });

client.startProxyServer(3);   // 3 = Force UDP 云代理；5 = Force TCP/TLS 443（v4.9.0+）
await client.join(APP_ID, channel, token, null);
// ...
await client.leave();
client.stopProxyServer();     // 离开频道后才能关闭
```

- `startProxyServer` 必须在 `join` **之前**调用；`stopProxyServer` 必须在 `leave` **之后**调用。
- 开通前置：联系 `sales@shengwang.cn` 提供 App ID / 使用区域 / 并发规模 / 运营商（不是开箱即用）。
- 判断媒体是否走代理：`client.on("is-using-cloud-proxy", (isUsingProxy) => ...)`。
- 自建代理（私有化/混合部署，非云代理）：`client.setProxyServer(domain)`（ASCII 域名）+ `client.setTurnServer(config)`；
  二者与 `startProxyServer` **不能混用**。

来源：
- `https://doc.shengwang.cn/doc/rtc/javascript/basic-features/firewall`
- `https://cdn.jsdelivr.net/npm/agora-rtc-sdk-ng@4.24.7/rtc-sdk_en.d.ts`（`startProxyServer`/`stopProxyServer`/`setProxyServer`）

### 3. 原生 SDK 区域码（Android / iOS / C++）

**Android**（`RtcEngineConfig.mAreaCode`）：

```java
RtcEngineConfig config = new RtcEngineConfig();
config.mAppId = appId;
config.mContext = mContext;
config.mAreaCode = AREA_CODE_CN;      // 中国大陆
mRtcEngine = RtcEngine.create(config);
```

- 常量 `AREA_CODE_CN = 0x00000001`（`Constants.AreaCode`）。其余：`AREA_CODE_GLOB`（默认）/ `NA` / `EU` / `AS` / `JP` / `IN`。
- 支持位运算：排除大陆用 `AREA_CODE_GLOB ^ AREA_CODE_CN`。

**iOS**（`AgoraRtcEngineConfig.areaCode`）：

```swift
let config = AgoraRtcEngineConfig()
config.appId = "YourAppId"
config.areaCode = .CN            // AgoraAreaCodeTypeCN
agoraKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
```

- 枚举：`AgoraAreaCodeTypeGlobal`（默认）/ `AgoraAreaCodeTypeCN` / `...NA` / `...EUR` / `...AS` / `...JP` / `...IN`。

**C++ / Windows**（`RtcEngineContext.areaCode`）：

```cpp
RtcEngineContext context;
context.appId = appId;
context.areaCode = AREA_CODE_CN;   // 中国大陆
m_rtcEngine->initialize(context);
```

来源：
- `https://doc.shengwang.cn/doc/rtc/android/advanced-features/region`
- `https://doc.shengwang.cn/doc/rtc/ios/advanced-features/region`
- `https://doc.shengwang.cn/doc/rtc/windows/advanced-features/region`
- `https://doc.shengwang.cn/api-ref/rtc/android/API/class_areacode`（`AREA_CODE_CN = 0x00000001`）

### 4. 原生 SDK 云代理（受限网络）

原生在受限网络下**只支持云代理，不支持防火墙域名白名单**（见 §6 表格）。

- Android/C++：`RtcEngine.setCloudProxy(proxyType)`
  - `TRANSPORT_TYPE_NONE_PROXY`(0) 默认自动；`TRANSPORT_TYPE_UDP_PROXY`(1) Force UDP；`TRANSPORT_TYPE_TCP_PROXY`(2) Force TCP/TLS 443。
- iOS：`setCloudProxy(_ proxyType: AgoraCloudProxyType)`
  - `AgoraNoneProxy`(0) / `AgoraUdpProxy`(1) / `AgoraTcpProxy`(2)。
- 需在频道外调用，`RtcEngine` 生命周期内有效；同样要先向 `sales@shengwang.cn` 申请开通并加白名单 IP。

来源：
- `https://doc.shengwang.cn/doc/rtc/android/basic-features/firewall`
- `https://doc.shengwang.cn/api-ref/rtc/ios/API/enum_cloudproxytype`

### 5. CN 域名后缀 / 信令域名

- 国内主域名后缀 **`sd-rtn.com`**（海外 `agora.io`）。
- Web SDK 防火墙白名单域名（国内部分）：
  `*.sd-rtn.com`、`*.edge.sd-rtn.com`、`*.ap.sd-rtn.com`、`*.statscollector.sd-rtn.com`、`*.webrtc-cloud-proxy.sd-rtn.com`
  （海外是 `*.agora.io` / `*.edge.agora.io`）。
- REST API 主域名（服务端在大陆时）：`api.sd-rtn.com`（海外 `api.agora.io`）；CN 区域子域
  `api-cn-east-1.sd-rtn.com` / `api-cn-north-1.sd-rtn.com`。

来源：
- `https://docs-md.agora.io/en/broadcast-streaming/reference/firewall_web.md`
- `https://docs-md.agora.io/en/broadcast-streaming/channel-management-api/best-practices/ensure-service-reliability.md`

### 6. 网络/防火墙策略差异（Web vs 原生）

| 产品 | 防火墙域名白名单 | 声网云代理 |
|---|---|---|
| Video SDK（原生 / 三方框架） | ✘ 不支持 | ✔ |
| Video SDK（Web） | ✔ | ✔ |

- 即：**原生 RTC 在受限网络只能走云代理**（申请开通 + `setCloudProxy`）；只有 Web SDK 能走域名白名单。

来源：
- `https://docs-md.agora.io/en/broadcast-streaming/reference/firewall_android.md`

---

## 与海外一致（无 delta）

- **凭据模型**：App ID + App Certificate + token（`join` 传 token）这套完全不变；国内只是去
  `console.shengwang.cn`（声网）建项目拿 App ID，拿到后 SDK 用法与海外一致。
- **频道机制**：`joinChannel` / `createClient` / `publish` / `subscribe` / channel profile
  (`rtc`/`live`) / client role (`host`/`audience`) 全部同海外。
- **token 续期**：`token-privilege-will-expire`（Web）/ `onTokenPrivilegeWillExpire`（原生）+ `renewToken` 同海外。
- **编解码/双流/屏幕共享**等能力面无 CN 差异；差异只在"连哪个区域/什么网络"。

---

## 待验证 / 未知

- **原生 RTC 信令的精确接入点域名**：设置 `AREA_CODE_CN` 后原生 SDK 连接的确切信令主机名
  （是否字面就是 `api.sd-rtn.com`）没有公开的"白名单域名"页可查（原生不支持防火墙白名单，官方未列域名）。
  已确认的是后缀 `sd-rtn.com` + REST 主域名 `api.sd-rtn.com`；原生媒体信令具体 host 记为待验证。
- **私有媒体网关（本地接入点 / 混合部署）**：确认原生有 `AgoraLocalAccessPointConfiguration` +
  `setLocalAccessPoint`、Web 有 `setProxyServer`，但这是单独的企业私有化/混合部署项目（需声网部署本地媒体网关），
  未在本任务里核实其完整开通流程与字段，落地前需按 `doc.shengwang.cn` 现查。
- **Web `setArea` 单字符串写法**：中文文档示例是 `AgoraRTC.setArea("ASIA")`（单字符串），
  而 4.24.7 类型签名是 `AREAS[] | { areaCode, excludedArea }`；运行时是否仍兼容单字符串未实测，
  建议统一用 `setArea({ areaCode: "CHINA" })`。
- **云代理"国内测试 IP"清单会漂移**：中文防火墙文档列出的国内测试 IP（如 `150.138.153.78` 等）
  仅供测试、正式上线要声网另发，且清单随版本更新，落地以申请后声网提供为准。
