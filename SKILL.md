---
name: xiaohongshu-publisher
description: >
  小红书全能助手：搜索浏览、文案创作、封面生成、一键发布、社交互动。
  当对话中出现"小红书"相关内容时自动激活。
  触发场景：搜索小红书内容、查热门/趋势/新闻/八卦、写小红书文案、生成小红书封面、
  发布到小红书、点赞/收藏/评论、查看用户主页。
  需要配置：ARK_API_KEY（Seedream 生图）、xiaohongshu-mcp 服务（首次自动安装）。
  xiaohongshu-mcp 项目地址：https://github.com/xpzouying/xiaohongshu-mcp
---

# 📕 小红书全能助手

本 Skill 覆盖小红书全场景：**搜索浏览** · **文案创作** · **封面生成** · **一键发布** · **社交互动**

当对话中出现小红书相关意图时自动激活，根据用户意图路由到对应流程。

---

## 〇、意图识别与路由（核心）

收到用户消息后，先判断属于哪种场景，再执行对应流程：

| 用户意图 | 触发词示例 | 执行流程 |
|----------|-----------|----------|
| **搜索/浏览** | "搜一下小红书上的…"、"查一下小红书…"、"小红书上XXX怎么样"、"小红书热门/趋势/新闻/八卦/娱乐" | → 第一章 |
| **写文案** | "写小红书文案"、"帮我写一篇小红书"、"小红书文案"、"写笔记" | → 第二章 |
| **生成封面** | "生成小红书封面"、"小红书封面"、"做个封面图" | → 第三章 |
| **完整发布** | "发小红书"、"发一条小红书"、"发布到小红书"、"帮我发一条关于XXX的小红书" | → 第四章（完整流程） |
| **社交互动** | "点赞"、"收藏"、"评论"、"回复评论" | → 第五章 |
| **查看用户** | "看看这个用户"、"用户主页" | → 第五章 5.4 |
| **登录管理** | "登录小红书"、"检查登录状态" | → 第七章 |

**路由规则**：
- 仅提到"小红书"+ 信息查询类词汇（新闻、热门、流行、趋势、八卦、推荐、怎么样、有什么）→ 搜索浏览
- 仅提到"文案"、"写"、"笔记" → 文案创作
- 仅提到"封面"、"图"、"海报" → 封面生成
- 提到"发"、"发布" → 完整发布流程
- 模糊时优先询问用户，但倾向完整发布流程

---

## 一、搜索与浏览

当用户想了解小红书上的内容、热点、趋势时执行。

### 1.1 关键词搜索

用户说"查一下小红书上的XXX"、"搜一下小红书的XXX"：

1. 提取用户意图中的关键词
2. 调用 MCP `search_feeds`：
   ```json
   {"name":"search_feeds","arguments":{"keyword":"关键词"}}
   ```
3. 可选筛选参数：
   - `sort_by`：`综合`（默认）/ `最新` / `最多点赞` / `最多评论` / `最多收藏`
   - `note_type`：`不限`（默认）/ `视频` / `图文`
   - `publish_time`：`不限`（默认）/ `一天内` / `一周内` / `半年内`
4. 整理搜索结果，以易读格式呈现：标题、作者、点赞/收藏/评论数
5. 如果用户想看详情，调用 `get_feed_detail` 获取完整内容

**智能筛选策略**：
- "最新/最近" → `sort_by: "最新"`
- "热门/爆款" → `sort_by: "最多点赞"`
- "新闻/今天" → `publish_time: "一天内"`
- "这周/本周" → `publish_time: "一周内"`

### 1.2 推荐浏览

用户说"看看小红书热门"、"小红书推荐"、"有什么好看的"：

1. 调用 MCP `list_feeds`（无参数）
2. 展示推荐列表：标题、作者、互动数据
3. 用户选择感兴趣的，调用 `get_feed_detail` 查看详情

### 1.3 笔记详情

用户提供 feed_id 或从搜索结果中选择：

1. 调用 MCP `get_feed_detail`：
   ```json
   {"name":"get_feed_detail","arguments":{"feed_id":"xxx","xsec_token":"xxx","load_all_comments":false}}
   ```
2. 展示完整内容：标题、正文、图片描述、互动数据、评论
3. 如需所有评论，设 `load_all_comments: true`

### 1.4 趋势分析

用户说"小红书流行趋势"、"最近什么火"：

1. 先调用 `list_feeds` 获取推荐内容
2. 再用 `search_feeds` 搜索多个热门关键词（根据用户兴趣领域）
3. 综合分析趋势：高频话题、热门标签、内容类型分布
4. 以摘要形式呈现趋势报告

---

## 二、文案创作

当用户只需要文案（标题+正文），不需要封面和发布时执行。

### 2.1 生成标题

- 参考 @references/title-guide.md 规范
- 生成5个不同风格标题，让用户选择
- 要求：20字以内，含1-2个emoji

**禁忌词**：速来、必看、全网第一、最全、最强、免费送、薅羊毛、踩雷、避坑

### 2.2 生成正文

- 参考 @references/content-guide.md 规范
- 根据用户指定风格（A闺蜜风/B硬核技术流/C实用主义/D文艺风，默认A）
- 600-800字，对应风格的语气和词库
- 结构：开头金句 → 3-5个核心要点 → 互动引导
- **正文中不要包含标签**，标签单独生成（见 2.3）

### 2.3 搜索热门标签

通过 MCP `search_feeds` 搜索相关关键词，提取高频标签，生成5-10个。格式：`#标签名[话题]#`

### 2.4 输出

将标题、正文、标签**分别**输出。标签独立列出，不要嵌入正文中。

---

## 三、封面生成

当用户只需要封面图时执行。

### 3.1 确认信息

需要用户提供（或从上下文推断）：
- **标题文字**：将显示在封面上的文字
- **主题/风格偏好**（可选）：用于选择配色

### 3.2 构建 Prompt

参考 @references/cover-guide.md：

1. 根据主题从配色库选择合适配色
2. 构建 Prompt：

```
A xiaohongshu style bold text poster, 3:4 aspect ratio, solid [底色] background.
Large bold Chinese text layout with title "[标题]" in [主字色] color.
[关键词高亮说明]. Simple decorative elements: [装饰].
Clean minimal typography, no photos, no illustrations, text-only poster.
Professional graphic design, high quality, no watermark, no logo.
```

### 3.3 配色库

| 风格 | 底色 | 主字色 | 强调色 | 场景 |
|------|------|--------|--------|------|
| 经典白底 | `#FFFFFF` | `#1A1A1A` | `#E74C3C`红 | 通用 |
| 奶油温暖 | `#F5E6D0` | `#1A1A1A` | `#D4545B`红 | 美食、家居 |
| 蜜桃甜美 | `#FCDBD3` | `#1A1A1A` | `#D4545B`玫红 | 美妆、穿搭 |
| 薄荷清新 | `#D4EDDF` | `#1A1A1A` | `#1B5E40`绿 | 健身、学习 |
| 雾蓝理性 | `#CEDAEB` | `#1A1A1A` | `#2B4A7C`蓝 | 科技、职场 |
| 鹅黄活力 | `#F5ECC8` | `#1A1A1A` | `#E67E22`橙 | 日常、育儿 |
| 暗夜高级 | `#1C1C1E` | `#FFFFFF` | `#E8C872`金 | 数码、高级感 |
| 珊瑚活力 | `#FBCEC5` | `#1A1A1A` | `#C04030`红 | 运动、潮流 |
| 浅蓝笔记 | `#E8F4FD` | `#1A1A1A` | `#2196F3`蓝 | 学习、知识 |
| 纯白红标 | `#FFFFFF` | `#1A1A1A` | `#FF4757`红 | 速报、热搜 |

### 3.4 生成命令

```bash
bash @scripts/cover.sh "标题" "完整prompt" /tmp/xhs_cover.png
# 或直接调用
python3 @scripts/seedream_gen.py "prompt" /tmp/xhs_cover.png 1080 1440
```

### 3.5 输出

展示生成的封面图路径，询问是否满意或需要调整配色/文字。

---

## 四、完整发布流程

当用户说"帮我发一条关于xxx的小红书"时，依次执行完整流程：

**标题 → 正文 → 标签 → 封面 → 发布**

### 4.1 生成标题

同第二章 2.1，生成5个标题让用户选择。

### 4.2 生成正文

同第二章 2.2，根据风格生成正文。

### 4.3 搜索热门标签

同第二章 2.3，通过 MCP 搜索提取标签。

### 4.4 生成封面图

同第三章，根据选定标题生成大字报封面。

### 4.5 发布

**前置检查**（自动安装 MCP）：
```bash
bash @scripts/check_env.sh --auto-install
```
返回码：`0`=已登录，`1`=安装失败，`2`=未登录

**发布调用**：
```json
{"name":"publish_content","arguments":{
  "title":"标题（不含标签）",
  "content":"纯正文（不含标签）",
  "images":["/tmp/xhs_cover.png"],
  "tags":["标签1[话题]","标签2[话题]","标签3[话题]"]
}}
```

> ⚠️ **重要**：`content` 中不要包含 `#标签[话题]#`，标签必须通过 `tags[]` 参数单独传递，MCP 才能正确识别和展示标签。

**可选高级参数**：
- `tags`：标签数组，每个元素格式为 `标签名[话题]`（不含 `#`）
- `schedule_at`：定时发布（ISO8601 格式，1小时至14天内）
- `is_original`：声明原创
- `visibility`：可见范围 — `公开可见`（默认）/ `仅自己可见` / `仅互关好友可见`

**规则**：标题≤20字，正文≤1000字，**标签不放正文里而是通过 `tags` 参数传递**，图片用绝对路径。

---

## 五、社交互动

### 5.1 点赞

```json
{"name":"like_feed","arguments":{"feed_id":"xxx","xsec_token":"xxx"}}
```
取消点赞加 `"unlike": true`

### 5.2 收藏

```json
{"name":"favorite_feed","arguments":{"feed_id":"xxx","xsec_token":"xxx"}}
```
取消收藏加 `"unfavorite": true`

### 5.3 评论

发表评论：
```json
{"name":"post_comment_to_feed","arguments":{"feed_id":"xxx","xsec_token":"xxx","content":"评论内容"}}
```

回复评论：
```json
{"name":"reply_comment_in_feed","arguments":{"feed_id":"xxx","xsec_token":"xxx","content":"回复内容","comment_id":"xxx","user_id":"xxx"}}
```

**规则**：评论间隔 > 30秒，避免被风控。

### 5.4 查看用户主页

```json
{"name":"user_profile","arguments":{"user_id":"xxx","xsec_token":"xxx"}}
```
展示用户信息：昵称、简介、粉丝数、获赞数、笔记列表。

---

## 六、MCP 通用调用协议

所有 MCP 工具通过以下三步流程调用：

```bash
MCP_URL="${XHS_MCP_URL:-http://localhost:18060/mcp}"

# 1. 初始化获取 Session ID
SESSION_ID=$(curl -s -D /tmp/xhs_headers -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"claude","version":"1.0"}},"id":1}' > /dev/null && grep -i 'Mcp-Session-Id' /tmp/xhs_headers | tr -d '\r' | awk '{print $2}')

# 2. 确认初始化
curl -s -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: $SESSION_ID" \
  -d '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}' > /dev/null

# 3. 调用工具（替换 TOOL_NAME 和 ARGUMENTS）
curl -s -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: $SESSION_ID" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"TOOL_NAME","arguments":ARGUMENTS},"id":2}'
```

**Session ID 约30分钟过期，超时需重新初始化。发布操作超时设 120 秒。**

---

## 七、MCP 工具完整列表

| 工具 | 参数 | 说明 |
|------|------|------|
| `check_login_status` | 无 | 检查登录状态 |
| `get_login_qrcode` | 无 | 获取登录二维码（Base64） |
| `delete_cookies` | 无 | 重置登录 |
| `publish_content` | title, content, images[], tags[]?, schedule_at?, is_original?, visibility?, products[]? | 发布图文 |
| `publish_with_video` | title, content, video, tags[]?, schedule_at?, visibility?, products[]? | 发布视频 |
| `search_feeds` | keyword, sort_by?, note_type?, publish_time? | 搜索笔记 |
| `list_feeds` | 无 | 推荐列表 |
| `get_feed_detail` | feed_id, xsec_token, load_all_comments?, limit? | 笔记详情 |
| `like_feed` | feed_id, xsec_token, unlike? | 点赞/取消 |
| `favorite_feed` | feed_id, xsec_token, unfavorite? | 收藏/取消 |
| `post_comment_to_feed` | feed_id, xsec_token, content | 评论 |
| `reply_comment_in_feed` | feed_id, xsec_token, content, comment_id, user_id | 回复评论 |
| `user_profile` | user_id, xsec_token | 用户主页 |

---

## 八、登录

MCP 服务需登录才能使用大部分功能。

**扫码登录（推荐）**：调用 `get_login_qrcode` 获取二维码 → 保存为图片 → 用户扫码 → 等10秒 → `check_login_status` 确认

**手动 Cookie 登录**：浏览器登录小红书 → F12 复制 Cookie → 转换为 JSON 保存到 `~/xiaohongshu-mcp/cookies.json` → 重启 MCP

---

## 九、安装

> 项目地址：https://github.com/xpzouying/xiaohongshu-mcp

**正常无需手动安装**，`check_env.sh --auto-install` 自动完成。

手动安装：
```bash
bash @scripts/install_mcp.sh          # 安装
bash @scripts/install_mcp.sh --force  # 强制重装
```

---

## 十、环境变量

| 变量 | 用途 | 默认值 | 必填 |
|------|------|--------|------|
| `ARK_API_KEY` | Seedream 生图 | 无 | 是（生成封面时） |
| `ARK_API_BASE` | Ark API 地址 | `https://ark.cn-beijing.volces.com/api/v3` | 否 |
| `SEEDREAM_MODEL` | 模型名称 | `doubao-seedream-5-0-260128` | 否 |
| `IMG_API_TYPE` | 生图类型 | `seedream` | 否 |
| `GEMINI_API_KEY` | Gemini 生图 | 无 | 否 |
| `IMG_API_KEY` | OpenAI 兼容生图 | 无 | 否 |
| `HUNYUAN_SECRET_ID/KEY` | 混元生图 | 无 | 否 |
| `XHS_MCP_URL` | MCP 地址 | `http://localhost:18060/mcp` | 否 |

**备用文案生成**（不推荐）：`XHS_AI_API_KEY` + `XHS_AI_API_URL` + `XHS_AI_MODEL`

```bash
bash @scripts/generate.sh title "内容"
bash @scripts/generate.sh content "内容" "标题"
```

---

## 十一、注意事项

- 标签格式 `标签名[话题]`，通过 `tags[]` 参数独立传递，**不要放在正文中**
- 评论间隔 > 30秒，每天发布 ≤ 5篇
- MCP Session ID 约30分钟过期，超时重新初始化
- 发布超时设 120 秒
- 封面 prompt 必须包含 `no photos, no illustrations, text-only poster`
- 搜索浏览功能也需要先登录 MCP
