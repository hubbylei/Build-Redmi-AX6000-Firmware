#!/bin/bash

git clone https://github.com/pymumu/openwrt-smartdns package/custom/smartdns
git clone https://github.com/pymumu/luci-app-smartdns -b master package/custom/luci-app-smartdns
git clone https://github.com/xiaorouji/openwrt-passwall -b main package/custom/luci-app-passwall
git clone https://github.com/xiaorouji/openwrt-passwall-packages -b main package/custom/openwrt-passwall
git clone https://github.com/tty228/luci-app-wechatpush -b master package/custom/luci-app-wechatpush
git clone https://github.com/hubbylei/openssl package/custom/openssl
git clone https://github.com/hubbylei/wrtbwmon -b master package/custom/wrtbwmon
git clone https://github.com/coolsnowwolf/packages -b master tmp/packages
