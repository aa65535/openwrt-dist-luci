--[[
openwrt-dist
]]--

local fs = require "nixio.fs"

local running =(luci.sys.call("pidof ss-redir > /dev/null") == 0)
if running then
	m = Map("shadowsocks", translate("ShadowSocks"), translate("ShadowSocks is running"))
else
	m = Map("shadowsocks", translate("ShadowSocks"), translate("ShadowSocks is not running"))
end

general = m:section(TypedSection, "shadowsocks", translate("General Setting"))
general.anonymous = true

enable = general:option(Flag, "enable", translate("Enable"))
enable.rmempty = false

use_conf_file = general:option(Flag, "use_conf_file", translate("Use Config File"))
use_conf_file.default = 1
use_conf_file.rmempty = false

config_file = general:option(Value, "config_file", translate("Config File"))
config_file.default = "/etc/shadowsocks/config.json"
config_file.placeholder = "/etc/shadowsocks/config.json"
config_file.datatype = "file"
config_file.optional = false
config_file:depends("use_conf_file", 1)

server = general:option(Value, "server", translate("Server Address"))
server.datatype = "host"
server.optional = false
server:depends("use_conf_file", "")

server_port = general:option(Value, "server_port", translate("Server Port"))
server_port.datatype = "port"
server_port.optional = false
server_port:depends("use_conf_file", "")

local_port = general:option(Value, "local_port", translate("Local Port"))
local_port.datatype = "port"
local_port.placeholder = 1080
local_port.optional = false
local_port:depends("use_conf_file", "")

password = general:option(Value, "password", translate("Password"))
password.password = true
password:depends("use_conf_file", "")

encrypt_method = general:option(ListValue, "encrypt_method", translate("Encrypt Method"))
encrypt_method:value("table")
encrypt_method:value("rc4")
encrypt_method:value("rc4-md5")
encrypt_method:value("aes-128-cfb")
encrypt_method:value("aes-192-cfb")
encrypt_method:value("aes-256-cfb")
encrypt_method:value("bf-cfb")
encrypt_method:value("cast5-cfb")
encrypt_method:value("des-cfb")
encrypt_method:value("camellia-128-cfb")
encrypt_method:value("camellia-192-cfb")
encrypt_method:value("camellia-256-cfb")
encrypt_method:value("idea-cfb")
encrypt_method:value("rc2-cfb")
encrypt_method:value("seed-cfb")
encrypt_method:depends("use_conf_file", "")

ignore_list = general:option(Value, "ignore_list", translate("Ignore IP List"))
ignore_list.placeholder = "/etc/shadowsocks/ignore.list"
ignore_list.datatype = "file"
ignore_list.optional = false


tunnel = m:section(TypedSection, "shadowsocks", translate("UDP Forward"))
tunnel.anonymous = true

tunnel_enable = tunnel:option(Flag, "tunnel_enable", translate("Enable"))
tunnel_enable.default = 1
tunnel_enable.rmempty = false

tunnel_port = tunnel:option(Value, "tunnel_port", translate("UDP Local Port"))
tunnel_port.datatype = "port"
tunnel_port.default = 5353
tunnel_port.placeholder = 5353
tunnel_port.optional = false
tunnel_port:depends("tunnel_enable", 1)

tunnel_forward = tunnel:option(Value, "tunnel_forward",
	translate("Forwarding Tunnel"),
	translate("Setup a local port forwarding tunnel"))
tunnel_forward.default = "8.8.4.4:53"
tunnel_forward.placeholder = "8.8.4.4:53"
tunnel_forward.optional = false
tunnel_forward:depends("tunnel_enable", 1)


ac = m:section(TypedSection, "shadowsocks", translate("Access Control"))
ac.anonymous = true

ac_mode = ac:option(ListValue, "ac_mode", translate("Access Control Mode"))
ac_mode:value("0", translate("Off"))
ac_mode:value("1", translate("Accept"))
ac_mode:value("2", translate("Reject"))

accept_ip = ac:option(DynamicList, "accept_ip",
	translate("Accept IP"),
	translate("The traffic of these IP will be transited through shadowsocks"))
accept_ip.datatype = "ipaddr"
accept_ip.optional = false
accept_ip:depends("ac_mode", 1)

reject_ip = ac:option(Value, "reject_ip",
	translate("Reject IP"),
	translate("The traffic of this IP won't be transited through shadowsocks"))
reject_ip.datatype = "ipaddr"
reject_ip.optional = false
reject_ip:depends("ac_mode", 2)

return m
