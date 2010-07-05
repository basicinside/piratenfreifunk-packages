--[[
This file has been modified by
Andreas Pittrich <andreas.pittrich@web.de>
in behalf of the german pirate party (Piratenpartei)
www.piratenpartei.de

Original Disclaimer:
-------
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

luci.i18n.loadc("freifunk")
local uci = require "luci.model.uci".cursor()
require("luci.tools.webadmin")

m = Map("manager", "Manager")

d = m:section(NamedSection, "heartbeat", "heartbeat", "Heartbeat")
d.addremove = false
d.anonymous = false
dd = d:option(Flag, "enabled")
dd.rmempty = false
function dd.cfgvalue(self, section)
	return Flag.cfgvalue(self, section) or "1"
end

e = m:section(NamedSection, "server", "server", "Heartbeat Server")
e.addremove = true
e.anonymous = false
ee = e:option(Value, "url", "Heartbeat Server")
ee.rmempty = true
function ee.filter(self, section)
	return section ~= "default" and section
end
ee:value("http://heartbeat.basicinside.de")

iface = d:option(MultiValue, "interface",  "Interface for mac-hash", "Wenn nichts ausgewählt ist wird von allen Interfaces die DHCP requests mitgelesen und als hash für 1h ($interval heartbeat) im ram gespeichert.")
iface.widget = "select"
iface.size   = 5
iface:depends( "enabled", 1 )
luci.tools.webadmin.cbi_add_networks(iface)
uci:foreach("network", "interface",
	function (section)
		if section[".name"] ~= "loopback" then
			iface.default = iface.default or section[".name"]
			iface:value("interface", section[".name"])
		end
	end)
	
-- uci:foreach("network", "alias",
-- 	function (section)
-- 		iface:value(section[".name"])
-- 		d:depends("interface", section[".name"])
-- 	end)


n = Map("system", "System")
s = n:section(TypedSection, "system", "")
s.anonymous = true
s.addremove = false
hn = s:option(Value, "nodeid", "Node ID")

return m , n
