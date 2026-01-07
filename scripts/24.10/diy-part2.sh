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
  echo "$EEPROM_FILE 不存在，跳过创建符号链接"
fi

# 兼容cmcc rax3000m 和 cmcc rax3000m-emmc（当前目录是 openwrt/）
echo "当前工作目录: $(pwd)"
FILE="target/linux/mediatek/image/filogic.mk"

if [ -f "$FILE" ]; then
  echo "找到文件: $FILE"

  echo "----- 修改前 SUPPORTED_DEVICES -----"
  grep -n "SUPPORTED_DEVICES" "$FILE"

  # 兼容 cmcc,rax3000m
  sed -i 's/SUPPORTED_DEVICES += cmcc,rax3000m-emmc/SUPPORTED_DEVICES += cmcc,rax3000m cmcc,rax3000m-emmc/' "$FILE"

  echo "----- 修改后 SUPPORTED_DEVICES -----"
  grep -n "SUPPORTED_DEVICES" "$FILE"

  echo "----- 修改 sysupgrade 格式为 FIT (.itb) -----"

  # 删除旧的 sysupgrade.bin 定义
  sed -i '/IMAGE\/sysupgrade.bin/d' "$FILE"

  # 添加新的 sysupgrade.itb 定义
  sed -i '/define Device\/cmcc_rax3000m-emmc-mtk/a\  IMAGE\/sysupgrade.itb := fit-image' "$FILE"

  echo "----- 修改后 sysupgrade 定义 -----"
  grep -n "sysupgrade" "$FILE"

  echo "已成功将 sysupgrade 格式改为 .itb（FIT）"
else
  echo "❌ 未找到文件: $FILE"
fi

echo "===== diy-part2.sh 执行结束 ====="
