OpenWrt-dist LuCI
===

APP 列表
---
 > [下载预编译 IPK][0]  

 Name                      | Depends                  | Description
 --------------------------|--------------------------|----------------------------------------
 luci-app-chinadns         | [openwrt-chinadns][5]    | LuCI Support for ChinaDNS
 luci-app-redsocks2        | [openwrt-redsocks2][R]   | LuCI Support for RedSocks2
 luci-app-shadowvpn        | [openwrt-shadowvpn][8]   | LuCI Support for ShadowVPN
 luci-app-shadowsocks-spec | [openwrt-shadowsocks][7] | LuCI Support for shadowsocks-libev-spec

编译说明
---
 > 从 OpenWrt 的 [SDK][S] 编译  

```bash
# 解压下载好的 SDK
tar xjf OpenWrt-SDK-ar71xx-for-linux-x86_64-gcc-4.8-linaro_uClibc-0.9.33.2.tar.bz2
cd OpenWrt-SDK-ar71xx-*
# Clone 项目
git clone https://github.com/aa65535/openwrt-dist-luci.git package/openwrt-dist-luci
# 编译 po2lmo (如果有po2lmo可跳过)
pushd package/openwrt-dist-luci/tools/po2lmo
make && sudo make install
popd
# 选择要编译的包 LuCI -> 3. Applications
make menuconfig
# 开始编译
make package/openwrt-dist-luci/compile V=99
```


  [0]: https://github.com/aa65535/openwrt-dist-luci/releases
  [5]: https://github.com/aa65535/openwrt-chinadns
  [7]: https://github.com/shadowsocks/openwrt-shadowsocks
  [8]: https://github.com/aa65535/openwrt-shadowvpn
  [R]: https://github.com/aa65535/openwrt-redsocks2
  [S]: http://wiki.openwrt.org/doc/howto/obtain.firmware.sdk
