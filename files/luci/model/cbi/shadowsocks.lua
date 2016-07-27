--[[
openwrt-dist-luci: ShadowSocks
]]--

local pkg_name
local min_version = "2.4.8-2"
local m, s, o
local shadowsocks = "shadowsocks"
local uci = luci.model.uci.cursor()
local ipkg = require("luci.model.ipkg")

function is_running(name)
	return luci.sys.call("pidof %s >/dev/null" %{name}) == 0
end

function get_status(name)
	if is_running(name) then
		return translate("RUNNING")
	end
	return translate("NOT RUNNING")
end

function is_installed(name)
	return ipkg.installed(name)
end

function get_version()
	local version = "1.0.0-1"
	ipkg.list_installed("shadowsocks-libev-spec*", function(n, v, d)
		pkg_name = n
		version = v
	end)
	return version
end

function compare_versions(ver1, comp, ver2)
	if not ver1 or not (#ver1 > 0)
	or not comp or not (#comp > 0)
	or not ver2 or not (#ver2 > 0) then
		return nil
	end
	return luci.sys.call("opkg compare-versions '%s' '%s' '%s'" %{ver1, comp, ver2}) == 1
end

if compare_versions(min_version, ">>", get_version()) then
	local tip = 'shadowsocks-libev-spec not found'
	if pkg_name then
		tip = 'Please upgrade %s to v%s and above.' %{pkg_name, min_version}
	end
	return Map(shadowsocks, translate("ShadowSocks"), '<b style="color:red">%s</b>' %{tip})
end

local chnroute = uci:get_first("chinadns", "chinadns", "chnroute")
local server_table = {}
local arp_table = luci.sys.net.arptable() or {}
local encrypt_methods = {
	"table",
	"rc4",
	"rc4-md5",
	"aes-128-cfb",
	"aes-192-cfb",
	"aes-256-cfb",
	"bf-cfb",
	"camellia-128-cfb",
	"camellia-192-cfb",
	"camellia-256-cfb",
	"cast5-cfb",
	"des-cfb",
	"idea-cfb",
	"rc2-cfb",
	"seed-cfb",
	"salsa20",
	"chacha20",
	"chacha20-ietf",
}

if is_installed("shadowsocks-libev-spec-polarssl") then
	for i=1,5,1 do table.remove(encrypt_methods, 11) end
end

uci:foreach(shadowsocks, "servers", function(s)
	if s.alias then
		server_table[s[".name"]] = s.alias
	elseif s.server and s.server_port then
		server_table[s[".name"]] = "%s:%s" %{s.server, s.server_port}
	end
end)

m = Map(shadowsocks, translate("ShadowSocks"), translate("A lightweight secured SOCKS5 proxy"))

-- [[ Running Status ]]--
s = m:section(TypedSection, "global", translate("Running Status"))
s.anonymous = true

o = s:option(DummyValue, "_status", translate("Transparent Proxy"))
o.value = get_status("ss-redir")

o = s:option(DummyValue, "_status", translate("UDP Forward"))
o.value = get_status("ss-tunnel")

-- [[ Global Setting ]]--
s = m:section(TypedSection, "global", translate("Global Setting"))
s.anonymous = true

o = s:option(ListValue, "global_server", translate("Global Server"))
o:value("nil", translate("Disable ShadowSocks"))
for k, v in pairs(server_table) do o:value(k, v) end
o.default = "nil"
o.rmempty = false

o = s:option(ListValue, "udp_relay_server", translate("UDP-Relay Server"))
if is_installed("iptables-mod-tproxy") then
	o:value("", translate("Disable"))
	o:value("same", translate("Same as Global Server"))
	for k, v in pairs(server_table) do o:value(k, v) end
else
	o:value("", translate("Unusable - Missing iptables-mod-tproxy"))
end

-- [[ Servers Setting ]]--
s = m:section(TypedSection, "servers", translate("Servers Setting"))
s.anonymous = true
s.addremove   = true

o = s:option(Value, "alias", translate("Alias(optional)"))

o = s:option(Flag, "auth_enable", translate("Onetime Authentication"))
o.rmempty = false

o = s:option(Value, "server", translate("Server Address"))
o.datatype = "ipaddr"
o.rmempty = false

o = s:option(Value, "server_port", translate("Server Port"))
o.datatype = "port"
o.rmempty = false

o = s:option(Value, "local_port", translate("Local Port"))
o.datatype = "port"
o.default = 1080
o.rmempty = false

o = s:option(Value, "timeout", translate("Connection Timeout"))
o.datatype = "uinteger"
o.default = 60
o.rmempty = false

o = s:option(Value, "password", translate("Password"))
o.password = true
o.rmempty = false

o = s:option(ListValue, "encrypt_method", translate("Encrypt Method"))
for _, v in ipairs(encrypt_methods) do o:value(v) end
o.rmempty = false

-- [[ UDP Forward ]]--
s = m:section(TypedSection, "udp_forward", translate("UDP Forward"))
s.anonymous = true

o = s:option(Flag, "tunnel_enable", translate("Enable"))
o.default = 0
o.rmempty = false

o = s:option(Value, "tunnel_port", translate("UDP Local Port"))
o.datatype = "port"
o.default = 5300
o.rmempty = false

o = s:option(Value, "tunnel_forward", translate("Forwarding Tunnel"))
o.default = "8.8.4.4:53"
o.rmempty = false

-- [[ Access Control ]]--
s = m:section(TypedSection, "access_control", translate("Access Control"))
s.anonymous = true

-- Part of WAN
s:tab("wan_ac", translate("Interfaces - WAN"))

o = s:taboption("wan_ac", Value, "wan_bp_list", translate("Bypassed IP List"))
o:value("/dev/null", translate("NULL - As Global Proxy"))
if chnroute then o:value(chnroute, translate("ChinaDNS CHNRoute")) end
o.default = "/dev/null"
o.rmempty = false

o = s:taboption("wan_ac", DynamicList, "wan_bp_ips", translate("Bypassed IP"))
o.datatype = "ip4addr"

o = s:taboption("wan_ac", DynamicList, "wan_fw_ips", translate("Forwarded IP"))
o.datatype = "ip4addr"

-- Part of LAN
s:tab("lan_ac", translate("Interfaces - LAN"))

o = s:taboption("lan_ac", DynamicList, "interface", translate("Interface"))
o.template = "cbi/network_netlist"
o.nocreate = true
o.unspecified = false
o.widget = "checkbox"
o.default = "lan"
o.rmempty = false

o = s:taboption("lan_ac", ListValue, "lan_default_target", translate("Default Action"))
o:value("SS_SPEC_WAN_AC", translate("Normal"))
o:value("RETURN", translate("Bypassed"))
o:value("SS_SPEC_WAN_FW", translate("Global"))
o.default = "SS_SPEC_WAN_AC"

o = s:taboption("lan_ac", DynamicList, "lan_hosts_action", translate("Hosts Action"))
for _, v in ipairs(arp_table) do
	o:value("b,%s" %{v["IP address"]}, "%s %s (%s)" %{translate("Bypassed"), v["IP address"], v["HW address"]})
	o:value("g,%s" %{v["IP address"]}, "%s %s (%s)" %{translate("Global"), v["IP address"], v["HW address"]})
	o:value("n,%s" %{v["IP address"]}, "%s %s (%s)" %{translate("Normal"), v["IP address"], v["HW address"]})
end

return m
