#
# Copyright (C) 2014 OpenWrt-dist
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=openwrt-dist-luci
PKG_VERSION:=1.1.2
PKG_RELEASE:=1

PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=aa65535 <aa65535@live.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/openwrt-dist-luci/Default
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=$(1) for LuCI
	PKGARCH:=all
endef

Package/luci-app-shadowvpn = $(call Package/openwrt-dist-luci/Default,ShadowVPN)
Package/luci-app-chinadns-c = $(call Package/openwrt-dist-luci/Default,ChinaDNS-C)
Package/luci-app-shadowsocks-spec = $(call Package/openwrt-dist-luci/Default,shadowsocks-libev-spec)

define Package/openwrt-dist-luci/description
	This package contains LuCI configuration pages for $(1).
endef

Package/luci-app-shadowvpn/description = $(call Package/openwrt-dist-luci/description,ShadowVPN)
Package/luci-app-chinadns-c/description = $(call Package/openwrt-dist-luci/description,ChinaDNS-C)
Package/luci-app-shadowsocks-spec/description = $(call Package/openwrt-dist-luci/description,shadowsocks-libev-spec)

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/openwrt-dist-luci/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	( . /etc/uci-defaults/luci-$(1) ) && rm -f /etc/uci-defaults/luci-$(1)
	chmod 755 /etc/init.d/$(1) >/dev/null 2>&1
	/etc/init.d/$(1) enable >/dev/null 2>&1
fi
exit 0
endef

Package/luci-app-shadowvpn/postinst = $(call Package/openwrt-dist-luci/postinst,shadowvpn)
Package/luci-app-chinadns-c/postinst = $(call Package/openwrt-dist-luci/postinst,chinadns)
Package/luci-app-shadowsocks-spec/postinst = $(call Package/openwrt-dist-luci/postinst,shadowsocks)

define Package/openwrt-dist-luci/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./files/luci/controller/$(2).lua $(1)/usr/lib/lua/luci/controller/$(2).lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) ./files/luci/i18n/$(2).*.lmo $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./files/luci/model/cbi/$(2).lua $(1)/usr/lib/lua/luci/model/cbi/$(2).lua
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/root/etc/uci-defaults/luci-$(2) $(1)/etc/uci-defaults/luci-$(2)
endef

Package/luci-app-shadowvpn/install = $(call Package/openwrt-dist-luci/install,$(1),shadowvpn)
Package/luci-app-chinadns-c/install = $(call Package/openwrt-dist-luci/install,$(1),chinadns)
Package/luci-app-shadowsocks-spec/install = $(call Package/openwrt-dist-luci/install,$(1),shadowsocks)

$(eval $(call BuildPackage,luci-app-shadowvpn))
$(eval $(call BuildPackage,luci-app-chinadns-c))
$(eval $(call BuildPackage,luci-app-shadowsocks-spec))
