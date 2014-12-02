OpenWrt-dist LuCI
===

APP 列表
---
 > 点击链接可下载预编译 IPK  

 Name                           | Description
 -------------------------------|-----------------------------------------------
 [luci-app-chinadns-c][1]       | LuCI configuration pages for ChinaDNS-C
 [luci-app-shadowsocks-spec][0] | LuCI configuration pages for shadowsocks-libev-spec
 [luci-app-shadowvpn][2] | LuCI configuration pages for ShadowVPN

适用项目
---
 > 默认不带相应的 UCI 配置文件, 需要搭配以下软件包使用  

 Name                     | Description
 -------------------------|-----------------------------------
 [openwrt-chinadns][5]    | OpenWrt's ChinaDNS-C Makefile
 [openwrt-shadowsocks][7] | OpenWrt's ShadowSocks Makefile
 [openwrt-shadowvpn][8]   | OpenWrt's ShadowVPN Makefile

编译说明
---
 > 从 OpenWrt 的 [SDK][S] 编译  

```bash
# luci-app 为全平台通用
tar xjf OpenWrt-SDK-ar71xx-for-linux-x86_64-gcc-4.8-linaro_uClibc-0.9.33.2.tar.bz2
cd OpenWrt-SDK-ar71xx-*
# 获取 Makefile
git clone https://github.com/aa65535/openwrt-dist-luci.git package/openwrt-dist-luci
# 选择要编译的包 LuCI -> 3. Applications
make menuconfig
# 开始编译
make V=99
```


  [0]: http://sourceforge.net/projects/openwrt-dist/files/luci-app/shadowsocks-spec/
  [1]: http://sourceforge.net/projects/openwrt-dist/files/luci-app/chinadns-c/
  [2]: http://sourceforge.net/projects/openwrt-dist/files/luci-app/shadowvpn/
  [5]: https://github.com/aa65535/openwrt-chinadns
  [7]: https://github.com/aa65535/openwrt-shadowsocks
  [8]: https://github.com/aa65535/openwrt-shadowvpn
  [S]: http://downloads.openwrt.org/snapshots/trunk/
