
# Add-Packages.sh
#UPDATE_PACKAGE "包名" "项目地址" "项目分支" "pkg/name，可选，pkg为从大杂烩中单独提取包名插件；name为重命名为包名"
echo 'Load Diy Packages'
#UPDATE_PACKAGE "luci-app-tailscale" "asvow/luci-app-tailscale" "main"
UPDATE_PACKAGE "netspeedtest" "sirpdboy/netspeedtest" "master" "netspeedtest"
#UPDATE_PACKAGE "luci-app-netspeedtest" "sirpdboy/netspeedtest" "master" "luci-app-netspeedtest"
