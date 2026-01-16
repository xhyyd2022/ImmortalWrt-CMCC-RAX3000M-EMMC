#!/bin/bash
#=================================================
# Description: DIY script (After first running make)
#=================================================

echo "===== diy-part2.sh 开始执行 ====="
echo "执行时间：$(date '+%Y-%m-%d %H:%M:%S %Z')"

# ── 1. 修改 LAN 默认 IP ───────────────────────────────────────────────
CONFIG_FILE="package/base-files/files/bin/config_generate"

if [[ -f "$CONFIG_FILE" ]]; then
    if grep -q "192\.168\.2\.1" "$CONFIG_FILE"; then
        echo "LAN IP 已是 192.168.2.1，无需修改"
    else
        echo "修改 LAN 默认 IP → 192.168.2.1 ..."
        sed -i \
            -e 's/192\.168\.1\.1/192.168.2.1/g' \
            -e 's/192\.168\.6\.1/192.168.2.1/g' \
            -e 's/192\.168\.0\.1/192.168.2.1/g' \
            -e 's/192\.168\.100\.1/192.168.2.1/g' \
            "$CONFIG_FILE" 2>/dev/null || echo "  sed 执行出现问题"
    fi
else
    echo "⚠️  未找到 config_generate，跳过 IP 修改"
fi

# ── 2. ccache 状态报告 ────────────────────────────────────────────────
echo -e "\n=== ccache 状态报告 ==="

if ! command -v ccache &>/dev/null; then
    echo "ccache 未找到或不在 PATH 中"
    echo "PATH 中包含 ccache 的路径："
    echo "$PATH" | tr ':' '\n' | grep -i ccache || echo "  （无）"
else
    echo "ccache 已启用"
    echo "  版本     : $(ccache --version | head -n1)"
    echo "  CCACHE_DIR: ${CCACHE_DIR:-未设置}"
    echo "  which     : $(which ccache)"
    echo "  CC        : ${CC:-未设置}"
    echo "  CXX       : ${CXX:-未设置}"

    echo -e "\n→ 统计概览（前 30 行）"
    ccache -s 2>/dev/null | sed '/^$/d' | head -n 30 || echo "  （获取统计失败）"

    echo -e "\n→ 缓存目录占用"
    CACHE_DIR="${CCACHE_DIR:-$HOME/.cache/ccache}"
    if [[ -d "$CACHE_DIR" && -w "$CACHE_DIR" ]]; then
        echo "  总大小：$(du -sh "$CACHE_DIR" 2>/dev/null || echo '无法读取')"
        du -h --max-depth=1 "$CACHE_DIR" 2>/dev/null | sort -hr | head -n 8 || true
    else
        echo "  缓存目录不存在或无权限"
    fi

    echo -e "\n→ 命中率评估"
    if hit_rate=$(ccache -s 2>&1 | grep -o '[0-9]\+\.[0-9]\+%' | head -1); then
        echo "   当前命中率：$hit_rate"
        rate=${hit_rate%\%}
        if (( rate >= 75 )); then
            echo "   🎉 非常优秀（≥75%）"
        elif (( rate >= 55 )); then
            echo "   ✅ 良好（55~74%）"
        elif (( rate >= 30 )); then
            echo "   ⚡ 正常范围（30~54%，继续积累会更好）"
        else
            echo "   🔄 首次编译 / 缓存刚建立 / 大量源码变更（正常现象）"
        fi
    else
        echo "   暂无有效命中率数据"
    fi
fi

echo -e "\n===== diy-part2.sh 执行结束 ====="
echo ""