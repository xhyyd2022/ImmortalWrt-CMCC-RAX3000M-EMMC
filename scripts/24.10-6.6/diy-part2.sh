#!/bin/bash
#
# 版权所有 (c) 2019-2020 P3TERX <https://p3terx.com>
#
# 这是一个自由软件，根据 MIT 许可证授权。
# 详细信息请参见 /LICENSE。
#
# https://github.com/P3TERX/Actions-OpenWrt

echo "===== diy-part2.sh 开始执行 ====="

# 修改默认 IP
CONFIG_FILE="package/base-files/files/bin/config_generate"
if [ -f "$CONFIG_FILE" ]; then
  if ! grep -q "192.168.2.1" "$CONFIG_FILE"; then
    sed -i 's/192\.168\.6\.1/192.168.2.1/g; s/192\.168\.1\.1/192.168.2.1/g' "$CONFIG_FILE"
    echo "IP 地址已更新为 192.168.2.1"
  else
    echo "IP 地址已是 192.168.2.1，无需修改"
  fi
else
  echo "警告：$CONFIG_FILE 不存在，跳过 IP 修改"
fi

# 删除 package/mtk/drivers/mt_wifi/files/mt7981-default-eeprom/e2p
rm -f package/mtk/drivers/mt_wifi/files/mt7981-default-eeprom/e2p
if [ $? -eq 0 ]; then
  echo "已删除 package/mtk/drivers/mt_wifi/files/mt7981-default-eeprom/e2p"
else
  echo "错误：删除 package/mtk/drivers/mt_wifi/files/mt7981-default-eeprom/e2p 失败"
fi

# 创建 MT7981 固件符号链接
EEPROM_FILE="package/mtk/drivers/mt_wifi/files/mt7981-default-eeprom/MT7981_iPAiLNA_EEPROM.bin"
if [ -f "$EEPROM_FILE" ]; then
  mkdir -p files/lib/firmware
  ln -sf /lib/firmware/MT7981_iPAiLNA_EEPROM.bin files/lib/firmware/e2p
  echo "符号链接已创建"
  ls -l files/lib/firmware/e2p || { echo "错误：符号链接创建失败"; exit 1; }
else
  echo "错误：$EEPROM_FILE 不存在，无法创建符号链接"
  exit 1
fi

# 兼容cmcc rax3000m 和 cmcc rax3000m-emmc（当前目录是 openwrt/）
echo "当前工作目录: $(pwd)"
echo "准备修改 SUPPORTED_DEVICES 兼容 cmcc,rax3000m"

FILE="target/linux/mediatek/image/filogic.mk"

# 检查文件是否存在
if [ -f "$FILE" ]; then
  echo "找到文件: $FILE"
  echo "----- 修改前内容（grep）-----"
  grep -n "SUPPORTED_DEVICES" "$FILE" || echo "未找到 SUPPORTED_DEVICES 字段"

  # 执行替换
  sed -i 's/SUPPORTED_DEVICES += cmcc,rax3000m-emmc/SUPPORTED_DEVICES += cmcc,rax3000m cmcc,rax3000m-emmc/' "$FILE"

  echo "----- 修改后内容（grep）-----"
  grep -n "SUPPORTED_DEVICES" "$FILE" || echo "未找到 SUPPORTED_DEVICES 字段"

  echo "已成功修改 SUPPORTED_DEVICES，兼容 cmcc,rax3000m"
else
  echo "❌ 未找到文件: $FILE"
  echo "请检查："
  echo "  1. diy-part2.sh 是否在 openwrt/ 目录下执行"
  echo "  2. filogic.mk 路径是否正确"
fi

echo "===== diy-part2.sh 执行结束 ====="
