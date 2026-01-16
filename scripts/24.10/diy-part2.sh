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

echo -e "\n===== diy-part2.sh 执行结束 ====="
echo ""