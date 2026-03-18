#!/bin/bash
# xiaohongshu-mcp 自动安装脚本
# 项目地址: https://github.com/xpzouying/xiaohongshu-mcp
#
# 功能: 自动检测系统架构，下载对应平台的 xiaohongshu-mcp 二进制文件并启动服务
# 用法: bash install_mcp.sh [--check-only] [--force]
#
# 参数:
#   --check-only  仅检查是否已安装，不执行安装（返回码 0=已安装, 1=未安装）
#   --force       强制重新安装（覆盖已有文件）

set -e

# ==================== 配置 ====================

GITHUB_REPO="xpzouying/xiaohongshu-mcp"
GITHUB_API="https://api.github.com/repos/${GITHUB_REPO}/releases/latest"
INSTALL_DIR="$HOME/xiaohongshu-mcp"
MCP_URL="${XHS_MCP_URL:-http://localhost:18060/mcp}"

# ==================== 参数解析 ====================

CHECK_ONLY=false
FORCE=false

for arg in "$@"; do
  case "$arg" in
    --check-only) CHECK_ONLY=true ;;
    --force) FORCE=true ;;
  esac
done

# ==================== 平台检测 ====================

detect_platform() {
  local os arch

  case "$(uname -s)" in
    Darwin) os="darwin" ;;
    Linux)  os="linux" ;;
    MINGW*|MSYS*|CYGWIN*) os="windows" ;;
    *)
      echo "❌ 不支持的操作系统: $(uname -s)"
      exit 1
      ;;
  esac

  case "$(uname -m)" in
    x86_64|amd64)       arch="amd64" ;;
    aarch64|arm64)       arch="arm64" ;;
    *)
      echo "❌ 不支持的 CPU 架构: $(uname -m)"
      exit 1
      ;;
  esac

  echo "${os}-${arch}"
}

# ==================== 查找已安装的二进制 ====================

find_mcp_binary() {
  local platform
  platform=$(detect_platform)
  local os="${platform%-*}"

  # 按优先级查找
  local candidates=(
    "${INSTALL_DIR}/xiaohongshu-mcp-${platform}"
    "${INSTALL_DIR}/xiaohongshu-mcp"
  )

  # macOS 不需要后缀，Windows 需要 .exe
  if [ "$os" = "windows" ]; then
    candidates=(
      "${INSTALL_DIR}/xiaohongshu-mcp-${platform}.exe"
      "${INSTALL_DIR}/xiaohongshu-mcp.exe"
    )
  fi

  for bin in "${candidates[@]}"; do
    if [ -x "$bin" ]; then
      echo "$bin"
      return 0
    fi
  done

  return 1
}

# ==================== 检查 MCP 服务是否在运行 ====================

check_mcp_running() {
  # 检查进程
  if pgrep -f "xiaohongshu-mcp" > /dev/null 2>&1; then
    return 0
  fi

  # 检查端口响应
  if curl -s --max-time 3 -X POST "$MCP_URL" \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"check","version":"1.0"}},"id":1}' \
    > /dev/null 2>&1; then
    return 0
  fi

  return 1
}

# ==================== 仅检查模式 ====================

if [ "$CHECK_ONLY" = true ]; then
  if find_mcp_binary > /dev/null 2>&1; then
    MCP_BIN=$(find_mcp_binary)
    echo "✅ xiaohongshu-mcp 已安装: $MCP_BIN"

    if check_mcp_running; then
      echo "✅ MCP 服务运行中"
    else
      echo "⚠️ MCP 服务未运行"
    fi
    exit 0
  else
    echo "❌ xiaohongshu-mcp 未安装"
    exit 1
  fi
fi

# ==================== 检查是否需要安装 ====================

if [ "$FORCE" = false ] && find_mcp_binary > /dev/null 2>&1; then
  MCP_BIN=$(find_mcp_binary)
  echo "✅ xiaohongshu-mcp 已安装: $MCP_BIN"

  # 检查服务是否运行
  if check_mcp_running; then
    echo "✅ MCP 服务已在运行"
    exit 0
  fi

  # 服务未运行，尝试启动
  echo "⚠️ MCP 服务未运行，尝试启动..."
  cd "$INSTALL_DIR"
  nohup "$MCP_BIN" > "$INSTALL_DIR/mcp.log" 2>&1 &
  sleep 3

  if check_mcp_running; then
    echo "✅ MCP 服务已启动"
    echo "   日志: $INSTALL_DIR/mcp.log"
    exit 0
  else
    echo "❌ MCP 服务启动失败，查看日志: $INSTALL_DIR/mcp.log"
    exit 1
  fi
fi

# ==================== 安装流程 ====================

PLATFORM=$(detect_platform)
OS="${PLATFORM%-*}"

echo "🚀 开始安装 xiaohongshu-mcp..."
echo "   项目: https://github.com/${GITHUB_REPO}"
echo "   平台: ${PLATFORM}"
echo "   安装目录: ${INSTALL_DIR}"
echo ""

# 创建安装目录
mkdir -p "$INSTALL_DIR"

# 获取最新版本的下载链接
echo "🔍 获取最新版本信息..."

# 确定压缩包格式
if [ "$OS" = "windows" ]; then
  ARCHIVE_NAME="xiaohongshu-mcp-${PLATFORM}.zip"
else
  ARCHIVE_NAME="xiaohongshu-mcp-${PLATFORM}.tar.gz"
fi

# 尝试从 GitHub API 获取精确下载链接
DOWNLOAD_URL=""
if command -v python3 > /dev/null 2>&1; then
  RELEASE_JSON=$(curl -s --max-time 15 "$GITHUB_API" 2>/dev/null || echo "")
  if [ -n "$RELEASE_JSON" ]; then
    DOWNLOAD_URL=$(echo "$RELEASE_JSON" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    assets = data.get('assets', [])
    for a in assets:
        if '${ARCHIVE_NAME}' in a.get('name', ''):
            print(a['browser_download_url'])
            break
except:
    pass
" 2>/dev/null)
    VERSION=$(echo "$RELEASE_JSON" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('tag_name', 'unknown'))
except:
    print('unknown')
" 2>/dev/null)
  fi
fi

# 如果 API 方式失败，使用 latest redirect 方式
if [ -z "$DOWNLOAD_URL" ]; then
  DOWNLOAD_URL="https://github.com/${GITHUB_REPO}/releases/latest/download/${ARCHIVE_NAME}"
  VERSION="latest"
fi

echo "   版本: ${VERSION}"
echo "   下载: ${DOWNLOAD_URL}"
echo ""

# 下载
ARCHIVE_PATH="${INSTALL_DIR}/${ARCHIVE_NAME}"
echo "📥 下载中..."

if command -v wget > /dev/null 2>&1; then
  wget -q --show-progress -O "$ARCHIVE_PATH" "$DOWNLOAD_URL"
elif command -v curl > /dev/null 2>&1; then
  curl -L --progress-bar -o "$ARCHIVE_PATH" "$DOWNLOAD_URL"
else
  echo "❌ 需要 wget 或 curl 来下载文件"
  exit 1
fi

if [ ! -s "$ARCHIVE_PATH" ]; then
  echo "❌ 下载失败，文件为空"
  rm -f "$ARCHIVE_PATH"
  exit 1
fi

echo "✅ 下载完成"

# 解压
echo "📦 解压中..."
cd "$INSTALL_DIR"

if [ "$OS" = "windows" ]; then
  unzip -o "$ARCHIVE_PATH"
else
  tar -xzf "$ARCHIVE_PATH"
fi

rm -f "$ARCHIVE_PATH"

# 设置可执行权限
chmod +x "$INSTALL_DIR"/xiaohongshu-mcp* 2>/dev/null || true
chmod +x "$INSTALL_DIR"/xiaohongshu-login* 2>/dev/null || true

# 确认安装
MCP_BIN=""
if find_mcp_binary > /dev/null 2>&1; then
  MCP_BIN=$(find_mcp_binary)
  echo "✅ 安装成功: $MCP_BIN"
else
  # 如果找不到预期名称，查找任何 xiaohongshu-mcp 可执行文件
  MCP_BIN=$(find "$INSTALL_DIR" -name "xiaohongshu-mcp*" -type f -perm +111 2>/dev/null | head -1)
  if [ -n "$MCP_BIN" ]; then
    echo "✅ 安装成功: $MCP_BIN"
  else
    echo "❌ 安装失败：未找到可执行文件"
    echo "   安装目录内容:"
    ls -la "$INSTALL_DIR"
    exit 1
  fi
fi

# 安装 Python 依赖
echo ""
echo "📦 检查 Python 依赖..."
if command -v python3 > /dev/null 2>&1; then
  python3 -c "import requests" 2>/dev/null || {
    echo "   安装 requests..."
    pip3 install requests --quiet 2>/dev/null || pip install requests --quiet 2>/dev/null || true
  }
  echo "✅ Python 依赖就绪"
else
  echo "⚠️ Python3 未安装，部分功能（生图脚本）可能不可用"
fi

# 启动 MCP 服务
echo ""
echo "🚀 启动 MCP 服务..."

# Linux 环境下检查/启动 Xvfb
if [ "$OS" = "linux" ]; then
  if ! pgrep -x Xvfb > /dev/null 2>&1; then
    if command -v Xvfb > /dev/null 2>&1; then
      echo "   启动 Xvfb..."
      Xvfb :99 -screen 0 1920x1080x24 > /dev/null 2>&1 &
      sleep 1
      export DISPLAY=:99
    else
      echo "⚠️ Xvfb 未安装（登录功能可能受限）"
      echo "   安装: sudo apt install xvfb (Ubuntu) / sudo yum install xorg-x11-server-Xvfb (CentOS)"
    fi
  else
    export DISPLAY=:99
  fi
fi

cd "$INSTALL_DIR"
nohup "$MCP_BIN" > "$INSTALL_DIR/mcp.log" 2>&1 &
MCP_PID=$!
sleep 3

if check_mcp_running; then
  echo "✅ MCP 服务已启动 (PID: $MCP_PID)"
  echo "   日志: $INSTALL_DIR/mcp.log"
  echo "   地址: $MCP_URL"
else
  echo "⚠️ MCP 服务可能启动失败，请检查日志:"
  echo "   tail -20 $INSTALL_DIR/mcp.log"
fi

echo ""
echo "================================================"
echo "✅ xiaohongshu-mcp 安装完成！"
echo ""
echo "📌 项目地址: https://github.com/${GITHUB_REPO}"
echo "📂 安装目录: ${INSTALL_DIR}"
echo "🌐 MCP 地址: ${MCP_URL}"
echo ""
echo "📖 下一步:"
echo "   1. 如果首次使用，需要登录小红书（扫码登录）"
echo "   2. 设置生图 API Key（如 export ARK_API_KEY=xxx）"
echo "================================================"
