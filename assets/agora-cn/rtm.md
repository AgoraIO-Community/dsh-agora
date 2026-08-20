<!-- CN-REGION 触发条件：仅当用户目标是国内/声网/China/CN/大陆时适用本段；若用户未说明 region，先问"国内还是海外"再决定；海外（global/console.agora.io）场景跳过本段。 -->


# 国内 RTM（云信令 / Signaling）差异：区域 / 数据中心

> 本页只记录国内（大陆 / 声网 / CN 区域）与海外 RTM 的差异。
> 基础机制（login / subscribe / publish / presence / storage / lock / stream channel）见上文（海外部分）。
> 海外基线里**完全没有** region/area/domain 内容，本节补齐。

验证基线：Web SDK `agora-rtm` 2.3.0（npm 包 `agora-rtm.d.ts` 实测，latest=2.3.0）；原生 SDK 2.x
声网文档（`doc.shengwang.cn` api-ref + `docs.agora.io` signaling 文档）。


## 已确认的国内 delta

### 1. Web SDK（`agora-rtm` v2）选择 CN 区域

**API 是顶层 `AgoraRTM.setArea`，值是大写字符串 `"CHINA"`，不是 `"CN"`。**（与 RTC 的
`AgoraRTC.setArea({ areaCode: "CHINA" })` 形状不同：RTM 用的是**复数数组** `areaCodes`。）

```js
import AgoraRTM from "agora-rtm";

// 只连国内服务器（中国大陆）
AgoraRTM.setArea({ areaCodes: ["CHINA"] });

// 或：全球里排除中国大陆（海外场景）
AgoraRTM.setArea({ areaCodes: ["GLOBAL"], excludedArea: "CHINA" });

// 之后才创建实例
const rtm = new AgoraRTM.RTM(appId, userId, { logLevel: "info" });
```

- TS 签名（2.3.0）：`setArea(options: { areaCodes: AreaCode[]; excludedArea?: AreaCode }): void`。
- 枚举 `AreaCode`（v2 字符串值）：`GLOBAL`（默认）/ `CHINA`（中国大陆）/ `INDIA` / `JAPAN` /
  `ASIA`（除大陆外亚洲）/ `EUROPE` / `NORTH_AMERICA`。
- ⚠️ **不是** `new RTM(appId, uid, { areaCode: ... })`：v2 的 `RTMConfig`（构造器第三参）里**没有**
  `areaCode` 字段（只有 `encryptionMode/salt/cipherKey/presenceTimeout/logUpload/cloudProxy/
  useStringUserId/logLevel/heartbeatInterval/privateConfig`）。
- ⚠️ 包内还保留了 legacy v1 的 `LegacyAreaCode` 枚举（`CN = "CN"`, `GLOB = "GLOB"`, `NA`, `EU`,
  `AS`, `JP`, `IN`, `OC`, `SA`, `AF`, `KR`, `US`, `OVS`）——那是 v1 兼容枚举，**v2 请用
  `AreaCode.CHINA = "CHINA"`**，不要照搬 v1 的 `"CN"`。

来源：
- `https://registry.npmjs.org/agora-rtm`（latest=2.3.0；`agora-rtm.d.ts` 的 `AreaCode` / `LegacyAreaCode` / `setArea` / `RTMConfig`）
- `https://docs.agora.io/en/signaling/get-started/client-configuration?platform=web`（"Geographical area configuration" 示例 `setArea({ areaCodes: ["GLOBAL"], excludedArea: "CHINA" })`）

### 2. Android SDK（`io.agora:agora-rtm` v2）选择 CN 区域

**字段是 `RtmConfig.Builder(...).areaCode(...)`，类型 `EnumSet<RtmAreaCode>`，CN 常量是 `RtmAreaCode.CN`。**

```kotlin
import io.agora.rtm.RtmConfig
import io.agora.rtm.RtmConstants

val rtmConfig = RtmConfig.Builder("your-app-id", "user-id")
    .areaCode(EnumSet.of(RtmConstants.RtmAreaCode.CN))   // 中国大陆
    .eventListener(rtmEventListener)
    .build()
val rtmClient = RtmClient.create(rtmConfig)
```

- 枚举 `RtmAreaCode`（位掩码）：`CN` = `0x00000001`（中国大陆）、`NA` = `0x00000002`、`EU` =
  `0x00000004`、`AS` = `0x00000008`（除大陆外亚洲）、`JP` = `0x00000010`、`IN` = `0x00000020`、
  `GLOB` = `0xFFFFFFFF`（默认，全球）。
- 默认值 `GLOB`；不设 `areaCode` 即全球，不限定大陆。

来源：
- `https://docs.agora.io/en/signaling/get-started/client-configuration?platform=android`（`.areaCode(EnumSet.of(RtmConstants.RtmAreaCode.AS, RtmConstants.RtmAreaCode.CN))`）
- `https://doc.shengwang.cn/api-ref/rtm2/android/enumv`（`RtmAreaCode.CN` = `0x00000001` 中国大陆）

### 3. iOS SDK（`AgoraRtmKit` / `AgoraRtmClientKit` v2）选择 CN 区域

**字段是 `AgoraRtmClientConfig.areaCode`，类型 `AgoraRtmAreaCode`（OptionSet），CN 是 `.CN`。**

```swift
import AgoraRtmKit

let config = AgoraRtmClientConfig(appId: "yourAppId", userId: "yourUserId")
config.areaCode = [.CN]        // 中国大陆（可组合多区域，如 [.CN, .NA]）
let rtmClient = try AgoraRtmClientKit(config, delegate: nil)
```

- 枚举 `AgoraRtmAreaCode`（位掩码）：`CN` = `0x00000001`（中国大陆）、`NA` = `0x00000002`、`EU` =
  `0x00000004`、`AS` = `0x00000008`、`JP` = `0x00000010`、`IN` = `0x00000020`、`GLOB` =
  `0xFFFFFFFF`（默认，全球）。
- Objective-C 写法：`rtm_config.areaCode = AgoraRtmAreaCodeCN;`（`@property (nonatomic, assign) AgoraRtmAreaCode areaCode;`，默认 `AgoraRtmAreaCodeGLOB`）。

来源：
- `https://doc.shengwang.cn/api-ref/rtm2/swift/toc-configuration/configuration`（`config.areaCode = [.CN, .NA]` 示例）
- `https://doc.shengwang.cn/api-ref/rtm2/ios/enumv`（`AgoraRtmAreaCodeCN` = `0x00000001` 中国大陆）
- `https://doc.shengwang.cn/api-ref/rtm2/ios/toc-configuration/configuration`（`areaCode` 属性声明）

### 4. RTM 数据中心：控制面 vs 数据面（与 CLI `--rtm-data-center CN` 的关系）

国内 RTM 涉及**两层独立配置**，二者互补、不可互相替代：

| 层 | 入口 | 作用 | CN 取值 |
|---|---|---|---|
| **控制面**（项目/凭据落在哪个区域后端） | CLI `agora project create ... --rtm-data-center CN` / `agora init --rtm-data-center CN` | 决定项目在哪个区域后台开通、去哪个控制台拿 App ID | `CN`（另 `NA`/`EU`/`AP`，默认 `NA`） |
| **数据面**（SDK 运行时连哪个 SDRTN 边缘区域） | 客户端 area code（§1–§3 的 `setArea` / `areaCode`） | 决定 SDK 连到哪个区域的 RTM 服务边缘节点 | Web `"CHINA"`；Android `RtmAreaCode.CN`；iOS `.CN` |

- CLI 的 `--rtm-data-center CN` **不会**替客户端设置 area code，反之亦然：国内部署要**两者都设**
  （CN 项目拿 App ID + 客户端 areaCode = CN）。
- ⚠️ 取值集不对齐：CLI 是 `CN|NA|EU|AP`，SDK area code 是更细的位掩码
  （`CN/NA/EU/AS/JP/IN/GLOB`），没有字面一一对应（CLI 的 `AP` 无同名 SDK 码）。这是"控制面 vs 数据面"
  两个维度，不是同一枚举的两套别名。

来源：CLI 行为以 `agora` CLI 实测为准（`agora init --rtm-data-center CN` / `project create`）；SDK
area code 见 §1–§3 来源。

### 5. CN 域名 / 端点（RTM Web 消息频道）

- 国内主域名后缀 **`sd-rtn.com`**（海外 `agora.io`）。
- Signaling SDK（Web）消息频道防火墙白名单里同时列了两套，其中 **国内（`sd-rtn.com`）部分**：
  `.edge.sd-rtn.com`、`web-1.ap.sd-rtn.com` … `web-4.ap.sd-rtn.com`、`rtm.statscollector.sd-rtn.com`、
  `rtm.logservice.sd-rtn.com`；**海外（`agora.io`）部分**：`.edge.agora.io`、`ap-web-1.agora.io` …
  `ap-web-4.agora.io`、`webcollector-rtm.agora.io`、`logservice-rtm.agora.io`。
- 端口（消息频道）：`443; 9591; 9593; 27387`（TCP）；v1.x 另加 `9601`。

来源：
- `https://docs.agora.io/en/signaling/reference/firewall`（"Signaling SDK (Web) → Message channel → Domains"）


## 与海外一致（无 delta）

- **凭据模型**：App ID + App Certificate + token 完全不变。国内只是去 `console.shengwang.cn`
  建项目拿 App ID/证书，token 生成方式（App ID + App Certificate → token）与海外一致。
- **RTM API 面**：`login` / `subscribe` / `publish` / presence（`getOnlineUsers`/事件）/ storage /
  lock / stream channel（topic）全部同海外；RTM UID 仍是字符串、RTC↔RTM 命名空间隔离等规则不变。
- **客户端形态**：RTM 仍是纯客户端 SDK（无服务端 SDK / 无 Electron/桌面版），CN 下不变。
- **areaCode 是可选的**：不设默认 `GLOB`（全球），行为与海外完全一致；只有需要限定/合规时才设 CN。


## 待验证 / 未知

- **原生（Android/iOS）RTM 的精确 CN 接入点域名**：海外防火墙文档"Signaling SDK (Native)"小节只列了
  `.agora.io`（未列出 `.sd-rtn.com` 原生宿主名）。已确认的是后缀 `sd-rtn.com` + Web 端列出的
  `rtm.*.sd-rtn.com` 系列；原生设 `RtmAreaCode.CN` / `.CN` 后连接的确切信令 host 未在公开白名单页
  单独枚举，落地如需精确域名按 `doc.shengwang.cn` 现查。
- **`--rtm-data-center CN` 与 SDK area code 的字面等价**：官方文档没有一句"CLI CN == 客户端 areaCode CN"
  的直接表述；本页按"控制面 vs 数据面"两层表述（§4），但若需要权威原文确认二者的绑定关系，属待验证。
- **v1（legacy）SDK 的国内配置**：v2 包里保留的 `LegacyAreaCode.CN = "CN"` 是 v1 兼容枚举；独立 v1
  包（`agora-rtm-sdk`）的国内 area code 具体 API/取值未在本任务核实。
