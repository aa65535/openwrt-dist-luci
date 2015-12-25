--[[
openwrt-dist-luci: ShadowSocks
]]--

local m, s, o
local shadowsocks = "shadowsocks"
local uci = luci.model.uci.cursor()
local ipkg = require("luci.model.ipkg")

if luci.sys.call("pidof ss-redir >/dev/null") == 0 then
	m = Map(shadowsocks, translate("ShadowSocks"), translate("ShadowSocks is running"))
else
	m = Map(shadowsocks, translate("ShadowSocks"), translate("ShadowSocks is not running"))
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

ipkg.list_installed("shadowsocks-libev-spec-polarssl", function(n, v, d)
	for i=1,5,1 do table.remove(encrypt_methods, 11) end
end)

uci:foreach(shadowsocks, "servers", function(s)
	if s.alias then
		server_table[s[".name"]] = s.alias
	elseif s.server and s.server_port then
		server_table[s[".name"]] = "%s:%s" %{s.server, s.server_port}
	end
end)

-- [[ Global Setting ]]--
s = m:section(TypedSection, "global", translate("Global Setting"))
s.anonymous = true

o = s:option(ListValue, "global_server", translate("Global Server"))
o:value("nil", translate("Disable ShadowSocks"))
for k, v in pairs(server_table) do o:value(k, v) end
o.default = "nil"
o.rmempty = false

o = s:option(ListValue, "udp_relay_server", translate("UDP Relay Server"))
o:value("", translate("Disable"))
o:value("same", translate("Same as Global Server"))
for k, v in pairs(server_table) do o:value(k, v) end

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

o = s:taboption("lan_ac", ListValue, "lan_ac_mode", translate("LAN Access Control"))
o:value("0", translate("Disable"))
o:value("w", translate("Allow listed only"))
o:value("b", translate("Allow all except listed"))
o.rmempty = false

o = s:taboption("lan_ac", DynamicList, "lan_ac_ips", translate("LAN Host List"))
o.datatype = "ipaddr"
for _, v in ipairs(arp_table) do o:value(v["IP address"]) end

return m
