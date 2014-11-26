--[[
openwrt-dist-luci: ShadowVPN
]]--

local m, s, o, fs
fs = require "nixio.fs"

if luci.sys.call("pidof shadowvpn >/dev/null") == 0 then
	m = Map("shadowvpn", translate("ShadowVPN"), translate("ShadowVPN is running"))
else
	m = Map("shadowvpn", translate("ShadowVPN"), translate("ShadowVPN is not running"))
end

-- Common Configuration
s = m:section(TypedSection, "shadowvpn", translate("Common Configuration"))
s.anonymous = true

-- General Setting
s:tab("general", translate("General Setting"))

o = s:taboption("general", Flag, "enable", translate("Enable"))
o.default = 1
o.rmempty = false

o = s:taboption("general", Value, "server", translate("Server Address"))
o.datatype = "host"
o.rmempty = false

o = s:taboption("general", Value, "port", translate("Server Port"))
o.datatype = "port"
o.rmempty = false

o = s:taboption("general", Value, "password", translate("Password"))
o.password = true
o.rmempty = false

o = s:taboption("general", Value, "mtu", translate("Override MTU"))
o.placeholder = 1440
o.default = 1440
o.datatype = "range(296,1500)"
o.rmempty = false

o = s:taboption("general", Value, "intf", translate("Interface Name"))
o.placeholder = "tun0"
o.default = "tun0"
o.rmempty = false

-- Edit Configuration Template
s:tab("edit_tpl", translate("Edit Configuration Template"))

o = s:taboption("edit_tpl", TextValue, "_tpl", translate(""),
	translate("This is the content of the file '/etc/shadowvpn/client.conf' from which your ShadowVPN configuration will be generated. " ..
		"Values enclosed by pipe symbols ('|') should not be changed. They get their values from the 'General Setting' tab."))
o.template = "cbi/tvalue"
o.rows = 20

function o.cfgvalue(self, section)
	return fs.readfile("/etc/shadowvpn/client.conf") or ""
end

function o.write(self, section, value)
	if value then
		fs.writefile("/etc/shadowvpn/client.conf", value:gsub("\r\n?", "\n"))
	end
end

-- Route Configuration
s = m:section(TypedSection, "shadowvpn", translate("Routing Configuration"))
s.anonymous = true

o = s:option(ListValue, "route_mode", translate("Routing Mode"))
o:value("0", translate("Global Mode"))
o:value("1", translate("Domestic Routes"))
o:value("2", translate("Foreign Routes"))
o.default = 0
o.rmempty = false

o = s:option(Value, "route_file", translate("Routing File"))
o.datatype = "file"
o:depends("route_mode", 1)
o:depends("route_mode", 2)

return m
