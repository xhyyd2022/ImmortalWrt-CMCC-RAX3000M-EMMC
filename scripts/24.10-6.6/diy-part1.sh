#!/bin/bash
#
# 版权所有 (c) 2019-2020 P3TERX <https://p3terx.com>
#
# 这是一个自由软件，遵循 MIT 许可证。
# 更多信息请见 /LICENSE 文件。
#
# https://github.com/P3TERX/Actions-OpenWrt
# 文件名: diy-part1.sh
# 描述: OpenWrt DIY 脚本第一部分 (更新 feeds 之前)


echo ">>> 注入 IPVS 内核配置"

CONFIG_PATH="target/linux/mediatek/filogic/config-6.6"

cat <<EOF >> "$CONFIG_PATH"
CONFIG_IP_VS=y
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_RR=y
CONFIG_IP_VS_NFCT=y
EOF

echo ">>> IPVS 内核配置已注入到 $CONFIG_PATH"
