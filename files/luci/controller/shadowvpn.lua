--[[
openwrt-dist-luci: ShadowVPN
]]--

module("luci.controller.shadowvpn", package.seeall)

function index()

	if not nixio.fs.access("/etc/config/shadowvpn") then
		return
	end

	local page
	page = node("admin", "services", "shadowvpn")
	page.target = firstchild()
	page.title = _("shadowvpn")
	page.order  = 65

	page = entry({"admin", "services", "shadowvpn"}, cbi("shadowvpn"), _("shadowvpn"), 45)
	page.i18n = "shadowvpn"
	page.dependent = true
end
