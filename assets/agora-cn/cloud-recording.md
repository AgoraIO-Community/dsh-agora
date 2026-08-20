<!-- CN-REGION 触发条件：仅当用户目标是国内/声网/China/CN/大陆时适用本段；若用户未说明 region，先问"国内还是海外"再决定；海外（global/console.agora.io）场景跳过本段。 -->


# 国内 Cloud Recording：控制台 / 端点 / 存储

验证基线：声网 `doc.shengwang.cn` 与海外 `docs.agora.io` 对照。

## 已确认的国内 delta

### 1. 控制台 / 账号 / 开通

- 国内控制台 `console.shengwang.cn`（声网）。App ID / App 证书 / 客户 ID·密钥 / 开通服务都在声网控制台完成。
- 需先**开通云端录制服务**（项目类型选**通用项目**）。

### 2. 端点：`api.sd-rtn.com`（关键修正：云端录制已基本统一，非 CN 独有）

- 国内 quick-start 全程 `https://api.sd-rtn.com/v1/apps/{appid}/cloud_recording/...`（acquire/start/stop 一致）。
- **海外 canonical 参考也写 base URL `https://api.sd-rtn.com`**——即云端录制当前 base URL 在两套文档里**已统一为 `api.sd-rtn.com`**。
  `api.agora.io` 只残留在海外 quickstart/认证示例里，属陈旧内容。
- 路径与海外**完全一致，且无 `/cn/` 前缀**。

### 3. CN 区域绑定：`clientRequest.region = "CN"`

- acquire 请求体有 `clientRequest.region`（string）：`"CN"`（中国大陆）/ `"AP"` / `"EU"` / `"NA"`。
- 默认「使用发起请求所在服务器的区域」；一旦显式设置，服务不访问该区域之外。
- **约束**：`start` 时第三方云存储的 `region` 必须与之匹配。

## 与海外一致（无 delta）

- **操作路径**：acquire / start / query / update / updateLayout / stop 六个操作 path 完全一致。
- **存储 vendor 枚举**：`1`=Amazon S3、`2`=阿里云 OSS、`3`=腾讯云 COS、`5`=Azure、`6`=GCP、`7`=华为云 OBS、`8`=百度云 BOS、`11`=其他 S3（需 `extensionParams.endpoint`）；无 vendor 4。
- **存储 region（大陆可用，两边都有）**：阿里云 `CN_*`（杭州/上海/北京/广州/成都…）、腾讯云 `AP_Beijing/AP_Shanghai/AP_Guangzhou/…`、AWS `CN_NORTH_1`/`CN_NORTHWEST_1`、华为云 `CN_*`、百度云（保定/苏州/广州）。
- **鉴权机制**：HTTP Basic Auth `Authorization: Basic base64(CustomerID:CustomerSecret)` 完全一致；仅 Customer ID/Secret 的生成控制台不同（声网：设置 → RESTful API）。
- **录制模式/特性**：`individual`/`mix`/`web`、`streamMode`、`transcodingConfig`、订阅黑白名单、NCS webhook、云端截图、格式转换——均一致。
- **storageConfig 字段集**：bucket/accessKey/secretKey/fileNamePrefix + `stsToken`/`stsExpiration`（S3/Aliyun/Tencent）一致。

## 待验证 / 未知

1. `clientRequest.region` 字段在**声网（CN）文档**里是否逐字一致未直接取到（CN operation 页 doc-mcp 返回"获取文档内容失败"；字段已从海外 canonical acquire 参考确认，但 CN 侧逐字出处缺失）。
2. 阿里云 region 编号 26/27 命名在 CN 与海外文档不一致（一方疑似笔误，未判定哪方正确）。
3. 迁移期 `api.agora.io` 是否仍实际可用（海外 canonical 已统一为 `api.sd-rtn.com`）。
4. 是否需要显式传 `clientRequest.region="CN"`（默认按发起服务器区域；声网账号默认是否已落 CN 未实测）。硬性大陆数据驻留时建议显式 `"CN"` 并匹配存储 region，但未经运行时验证。

## 来源

- 声网云端录制快速开始：https://doc.shengwang.cn/doc/cloud-recording/restful/get-started/quick-start
- 声网开通服务：https://doc.shengwang.cn/doc/cloud-recording/restful/get-started/enable-service
- 海外 canonical：https://docs.agora.io/en/realtime-media/cloud-recording/reference/restful-api.md
- acquire `clientRequest.region`：https://docs.agora.io/en/api-reference/api-ref/cloud-recording/acquire.md
- region/vendor 对照：https://docs.agora.io/en/realtime-media/cloud-recording/reference/region-vendor.md
