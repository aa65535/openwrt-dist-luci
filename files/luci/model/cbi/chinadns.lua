--[[
openwrt-dist-luci: ChinaDNS
]]--

local m, s, o

if luci.sys.call("pidof chinadns >/dev/null") == 0 then
	m = Map("chinadns", translate("ChinaDNS"), translate("ChinaDNS is running"))
else
	m = Map("chinadns", translate("ChinaDNS"), translate("ChinaDNS is not running"))
end

s = m:section(TypedSection, "chinadns", translate("General Setting"))
s.anonymous = true

o = s:option(Flag, "enable", translate("Enable"))
o.default = 1
o.rmempty = false

o = s:option(Value, "iplist", translate("Fake IP List"))
o.placeholder = "/etc/chinadns_iplist.txt"
o.datatype = "file"
o.rmempty = false

o = s:option(Value, "chnroute", translate("Chnroute File"))
o.placeholder = "/etc/chinadns_chnroute.txt"
o.datatype = "file"

o = s:option(Value, "port", translate("Local Port"))
o.placeholder = 5353
o.datatype = "port"
o.rmempty = false

o = s:option(Value, "server",
	translate("Upstream Servers"),
	translate("Use commas to separate multiple ip address"))
o.placeholder = "114.114.114.114,208.67.222.222:443,8.8.8.8"

return m
