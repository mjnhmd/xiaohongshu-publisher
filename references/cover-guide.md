# 小红书封面图生成详细指南

## 封面图风格：纯色底大字报

封面图由 Seedream（或其他 AI 生图 API）直接一步生成**纯色背景 + 大号中文文字**的大字报风格封面（1080x1440，3:4）。
不包含场景图片，整张封面只有纯色底+醒目大字+简单装饰元素（emoji、标点、手绘小图标等）。

```
┌──────────────────┐
│                  │
│   纯色背景       │  整张图由 AI 直接生成
│                  │  纯色底 + 大号中文文字
│  「大标题文字」   │  + 简单装饰元素
│                  │  1080x1440 (3:4)
│   小装饰元素      │
│                  │
└──────────────────┘
```

**期望效果**：纯色背景上排列醒目的大号中文标题，文字有大小、颜色层次变化，搭配简单的装饰元素（emoji、感叹号、圆点、波浪线、手绘小图标等），整体简洁吸睛。

## AI 封面 Prompt 编写规范

### Prompt 模板

```
A xiaohongshu style bold text poster, 3:4 aspect ratio, solid [底色描述] background.
Large bold Chinese text layout with title "[标题文字]" in [主字色描述] color.
[关键词/副标题高亮说明，如：key phrase "xxx" highlighted in [强调色] with underline/box].
Simple decorative elements: [装饰元素描述，如 small emoji icons, exclamation marks, dots, wavy lines].
Clean minimal typography design, no photos, no illustrations, no scene, text-only poster.
Professional graphic design, high quality, no watermark, no logo.
```

### Prompt 关键要素

1. **风格定义**：`xiaohongshu style bold text poster` — 明确是纯文字排版海报
2. **背景**：`solid [颜色] background` — 纯色背景，无图片无场景
3. **文字排版**：大号中文粗体为主体，可有大小层次（主标题大、副标题小）
4. **文字高亮**：关键短语可用不同颜色、下划线、方框等方式强调
5. **装饰元素**：emoji、感叹号、圆点、波浪线、手绘箭头等简单元素
6. **排除项**：`no photos, no illustrations, no scene, text-only poster` — 明确排除图片和场景
7. **质量词**：`professional graphic design, high quality, no watermark, no logo`

### Prompt 示例

- 后悔类 → `A xiaohongshu style bold text poster, 3:4 aspect ratio, solid white background. Large bold Chinese text "后悔" at top in black color, followed by "没有早点" in black bold. Six black dots as decorative separator at bottom. Clean minimal typography, no photos, no illustrations, text-only poster. Professional graphic design, high quality, no watermark, no logo.`

- 速报类 → `A xiaohongshu style bold text poster, 3:4 aspect ratio, solid white background. Bold Chinese text "速报!!" at top in black with yellow exclamation mark decorations. Below: "最近互联网" in medium black text, "又有什么" in medium black text, "大树花生？" in medium black text with question mark. Yellow lightning bolt decorative elements scattered around. Clean minimal typography, no photos, no illustrations, text-only poster. Professional graphic design, high quality, no watermark, no logo.`

- 电商入门 → `A xiaohongshu style bold text poster, 3:4 aspect ratio, solid warm cream background. Chinese text layout: "一个新人" in black, "做电商" in bold black, "到底应该" in black, "如何起步" in bold black with a yellow question mark decoration. Small yellow number "2" icon at bottom right. Clean minimal typography, no photos, no illustrations, text-only poster. Professional graphic design, high quality, no watermark, no logo.`

- 旅游签证 → `A xiaohongshu style bold text poster, 3:4 aspect ratio, solid white background. Bold Chinese text: "出国旅游" in large black, "签证" in large black, "需要提前" in large black, "多久办？" in large bold black with red question mark. Small red megaphone icon decoration. Clean minimal typography, no photos, no illustrations, text-only poster. Professional graphic design, high quality, no watermark, no logo.`

- 自媒体类 → `A xiaohongshu style bold text poster, 3:4 aspect ratio, solid light blue background. Chinese text: "逼自己做" in bold black at top, "自媒体" in extra large bold red/orange highlighted text in center, "的第一天" in bold black below. At bottom: "建议收藏" in white text on blue highlight box. Clean minimal typography, no photos, no illustrations, text-only poster. Professional graphic design, high quality, no watermark, no logo.`

- 学习方法 → `A xiaohongshu style bold text poster, 3:4 aspect ratio, solid light yellow background with green decorative border. Bold Chinese text: "这样记笔记" in black at top with pink pencil icon decoration. "成绩暴涨" in extra large bold red text in center. "50分！" in extra large bold red text with exclamation mark. Clean minimal typography, no photos, no illustrations, text-only poster. Professional graphic design, high quality, no watermark, no logo.`

### 大字报排版技巧

1. **文字层次**：主标题用超大号粗体，副标题/说明用中号，形成大小对比
2. **颜色对比**：标题主体用深色（黑色），关键词用强调色（红、蓝、橙等），营造视觉焦点
3. **高亮手法**：关键短语可用色块背景、下划线、方框包裹等方式突出
4. **装饰克制**：装饰元素不超过 2-3 种，保持简洁不杂乱
5. **留白充足**：文字之间留有呼吸空间，不要挤满整个画面

### 禁止内容
- 不包含水印、logo
- 不包含真实照片或复杂插画
- 不使用场景描述（no scene, no illustration）

## 配色搭配规则（重要）

Agent 必须根据主题主动搭配底色与字色，不要用默认白底黑字（纯白底可用但需搭配装饰色）。

### 原则

1. **底色简洁**：纯色背景，可以是白色、浅色或深色
2. **字色醒目**：主文字用深色（黑色为主），关键词用强调色突出
3. **强调色点缀**：每张封面选 1 种强调色用于高亮关键词（红、蓝、橙、黄等）
4. **整体风格一致**：暖色主题用暖色搭配，冷色主题用冷色搭配
5. **小红书审美偏好**：偏向简洁、醒目、有冲击力

### 配色参考库（大字报专用）

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

### 在 Prompt 中使用配色

在 prompt 中使用自然语言描述颜色（而非 hex 值），例如：
- 底色：`solid white background` / `solid warm cream background` / `solid light blue background`
- 主字色：`black` / `dark charcoal` / `white`（暗底时）
- 强调色：`red` / `bright red` / `orange` / `blue` / `golden yellow`
- 高亮方式：`highlighted in red` / `with red underline` / `in white text on blue box`

### 自定义搭配原则

- 大字报以文字可读性为第一优先级
- 主文字用黑色/深色，保证清晰
- 每张封面最多用 1 种强调色，避免花哨
- 浅色底色可以是纯白或带淡淡色调的浅色
- 暗色底色（如暗夜高级）主文字改为白色/浅色
- 装饰元素颜色与强调色保持一致
