#!/bin/bash
# 小红书 MCP 环境检查脚本（支持自动安装）
# 项目地址: https://github.com/xpzouying/xiaohongshu-mcp
#
# 用法: bash check_env.sh [--auto-install]
#
# 参数:
#   --auto-install  如果 MCP 未安装，自动执行安装（默认仅提示）
#
# 返回码:
#   0 = 正常已登录
#   1 = MCP 未安装（已提示安装方式）
#   2 = 未登录

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MCP_URL="${XHS_MCP_URL:-http://localhost:18060/mcp}"
INSTALL_DIR="$HOME/xiaohongshu-mcp"

AUTO_INSTALL=false
for arg in "$@"; do
  [ "$arg" = "--auto-install" ] && AUTO_INSTALL=true
done

# ==================== 平台检测 ====================

detect_platform() {
  local os arch
  case "$(uname -s)" in
    Darwin) os="darwin" ;;
    Linux)  os="linux" ;;
    *)      os="unknown" ;;
  esac
  case "$(uname -m)" in
    x86_64|amd64)       arch="amd64" ;;
    aarch64|arm64)       arch="arm64" ;;
    *)                   arch="unknown" ;;
  esac
  echo "${os}-${arch}"
}

find_mcp_binary() {
  local platform
  platform=$(detect_platform)
  local candidates=(
    "${INSTALL_DIR}/xiaohongshu-mcp-${platform}"
    "${INSTALL_DIR}/xiaohongshu-mcp"
  )
  for bin in "${candidates[@]}"; do
    if [ -x "$bin" ]; then
      echo "$bin"
      return 0
    fi
  done
  return 1
}

check_mcp_running() {
  if pgrep -f "xiaohongshu-mcp" > /dev/null 2>&1; then
    return 0
  fi
  if curl -s --max-time 3 -X POST "$MCP_URL" \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"check","version":"1.0"}},"id":1}' \
    > /dev/null 2>&1; then
    return 0
  fi
  return 1
}

# ==================== 1. 检查 MCP 是否安装 ====================

echo "=== 1. 检查 xiaohongshu-mcp 是否安装 ==="
echo "   项目: https://github.com/xpzouying/xiaohongshu-mcp"

if find_mcp_binary > /dev/null 2>&1; then
  MCP_BIN=$(find_mcp_binary)
  echo "✅ MCP 已安装: $MCP_BIN"
elif check_mcp_running; then
  echo "✅ MCP 服务已在运行（端口响应正常）"
  MCP_BIN="(running)"
else
  echo "❌ xiaohongshu-mcp 未安装"

  if [ "$AUTO_INSTALL" = true ]; then
    echo ""
    echo "🚀 自动安装 xiaohongshu-mcp..."
    bash "${SCRIPT_DIR}/install_mcp.sh"
    INSTALL_EXIT=$?
    if [ $INSTALL_EXIT -ne 0 ]; then
      echo "❌ 自动安装失败"
      exit 1
    fi
    echo ""
    echo "=== 安装完成，继续检查 ==="
    # 重新查找
    if find_mcp_binary > /dev/null 2>&1; then
      MCP_BIN=$(find_mcp_binary)
    fi
  else
    echo ""
    echo "💡 安装方式（任选其一）："
    echo ""
    echo "   方式一：自动安装（推荐）"
    echo "   bash ${SCRIPT_DIR}/install_mcp.sh"
    echo ""
    echo "   方式二：带自动安装重新运行本脚本"
    echo "   bash ${SCRIPT_DIR}/check_env.sh --auto-install"
    echo ""
    echo "   方式三：手动下载"
    echo "   https://github.com/xpzouying/xiaohongshu-mcp/releases"
    exit 1
  fi
fi

# ==================== 2. 检查 MCP 服务是否运行 ====================

echo ""
echo "=== 2. 检查 MCP 服务是否运行 ==="

if check_mcp_running; then
  echo "✅ MCP 服务运行中 (${MCP_URL})"
else
  echo "⚠️ MCP 服务未运行，尝试启动..."

  if [ "$MCP_BIN" != "(running)" ] && [ -n "$MCP_BIN" ] && [ -x "$MCP_BIN" ]; then
    # Linux 下检查 Xvfb
    if [ "$(uname -s)" = "Linux" ]; then
      if ! pgrep -x Xvfb > /dev/null 2>&1; then
        if command -v Xvfb > /dev/null 2>&1; then
          Xvfb :99 -screen 0 1920x1080x24 > /dev/null 2>&1 &
          sleep 1
        fi
      fi
      export DISPLAY=:99
    fi

    cd "$INSTALL_DIR"
    nohup "$MCP_BIN" > "$INSTALL_DIR/mcp.log" 2>&1 &
    sleep 3

    if check_mcp_running; then
      echo "✅ MCP 服务已启动"
    else
      echo "❌ MCP 服务启动失败，请查看日志: $INSTALL_DIR/mcp.log"
      exit 1
    fi
  else
    echo "❌ 无法启动 MCP 服务（未找到可执行文件）"
    exit 1
  fi
fi

# ==================== 3. 检查生图 API 配置 ====================

echo ""
echo "=== 3. 检查生图 API 配置 ==="
IMG_API_TYPE="${IMG_API_TYPE:-seedream}"
IMG_OK=false

case "$IMG_API_TYPE" in
  seedream)
    if [ -n "${ARK_API_KEY:-}" ]; then
      echo "✅ Seedream API Key 已配置 (IMG_API_TYPE=seedream)"
      IMG_OK=true
    else
      echo "❌ Seedream API Key 未配置（需设置 ARK_API_KEY）"
    fi
    ;;
  gemini)
    if [ -n "${GEMINI_API_KEY:-}" ]; then
      echo "✅ Gemini API Key 已配置 (IMG_API_TYPE=gemini)"
      IMG_OK=true
    else
      echo "❌ Gemini API Key 未配置（需设置 GEMINI_API_KEY）"
    fi
    ;;
  openai)
    if [ -n "${IMG_API_KEY:-}" ]; then
      echo "✅ OpenAI 兼容 API Key 已配置 (IMG_API_TYPE=openai, BASE=${IMG_API_BASE:-https://api.openai.com/v1})"
      IMG_OK=true
    else
      echo "❌ OpenAI 兼容 API Key 未配置（需设置 IMG_API_KEY）"
    fi
    ;;
  hunyuan)
    if [ -n "${HUNYUAN_SECRET_ID:-}" ] && [ -n "${HUNYUAN_SECRET_KEY:-}" ]; then
      echo "✅ 腾讯云混元 API 已配置 (IMG_API_TYPE=hunyuan)"
      IMG_OK=true
    else
      echo "❌ 腾讯云混元 API 未配置（需设置 HUNYUAN_SECRET_ID 和 HUNYUAN_SECRET_KEY）"
    fi
    ;;
  *)
    echo "⚠️ 未知的 IMG_API_TYPE: $IMG_API_TYPE（支持 seedream/gemini/openai/hunyuan）"
    ;;
esac

if [ "$IMG_OK" = false ]; then
  FALLBACKS=""
  [ -n "${ARK_API_KEY:-}" ] && FALLBACKS="${FALLBACKS} seedream(ARK_API_KEY)"
  [ -n "${GEMINI_API_KEY:-}" ] && FALLBACKS="${FALLBACKS} gemini(GEMINI_API_KEY)"
  [ -n "${IMG_API_KEY:-}" ] && FALLBACKS="${FALLBACKS} openai(IMG_API_KEY)"
  [ -n "${HUNYUAN_SECRET_ID:-}" ] && [ -n "${HUNYUAN_SECRET_KEY:-}" ] && FALLBACKS="${FALLBACKS} hunyuan(HUNYUAN_SECRET_ID+KEY)"
  if [ -n "$FALLBACKS" ]; then
    echo "💡 检测到其他可用的生图 API:$FALLBACKS"
    echo "   可通过 export IMG_API_TYPE=xxx 切换"
  else
    echo "⚠️ 未配置任何生图 API，封面生成功能不可用"
    echo "   请设置以下任一组环境变量："
    echo "   - ARK_API_KEY（Seedream，推荐）"
    echo "   - GEMINI_API_KEY"
    echo "   - IMG_API_KEY + IMG_API_BASE"
    echo "   - HUNYUAN_SECRET_ID + HUNYUAN_SECRET_KEY"
  fi
fi

# ==================== 4. 检查登录状态 ====================

echo ""
echo "=== 4. 检查登录状态 ==="

SESSION_ID=""
INIT_RESP=$(curl -s -D /tmp/xhs_headers --max-time 10 -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"claude","version":"1.0"}},"id":1}' 2>/dev/null)

if [ $? -ne 0 ]; then
  echo "❌ 无法连接 MCP 服务 ($MCP_URL)"
  exit 1
fi

SESSION_ID=$(grep -i 'Mcp-Session-Id' /tmp/xhs_headers 2>/dev/null | tr -d '\r' | awk '{print $2}')

if [ -z "$SESSION_ID" ]; then
  echo "❌ 无法获取 MCP Session ID"
  exit 1
fi

curl -s --max-time 5 -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: $SESSION_ID" \
  -d '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}' > /dev/null 2>&1

LOGIN_RESULT=$(curl -s --max-time 15 -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: $SESSION_ID" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"check_login_status","arguments":{}},"id":2}' 2>/dev/null)

if echo "$LOGIN_RESULT" | grep -q "已登录"; then
  echo "✅ 已登录，可以正常使用"
  echo ""
  echo "================================================"
  echo "✅ 环境检查全部通过！"
  echo "================================================"
  exit 0
else
  echo "❌ 未登录，需要扫码登录"
  echo ""
  echo "💡 登录方式："
  echo "   Agent 会自动调用 get_login_qrcode 获取二维码"
  echo "   或手动登录: https://github.com/xpzouying/xiaohongshu-mcp#登录"
  exit 2
fi
