#!/bin/bash
set -e

# ========== DTS补丁 红米AX5魔改1G内存、512M闪存 ==========
patch -p1 <<'PATCH'
--- a/target/linux/qualcommax/files/ipq6018.dtsi
+++ b/target/linux/qualcommax/files/ipq6018.dtsi
@@ -10,7 +10,7 @@
         memory@40000000 {
                 device_type = "memory";
                 reg = <0x0 0x40000000 0x0 0x20000000>;
-                reg = <0x0 0x40000000 0x0 0x08000000>;
+                reg = <0x0 0x40000000 0x0 0x40000000>;
         };
PATCH

# ========== Argon左上角标题改为 TikTok-wrt ==========
sed -i 's|<%=dmi.get("product_name")%>|TikTok-wrt|g' feeds/luci-theme-argon/luci-theme-argon/htdocs/luci-static/argon/layout/header.htm
sed -i 's|OpenWrt|TikTok-wrt 业务专用防关联软路由|g' package/base-files/files/etc/openwrt_release

# ========== 浏览器标签标题 ==========
sed -i 's|document.title="OpenWrt"|document.title="TikTok-wrt"|g' feeds/luci-theme-argon/luci-theme-argon/htdocs/luci-static/argon/js/app.js
