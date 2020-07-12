-- Copyright (C) 2014-2018 OpenWrt-dist
-- Copyright (C) 2014-2018 Jian Chang <aa65535@live.com>
-- Licensed to the public under the GNU General Public License v3.

module("luci.controller.chinadns", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/chinadns") then
		return
	end

	page = entry({"admin", "services", "chinadns"},
		cbi("chinadns"),
		_("ChinaDNS"), 70)
	page.dependent = true
	page.acl_depends = { "luci-app-chinadns" }
end
