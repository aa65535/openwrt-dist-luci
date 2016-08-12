--[[
openwrt-dist-luci: ShadowSocks
]]--

local m, s, o
local pkg_name
local version = "1.0.0-1"
local min_version = "2.4.8-2"
local shadowsocks = "shadowsocks"
local ipkg = require("luci.model.ipkg")
local uci = luci.model.uci.cursor()

function compare_versions(ver1, comp, ver2)
	if not ver1 or not (#ver1 > 0)
	or not comp or not (#comp > 0)
	or not ver2 or not (#ver2 > 0) then
		return nil
	end
	return luci.sys.call("opkg compare-versions '%s' '%s' '%s'" %{ver1, comp, ver2}) == 1
end

ipkg.list_installed("shadowsocks-libev-spec", function(n, v, d)
	version = v
	pkg_name = n
end)

if compare_versions(min_version, ">>", version) then
	local tip = 'shadowsocks-libev-spec not found'
	if pkg_name then
		tip = 'Please upgrade %s to v%s and above.' %{pkg_name, min_version}
	end
	return Map(shadowsocks, "%s - %s" %{translate("ShadowSocks"), translate("Access Control")}, '<b style="color:red">%s</b>' %{tip})
end

local nwm = require("luci.model.network").init()
local fwm = require("luci.model.firewall").init()
local chnroute = uci:get_first("chinadns", "chinadns", "chnroute")

m = Map(shadowsocks, "%s - %s" %{translate("ShadowSocks"), translate("Access Control")})

-- [[ Zone WAN ]]--
s = m:section(TypedSection, "access_control", translate("Zone WAN"))
s.anonymous = true

o = s:option(Value, "wan_bp_list", translate("Bypassed IP List"))
o:value("/dev/null", translate("NULL - As Global Proxy"))
if chnroute then o:value(chnroute, translate("ChinaDNS CHNRoute")) end
o.datatype = "file"
o.default = chnroute or "/dev/null"
o.rmempty = false

o = s:option(DynamicList, "wan_bp_ips", translate("Bypassed IP"))
o.datatype = "ip4addr"

o = s:option(DynamicList, "wan_fw_ips", translate("Forwarded IP"))
o.datatype = "ip4addr"

-- [[ Zone LAN ]]--
s = m:section(TypedSection, "access_control", translate("Zone LAN"))
s.anonymous = true

o = s:option(MultiValue, "lan_ifaces", translate("Interface"))
for _, zone in ipairs(fwm:get_zones()) do
	if string.find(zone:name(), "wan") ~= 1 then
		local net = nwm:get_network(zone:name())
		local device = net and net:get_interface()
		if device then
			o:value(device:name(), device:get_i18n())
		end
	end
end

o = s:option(ListValue, "lan_default_target", translate("Default Action"))
o:value("SS_SPEC_WAN_AC", translate("Normal"))
o:value("RETURN", translate("Bypassed"))
o:value("SS_SPEC_WAN_FW", translate("Global"))

-- [[ Hosts Action ]]--
s = m:section(TypedSection, "lan_hosts_action", translate("Hosts Action"))
s.template  = "cbi/tblsection"
s.addremove = true
s.anonymous = true

o = s:option(Value, "host", translate("Hosts IP"))
luci.sys.net.ipv4_hints(function(ip, name)
	o:value(ip, "%s (%s)" %{ip, name})
end)
o.datatype = "ip4addr"
o.rmempty  = false

o = s:option(ListValue, "action", translate("Hosts Action"))
o:value("b", translatef("Bypassed"))
o:value("g", translatef("Global"))
o:value("n", translatef("Normal"))
o.rmempty  = false

o = s:option(Flag, "enable", translate("Enable"))
o.default = 1
o.rmempty = false

return m
