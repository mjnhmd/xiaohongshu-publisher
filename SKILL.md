---
name: xiaohongshu-publisher
description: >
  小红书一站式内容创作与发布助手。根据题材自动生成爆款标题、文案、大字报风格封面图（通过 Seedream 文生图），并一键发布到小红书。
  触发词：小红书、发小红书、写笔记、生成文案、小红书封面、发布到小红书。
  需要配置：火山引擎 AK/SK（Seedream 生图）、xiaohongshu-mcp 服务（发布，首次运行自动安装）。
  xiaohongshu-mcp 项目地址：https://github.com/xpzouying/xiaohongshu-mcp
---

# 📕 小红书一站式创作发布助手

核心流程：题材输入 → 生成标题（5选1） → 生成正文（600-800字） → 搜索平台热门标签（4-5个） → 生成纯色底大字报封面（Seedream） → 确认后一键发布

**重要说明**：本 Skill 的核心理念是 **Agent 直接使用当前对话模型生成内容**，无需依赖外部 API。仅在用户明确配置了外部 API 并要求使用时，才调用备用脚本。

**xiaohongshu-mcp 自动安装**：发布功能依赖 [xiaohongshu-mcp](https://github.com/xpzouying/xiaohongshu-mcp) 服务。首次运行发布流程时，前置检查脚本会自动从 GitHub Releases 下载安装对应平台的二进制文件并启动服务，无需手动安装。

---

## 一、一键发布流程（推荐）

当用户说"帮我发一条关于xxx的小红书"时，执行完整的自动化流程：

### 1.1 生成标题

**优先方式**：Agent 直接使用当前对话模型生成（推荐）

- 参考 `/Users/mengjingnan/Downloads/归档/xiaohongshu-publisher/references/title-guide.md` 规范
- 生成5个不同风格标题，让用户选择
- 核心要求：20字以内，含1-2个emoji，禁用平台禁忌词

**标题创作方法（5种）**：
1. **数字法则**：用具体数字增加可信度（如"7天"、"3个方法"）
2. **二极管标题**：制造强烈反差和对比效果
3. **疑问句式**：激发好奇心（如"为什么..."、"怎么..."）
4. **情绪共鸣**：使用高唤起情绪词，瞬间唤醒用户共鸣
5. **利益驱动**：直击痛点或利益点

**7大爆款标题风格**：
- 数字悬念型：【3个懒人收纳法，房间一周不乱！】
- 情感共鸣型：【谁懂啊！这碗面直接治愈了我的周一！】
- 结果导向型：【跟着博主做，7天搞定Python基础！】
- 反差对比型：【从烂脸到水光肌，我只做了这两件事】
- 稀缺信息型：【这10个上海小众秘境，90%的人没去过】
- 对话互动型：【你的枕头选对了吗？快来对照这份指南！】
- 价值宣言型：【2025年投资自己，这3项技能最值钱】

**平台禁忌词（严禁使用）**：
- 【诱导类】速来、必看、必收、千万不要、马上、抓紧、最后一波
- 【夸大类】全网第一、最全、最强、史上、终极、完美、天花板、封神
- 【营销类】免费送、0元购、薅羊毛、福利、红包、点击领取、价格感人
- 【负面类】丑哭、踩雷、血亏、别买、避坑、垃圾、后悔、翻车

**备用方式**：使用脚本生成（仅当用户明确配置了 XHS_AI_API_KEY 等环境变量并要求使用时）

```bash
bash /Users/mengjingnan/Downloads/归档/xiaohongshu-publisher/scripts/generate.sh title "内容摘要"
```

环境变量（需用户自行设置）：
- `XHS_AI_API_KEY` - API Key
- `XHS_AI_API_URL` - API URL（如 https://api.openai.com/v1/chat/completions）
- `XHS_AI_MODEL` - 模型名称（如 gpt-4o、deepseek-v3）

### 1.2 生成正文

**优先方式**：Agent 直接使用当前对话模型生成（推荐）

- 参考 `/Users/mengjingnan/Downloads/归档/xiaohongshu-publisher/references/content-guide.md` 规范
- 50-200字，像朋友聊天的语气
- 禁用列表/编号，用自然段落呈现
- 文末**不要**放标签（标签在发布时单独处理）

**写作风格**：
- **语言风格**：像朋友聊天，真诚、直接、有温度
- **句式结构**：简单明了，主谓宾清晰，一句话一个意思
- **词汇选择**：大白话优先，专业术语必须解释
- **段落节奏**：每段2-3句，保持呼吸感

**写作开篇方法（选择1种）**：
- **金句开场**：用一句话抓住注意力
- **痛点切入**：直接说出用户困扰
- **反转开场**：先说常见误区，再给出正确方法
- **故事引入**：用个人经历引发共鸣

**文本结构**：
- **开头**：emoji+金句/痛点（1-2句话）
- **主体**：分点叙述，每点前加emoji，3-5个要点，用段落展开，简单可以不展开
- **每个要点包含**：具体方法+个人体验+效果说明
- **结尾**：总结+互动引导


**写作约束（严格执行）**：

**禁止**：
1. 绝对不使用任何形式的项目符号或编号列表（不用 *、-、1.2.3. 等列表形式）
2. 不使用破折号（——）
3. 禁用"A而且B"的对仗结构
4. 尽量避免使用冒号（：），用句号代替
5. 开头不用设问句
6. 一句话只表达一个完整意思
7. 每段不超过3句话
8. 避免嵌套从句和复合句
9. 所有内容都用自然段落呈现，用"第一"、"第二"、"第三"等词语自然串联

**备用方式**：使用脚本生成（仅当用户明确配置并要求使用时）

```bash
bash /Users/mengjingnan/Downloads/归档/xiaohongshu-publisher/scripts/generate.sh content "完整内容" "选定标题"
```

### 1.3 搜索热门标签

通过 xiaohongshu-mcp 的 search_feeds 工具搜索相关内容，从搜索结果中提取高频标签。

**执行流程**：
1. 使用 MCP 工具搜索与文案主题相关的关键词
2. 分析搜索结果中的高频标签
3. Agent 结合搜索结果 + 文案主题，生成4-5个相关标签
4. 标签格式：`#标签名[话题]#`（小红书话题格式）
5. 展示给用户确认

**MCP 调用示例**（通过 Streamable HTTP 方式）：

```bash
MCP_URL="${XHS_MCP_URL:-http://localhost:18060/mcp}"

# 初始化并获取 Session ID
SESSION_ID=$(curl -s -D /tmp/xhs_headers -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"claude","version":"1.0"}},"id":1}' > /dev/null && grep -i 'Mcp-Session-Id' /tmp/xhs_headers | tr -d '\r' | awk '{print $2}')

# 确认初始化
curl -s -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: $SESSION_ID" \
  -d '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}' > /dev/null

# 搜索相关内容
curl -s -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: $SESSION_ID" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"search_feeds","arguments":{"keyword":"咖啡"}},"id":2}'
```

### 1.4 生成封面图

封面图由 Seedream 直接一步生成**纯色底大字报**风格封面（1080x1440，3:4）。

**封面图风格**：纯色背景 + 大号中文文字 + 简单装饰元素（emoji、标点、手绘小图标等），不包含场景图片或复杂插画。

#### 生成流程：

**第一步：Agent 构建纯色底大字报 Prompt**

Agent 参考 `/Users/mengjingnan/Downloads/归档/xiaohongshu-publisher/references/cover-guide.md`，将标题文字、配色、排版要求全部融入一个 prompt，让 Seedream 直接生成纯色底大字报封面。

**Prompt 构建规则**：

1. **风格定义**：`xiaohongshu style bold text poster` — 明确是纯文字排版海报
2. **背景**：`solid [颜色] background` — 纯色背景，无图片无场景
3. **文字排版**：大号中文粗体为主体，可有大小层次（主标题大、副标题/说明小）
4. **文字高亮**：关键短语可用不同颜色、下划线、方框等方式强调
5. **装饰元素**：emoji、感叹号、圆点、波浪线、手绘箭头等简单元素（不超过 2-3 种）
6. **排除项**：`no photos, no illustrations, no scene, text-only poster`
7. **质量词**：`professional graphic design, high quality, no watermark, no logo`

**Prompt 模板**：

```
A xiaohongshu style bold text poster, 3:4 aspect ratio, solid [底色描述] background.
Large bold Chinese text layout with title "[标题文字]" in [主字色描述] color.
[关键词/副标题高亮说明，如：key phrase "xxx" highlighted in [强调色] with underline/box].
Simple decorative elements: [装饰元素描述].
Clean minimal typography design, no photos, no illustrations, no scene, text-only poster.
Professional graphic design, high quality, no watermark, no logo.
```

**Prompt 示例**：
- 后悔类 → `A xiaohongshu style bold text poster, 3:4 aspect ratio, solid white background. Large bold Chinese text "后悔" at top in black color, followed by "没有早点" in black bold. Six black dots as decorative separator at bottom. Clean minimal typography, no photos, no illustrations, text-only poster. Professional graphic design, high quality, no watermark, no logo.`
- 速报类 → `A xiaohongshu style bold text poster, 3:4 aspect ratio, solid white background. Bold Chinese text "速报!!" at top in black with yellow exclamation mark decorations. Below: "最近互联网" in medium black text, "又有什么" in medium black text, "大树花生？" in medium black text with question mark. Yellow lightning bolt decorative elements scattered around. Clean minimal typography, no photos, no illustrations, text-only poster. Professional graphic design, high quality, no watermark, no logo.`
- 自媒体类 → `A xiaohongshu style bold text poster, 3:4 aspect ratio, solid light blue background. Chinese text: "逼自己做" in bold black at top, "自媒体" in extra large bold red/orange highlighted text in center, "的第一天" in bold black below. At bottom: "建议收藏" in white text on blue highlight box. Clean minimal typography, no photos, no illustrations, text-only poster. Professional graphic design, high quality, no watermark, no logo.`

**第二步：Agent 选择配色**

从配色库中选择与主题匹配的底色、主字色和强调色，用于写入 prompt：

**配色搭配原则**：
1. **底色简洁**：纯色背景（白色、浅色或深色均可）
2. **字色醒目**：主文字用深色（黑色为主），关键词用强调色突出
3. **强调色点缀**：每张封面选 1 种强调色用于高亮关键词（红、蓝、橙、黄等）
4. **整体风格一致**：暖色主题用暖色搭配，冷色主题用冷色搭配
5. **小红书审美偏好**：偏向简洁、醒目、有冲击力

**配色参考库（大字报专用）**：

| 风格 | 底色 | 主字色 | 强调色 | 适用场景 |
|------|------|--------|--------|---------|
| 经典白底 | `#FFFFFF` | `#1A1A1A`（黑） | `#E74C3C`（红） | 通用、话题讨论、观点 |
| 奶油温暖 | `#F5E6D0` | `#1A1A1A`（黑） | `#D4545B`（红） | 美食、生活、家居 |
| 蜜桃甜美 | `#FCDBD3` | `#1A1A1A`（黑） | `#D4545B`（玫红） | 美妆、穿搭、恋爱 |
| 薄荷清新 | `#D4EDDF` | `#1A1A1A`（黑） | `#1B5E40`（深绿） | 健身、户外、学习 |
| 雾蓝理性 | `#CEDAEB` | `#1A1A1A`（黑） | `#2B4A7C`（深蓝） | 科技、职场、理性讨论 |
| 鹅黄活力 | `#F5ECC8` | `#1A1A1A`（黑） | `#E67E22`（橙） | 日常、育儿、趣闻 |
| 暗夜高级 | `#1C1C1E` | `#FFFFFF`（白） | `#E8C872`（金） | 奢侈品、数码、高级感 |
| 珊瑚活力 | `#FBCEC5` | `#1A1A1A`（黑） | `#C04030`（红） | 运动、夏日、潮流 |
| 浅蓝笔记 | `#E8F4FD` | `#1A1A1A`（黑） | `#2196F3`（蓝） | 学习、笔记、知识分享 |
| 纯白红标 | `#FFFFFF` | `#1A1A1A`（黑） | `#FF4757`（亮红） | 速报、热搜、紧急话题 |

**第三步：调用 Seedream 生成纯色底大字报封面**

使用 cover.sh 脚本生成封面图（内部调用 Seedream，尺寸为 1080x1440）：

```bash
bash /Users/mengjingnan/Downloads/归档/xiaohongshu-publisher/scripts/cover.sh \
  "标题文字" \
  "完整的纯色底大字报prompt" \
  /tmp/xhs_cover.png
```

或直接使用 Python 脚本：

```bash
python3 /Users/mengjingnan/Downloads/归档/xiaohongshu-publisher/scripts/seedream_gen.py \
  "A xiaohongshu style bold text poster..." \
  /tmp/xhs_cover.png \
  1080 1440
```

**环境变量**（Seedream 模式，默认）：
- `ARK_API_KEY` - 火山引擎 Ark API Key（必填）
- `ARK_API_BASE` - API 地址（默认 https://ark.cn-beijing.volces.com/api/v3）
- `SEEDREAM_MODEL` - 模型名称（默认 doubao-seedream-5-0-260128）

**备选生图方式**（通过 IMG_API_TYPE 环境变量切换）：
- `seedream`（默认）：需要 ARK_API_KEY
- `gemini`：需要 GEMINI_API_KEY
- `openai`：需要 IMG_API_KEY + IMG_API_BASE
- `hunyuan`：需要 HUNYUAN_SECRET_ID + HUNYUAN_SECRET_KEY

### 1.5 发布到小红书

确认标题、正文、标签、封面后，通过 MCP 工具发布。

#### 前置检查（自动安装）

使用 `--auto-install` 参数，如果 xiaohongshu-mcp 未安装会自动从 GitHub 下载安装：

```bash
bash /Users/mengjingnan/Downloads/归档/xiaohongshu-publisher/scripts/check_env.sh --auto-install
```

> **xiaohongshu-mcp 项目地址**：https://github.com/xpzouying/xiaohongshu-mcp
> 首次运行时脚本会自动检测系统架构，从 GitHub Releases 下载对应平台的二进制文件并启动服务。

返回码：
- `0` = 正常已登录
- `1` = MCP 未安装（自动安装失败时）
- `2` = 未登录

#### 发布调用（MCP Streamable HTTP）

**重要**：每次调用 MCP 工具必须执行三步：初始化 → 获取 Session ID → 带 Session ID 调用工具。

**完整示例**：

```bash
MCP_URL="${XHS_MCP_URL:-http://localhost:18060/mcp}"

# 第一步：初始化并获取 Session ID
SESSION_ID=$(curl -s -D /tmp/xhs_headers -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"claude","version":"1.0"}},"id":1}' > /dev/null && grep -i 'Mcp-Session-Id' /tmp/xhs_headers | tr -d '\r' | awk '{print $2}')

# 第二步：确认初始化
curl -s -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: $SESSION_ID" \
  -d '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}' > /dev/null

# 第三步：调用 publish_content 发布（标题不包含标签，标签在正文末尾）
curl -s -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: $SESSION_ID" \
  -d '{
    "jsonrpc":"2.0",
    "method":"tools/call",
    "params":{
      "name":"publish_content",
      "arguments":{
        "title":"标题文字（不含标签）",
        "content":"正文内容\n\n#标签1[话题]# #标签2[话题]# #标签3[话题]# #标签4[话题]#",
        "images":["/tmp/xhs_cover.png"]
      }
    },
    "id":2
  }'
```

**注意事项**：
1. 标题不要包含标签，标签放在正文末尾
2. 标签格式：`#标签名[话题]#`（小红书平台格式）
3. 图片使用本地绝对路径
4. 正文不超过1000字
5. 发布前必须确认登录状态

---

## 二、单独功能

### 2.1 仅生成文案（不发布）

当用户说"帮我写一篇关于xxx的小红书文案"时，只执行 1.1-1.2 步骤：
1. 生成5个标题供选择
2. 生成正文（600-800字）
3. 不生成封面，不发布

### 2.2 仅生成封面

当用户说"帮我生成一张小红书封面"时：
1. 询问标题文字
2. Agent 根据标题构建纯色底大字报 prompt（纯色背景+大号文字排版+装饰元素）
3. 从配色库选择底色、主字色和强调色，写入 prompt
4. 调用 Seedream 生成纯色底大字报封面（1080x1440）
5. 保存到 `/tmp/xhs_cover.png` 并展示给用户

### 2.3 平台操作（MCP 工具列表）

xiaohongshu-mcp 服务提供以下所有工具，所有工具均通过 MCP Streamable HTTP 协议调用。

**调用模板**（所有工具通用）：

```bash
MCP_URL="${XHS_MCP_URL:-http://localhost:18060/mcp}"

# 初始化
SESSION_ID=$(curl -s -D /tmp/xhs_headers -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"claude","version":"1.0"}},"id":1}' > /dev/null && grep -i 'Mcp-Session-Id' /tmp/xhs_headers | tr -d '\r' | awk '{print $2}')

# 确认初始化
curl -s -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: $SESSION_ID" \
  -d '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}' > /dev/null

# 调用工具（替换 TOOL_NAME 和 ARGUMENTS）
curl -s -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: $SESSION_ID" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"TOOL_NAME","arguments":ARGUMENTS},"id":2}'
```

#### 工具1: check_login_status - 检查登录状态

**参数**：无

**示例**：
```json
{
  "name": "check_login_status",
  "arguments": {}
}
```

#### 工具2: get_login_qrcode - 获取登录二维码

**参数**：无

**返回**：二维码 Base64 图片数据

**示例**：
```json
{
  "name": "get_login_qrcode",
  "arguments": {}
}
```

**处理方式**：
1. 提取返回的 Base64 数据
2. 保存为图片文件：`echo "base64data" | base64 -d > /tmp/xhs_qrcode.png`
3. 展示给用户扫码

#### 工具3: delete_cookies - 重置登录状态

**参数**：无

**用途**：清除本地 cookies，用于切换账号或重新登录

**示例**：
```json
{
  "name": "delete_cookies",
  "arguments": {}
}
```

#### 工具4: publish_content - 发布图文笔记

**参数**：
- `title` (string, 必填) - 笔记标题（不超过20字）
- `content` (string, 必填) - 笔记正文（不超过1000字）
- `images` (array, 必填) - 图片路径数组（本地绝对路径，最多9张）

**示例**：
```json
{
  "name": "publish_content",
  "arguments": {
    "title": "7天学会Python基础",
    "content": "正文内容...\n\n#Python[话题]# #编程[话题]# #学习[话题]#",
    "images": ["/tmp/xhs_cover.png"]
  }
}
```

#### 工具5: publish_with_video - 发布视频笔记

**参数**：
- `title` (string, 必填) - 笔记标题
- `content` (string, 必填) - 笔记正文
- `video` (string, 必填) - 视频文件路径（本地绝对路径）

**示例**：
```json
{
  "name": "publish_with_video",
  "arguments": {
    "title": "咖啡拉花教程",
    "content": "视频教你如何拉花...\n\n#咖啡[话题]# #拉花[话题]#",
    "video": "/path/to/video.mp4"
  }
}
```

#### 工具6: search_feeds - 搜索笔记

**参数**：
- `keyword` (string, 必填) - 搜索关键词
- `sort_by` (string, 可选) - 排序方式：综合（默认）、最新、最多点赞
- `note_type` (string, 可选) - 笔记类型：不限（默认）、视频、图文
- `publish_time` (string, 可选) - 发布时间：不限（默认）、一天内、一周内、半年内

**返回**：笔记列表，包含 feed_id, xsec_token, 标题、作者、点赞数等

**示例**：
```json
{
  "name": "search_feeds",
  "arguments": {
    "keyword": "咖啡推荐",
    "sort_by": "最多点赞",
    "note_type": "图文"
  }
}
```

#### 工具7: list_feeds - 获取推荐笔记列表

**参数**：无

**返回**：首页推荐笔记列表

**示例**：
```json
{
  "name": "list_feeds",
  "arguments": {}
}
```

#### 工具8: get_feed_detail - 获取笔记详情

**参数**：
- `feed_id` (string, 必填) - 笔记 ID
- `xsec_token` (string, 必填) - 安全令牌（从搜索结果获取）
- `load_all_comments` (boolean, 可选) - 是否加载所有评论（默认 false）

**返回**：笔记详细信息、评论列表、点赞收藏数等

**示例**：
```json
{
  "name": "get_feed_detail",
  "arguments": {
    "feed_id": "65a1b2c3d4e5f6789",
    "xsec_token": "XYZ...",
    "load_all_comments": true
  }
}
```

#### 工具9: like_feed - 点赞/取消点赞

**参数**：
- `feed_id` (string, 必填) - 笔记 ID
- `xsec_token` (string, 必填) - 安全令牌
- `unlike` (boolean, 可选) - true 表示取消点赞（默认 false）

**示例**：
```json
{
  "name": "like_feed",
  "arguments": {
    "feed_id": "65a1b2c3d4e5f6789",
    "xsec_token": "XYZ...",
    "unlike": false
  }
}
```

#### 工具10: favorite_feed - 收藏/取消收藏

**参数**：
- `feed_id` (string, 必填) - 笔记 ID
- `xsec_token` (string, 必填) - 安全令牌
- `unfavorite` (boolean, 可选) - true 表示取消收藏（默认 false）

**示例**：
```json
{
  "name": "favorite_feed",
  "arguments": {
    "feed_id": "65a1b2c3d4e5f6789",
    "xsec_token": "XYZ...",
    "unfavorite": false
  }
}
```

#### 工具11: post_comment_to_feed - 发表评论

**参数**：
- `feed_id` (string, 必填) - 笔记 ID
- `xsec_token` (string, 必填) - 安全令牌
- `content` (string, 必填) - 评论内容

**建议**：评论间隔 > 30 秒，避免被限流

**示例**：
```json
{
  "name": "post_comment_to_feed",
  "arguments": {
    "feed_id": "65a1b2c3d4e5f6789",
    "xsec_token": "XYZ...",
    "content": "感谢分享！很有用～"
  }
}
```

#### 工具12: reply_comment_in_feed - 回复评论

**参数**：
- `feed_id` (string, 必填) - 笔记 ID
- `xsec_token` (string, 必填) - 安全令牌
- `content` (string, 必填) - 回复内容
- `comment_id` (string, 必填) - 被回复的评论 ID
- `user_id` (string, 必填) - 被回复的用户 ID

**示例**：
```json
{
  "name": "reply_comment_in_feed",
  "arguments": {
    "feed_id": "65a1b2c3d4e5f6789",
    "xsec_token": "XYZ...",
    "content": "确实是这样～",
    "comment_id": "comment_123",
    "user_id": "user_456"
  }
}
```

#### 工具13: user_profile - 获取用户主页信息

**参数**：
- `user_id` (string, 必填) - 用户 ID
- `xsec_token` (string, 必填) - 安全令牌

**返回**：用户昵称、简介、粉丝数、笔记列表等

**示例**：
```json
{
  "name": "user_profile",
  "arguments": {
    "user_id": "user_456",
    "xsec_token": "XYZ..."
  }
}
```

---

## 三、登录流程

xiaohongshu-mcp 服务必须登录后才能使用发布、点赞、评论等功能。提供三种登录方式：

### 方式一：快捷扫码（推荐）

**适用场景**：服务器有网络但无图形界面

**步骤**：

1. 调用 MCP 工具获取二维码

```bash
MCP_URL="${XHS_MCP_URL:-http://localhost:18060/mcp}"

SESSION_ID=$(curl -s -D /tmp/xhs_headers -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"claude","version":"1.0"}},"id":1}' > /dev/null && grep -i 'Mcp-Session-Id' /tmp/xhs_headers | tr -d '\r' | awk '{print $2}')

curl -s -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: $SESSION_ID" \
  -d '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}' > /dev/null

QRCODE_RESULT=$(curl -s -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: $SESSION_ID" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"get_login_qrcode","arguments":{}},"id":2}')

# 提取 Base64 数据并保存为图片
echo "$QRCODE_RESULT" | python3 -c "
import sys, json, base64
data = json.load(sys.stdin)
qr_base64 = data.get('result', {}).get('content', [{}])[0].get('text', '')
if qr_base64:
    with open('/tmp/xhs_qrcode.png', 'wb') as f:
        f.write(base64.b64decode(qr_base64))
    print('✅ 二维码已保存到 /tmp/xhs_qrcode.png')
else:
    print('❌ 获取二维码失败')
"
```

2. 展示二维码给用户，提示扫码登录
3. 用户扫码后，等待约 10 秒
4. 调用 `check_login_status` 确认登录成功

### 方式二：截图扫码（GUI 登录工具）

**适用场景**：需要在有虚拟显示的环境中使用登录工具

**前置条件**：
- 已安装 Xvfb（虚拟显示服务）
- 已下载 xiaohongshu-mcp 登录工具

**步骤**：

1. 启动 Xvfb（如未运行）

```bash
# 检查 Xvfb 是否运行
if ! pgrep -x Xvfb > /dev/null; then
  Xvfb :99 -screen 0 1920x1080x24 &
  echo "✅ Xvfb 已启动"
fi
```

2. 运行登录工具

```bash
DISPLAY=:99 ~/xiaohongshu-mcp/xiaohongshu-mcp-linux-amd64 --mode=login --cookies-path=~/xiaohongshu-mcp/cookies.json
```

3. 登录工具会显示二维码窗口（通过虚拟显示）
4. 使用 `scrot` 或其他工具截图

```bash
DISPLAY=:99 scrot /tmp/xhs_qrcode_screenshot.png
```

5. 展示截图给用户，提示扫码
6. 如果是异地登录，用户扫码后输入验证码到登录工具界面
7. 登录成功后，cookies 自动保存到 `~/xiaohongshu-mcp/cookies.json`

### 方式三：手动 Cookie 登录

**适用场景**：用户已在浏览器登录小红书，想复用 cookies

**步骤**：

1. 用户在浏览器打开小红书网页版（https://www.xiaohongshu.com）并登录
2. 打开浏览器开发者工具（F12）→ Network → 刷新页面
3. 找到任意请求，复制 Cookie 请求头的完整字符串
4. 将 Cookie 字符串转换为 JSON 格式并保存

**转换脚本**（Agent 可执行）：

```bash
# 用户提供的 Cookie 字符串
COOKIE_STRING="a1=xxx; webId=yyy; ..."

# 转换为 JSON 格式
python3 << 'EOF' > ~/xiaohongshu-mcp/cookies.json
import sys
cookie_string = """$COOKIE_STRING"""

cookies = []
for item in cookie_string.split('; '):
    if '=' in item:
        name, value = item.split('=', 1)
        cookies.append({
            "name": name.strip(),
            "value": value.strip(),
            "domain": ".xiaohongshu.com",
            "path": "/",
            "secure": True,
            "httpOnly": False
        })

import json
print(json.dumps(cookies, indent=2, ensure_ascii=False))
EOF

echo "✅ Cookies 已保存到 ~/xiaohongshu-mcp/cookies.json"
```

5. 重启 MCP 服务以加载新 cookies

```bash
pkill -f xiaohongshu-mcp
sleep 1
cd ~/xiaohongshu-mcp && DISPLAY=:99 nohup ./xiaohongshu-mcp-linux-amd64 > mcp.log 2>&1 &
echo "✅ MCP 服务已重启"
```

6. 调用 `check_login_status` 确认登录成功

---

## 四、安装 MCP 服务

> **项目地址**：https://github.com/xpzouying/xiaohongshu-mcp

**正常情况下无需手动安装**。前置检查脚本 `check_env.sh --auto-install` 会在检测到 MCP 未安装时自动执行安装。安装脚本会自动检测系统架构（macOS/Linux, amd64/arm64），从 GitHub Releases 下载对应的二进制文件并启动服务。

### 4.1 自动安装（推荐，默认行为）

前置检查已包含自动安装，Agent 在执行发布流程时会自动触发：

```bash
# 自动检查环境 + 未安装时自动安装
bash /Users/mengjingnan/Downloads/归档/xiaohongshu-publisher/scripts/check_env.sh --auto-install
```

该命令会依次完成：
1. 检测系统平台和架构
2. 从 https://github.com/xpzouying/xiaohongshu-mcp/releases 下载最新版二进制
3. 解压到 `~/xiaohongshu-mcp/` 目录
4. 安装 Python 依赖（requests）
5. 启动 MCP 服务
6. 检查登录状态

### 4.2 手动安装（备选）

如果自动安装失败，可以单独运行安装脚本：

```bash
# 安装脚本（自动检测架构，从 GitHub Releases 下载）
bash /Users/mengjingnan/Downloads/归档/xiaohongshu-publisher/scripts/install_mcp.sh

# 强制重新安装
bash /Users/mengjingnan/Downloads/归档/xiaohongshu-publisher/scripts/install_mcp.sh --force

# 仅检查安装状态
bash /Users/mengjingnan/Downloads/归档/xiaohongshu-publisher/scripts/install_mcp.sh --check-only
```

或手动从 GitHub 下载：https://github.com/xpzouying/xiaohongshu-mcp/releases

### 4.3 手动启动服务

安装完成后如需手动启动：

```bash
cd ~/xiaohongshu-mcp
nohup ./xiaohongshu-mcp-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/') > mcp.log 2>&1 &
echo "✅ MCP 服务已启动，日志: ~/xiaohongshu-mcp/mcp.log"
```

Linux 环境下如需虚拟显示（GUI 登录工具），先启动 Xvfb：

```bash
Xvfb :99 -screen 0 1920x1080x24 &
export DISPLAY=:99
```

---

## 五、前置依赖

### 必需依赖

| 依赖 | 用途 | 安装方式 |
|------|------|---------|
| Python 3 | 脚本运行 | `apt install python3` / 系统自带 |
| xiaohongshu-mcp 服务 | 小红书平台操作 | 自动安装（`check_env.sh --auto-install`），项目地址：https://github.com/xpzouying/xiaohongshu-mcp |

### 可选依赖

| 依赖 | 用途 | 安装方式 |
|------|------|---------|
| Xvfb | 虚拟显示（GUI 登录工具） | `apt install xvfb` |
| scrot | 截图工具 | `apt install scrot` |
| requests | Python HTTP 库 | `pip install requests` |

---

## 六、注意事项

### 发布规则
1. **标题长度**：不超过20字
2. **正文长度**：不超过1000字
3. **图片数量**：最多9张，必须使用本地绝对路径
4. **标签格式**：`#标签名[话题]#`，放在正文末尾，不放在标题中
5. **多设备登录**：小红书不支持多设备同时登录，会自动踢下线
6. **评论频率**：评论间隔建议 > 30 秒，避免被限流

### 登录状态
1. **发布前检查**：必须确认登录状态（`check_login_status`）
2. **Cookie 有效期**：Cookies 可能在一段时间后失效，需重新登录
3. **异地登录**：如果在不同 IP 登录，可能需要输入验证码

### MCP 调用规范
1. **Session ID**：每次调用工具前必须先初始化获取 Session ID
2. **三步流程**：初始化 → 确认 → 调用工具（三步在同一个 bash 执行块中完成）
3. **超时处理**：发布操作可能需要较长时间（最多 120 秒），注意设置合理的超时

### 封面图生成
1. **纯色底大字报风格**：纯色背景+大号中文文字+简单装饰元素，不包含场景图片
2. **配色选择**：从配色库选择底色、主字色和强调色，每张封面最多 1 种强调色
3. **完整封面尺寸**：1080x1440（3:4），由 Seedream 直接生成
4. **Prompt 质量**：封面效果完全取决于 prompt 质量，务必包含文字排版、配色、装饰元素等完整描述
5. **排除场景**：prompt 中必须包含 `no photos, no illustrations, no scene, text-only poster`
6. **中文文字渲染**：Seedream 支持中文文字，但复杂标题可能出现渲染不完美的情况，必要时可简化标题

### 环境变量
1. **Seedream 必填**：`ARK_API_KEY`
2. **MCP 地址**：`XHS_MCP_URL`（默认 http://localhost:18060/mcp）
3. **备用生图 API**：通过 `IMG_API_TYPE` 切换（seedream/gemini/openai/hunyuan）

---

## 七、故障排查

### 问题1: MCP 服务无法连接

**症状**：curl 返回 "Connection refused"

**排查步骤**：

```bash
# 检查 MCP 服务是否运行
pgrep -f xiaohongshu-mcp

# 如果没有运行，检查 systemd 服务状态
systemctl status xhs-mcp

# 查看 MCP 日志
tail -50 ~/xiaohongshu-mcp/mcp.log

# 检查端口占用
lsof -i :18060

# 手动启动（调试模式）
cd ~/xiaohongshu-mcp
DISPLAY=:99 ./xiaohongshu-mcp-linux-amd64
```

### 问题2: Seedream 生图失败

**症状**：Python 脚本报错或返回空数据

**排查步骤**：

```bash
# 检查环境变量
echo "ARK_API_KEY=${ARK_API_KEY:+已设置}"

# 测试 Seedream API
python3 /Users/mengjingnan/Downloads/归档/xiaohongshu-publisher/scripts/seedream_gen.py \
  "a beautiful sunset over mountains" \
  /tmp/test.png \
  1080 720

# 查看错误信息（API 调用失败通常是 API Key 错误或余额不足）
```

### 问题3: 封面图生成失败

**症状**：Seedream 返回的封面不符合预期

**排查步骤**：

```bash
# 检查 Seedream API 是否可用
python3 /Users/mengjingnan/Downloads/归档/xiaohongshu-publisher/scripts/seedream_gen.py \
  "A xiaohongshu style bold text poster, 3:4 aspect ratio, solid white background. Large bold Chinese text test in black. No photos, no illustrations, text-only poster." \
  /tmp/test.png \
  1080 1440

# 常见问题：
# 1. Prompt 中的中文文字渲染不清晰 → 简化标题，减少字数
# 2. 出现场景图片/插画 → 确保 prompt 包含 "no photos, no illustrations, no scene, text-only poster"
# 3. 配色不协调 → 在 prompt 中用更具体的颜色描述
# 4. 装饰元素过多 → 减少装饰描述，保持简洁
```

### 问题4: 登录失败或 Cookie 失效

**症状**：check_login_status 返回"未登录"

**解决方案**：

```bash
# 清除旧 cookies
rm -f ~/xiaohongshu-mcp/cookies.json

# 重新登录（方式一：获取二维码）
# 执行"三、登录流程"中的方式一或方式二

# 方式三：手动复制浏览器 Cookie
# 参考"三、登录流程 - 方式三"
```

### 问题5: Xvfb 虚拟显示无法启动

**症状**：DISPLAY=:99 命令报错

**排查步骤**：

```bash
# 检查 Xvfb 是否运行
pgrep -x Xvfb

# 检查 Xvfb 进程详情
ps aux | grep Xvfb

# 检查 systemd 服务状态
systemctl status xvfb

# 手动启动 Xvfb
Xvfb :99 -screen 0 1920x1080x24 &

# 测试虚拟显示
DISPLAY=:99 xdpyinfo
```

### 问题6: 发布失败

**症状**：publish_content 返回错误

**常见原因**：
1. 未登录或 Cookie 失效 → 重新登录
2. 图片路径错误 → 检查路径是否为绝对路径
3. 内容包含敏感词 → 修改文案
4. 标题或正文超长 → 缩短文字
5. 图片格式不支持 → 转换为 PNG/JPG

**调试方式**：

```bash
# 检查登录状态（如未安装会自动安装）
bash /Users/mengjingnan/Downloads/归档/xiaohongshu-publisher/scripts/check_env.sh --auto-install

# 查看 MCP 日志
tail -50 ~/xiaohongshu-mcp/mcp.log

# 手动测试发布（使用测试内容）
# 执行完整的 MCP 调用流程
```

---

## 八、完整示例（端到端）

假设用户说："帮我发一条关于咖啡拉花技巧的小红书"

**Agent 执行流程**：

### 步骤1: 生成标题

Agent 直接使用当前模型生成5个标题：

```
1. 咖啡拉花秘籍✨3个技巧让你秒变大师
2. 谁懂啊😭这些拉花技巧我早该知道！
3. 从小白到高手💡7天学会咖啡拉花
4. 你的拉花总是失败❗️90%人不知道的诀窍
5. 2026必学技能🔥咖啡拉花让你朋友圈爆赞
```

用户选择：**1. 咖啡拉花秘籍✨3个技巧让你秒变大师**

### 步骤2: 生成正文

Agent 生成正文（示例）：

```
✨姐妹们！今天分享我试了半年总结出的咖啡拉花技巧。真的超级实用！

第一个技巧是控制奶泡密度。你得打出那种像酸奶一样的质感。太稀太粗都不行。我一开始就是奶泡打太稀，倒下去直接散开。后来发现打到有明显挂壁感就对了。这个真的需要多练几次找手感。

第二个是融合角度。倒奶的时候杯子要倾斜45度左右。距离拉远一点先融合底层。等咖啡变成浅棕色再拉近倒。这样图案才会清晰。我之前角度不对，拉出来的心都歪了。你们可以先用水加酱油练手。

第三个是手腕抖动频率。画叶子的时候要快速左右摆动。频率越高纹路越细腻。我练了一周才找到感觉。刚开始真的手酸到不行。但看到成品那一刻真的绝了！

姐妹们有没有遇到拉花失败的情况？评论区说说你的经验～

#咖啡拉花[话题]# #咖啡[话题]# #手冲咖啡[话题]# #咖啡技巧[话题]#
```

### 步骤3: 搜索热门标签

Agent 调用 MCP 搜索"咖啡拉花"，提取热门标签：

```bash
curl -s -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: $SESSION_ID" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"search_feeds","arguments":{"keyword":"咖啡拉花"}},"id":2}'
```

从搜索结果中提取标签，最终确定：
- `#咖啡拉花[话题]#`
- `#咖啡[话题]#`
- `#手冲咖啡[话题]#`
- `#咖啡技巧[话题]#`

### 步骤4: 生成封面图

**4.1 Agent 构建纯色底大字报 Prompt**：

```
A xiaohongshu style bold text poster, 3:4 aspect ratio, solid warm cream background. Large bold Chinese text layout: "咖啡拉花秘籍" in extra large black bold at top, "✨3个技巧" in black bold in center, "让你秒变大师" in black bold below. Key phrase "秒变大师" highlighted in dark brown with underline. Simple decorative elements: small coffee cup emoji icon, sparkle decorations. Clean minimal typography design, no photos, no illustrations, no scene, text-only poster. Professional graphic design, high quality, no watermark, no logo.
```

**4.2 Agent 选择配色**：

主题为咖啡（美食类），选择**奶油温暖**风格：
- 底色描述：warm cream（对应 `#F5E6D0`）
- 主字色描述：black（对应 `#1A1A1A`）
- 强调色描述：dark brown（对应 `#D4545B`）

**4.3 调用 Seedream 生成纯色底大字报封面**：

```bash
python3 /Users/mengjingnan/Downloads/归档/xiaohongshu-publisher/scripts/seedream_gen.py \
  "A xiaohongshu style bold text poster, 3:4 aspect ratio, solid warm cream background. Large bold Chinese text layout: \"咖啡拉花秘籍\" in extra large black bold at top, \"✨3个技巧\" in black bold in center, \"让你秒变大师\" in black bold below. Key phrase \"秒变大师\" highlighted in dark brown with underline. Simple decorative elements: small coffee cup emoji icon, sparkle decorations. Clean minimal typography design, no photos, no illustrations, no scene, text-only poster. Professional graphic design, high quality, no watermark, no logo." \
  /tmp/xhs_cover.png \
  1080 1440
```

封面图已生成：`/tmp/xhs_cover.png`

### 步骤5: 发布到小红书

**5.1 检查登录状态**：

```bash
bash /Users/mengjingnan/Downloads/归档/xiaohongshu-publisher/scripts/check_env.sh --auto-install
```

返回码 0，已登录。

**5.2 调用 MCP 发布**：

```bash
MCP_URL="${XHS_MCP_URL:-http://localhost:18060/mcp}"

SESSION_ID=$(curl -s -D /tmp/xhs_headers -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"claude","version":"1.0"}},"id":1}' > /dev/null && grep -i 'Mcp-Session-Id' /tmp/xhs_headers | tr -d '\r' | awk '{print $2}')

curl -s -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: $SESSION_ID" \
  -d '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}' > /dev/null

PUBLISH_RESULT=$(curl -s -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: $SESSION_ID" \
  -d '{
    "jsonrpc":"2.0",
    "method":"tools/call",
    "params":{
      "name":"publish_content",
      "arguments":{
        "title":"咖啡拉花秘籍✨3个技巧让你秒变大师",
        "content":"✨姐妹们！今天分享我试了半年总结出的咖啡拉花技巧。真的超级实用！\n\n第一个技巧是控制奶泡密度...\n\n#咖啡拉花[话题]# #咖啡[话题]# #手冲咖啡[话题]# #咖啡技巧[话题]#",
        "images":["/tmp/xhs_cover.png"]
      }
    },
    "id":2
  }')

echo "$PUBLISH_RESULT"
```

**5.3 检查结果**：

如果返回 `"success": true`，则发布成功。Agent 告知用户：

```
✅ 小红书笔记发布成功！

标题：咖啡拉花秘籍✨3个技巧让你秒变大师
正文：600字
标签：#咖啡拉花[话题]# #咖啡[话题]# #手冲咖啡[话题]# #咖啡技巧[话题]#
封面：已生成大字报风格封面
```

---

## 九、高级用法

### 9.1 批量发布

如果用户提供多个主题，Agent 可以并行生成多篇内容，然后依次发布（注意发布间隔建议 > 1 分钟）。

### 9.2 定时发布

暂不支持定时发布。用户可以先生成内容和封面，Agent 保存到本地，稍后手动调用发布接口。

### 9.3 草稿保存

将生成的标题、正文、封面保存为本地文件：

```bash
mkdir -p ~/xhs_drafts

cat > ~/xhs_drafts/$(date +%Y%m%d_%H%M%S).md << EOF
# 标题
咖啡拉花秘籍✨3个技巧让你秒变大师

# 正文
（正文内容）

# 标签
#咖啡拉花[话题]# #咖啡[话题]# #手冲咖啡[话题]# #咖啡技巧[话题]#

# 封面
/tmp/xhs_cover.png
EOF

echo "✅ 草稿已保存到 ~/xhs_drafts/"
```

### 9.4 A/B 测试标题

生成 10 个标题（而不是 5 个），让用户挑选最佳标题进行发布。

---

## 十、API 限制与最佳实践

### Seedream API
- **限流**：每分钟最多 10 次请求
- **计费**：按生成次数计费（约 0.01-0.05 元/张）
- **最佳实践**：缓存已生成的图片，避免重复生成

### 小红书平台
- **发布频率**：建议每天不超过 5 篇
- **评论频率**：建议间隔 > 30 秒
- **多设备登录**：同一账号只能在一个设备登录
- **敏感词检测**：平台会自动审核内容，避免使用禁忌词

### MCP 服务
- **Session ID 有效期**：约 30 分钟，超时需重新初始化
- **并发限制**：建议同一时间只发起一个请求
- **超时设置**：发布操作建议设置 120 秒超时

---

## 十一、环境变量速查表

| 变量名 | 用途 | 默认值 | 必填 |
|--------|------|--------|------|
| `ARK_API_KEY` | 火山引擎 Ark API Key | 无 | 是（Seedream） |
| `ARK_API_BASE` | Ark API 地址 | `https://ark.cn-beijing.volces.com/api/v3` | 否 |
| `SEEDREAM_MODEL` | Seedream 模型名称 | `doubao-seedream-5-0-260128` | 否 |
| `IMG_API_TYPE` | 生图 API 类型 | `seedream` | 否 |
| `GEMINI_API_KEY` | Gemini API Key | 无 | 否（切换时需要） |
| `IMG_API_KEY` | OpenAI 兼容 API Key | 无 | 否（切换时需要） |
| `IMG_API_BASE` | OpenAI 兼容 API Base | `https://api.openai.com/v1` | 否 |
| `HUNYUAN_SECRET_ID` | 腾讯云混元 Secret ID | 无 | 否（切换时需要） |
| `HUNYUAN_SECRET_KEY` | 腾讯云混元 Secret Key | 无 | 否（切换时需要） |
| `XHS_MCP_URL` | MCP 服务地址 | `http://localhost:18060/mcp` | 否 |
| `XHS_AI_API_KEY` | 备用文案生成 API Key | 无 | 否（不推荐） |
| `XHS_AI_API_URL` | 备用文案生成 API URL | 无 | 否（不推荐） |
| `XHS_AI_MODEL` | 备用文案生成模型 | 无 | 否（不推荐） |

---

**文档版本**：v1.0
**最后更新**：2026-03-18
**维护者**：Claude Agent
**项目路径**：`/Users/mengjingnan/Downloads/归档/xiaohongshu-publisher/`
