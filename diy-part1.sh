#!/bin/bash

git clone --filter=blob:none --depth 1 --single-branch https://github.com/pymumu/openwrt-smartdns package/custom/smartdns
git clone --filter=blob:none --depth 1 --single-branch https://github.com/pymumu/luci-app-smartdns -b master package/custom/luci-app-smartdns
git clone --filter=blob:none --depth 1 --single-branch https://github.com/xiaorouji/openwrt-passwall -b main package/custom/luci-app-passwall
git clone --filter=blob:none --depth 1 --single-branch https://github.com/xiaorouji/openwrt-passwall-packages -b main package/custom/passwall-packages
git clone --filter=blob:none --depth 1 --single-branch https://github.com/tty228/luci-app-wechatpush -b master package/custom/luci-app-wechatpush
git clone --filter=blob:none --depth 1 --single-branch https://github.com/hubbylei/wrtbwmon -b master package/custom/wrtbwmon
git clone --filter=blob:none --depth 1 --single-branch https://github.com/hubbylei/openwrt-cdnspeedtest -b master package/custom/openwrt-cdnspeedtest
git clone --filter=blob:none --depth 1 --single-branch https://github.com/hubbylei/luci-app-cloudflarespeedtest -b main package/custom/luci-app-cloudflarespeedtest
git clone --filter=blob:none --depth 1 --single-branch https://github.com/immortalwrt/packages -b openwrt-24.10 tmp/packages