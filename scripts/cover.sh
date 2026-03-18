#!/bin/bash
# 小红书封面图生成脚本
# 功能：通过 Seedream / Gemini / OpenAI / 混元 直接生成纯色底大字报风格封面（1080x1440，3:4）
#       纯色背景 + 大号中文文字 + 简单装饰元素，无场景图片，无 ImageMagick 拼接
#
# 用法:
#   bash cover.sh "标题文字" "完整封面prompt" [输出路径]
#
# 参数:
#   $1 - 标题文字（必填，用于日志展示）
#   $2 - 完整封面 prompt（必填，应描述纯色底+大字排版+装饰元素）
#   $3 - 输出路径（可选，默认 /tmp/xhs_cover.png）
#
# 环境变量（生图 API 配置）:
#   IMG_API_TYPE    - API 类型: "seedream"（默认）| "gemini" | "openai" | "hunyuan"
#
#   Seedream 模式（火山引擎 Ark API）:
#     ARK_API_KEY     - 火山引擎 Ark API Key（必须设置）
#     ARK_API_BASE    - API 地址（默认 https://ark.cn-beijing.volces.com/api/v3）
#     SEEDREAM_MODEL  - 模型名称（默认 doubao-seedream-5-0-260128）
#
#   Gemini 模式:
#     GEMINI_API_KEY  - Google Gemini API Key（必须设置）
#     XHS_IMG_MODEL   - 模型名称（默认 gemini-2.5-flash-image）
#
#   OpenAI 兼容模式:
#     IMG_API_KEY     - API Key（必须设置）
#     IMG_API_BASE    - API Base URL（默认 https://api.openai.com/v1）
#     IMG_MODEL       - 模型名称（默认 dall-e-3）
#
#   腾讯云混元生图（AIART）模式:
#     HUNYUAN_SECRET_ID   - 腾讯云 SecretId（必须设置）
#     HUNYUAN_SECRET_KEY  - 腾讯云 SecretKey（必须设置）
#     HUNYUAN_REGION      - 地域（默认 ap-guangzhou）
#     HUNYUAN_ENDPOINT    - 请求域名（默认 aiart.tencentcloudapi.com）
#     HUNYUAN_RSP_TYPE    - 返回类型 url|base64（默认 url）
#
# 最终封面尺寸: 1080x1440 (3:4)，纯色底大字报风格

set -e

TITLE="${1:-}"
PROMPT="${2:-}"
OUTPUT="${3:-/tmp/xhs_cover.png}"

# 生图 API 配置（支持 seedream / gemini / openai / hunyuan 四种模式）
IMG_API_TYPE="${IMG_API_TYPE:-seedream}"

# Gemini 配置
GEMINI_API_KEY="${GEMINI_API_KEY:-}"
GEMINI_MODEL="${XHS_IMG_MODEL:-gemini-2.5-flash-image}"
GEMINI_API_URL="https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent"

# OpenAI 兼容配置
IMG_API_KEY="${IMG_API_KEY:-}"
IMG_API_BASE="${IMG_API_BASE:-https://api.openai.com/v1}"
IMG_MODEL="${IMG_MODEL:-dall-e-3}"

# 腾讯云混元生图（AIART）配置
HUNYUAN_SECRET_ID="${HUNYUAN_SECRET_ID:-}"
HUNYUAN_SECRET_KEY="${HUNYUAN_SECRET_KEY:-}"
HUNYUAN_REGION="${HUNYUAN_REGION:-ap-guangzhou}"
HUNYUAN_ENDPOINT="${HUNYUAN_ENDPOINT:-aiart.tencentcloudapi.com}"
HUNYUAN_RSP_TYPE="${HUNYUAN_RSP_TYPE:-url}"  # url | base64

# Seedream 配置（火山引擎 Ark API）
ARK_API_KEY="${ARK_API_KEY:-}"

# 尺寸定义（Ark API 要求最低 3,686,400 像素）
COVER_W=1920
COVER_H=2560

# 临时文件
TMP_DIR=$(mktemp -d)

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# ==================== 参数检查 ====================

if [ -z "$TITLE" ]; then
  echo "❌ 错误: 请提供标题文字"
  echo "用法: bash $0 \"标题文字\" \"完整封面prompt\" [输出路径]"
  exit 1
fi

if [ -z "$PROMPT" ]; then
  echo "❌ 错误: 请提供完整封面 prompt（纯色底大字报风格描述）"
  echo "用法: bash $0 \"标题文字\" \"完整封面prompt\" [输出路径]"
  exit 1
fi

# API Key 检查
if [ "$IMG_API_TYPE" = "seedream" ] && [ -z "$ARK_API_KEY" ]; then
  echo "❌ 错误: Seedream 模式下未设置 ARK_API_KEY 环境变量"
  echo "请先设置: export ARK_API_KEY=\"your-api-key\""
  echo "或切换为 Gemini 模式: export IMG_API_TYPE=gemini GEMINI_API_KEY=xxx"
  echo "或切换为 OpenAI 模式: export IMG_API_TYPE=openai IMG_API_KEY=xxx"
  echo "或切换为 混元 模式: export IMG_API_TYPE=hunyuan HUNYUAN_SECRET_ID=xxx HUNYUAN_SECRET_KEY=xxx"
  exit 1
elif [ "$IMG_API_TYPE" = "gemini" ] && [ -z "$GEMINI_API_KEY" ]; then
  echo "❌ 错误: Gemini 模式下未设置 GEMINI_API_KEY 环境变量"
  echo "请先设置: export GEMINI_API_KEY=\"your-api-key\""
  exit 1
elif [ "$IMG_API_TYPE" = "openai" ] && [ -z "$IMG_API_KEY" ]; then
  echo "❌ 错误: OpenAI 模式下未设置 IMG_API_KEY 环境变量"
  echo "请先设置: export IMG_API_KEY=\"your-api-key\" IMG_API_BASE=\"https://api.openai.com/v1\""
  exit 1
elif [ "$IMG_API_TYPE" = "hunyuan" ] && { [ -z "$HUNYUAN_SECRET_ID" ] || [ -z "$HUNYUAN_SECRET_KEY" ]; }; then
  echo "❌ 错误: 混元模式下未设置 HUNYUAN_SECRET_ID / HUNYUAN_SECRET_KEY 环境变量"
  exit 1
fi

echo "🎨 开始生成小红书纯色底大字报封面..."
echo "   标题: ${TITLE}"
echo "   模式: AI 直接生成纯色底大字报 (${IMG_API_TYPE})"
echo "   Prompt: ${PROMPT:0:100}..."
echo "   输出: ${OUTPUT}"
echo ""

# ==================== AI 直接生成纯色底大字报封面 ====================

echo "🔄 调用 ${IMG_API_TYPE} API 生成纯色底大字报封面（${COVER_W}x${COVER_H}）..."

if [ "$IMG_API_TYPE" = "seedream" ]; then
  echo "   模型: Doubao Seedream (Ark API)"
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  python3 "${SCRIPT_DIR}/seedream_gen.py" "$PROMPT" "$OUTPUT" "$COVER_W" "$COVER_H" 2>/tmp/xhs_cover_err.log

elif [ "$IMG_API_TYPE" = "openai" ]; then
  echo "   模型: ${IMG_MODEL} (OpenAI兼容)"
  echo "   Base: ${IMG_API_BASE}"

  PROMPT_ESCAPED=$(echo "$PROMPT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read().strip()))")
  RESPONSE_FILE="${TMP_DIR}/openai_response.json"

  curl -s -X POST "${IMG_API_BASE}/images/generations" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${IMG_API_KEY}" \
    -d "{\"model\": \"${IMG_MODEL}\", \"prompt\": ${PROMPT_ESCAPED}, \"n\": 1, \"size\": \"1024x1536\", \"response_format\": \"b64_json\"}" \
    -o "$RESPONSE_FILE"

  EXTRACT_PY="${TMP_DIR}/extract_openai.py"
  cat > "$EXTRACT_PY" << 'PYEOF'
import sys, json, base64

response_file = sys.argv[1]
output_file = sys.argv[2]

with open(response_file, "r") as f:
    data = json.load(f)

img_data = data.get("data", [])
if img_data and "b64_json" in img_data[0]:
    img_bytes = base64.b64decode(img_data[0]["b64_json"])
    with open(output_file, "wb") as f:
        f.write(img_bytes)
elif img_data and "url" in img_data[0]:
    import urllib.request
    urllib.request.urlretrieve(img_data[0]["url"], output_file)
else:
    error = data.get("error", {}).get("message", "")
    if not error:
        error = json.dumps(data, ensure_ascii=False)[:300]
    print(f"ERROR:{error}", file=sys.stderr)
    sys.exit(1)
PYEOF
  python3 "$EXTRACT_PY" "$RESPONSE_FILE" "$OUTPUT" 2>/tmp/xhs_cover_err.log

elif [ "$IMG_API_TYPE" = "hunyuan" ]; then
  echo "   服务: aiart (腾讯云混元生图)"

  GEN_PY="${TMP_DIR}/gen_hunyuan.py"
  cat > "$GEN_PY" << 'PYEOF'
import os, sys, json, base64, urllib.request
from tencentcloud.common import credential
from tencentcloud.common.profile.client_profile import ClientProfile
from tencentcloud.common.profile.http_profile import HttpProfile
from tencentcloud.aiart.v20221229 import aiart_client, models

prompt = sys.argv[1]
out_path = sys.argv[2]

sid = os.environ.get('HUNYUAN_SECRET_ID')
skey = os.environ.get('HUNYUAN_SECRET_KEY')
region = os.environ.get('HUNYUAN_REGION', 'ap-guangzhou')
endpoint = os.environ.get('HUNYUAN_ENDPOINT', 'aiart.tencentcloudapi.com')
rsp_type = os.environ.get('HUNYUAN_RSP_TYPE', 'url')

if not sid or not skey:
    raise SystemExit('missing HUNYUAN_SECRET_ID/HUNYUAN_SECRET_KEY')

cred = credential.Credential(sid, skey)
httpProfile = HttpProfile()
httpProfile.endpoint = endpoint
clientProfile = ClientProfile()
clientProfile.httpProfile = httpProfile
client = aiart_client.AiartClient(cred, region, clientProfile)

req = models.TextToImageRapidRequest()
req.Prompt = prompt
req.RspImgType = rsp_type

resp = client.TextToImageRapid(req)

if rsp_type == 'base64':
    img_bytes = base64.b64decode(resp.ResultImage)
    with open(out_path, 'wb') as f:
        f.write(img_bytes)
else:
    urllib.request.urlretrieve(resp.ResultImage, out_path)

print(json.dumps({
    'RequestId': resp.RequestId,
    'Seed': resp.Seed,
    'RspImgType': rsp_type,
}, ensure_ascii=False))
PYEOF
  python3 "$GEN_PY" "$PROMPT" "$OUTPUT" 2>/tmp/xhs_cover_err.log | tee "${TMP_DIR}/hunyuan_meta.json" >/dev/null

else
  # Gemini 模式
  echo "   模型: ${GEMINI_MODEL} (Gemini)"

  PROMPT_ESCAPED=$(echo "$PROMPT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read().strip()))")

  PAYLOAD=$(cat <<EOFPAYLOAD
{
  "contents": [{
    "parts": [
      {"text": ${PROMPT_ESCAPED}}
    ]
  }],
  "generationConfig": {
    "responseModalities": ["IMAGE"],
    "imageConfig": {
      "aspectRatio": "3:4"
    }
  }
}
EOFPAYLOAD
)

  RESPONSE_FILE="${TMP_DIR}/gemini_response.json"

  curl -s -X POST "${GEMINI_API_URL}?key=${GEMINI_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD" \
    -o "$RESPONSE_FILE"

  EXTRACT_PY="${TMP_DIR}/extract_img.py"
  cat > "$EXTRACT_PY" << 'PYEOF'
import sys, json, base64

response_file = sys.argv[1]
output_file = sys.argv[2]

with open(response_file, "r") as f:
    data = json.load(f)

found = False
candidates = data.get("candidates", [])
if candidates:
    parts = candidates[0].get("content", {}).get("parts", [])
    for part in parts:
        inline = part.get("inlineData") or part.get("inline_data")
        if inline and "data" in inline:
            img_bytes = base64.b64decode(inline["data"])
            with open(output_file, "wb") as f:
                f.write(img_bytes)
            found = True
            break

if not found:
    error = data.get("error", {}).get("message", "")
    if not error:
        error = json.dumps(data, ensure_ascii=False)[:300]
    print(f"ERROR:{error}", file=sys.stderr)
    sys.exit(1)
PYEOF
  python3 "$EXTRACT_PY" "$RESPONSE_FILE" "$OUTPUT" 2>/tmp/xhs_cover_err.log

fi

if [ ! -s "$OUTPUT" ]; then
  ERR=$(cat /tmp/xhs_cover_err.log 2>/dev/null)
  echo "❌ 封面生成失败: ${ERR:-未知错误}"
  exit 1
fi

echo ""
echo "✅ 纯色底大字报封面生成完成！"
echo "   路径: ${OUTPUT}"
echo "   尺寸: ${COVER_W}x${COVER_H} (3:4)"
echo "   风格: 纯色背景 + 大号中文文字"
