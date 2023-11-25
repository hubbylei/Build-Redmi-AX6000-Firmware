#!/bin/bash

del_data="
./feeds/luci/applications/luci-app-passwall
./feeds/luci/applications/luci-app-wechatpush
./feeds/luci/applications/luci-app-smartdns
./feeds/luci/applications/luci-app-serverchan
./feeds/packages/net/brook
./feeds/packages/net/dns2socks
./feeds/packages/net/microsocks
./feeds/packages/net/pdnsd-alt
./feeds/packages/net/v2ray-geodata
./feeds/packages/net/naiveproxy
./feeds/packages/net/shadowsocks-rust
./feeds/packages/net/shadowsocksr-libev
./feeds/packages/net/simple-obfs
./feeds/packages/net/sing-box
./feeds/packages/net/tcping
./feeds/packages/net/trojan
./feeds/packages/net/trojan-go
./feeds/packages/net/trojan-plus
./feeds/packages/net/v2ray-core
./feeds/packages/net/v2ray-plugin
./feeds/packages/net/xray-plugin
./feeds/packages/net/chinadns-ng
./feeds/packages/net/dns2tcp
./feeds/packages/net/tcping
./feeds/packages/net/hysteria
./feeds/packages/net/tuic-client
./feeds/packages/devel/gn
./feeds/packages/net/smartdns
./feeds/packages/net/ipt2socks
./feeds/packages/net/xray-core
./feeds/packages/lang/golang
./package/libs/openssl
./package/network/utils/iptables
"

for cmd in $del_data;
do
 	rm -rf $cmd
  echo "Deleted $cmd"
done

rm -rf target/linux/mediatek/patches-5.4/0504-macsec-revert-async-support.patch
Download_kernel(){
rm -rf ~/$DEVICE/include/kernel-5.4
wget -q https://raw.githubusercontent.com/coolsnowwolf/lede/master/include/kernel-5.4 -O include/kernel-5.4
tmp=`ls -l include/kernel-5.4 | awk '{print $5}'`
if [ $tmp == 0 ];then
    Download_kernel
fi
}
Download_kernel

sed -i '/sed -r -i/a\\tsed -i "s,#Port 22,Port 22,g" $(1)\/etc\/ssh\/sshd_config\n\tsed -i "s,#ListenAddress 0.0.0.0,ListenAddress 0.0.0.0,g" $(1)\/etc\/ssh\/sshd_config\n\tsed -i "s,#PermitRootLogin prohibit-password,PermitRootLogin yes,g" $(1)\/etc\/ssh\/sshd_config' feeds/packages/net/openssh/Makefile
sed -i 's/;Listen = 0.0.0.0:1688/Listen = 0.0.0.0:1688/g' feeds/packages/net/vlmcsd/files/vlmcsd.ini

GEOIP_VER=$(echo -n `curl -sL https://api.github.com/repos/Loyalsoldier/v2ray-rules-dat/releases/latest | jq .tag_name | sed 's/\"//g'`)
GEOIP_HASH=$(echo -n `curl -sL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/$GEOIP_VER/geoip.dat.sha256sum | awk '{print $1}'`)
GEOSITE_VER=$GEOIP_VER
GEOSITE_HASH=$(echo -n `curl -sL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/$GEOSITE_VER/geosite.dat.sha256sum | awk '{print $1}'`)
sed -i '/HASH:=/d' package/custom/openwrt-passwall/v2ray-geodata/Makefile

sed -i 's/GEOIP_VER:=.*/GEOIP_VER:='"$GEOIP_VER"'/g' package/custom/openwrt-passwall/v2ray-geodata/Makefile
sed -i 's/https:\/\/github.com\/v2fly\/geoip/https:\/\/github.com\/Loyalsoldier\/v2ray-rules-dat/g' package/custom/openwrt-passwall/v2ray-geodata/Makefile
sed -i '/FILE:=$(GEOIP_FILE)/a\\tHASH:='"$GEOIP_HASH"'' package/custom/openwrt-passwall/v2ray-geodata/Makefile

sed -i 's/https:\/\/github.com\/v2fly\/domain-list-community/https:\/\/github.com\/Loyalsoldier\/v2ray-rules-dat/g' package/custom/openwrt-passwall/v2ray-geodata/Makefile
sed -i 's/GEOSITE_VER:=.*/GEOSITE_VER:='"$GEOSITE_VER"'/g' package/custom/openwrt-passwall/v2ray-geodata/Makefile
sed -i 's/dlc.dat/geosite.dat/g' package/custom/openwrt-passwall/v2ray-geodata/Makefile
sed -i '/FILE:=$(GEOSITE_FILE)/a\\tHASH:='"$GEOSITE_HASH"'' package/custom/openwrt-passwall/v2ray-geodata/Makefile

sed -i 's/URL:=https:\/\/www.v2fly.org/URL:=https:\/\/github.com\/Loyalsoldier\/v2ray-rules-dat/g' package/custom/openwrt-passwall/v2ray-geodata/Makefile

SMARTDNS_VER=$(echo -n `curl -sL https://api.github.com/repos/pymumu/smartdns/commits | jq .[0].commit.committer.date | awk -F "T" '{print $1}' | sed 's/\"//g' | sed 's/\-/\./g'`)
SMAERTDNS_SHA=$(echo -n `curl -sL https://api.github.com/repos/pymumu/smartdns/commits | jq .[0].sha | sed 's/\"//g'`)
sed -i '/PKG_MIRROR_HASH:=/d' package/custom/smartdns/Makefile
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='"$SMARTDNS_VER"'/g' package/custom/smartdns/Makefile
sed -i 's/PKG_SOURCE_VERSION:=.*/PKG_SOURCE_VERSION:='"$SMAERTDNS_SHA"'/g' package/custom/smartdns/Makefile
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='"$SMARTDNS_VER"'/g' package/custom/luci-app-smartdns/Makefile
sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' package/custom/luci-app-smartdns/Makefile

Build_Date=R`date "+%y.%m.%d"`
sed -i '/exit 0/i\sed -i "s\/DISTRIB_REVISION=.*\/DISTRIB_REVISION='"'${Build_Date}'"'\/g" \/etc\/openwrt_release' package/emortal/default-settings/files/99-default-settings
sed -i '/exit 0/i\sed -i "s\/DISTRIB_DESCRIPTION=.*\/DISTRIB_DESCRIPTION='"'ImmortalWrt ${Build_Date} '"'\/g" \/etc\/openwrt_release\n' package/emortal/default-settings/files/99-default-settings

