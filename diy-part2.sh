#!/bin/bash

del_data="
feeds/luci/applications/luci-app-passwall
feeds/luci/applications/luci-app-wechatpush
feeds/luci/applications/luci-app-smartdns
feeds/luci/applications/luci-app-serverchan
feeds/packages/net/brook
feeds/packages/net/dns2socks
feeds/packages/net/microsocks
feeds/packages/net/pdnsd-alt
feeds/packages/net/v2ray-geodata
feeds/packages/net/naiveproxy
feeds/packages/net/shadowsocks-rust
feeds/packages/net/shadowsocksr-libev
feeds/packages/net/simple-obfs
feeds/packages/net/sing-box
feeds/packages/net/tcping
feeds/packages/net/trojan
feeds/packages/net/trojan-go
feeds/packages/net/trojan-plus
feeds/packages/net/v2ray-core
feeds/packages/net/v2ray-plugin
feeds/packages/net/xray-plugin
feeds/packages/net/chinadns-ng
feeds/packages/net/dns2tcp
feeds/packages/net/tcping
feeds/packages/net/hysteria
feeds/packages/net/tuic-client
feeds/packages/net/smartdns
feeds/packages/net/ipt2socks
feeds/packages/net/xray-core
feeds/packages/net/cdnspeedtest
feeds/packages/lang/golang
feeds/packages/devel/gn
package/libs/openssl
package/network/utils/iptables
package/network/services/dnsmasq
target/linux/mediatek/patches-5.4/0504-macsec-revert-async-support.patch
target/linux/mediatek/patches-5.4/0005-dts-mt7622-add-gsw.patch
target/linux/mediatek/patches-5.4/0993-arm64-dts-mediatek-Split-PCIe-node-for-MT2712-MT7622.patch
target/linux/mediatek/patches-5.4/1024-pcie-add-multi-MSI-support.patch
"

for cmd in $del_data;
do
 rm -rf $cmd
 echo "Deleted $cmd"
done

cp -rf tmp/packages/lang/golang feeds/packages/lang/
cp -rf tmp/packages/lang/rust feeds/packages/lang/
cp -rf tmp/lede/package/network/services/dnsmasq package/network/services/
rm package/kernel/linux/modules/netfilter.mk
cp ${GITHUB_WORKSPACE}/modules/netfilter.mk package/kernel/linux/modules/netfilter.mk
rm include/kernel-5.4
cp tmp/lede/include/kernel-5.4 include/kernel-5.4

# ssh
sed -i '/sed -r -i/a\\tsed -i "s,#Port 22,Port 22,g" $(1)\/etc\/ssh\/sshd_config\n\tsed -i "s,#ListenAddress 0.0.0.0,ListenAddress 0.0.0.0,g" $(1)\/etc\/ssh\/sshd_config\n\tsed -i "s,#PermitRootLogin prohibit-password,PermitRootLogin yes,g" $(1)\/etc\/ssh\/sshd_config' feeds/packages/net/openssh/Makefile

# vlmcsd
VLMCSD_VER=$(echo -n `curl -sL https://api.github.com/repos/Wind4/vlmcsd/commits | jq -r .[0].commit.committer.date | awk -F "T" '{print $1}' | sed 's/\-/\./g'`)
VLMCSD_SHA=$(echo -n `curl -sL https://api.github.com/repos/Wind4/vlmcsd/commits | jq -r .[0].sha`)
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='"$VLMCSD_VER"'/g' feeds/packages/net/vlmcsd/Makefile
sed -i 's/PKG_RELEASE:=3/PKG_RELEASE:=1/g' feeds/packages/net/vlmcsd/Makefile
sed -i 's/PKG_SOURCE:=.*/PKG_SOURCE_PROTO:=git/g' feeds/packages/net/vlmcsd/Makefile
sed -i 's/PKG_SOURCE_URL:=.*/PKG_SOURCE_URL:=https:\/\/github.com\/Wind4\/vlmcsd/g' feeds/packages/net/vlmcsd/Makefile
sed -i 's/PKG_HASH:=.*/PKG_SOURCE_VERSION:='"${VLMCSD_SHA}"'/g' feeds/packages/net/vlmcsd/Makefile
sed -i 's/;Listen = 0.0.0.0:1688/Listen = 0.0.0.0:1688/g' feeds/packages/net/vlmcsd/files/vlmcsd.ini
echo -e "\n#Windows 10/ Windows 11 KMS 安装激活密钥\n#Windows 10/11 Pro：W269N-WFGWX-YVC9B-4J6C9-T83GX\n#Windows 10/11 Enterprise：NPPR9-FWDCX-D2C8J-H872K-2YT43\n#Windows 10/11 Pro for Workstations：NRG8B-VKK3Q-CXVCJ-9G2XF-6Q84J\n" >> feeds/packages/net/vlmcsd/files/vlmcsd.ini
sed -i 's/ -L \[::\]:1688//g' feeds/luci/applications/luci-app-vlmcsd/root/etc/init.d/kms

# v2ray-geodata
GEOIP_VER=$(echo -n `curl -sL https://api.github.com/repos/Loyalsoldier/v2ray-rules-dat/releases/latest | jq -r .tag_name`)
GEOIP_HASH=$(echo -n `curl -sL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/$GEOIP_VER/geoip.dat.sha256sum | awk '{print $1}'`)
GEOSITE_VER=$GEOIP_VER
GEOSITE_HASH=$(echo -n `curl -sL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/$GEOSITE_VER/geosite.dat.sha256sum | awk '{print $1}'`)
sed -i '/HASH:=/d' package/custom/passwall-packages/v2ray-geodata/Makefile

sed -i 's/GEOIP_VER:=.*/GEOIP_VER:='"$GEOIP_VER"'/g' package/custom/passwall-packages/v2ray-geodata/Makefile
sed -i 's/https:\/\/github.com\/v2fly\/geoip/https:\/\/github.com\/Loyalsoldier\/v2ray-rules-dat/g' package/custom/passwall-packages/v2ray-geodata/Makefile
sed -i '/FILE:=$(GEOIP_FILE)/a\\tHASH:='"$GEOIP_HASH"'' package/custom/passwall-packages/v2ray-geodata/Makefile

sed -i 's/https:\/\/github.com\/v2fly\/domain-list-community/https:\/\/github.com\/Loyalsoldier\/v2ray-rules-dat/g' package/custom/passwall-packages/v2ray-geodata/Makefile
sed -i 's/GEOSITE_VER:=.*/GEOSITE_VER:='"$GEOSITE_VER"'/g' package/custom/passwall-packages/v2ray-geodata/Makefile
sed -i 's/dlc.dat/geosite.dat/g' package/custom/passwall-packages/v2ray-geodata/Makefile
sed -i '/FILE:=$(GEOSITE_FILE)/a\\tHASH:='"$GEOSITE_HASH"'' package/custom/passwall-packages/v2ray-geodata/Makefile

sed -i 's/URL:=https:\/\/www.v2fly.org/URL:=https:\/\/github.com\/Loyalsoldier\/v2ray-rules-dat/g' package/custom/passwall-packages/v2ray-geodata/Makefile

# smartdns
SMARTDNS_JSON=$(curl -sL https://api.github.com/repos/pymumu/smartdns/commits)
SMARTDNS_VER=$(echo -n `echo ${SMARTDNS_JSON} | jq -r .[0].commit.committer.date | awk -F "T" '{print $1}' | sed 's/\-/\./g'`)
SMAERTDNS_SHA=$(echo -n `echo ${SMARTDNS_JSON} | jq -r .[0].sha`)

sed -i '/PKG_MIRROR_HASH:=/d' package/custom/smartdns/Makefile
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='"$SMARTDNS_VER"'/g' package/custom/smartdns/Makefile
sed -i 's/PKG_SOURCE_VERSION:=.*/PKG_SOURCE_VERSION:='"$SMAERTDNS_SHA"'/g' package/custom/smartdns/Makefile
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='"$SMARTDNS_VER"'/g' package/custom/luci-app-smartdns/Makefile
sed -i 's/href = "smartdns"/href = "\/cgi-bin\/luci\/admin\/services\/smartdns"/g' package/custom/luci-app-smartdns/htdocs/luci-static/resources/view/smartdns/log.js
sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' package/custom/luci-app-smartdns/Makefile

# default-settings
Build_Date=R`date "+%y.%m.%d"`
sed -i '/exit 0/i\sed -i "s\/DISTRIB_REVISION=.*\/DISTRIB_REVISION='"'${Build_Date}'"'\/g" \/etc\/openwrt_release' package/emortal/default-settings/files/99-default-settings
sed -i '/exit 0/i\sed -i "s\/DISTRIB_DESCRIPTION=.*\/DISTRIB_DESCRIPTION='"'ImmortalWrt ${Build_Date} '"'\/g" \/etc\/openwrt_release\n' package/emortal/default-settings/files/99-default-settings
sed -i '/exit 0/i\echo "vm.min_free_kbytes=65536" > \/etc\/sysctl.d\/11-nf-conntrack-max.conf' package/emortal/default-settings/files/99-default-settings
sed -i '/exit 0/i\echo "net.netfilter.nf_conntrack_max=65535" >> \/etc\/sysctl.d\/11-nf-conntrack-max.conf' package/emortal/default-settings/files/99-default-settings
