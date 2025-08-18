#!/bin/bash

del_data="
feeds/packages/lang/golang
feeds/packages/lang/rust
target/linux/mediatek/patches-5.4/0504-macsec-revert-async-support.patch
target/linux/mediatek/patches-5.4/0005-dts-mt7622-add-gsw.patch
target/linux/mediatek/patches-5.4/0993-arm64-dts-mediatek-Split-PCIe-node-for-MT2712-MT7622.patch
target/linux/mediatek/patches-5.4/1024-pcie-add-multi-MSI-support.patch
"

for data in ${del_data};
do
    if [[ -d ${data} || -f ${data} ]];then
        rm -rf ${data}
        echo "Deleted ${data}"
    fi
done

cp -rf tmp/packages/lang/rust feeds/packages/lang/

# golang
git clone --depth 1 --single-branch https://github.com/sbwml/packages_lang_golang -b 25.x feeds/packages/lang/golang

# frp
FRP_VER=$(curl -sL https://api.github.com/repos/fatedier/frp/releases/latest | jq -r .name | sed 's/v//g')
curl -sL -o /tmp/frp-${FRP_VER}.tar.gz https://codeload.github.com/fatedier/frp/tar.gz/v${FRP_VER}
FRP_PKG_SHA=$(sha256sum /tmp/frp-${FRP_VER}.tar.gz | awk '{print $1}')
rm -rf /tmp/frp-${FRP_VER}.tar.gz

sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='${FRP_VER}'/g' feeds/packages/net/frp/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:='${FRP_PKG_SHA}'/g' feeds/packages/net/frp/Makefile
sed -i 's/\$(2)_full.ini/legacy\/\$(2)_legacy_full.ini/g' feeds/packages/net/frp/Makefile

# iptables
IMS=$(grep "iptables-mod-socket" package/network/utils/iptables/Makefile)
if [ -z "${IMS}" ];then
	echo "Add iptables-mod-socket"
    echo -e "\ndefine Package/iptables-mod-socket\n\$(call Package/iptables/Module, +kmod-ipt-socket)\n  TITLE:=Socket match iptables extensions\nendef\n\ndefine Package/iptables-mod-socket/description\nSocket match iptables extensions.\n\n Matches:\n  - socket\n\nendef\n\n\$(eval \$(call BuildPlugin,iptables-mod-socket,\$(IPT_SOCKET-m)))" >> package/network/utils/iptables/Makefile
fi

# netfilter.mk
IS=$(grep "ipt-socket" package/kernel/linux/modules/netfilter.mk)
NS=$(grep "nf-socket" package/kernel/linux/modules/netfilter.mk)
if [ -z "${IS}" ];then
	echo "Add ipt-socket"
    echo -e "\ndefine KernelPackage/ipt-socket\n  TITLE:=Iptables socket matching support\n  DEPENDS+=+kmod-nf-socket +kmod-nf-conntrack\n  KCONFIG:=\$(KCONFIG_IPT_SOCKET)\n  FILES:=\$(foreach mod,\$(IPT_SOCKET-m),\$(LINUX_DIR)/net/\$(mod).ko)\n  AUTOLOAD:=\$(call AutoProbe,\$(notdir \$(IPT_SOCKET-m)))\n  \$(call AddDepends/ipt)\nendef\n\ndefine KernelPackage/ipt-socket/description\n  Kernel modules for socket matching\nendef\n\n\$(eval \$(call KernelPackage,ipt-socket))" >> package/kernel/linux/modules/netfilter.mk
fi
if [ -z "${NS}" ];then
	echo "Add nf-socket"
    echo -e "\ndefine KernelPackage/nf-socket\n  SUBMENU:=\$(NF_MENU)\n  TITLE:=Netfilter socket lookup support\n  KCONFIG:= \$(KCONFIG_NF_SOCKET)\n  FILES:=\$(foreach mod,\$(NF_SOCKET-m),\$(LINUX_DIR)/net/\$(mod).ko)\n  AUTOLOAD:=\$(call AutoProbe,\$(notdir \$(NF_SOCKET-m)))\nendef\n\n\$(eval \$(call KernelPackage,nf-socket))" >> package/kernel/linux/modules/netfilter.mk
fi

# ssh
sed -i '/sed -r -i/a\\tsed -i "s,#Port 22,Port 22,g" $(1)\/etc\/ssh\/sshd_config\n\tsed -i "s,#ListenAddress 0.0.0.0,ListenAddress 0.0.0.0,g" $(1)\/etc\/ssh\/sshd_config\n\tsed -i "s,#PermitRootLogin prohibit-password,PermitRootLogin yes,g" $(1)\/etc\/ssh\/sshd_config' feeds/packages/net/openssh/Makefile

# vlmcsd
VLMCSD_JSON=$(curl -sL https://api.github.com/repos/Wind4/vlmcsd/commits)
VLMCSD_SHA=$(echo ${VLMCSD_JSON} | jq -r .[0].sha)

curl -sL -o /tmp/vlmcsd-${VLMCSD_SHA}.tar.gz https://codeload.github.com/Wind4/vlmcsd/tar.gz/${VLMCSD_SHA}
VLMCSD_PKG_SHA=$(sha256sum /tmp/vlmcsd-${VLMCSD_SHA}.tar.gz | awk '{print $1}')
rm -rf /tmp/vlmcsd-${VLMCSD_SHA}.tar.gz

sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='${VLMCSD_SHA}'/g' feeds/packages/net/vlmcsd/Makefile
sed -i 's/PKG_RELEASE:=3/PKG_RELEASE:=1/g' feeds/packages/net/vlmcsd/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:='${VLMCSD_PKG_SHA}'/g' feeds/packages/net/vlmcsd/Makefile
sed -i 's/;Listen = 0.0.0.0:1688/Listen = 0.0.0.0:1688/g' feeds/packages/net/vlmcsd/files/vlmcsd.ini
sed -i 's/ -L \[::\]:1688//g' feeds/luci/applications/luci-app-vlmcsd/root/etc/init.d/kms
echo -e "\n#Windows 10/ Windows 11 KMS 安装激活密钥\n#Windows 10/11 Pro：W269N-WFGWX-YVC9B-4J6C9-T83GX\n#Windows 10/11 Enterprise：NPPR9-FWDCX-D2C8J-H872K-2YT43\n#Windows 10/11 Pro for Workstations：NRG8B-VKK3Q-CXVCJ-9G2XF-6Q84J\n" >> feeds/packages/net/vlmcsd/files/vlmcsd.ini

# v2ray-geodata
GEOIP_VER=$(echo -n `curl -sL https://api.github.com/repos/Loyalsoldier/v2ray-rules-dat/releases/latest | jq -r .tag_name`)
GEOIP_HASH=$(echo -n `curl -sL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/$GEOIP_VER/geoip.dat.sha256sum | awk '{print $1}'`)
GEOSITE_VER=$GEOIP_VER
GEOSITE_HASH=$(echo -n `curl -sL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/$GEOSITE_VER/geosite.dat.sha256sum | awk '{print $1}'`)

sed -i '/HASH:=/d' package/custom/passwall-packages/v2ray-geodata/Makefile
sed -i 's/Loyalsoldier\/geoip/Loyalsoldier\/v2ray-rules-dat/g' package/custom/passwall-packages/v2ray-geodata/Makefile
sed -i 's/GEOIP_VER:=.*/GEOIP_VER:='"$GEOIP_VER"'/g' package/custom/passwall-packages/v2ray-geodata/Makefile
sed -i '/FILE:=$(GEOIP_FILE)/a\ HASH:='"$GEOIP_HASH"'' package/custom/passwall-packages/v2ray-geodata/Makefile
sed -i 's/GEOSITE_VER:=.*/GEOSITE_VER:='"$GEOSITE_VER"'/g' package/custom/passwall-packages/v2ray-geodata/Makefile
sed -i '/FILE:=$(GEOSITE_FILE)/a\ HASH:='"$GEOSITE_HASH"'' package/custom/passwall-packages/v2ray-geodata/Makefile

sed -i 's/URL:=https:\/\/www.v2fly.org/URL:=https:\/\/github.com\/Loyalsoldier\/v2ray-rules-dat/g' package/custom/passwall-packages/v2ray-geodata/Makefile

# smartdns
SMARTDNS_JSON=$(curl -sL -H "${headers}" https://api.github.com/repos/pymumu/smartdns/commits)
SMARTDNS_VER=$(echo ${SMARTDNS_JSON} | jq -r .[0].commit.committer.date | awk -F "T" '{print $1}')
SMARTDNS_SHA=$(echo ${SMARTDNS_JSON} | jq -r .[0].sha)

curl -sL -o /tmp/smartdns-${SMARTDNS_SHA}.tar.gz https://codeload.github.com/pymumu/smartdns/tar.gz/${SMARTDNS_SHA}
SMARTDNS_PKG_SHA=$(sha256sum /tmp/smartdns-${SMARTDNS_SHA}.tar.gz | awk '{print $1}')
rm -rf /tmp/smartdns-${SMARTDNS_SHA}.tar.gz

sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='${SMARTDNS_SHA}'/g' package/custom/smartdns/Makefile
sed -i 's/PKG_SOURCE_PROTO:=git/PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz/g' package/custom/smartdns/Makefile
sed -i 's/PKG_SOURCE_URL:=.*/PKG_SOURCE_URL:=https:\/\/codeload.github.com\/pymumu\/smartdns\/tar.gz\/$(PKG_VERSION)?/g' package/custom/smartdns/Makefile
sed -i '/PKG_SOURCE_VERSION:=.*/d' package/custom/smartdns/Makefile
sed -i 's/PKG_MIRROR_HASH:=.*/PKG_HASH:='${SMARTDNS_PKG_SHA}'/g' package/custom/smartdns/Makefile
sed -i 's/..\/..\/lang/$(TOPDIR)\/feeds\/packages\/lang/g' package/custom/smartdns/Makefile
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='${SMARTDNS_VER}'/g' package/custom/luci-app-smartdns/Makefile
sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' package/custom/luci-app-smartdns/Makefile

# default-settings
Build_Date=R`date "+%y.%m.%d"`
sed -i '/exit 0/i\sed -i "s\/DISTRIB_REVISION=.*\/DISTRIB_REVISION='"'${Build_Date}'"'\/g" \/etc\/openwrt_release' package/emortal/default-settings/files/99-default-settings
sed -i '/exit 0/i\sed -i "s\/DISTRIB_DESCRIPTION=.*\/DISTRIB_DESCRIPTION='"'IWRT ${Build_Date} '"'\/g" \/etc\/openwrt_release\n' package/emortal/default-settings/files/99-default-settings
sed -i '/exit 0/i\echo "vm.min_free_kbytes=65536" > \/etc\/sysctl.d\/11-nf-conntrack-max.conf' package/emortal/default-settings/files/99-default-settings
sed -i '/exit 0/i\echo "net.netfilter.nf_conntrack_max=65535" >> \/etc\/sysctl.d\/11-nf-conntrack-max.conf' package/emortal/default-settings/files/99-default-settings

# Lan IP
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate
