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

s = m:section(TypedSection, "shadowvpn", translate("Common Configuration"))
s.anonymous = true

-- General Setting
s:tab("general", translate("General Setting"))

o = s:taboption("general", Flag, "enable", translate("Enable"))
o.default = 1
o.rmempty = false

o = s:taboption("general", Value, "server", translate("Server Address"))
o.placeholder = "127.0.0.1"
o.datatype = "host"
o.rmempty = false

o = s:taboption("general", Value, "port", translate("Server Port"))
o.placeholder = "4000"
o.datatype = "port"
o.rmempty = false

o = s:taboption("general", Value, "password", translate("Password"))
o.password = true
o.rmempty = false

o = s:taboption("general", Value, "mtu", translate("Override MTU"))
o.placeholder = 1440
o.datatype = "range(296,1500)"
o.rmempty = false

o = s:taboption("general", Value, "intf", translate("Interface Name"))
o.placeholder = "tun0"
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

-- Edit Up Script
s:tab("edit_up", translate("Edit Up Script"))

o = s:taboption("edit_up", TextValue, "_up", translate(""),
	translate("This is the content of the file '/etc/shadowvpn/client_up.sh'. " ..
		"The script to run after VPN is created."))
o.template = "cbi/tvalue"
o.rows = 20

function o.cfgvalue(self, section)
	return fs.readfile("/etc/shadowvpn/client_up.sh") or ""
end

function o.write(self, section, value)
	if value then
		fs.writefile("/etc/shadowvpn/client_up.sh", value:gsub("\r\n?", "\n"))
	end
end

-- Edit Down Script
s:tab("edit_down", translate("Edit Down Script"))

o = s:taboption("edit_down", TextValue, "_down", translate(""),
	translate("This is the content of the file '/etc/shadowvpn/client_down.sh'. " ..
		"The script to run before stopping VPN."))
o.template = "cbi/tvalue"
o.rows = 20

function o.cfgvalue(self, section)
	return fs.readfile("/etc/shadowvpn/client_down.sh") or ""
end

function o.write(self, section, value)
	if value then
		fs.writefile("/etc/shadowvpn/client_down.sh", value:gsub("\r\n?", "\n"))
	end
end

return m
