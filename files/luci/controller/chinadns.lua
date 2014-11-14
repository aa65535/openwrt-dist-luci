--[[
openwrt-dist
]]--

module("luci.controller.chinadns", package.seeall)

function index()

	if not nixio.fs.access("/etc/config/chinadns") then
		return
	end

	local page
	page = node("admin", "services", "chinadns")
	page.target = firstchild()
	page.title = _("chinadns")
	page.order  = 65

	page = entry({"admin", "services", "chinadns"}, cbi("chinadns"), _("chinadns"), 45)
	page.i18n = "chinadns"
	page.dependent = true
end
