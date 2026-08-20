# 国内 ConvoAI 差异映射（region == cn 时使用）

> 本文件不是独立教程，是英文 reference 的 CN 差异对照。英文 route 不变：进入每个英文 ref 前，
> 按本表替换 CN 差异点。region == global 时忽略本文件。

## 英文 ref → CN 差异对照

| 英文 ref | CN 差异 |
|---|---|
| quickstarts.md | 无 CN 版 quickstart；用英文 quickstart 骨架（`agent-quickstart-python` / `agent-quickstart-nextjs`），默认管线（Deepgram/OpenAI/MiniMax）**不可用** |
| README.md（Base URL） | 直接 REST：`https://api.agora.io/cn/api/conversational-ai-agent/v2/projects/{appid}/...` |
| server-sdks.md | 客户端 `AgoraClient({ area: Area.CN })`（TS）/ `AsyncAgora(area=Area.CN)`（Python）；Python 专属类 `CNAgora` / `CNAsyncAgora` |
| auth-flow.md | 鉴权控制台 `console.shengwang.cn`（设置 → RESTful API），非 `console.agora.io` |
| server-custom-llm.md | CN vendor：`deepseek` / `aliyun` / `bytedance` / `tencent`，均需 **BYOK（api_key + base_url）** |

## 首次搭建（无 baseline）

英文 quickstart 骨架 + CN 端点 + 必须 BYOK：

| 环节 | 选择 | 凭据 |
|---|---|---|
| ASR | `fengming`（托管，默认） | 无需 key |
| LLM | `deepseek` / `aliyun` / `bytedance` / `tencent` | **api_key + base_url（必填）** |
| TTS | `minimax` / `tencent` / `bytedance` / `cosyvoice` / `stepfun` | **vendor key（必填）** |

推荐组合：`fengming`（ASR）+ `deepseek`（LLM）+ `minimax`（TTS）。

## 账号与控制台

- 国内控制台 `https://console.shengwang.cn`（声网账号，与海外不互通）。
- **需先在声网控制台开通 ConvoAI 服务**（海外无此步）。
- 入口：`https://console.shengwang.cn/product/ConversationAI?tab=Playground`。

## 已知边界

- `properties.geofence.area` 无 `CHINA` 选项（仅 GLOBAL / NORTH_AMERICA / EUROPE / ASIA / INDIA / JAPAN）。
