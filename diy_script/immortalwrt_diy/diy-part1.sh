#!/bin/bash
#
# Copyright (c) 2019-2025 SmallProgram <https://github.com/smallprogram>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/smallprogram/OpenWrtAction
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$CURRENT_DIR")"
source "$PARENT_DIR/custom_feeds_and_packages.sh"

# ---------------------------------------------------------------feeds update---------------------------------------------------------------
# 备份原始 feeds.conf.default
cp -a feeds.conf.default feeds.conf.default.bak

# 删除 feeds.conf.default 中的注释行（以 # 开头）
sed -i '/^#/d' feeds.conf.default
sed -i -e 's|git.openwrt.org/feed|github.com/openwrt|g' -e 's|git.openwrt.org/project|github.com/openwrt|g' feeds.conf.default


# 创建临时文件
temp_file=$(mktemp)

# 倒序遍历 repos 数组
for ((i=${#repos[@]}-1; i>=0; i--)); do
  repo="${repos[$i]}"
  # 提取 feed 名称（src-git 后的第一个字段）
  feed_name=$(echo "$repo" | awk '{print $2}')
  
  # 检查 feeds.conf.default 是否包含该 feed 名称
  if ! grep -q "src-git $feed_name " feeds.conf.default; then
    # 如果不存在，将该 repo 插入到临时文件的第一行
    echo "$repo" > "$temp_file"
    cat feeds.conf.default >> "$temp_file"
    mv "$temp_file" feeds.conf.default
    echo "Added: $repo"
  else
    echo "Skipped (already exists): $repo"
  fi
done

# 清理临时文件（如果仍然存在）
[ -f "$temp_file" ] && rm "$temp_file"

echo "Updated feeds.conf.default"
# ---------------------------------------------------------------end feeds update---------------------------------------------------------------

clone_custom_packages
# 替换红米AX5 DTS，适配魔改1G内存 + 512闪存分区
cat > target/linux/qualcommax/ipq60xx/dts/ipq6018-redmi-router-ax5.dts <<'EOF'
#include "ipq6018.dtsi"
/ {
	aliases {
		bootargs-overlay = &bootargs;
	};
};
&nand {
	status = "okay";
	partitions {
		compatible = "fixed-partitions";
		#address-cells = <1>;
		#size-cells = <1>;
		partition@0 {
			label = "SBL1";
			reg = <0x00000000 0x00040000>;
			read-only;
		};
		partition@40000 {
			label = "MIBIB";
			reg = <0x00040000 0x00040000>;
			read-only;
		};
		partition@80000 {
			label = "QSEE";
			reg = <0x00080000 0x00140000>;
			read-only;
		};
		partition@1c0000 {
			label = "QSEE_HOB";
			reg = <0x001c0000 0x00040000>;
			read-only;
		};
		partition@200000 {
			label = "CDT";
			reg = <0x00200000 0x00040000>;
			read-only;
		};
		partition@240000 {
			label = "DDRPARAMS";
			reg = <0x00240000 0x00040000>;
			read-only;
		};
		partition@280000 {
			label = "APPSBLENV";
			reg = <0x00280000 0x00040000>;
			read-only;
		};
		partition@2c0000 {
			label = "APPSBL";
			reg = <0x002c0000 0x00380000>;
			read-only;
		};
		partition@640000 {
			label = "APPSBL_HOB";
			reg = <0x00640000 0x00040000>;
			read-only;
		};
		partition@680000 {
			label = "ART";
			reg = <0x00680000 0x00040000>;
			read-only;
		};
		partition@6c0000 {
			label = "ubi";
			reg = <0x006c0000 0x1d400000>;
		};
	};
};
EOF
