#!/usr/bin/env python3
"""
火山引擎 Ark API 文生图脚本（Doubao Seedream）
通过 Ark REST API 调用 doubao-seedream 模型生成图片。

用法:
    python seedream_gen.py "prompt" [输出路径] [宽度] [高度]

环境变量:
    ARK_API_KEY       - 火山引擎 Ark API Key（必填）
    ARK_API_BASE      - API 地址（默认 https://ark.cn-beijing.volces.com/api/v3）
    SEEDREAM_MODEL    - 模型名称（默认 doubao-seedream-5-0-260128）

依赖:
    仅需 Python3 标准库（urllib），无需额外安装
"""

import os
import sys
import json
import base64
import urllib.request
import urllib.error


def generate_image(prompt: str, output_path: str = "/tmp/xhs_seedream.png",
                   width: int = 1920, height: int = 2560) -> str:
    """调用 Ark API 生成图片并保存到本地"""
    api_key = os.environ.get("ARK_API_KEY", "")
    if not api_key:
        print("❌ 缺少环境变量 ARK_API_KEY", file=sys.stderr)
        print("   请先设置: export ARK_API_KEY=\"your-api-key\"", file=sys.stderr)
        sys.exit(1)

    api_base = os.environ.get("ARK_API_BASE", "https://ark.cn-beijing.volces.com/api/v3")
    model = os.environ.get("SEEDREAM_MODEL", "doubao-seedream-5-0-260128")
    url = f"{api_base}/images/generations"

    # 构造尺寸参数
    size = f"{width}x{height}"

    payload = {
        "model": model,
        "prompt": prompt,
        "response_format": "b64_json",
        "size": size,
        "sequential_image_generation": "disabled",
        "stream": False,
        "watermark": False,
    }

    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}",
    }

    print(f"🎨 调用 Ark API 生成图片...", file=sys.stderr)
    print(f"   模型: {model} | 尺寸: {size}", file=sys.stderr)
    print(f"   Prompt: {prompt[:80]}{'...' if len(prompt) > 80 else ''}", file=sys.stderr)

    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers=headers,
        method="POST",
    )

    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            data = json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        print(f"❌ API 请求失败 (HTTP {e.code}): {body[:500]}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"❌ API 调用异常: {e}", file=sys.stderr)
        sys.exit(1)

    # 解析响应
    img_list = data.get("data", [])
    if not img_list:
        error_msg = data.get("error", {}).get("message", json.dumps(data, ensure_ascii=False)[:300])
        print(f"❌ 响应无图片数据: {error_msg}", file=sys.stderr)
        sys.exit(1)

    item = img_list[0]

    # 优先 b64_json
    if "b64_json" in item and item["b64_json"]:
        img_bytes = base64.b64decode(item["b64_json"])
        with open(output_path, "wb") as f:
            f.write(img_bytes)
        print(f"✅ 图片已保存: {output_path}", file=sys.stderr)
        print(output_path)
        return output_path

    # 备选：url
    if "url" in item and item["url"]:
        urllib.request.urlretrieve(item["url"], output_path)
        print(f"✅ 图片已下载: {output_path}", file=sys.stderr)
        print(output_path)
        return output_path

    print(f"❌ 响应中无可用图片数据: {json.dumps(item, ensure_ascii=False)[:300]}", file=sys.stderr)
    sys.exit(1)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("用法: python seedream_gen.py \"prompt\" [输出路径] [宽度] [高度]")
        print("示例: python seedream_gen.py \"A beautiful sunset\" /tmp/img.png 1080 1440")
        sys.exit(1)

    p = sys.argv[1]
    out = sys.argv[2] if len(sys.argv) > 2 else "/tmp/xhs_seedream.png"
    w = int(sys.argv[3]) if len(sys.argv) > 3 else 1920
    h = int(sys.argv[4]) if len(sys.argv) > 4 else 2560

    generate_image(p, out, w, h)
