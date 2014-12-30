--[[
openwrt-dist-luci: ShadowSocks
]]--

local m, s, o, e

if luci.sys.call("pidof ss-redir >/dev/null") == 0 then
	m = Map("shadowsocks", translate("ShadowSocks"), translate("ShadowSocks is running"))
else
	m = Map("shadowsocks", translate("ShadowSocks"), translate("ShadowSocks is not running"))
end

-- Global Setting
s = m:section(TypedSection, "shadowsocks", translate("Global Setting"))
s.anonymous = true

o = s:option(Flag, "enable", translate("Enable"))
o.default = 1
o.rmempty = false

o = s:option(Flag, "use_conf_file", translate("Use Config File"))
o.default = 1
o.rmempty = false

o = s:option(Value, "config_file", translate("Config File"))
o.placeholder = "/etc/shadowsocks/config.json"
o.default = "/etc/shadowsocks/config.json"
o.datatype = "file"
o:depends("use_conf_file", 1)

o = s:option(Value, "server", translate("Server Address"))
o.datatype = "host"
o:depends("use_conf_file", "")

o = s:option(Value, "server_port", translate("Server Port"))
o.datatype = "port"
o:depends("use_conf_file", "")

o = s:option(Value, "local_port", translate("Local Port"))
o.datatype = "port"
o.placeholder = 1080
o.default = 1080
o:depends("use_conf_file", "")

o = s:option(Value, "password", translate("Password"))
o.password = true
o:depends("use_conf_file", "")

e = {
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
}

o = s:option(ListValue, "encrypt_method", translate("Encrypt Method"))
for i,v in ipairs(e) do
	o:value(v)
end
o:depends("use_conf_file", "")

o = s:option(Value, "ignore_list", translate("Proxy Method"))
o:value("/dev/null", translate("Global Proxy"))
o:value("/etc/shadowsocks/ignore.list", translate("Ignore List"))
o.default = "/etc/shadowsocks/ignore.list"
o.rmempty = false

-- UDP Forward
s = m:section(TypedSection, "shadowsocks", translate("UDP Forward"))
s.anonymous = true

o = s:option(Flag, "tunnel_enable", translate("Enable"))
o.default = 1
o.rmempty = false

o = s:option(Value, "tunnel_port", translate("UDP Local Port"))
o.datatype = "port"
o.default = 5353
o.placeholder = 5353

o = s:option(Value, "tunnel_forward",
	translate("Forwarding Tunnel"),
	translate("Setup a local port forwarding tunnel [addr:port]"))
o.default = "8.8.4.4:53"
o.placeholder = "8.8.4.4:53"

-- LAN Access Control
s = m:section(TypedSection, "shadowsocks", translate("LAN Access Control"))
s.anonymous = true

o = s:option(ListValue, "lan_ac_mode", translate("Access Control Mode"))
o:value("0", translate("Off"))
o:value("1", translate("Whitelist"))
o:value("2", translate("Blacklist"))
o.default = 0
o.rmempty = false

o = s:option(DynamicList, "lan_ac_ip", translate("LAN IP Address"))
o.datatype = "ipaddr"
o:depends("lan_ac_mode", 1)
o:depends("lan_ac_mode", 2)

return m
