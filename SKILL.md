---
name: xiaohongshu-publisher
description: >
  小红书一站式内容创作与发布助手。根据题材自动生成爆款标题、文案、大字报封面（Seedream），一键发布到小红书。
  触发词：小红书、发小红书、写笔记、生成文案、小红书封面、发布到小红书。
  需要配置：ARK_API_KEY（Seedream 生图）、xiaohongshu-mcp 服务（发布，首次自动安装）。
  xiaohongshu-mcp 项目地址：https://github.com/xpzouying/xiaohongshu-mcp
---

# 📕 小红书一站式创作发布助手

核心流程：题材 → 标题（5选1） → 正文 → 热门标签 → 大字报封面 → 一键发布

- Agent 直接用当前对话模型生成标题和正文，无需外部 API
- 发布依赖 [xiaohongshu-mcp](https://github.com/xpzouying/xiaohongshu-mcp)，首次运行自动安装

---

## 一、发布流程

当用户说"帮我发一条关于xxx的小红书"时，依次执行：

### 1.1 生成标题

- 参考 @references/title-guide.md 规范
- 生成5个不同风格标题，让用户选择
- 要求：20字以内，含1-2个emoji

**禁忌词**：速来、必看、全网第一、最全、最强、免费送、薅羊毛、踩雷、避坑

### 1.2 生成正文

- 参考 @references/content-guide.md 规范
- 50-200字，朋友聊天语气，自然段落
- 禁用列表/编号（不用 *、-、1.2.3.），用"第一"、"第二"自然串联
- 文末不放标签

### 1.3 搜索热门标签

通过 MCP `search_feeds` 搜索相关关键词，提取高频标签，生成4-5个。格式：`#标签名[话题]#`

### 1.4 生成封面图

纯色底大字报风格（1080x1440），由 Seedream 直接生成。

**流程**：
1. 参考 @references/cover-guide.md 构建 prompt
2. 从下方配色库选配色
3. 调用脚本生成

**Prompt 模板**：
```
A xiaohongshu style bold text poster, 3:4 aspect ratio, solid [底色] background.
Large bold Chinese text layout with title "[标题]" in [主字色] color.
[关键词高亮说明]. Simple decorative elements: [装饰].
Clean minimal typography, no photos, no illustrations, text-only poster.
Professional graphic design, high quality, no watermark, no logo.
```

**配色库**：

| 风格 | 底色 | 主字色 | 强调色 | 场景 |
|------|------|--------|--------|------|
| 经典白底 | `#FFFFFF` | `#1A1A1A` | `#E74C3C`红 | 通用 |
| 奶油温暖 | `#F5E6D0` | `#1A1A1A` | `#D4545B`红 | 美食、家居 |
| 蜜桃甜美 | `#FCDBD3` | `#1A1A1A` | `#D4545B`玫红 | 美妆、穿搭 |
| 薄荷清新 | `#D4EDDF` | `#1A1A1A` | `#1B5E40`绿 | 健身、学习 |
| 雾蓝理性 | `#CEDAEB` | `#1A1A1A` | `#2B4A7C`蓝 | 科技、职场 |
| 暗夜高级 | `#1C1C1E` | `#FFFFFF` | `#E8C872`金 | 数码、高级感 |
| 浅蓝笔记 | `#E8F4FD` | `#1A1A1A` | `#2196F3`蓝 | 学习、知识 |
| 纯白红标 | `#FFFFFF` | `#1A1A1A` | `#FF4757`红 | 速报、热搜 |

**生成命令**：
```bash
bash @scripts/cover.sh "标题" "完整prompt" /tmp/xhs_cover.png
# 或直接调用
python3 @scripts/seedream_gen.py "prompt" /tmp/xhs_cover.png 1080 1440
```

### 1.5 发布

**前置检查**（自动安装 MCP）：
```bash
bash @scripts/check_env.sh --auto-install
```
返回码：`0`=已登录，`1`=安装失败，`2`=未登录

**MCP 调用三步流程**（所有工具通用）：
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

**发布参数**：
```json
{"name":"publish_content","arguments":{"title":"标题（不含标签）","content":"正文\n\n#标签[话题]#","images":["/tmp/xhs_cover.png"]}}
```

**规则**：标题≤20字，正文≤1000字，标签放正文末尾，图片用绝对路径。

---

## 二、单独功能

- **仅生成文案**："写一篇关于xxx的小红书文案" → 执行 1.1-1.2
- **仅生成封面**："生成小红书封面" → 执行 1.4

---

## 三、MCP 工具列表

所有工具通过上述三步流程调用，以下仅列参数：

| 工具 | 参数 | 说明 |
|------|------|------|
| `check_login_status` | 无 | 检查登录状态 |
| `get_login_qrcode` | 无 | 获取登录二维码（Base64） |
| `delete_cookies` | 无 | 重置登录 |
| `publish_content` | title, content, images[] | 发布图文 |
| `publish_with_video` | title, content, video | 发布视频 |
| `search_feeds` | keyword, sort_by?, note_type?, publish_time? | 搜索笔记 |
| `list_feeds` | 无 | 推荐列表 |
| `get_feed_detail` | feed_id, xsec_token, load_all_comments? | 笔记详情 |
| `like_feed` | feed_id, xsec_token, unlike? | 点赞 |
| `favorite_feed` | feed_id, xsec_token, unfavorite? | 收藏 |
| `post_comment_to_feed` | feed_id, xsec_token, content | 评论 |
| `reply_comment_in_feed` | feed_id, xsec_token, content, comment_id, user_id | 回复评论 |
| `user_profile` | user_id, xsec_token | 用户主页 |

---

## 四、登录

MCP 服务需登录才能发布。

**扫码登录（推荐）**：调用 `get_login_qrcode` 获取二维码 → 保存为图片 → 用户扫码 → 等10秒 → `check_login_status` 确认

**手动 Cookie 登录**：浏览器登录小红书 → F12 复制 Cookie → 转换为 JSON 保存到 `~/xiaohongshu-mcp/cookies.json` → 重启 MCP

---

## 五、安装

> 项目地址：https://github.com/xpzouying/xiaohongshu-mcp

**正常无需手动安装**，`check_env.sh --auto-install` 自动完成。

手动安装：
```bash
bash @scripts/install_mcp.sh          # 安装
bash @scripts/install_mcp.sh --force  # 强制重装
```

---

## 六、注意事项

- 标签格式 `#标签名[话题]#`，放正文末尾
- 评论间隔 > 30秒，每天发布 ≤ 5篇
- MCP Session ID 约30分钟过期，超时重新初始化
- 发布超时设 120 秒
- 封面 prompt 必须包含 `no photos, no illustrations, text-only poster`

---

## 七、环境变量

| 变量 | 用途 | 默认值 | 必填 |
|------|------|--------|------|
| `ARK_API_KEY` | Seedream 生图 | 无 | 是 |
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
