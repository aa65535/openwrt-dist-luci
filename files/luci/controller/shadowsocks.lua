--[[
openwrt-dist-luci: ShadowSocks
]]--

module("luci.controller.shadowsocks", package.seeall)

function index()

	if not nixio.fs.access("/etc/config/shadowsocks") then
		return
	end

	local page
	page = node("admin", "services", "shadowsocks")
	page.target = firstchild()
	page.title = _("shadowsocks")
	page.order  = 65

	page = entry({"admin", "services", "shadowsocks"}, cbi("shadowsocks"), _("shadowsocks"), 45)
	page.i18n = "shadowsocks"
	page.dependent = true
end
