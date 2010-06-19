--[[
This file has been modified by
Andreas Pittrich <andreas.pittrich@web.de>
in behalf of the german pirate party (Piratenpartei)
www.piratenpartei.de

Original Disclaimer:
-------
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2008 Jo-Philipp Wich <xm@leipzig.freifunk.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

$Id$

]]--


local uci = require "luci.model.uci".cursor()
local tools = require "luci.tools.ffwizard"
local util = require "luci.util"
local sys = require "luci.sys"
local ip = require "luci.ip"

local function mksubnet(community, meship)
	local subnet_prefix = tonumber(uci:get("freifunk", community, "splash_prefix")) or 27
	local pool_network = uci:get("freifunk", community, "splash_network") or "10.104.0.0/16"
	local pool = luci.ip.IPv4(pool_network)

	if pool then
		local hosts_per_subnet = 2^(32 - subnet_prefix)
		local number_of_subnets = (2^pool:prefix())/hosts_per_subnet

		local seed1, seed2 = meship:match("(%d+)%.(%d+)$")
		math.randomseed(seed1 * seed2)

		local subnet = pool:add(hosts_per_subnet * math.random(number_of_subnets))

		local subnet_ipaddr = subnet:network(subnet_prefix):add(1):string()
		local subnet_netmask = subnet:mask(subnet_prefix):string()

		return subnet_ipaddr, subnet_netmask
	end
end


-------------------- View --------------------
f = SimpleForm("ffwizward", "Freifunkassistent",
 "Dieser Assistent unterstüzt bei der Einrichtung des Routers für das Freifunknetz.")


dev = f:field(ListValue, "device", "WLAN-Gerät")
uci:foreach("wireless", "wifi-device",
	function(section)
		dev:value(section[".name"])
	end)


main = f:field(ListValue, "wifi", "Freifunkzugang einrichten?")
main.size=0
main.widget="radio"
main:value("1", "Ja")
main:value("0", "Nein")
function main.cfgvalue(self, section)
	return uci:get("freifunk", "wizard", "setup_freifunk") or "1"
end



net = f:field(Value, "net", "Freifunk Community", "Mesh Netzbereich:")
net.rmempty = true
net:depends("wifi", "1")
uci:foreach("freifunk", "community", function(s)
	net:value(s[".name"], "%s (%s)" % {s.name, s.mesh_network or "?"})
end)

function net.cfgvalue(self, section)
	return uci:get("freifunk", "wizard", "net")
end
function net.write(self, section, value)
	uci:set("freifunk", "wizard", "net", value)
	uci:save("freifunk")
end




meship = f:field(Value, "meship", "Mesh IP Adresse", "Netzweit eindeutige Identifikation:")
meship.rmempty = true
meship:depends("wifi", "1")
function meship.cfgvalue(self, section)
	return uci:get("freifunk", "wizard", "meship")
end
function meship.write(self, section, value)
	uci:set("freifunk", "wizard", "meship", value)
	uci:save("freifunk")
end
function meship.validate(self, value)
	local x = ip.IPv4(value)
	return ( x and x:prefix() == 32 ) and x:string() or ""
end




client = f:field(ListValue, "client", "WLAN-DHCP anbieten?")
client:depends("wifi", "1")
client.size=0
client.widget="radio"
client:value("1", "Ja")
client:value("0", "Nein")
function client.cfgvalue(self, section)
	return uci:get("freifunk", "wizard", "dhcp_splash") or "0"
end



olsr = f:field(ListValue, "olsr", "OLSR einrichten?")
olsr.size=0
olsr.widget="radio"
olsr:value("1", "Ja")
olsr:value("0", "Nein")
function olsr.cfgvalue(self, section)
	return uci:get("freifunk", "wizard", "setup_olsr") or "0"

end


lon = f:field(Value, "lon", "Längengrad:")
lon.rmempty=true
lon:depends("olsr", "1")
function lon.cfgvalue(self, section)
	return uci:get("system", "", "longitude")
end

lat = f:field(Value, "lat", "Breitengrad:")
lat:depends("olsr", "1")
lat.rmempty = true
function lat.cfgvalue(self, section)
	return uci:get("system", "", "latitude")
end

local class = util.class

--[[ 
	*Opens an OpenStreetMap iframe or popup
	*Makes use of resources/OSMLatLon.htm and htdocs/resources/osm.js
	(is that the right place for files like these?)
]]--

OpenStreetMapLonLat = class(AbstractValue)

function OpenStreetMapLonLat.__init__(self, ...)
	AbstractValue.__init__(self, ...)
	self.template = "cbi/osmll_value"
	self.latfield = nil
	self.lonfield = nil
	self.centerlat = "0"
	self.centerlon = "0"
	self.zoom = "0"
	self.width = "100%"	--popups will ignore the %-symbol, "100%" is interpreted as "100"
	self.height = "600"
	self.popup = false
	self.displaytext="OpenStretMap" --text on button, that loads and displays the OSMap
	self.hidetext="X"	-- text on button, that hides OSMap
end


osm = f:field(OpenStreetMapLonLat, "latlon", "Geokoordinaten mit OpenStreetMap ermitteln:")
osm:depends("olsr", "1")
osm.latfield = "lat"
osm.lonfield = "lon"
osm.centerlat = "52"
osm.centerlon = "10"
osm.width = "100%"
osm.height = "600"
osm.popup = false
osm.zoom = "7"
osm.displaytext="OpenStreetMap anzeigen"
osm.hidetext="OpenStreetMap verbergen"

share = f:field(ListValue, "sharenet", "Eigenen Internetzugang freigeben?")
share.size=0
share.widget="radio"
share:value("1", "Ja")
share:value("0", "Nein")

function share.cfgvalue(self, section)
	return uci:get("freifunk", "wizard", "sharenet") or "0"
end


wansec = f:field(ListValue, "wansec", "Mein Netzwerk vor Zugriff aus dem Freifunknetz schützen?")
wansec:depends("sharenet", "1")
wansec.size=0
wansec.widget="radio"
wansec:value("1", "Ja")
wansec:value("0", "Nein")

function wansec.cfgvalue(self, section)
	return uci:get("freifunk", "wizard", "wan_security")
end

function wansec.write(self, section, value)
	uci:set("freifunk", "wizard", "wan_security", value)
	uci:save("freifunk")
end


hng = f:field(ListValue, "gen_hostname", "Hostname automatisch generieren?")
hng.size=0
hng.widget="radio"
hng:value("1", "Ja")
hng:value("0", "Nein")
function hng.cfgvalue(self, section)
	return uci:get("freifunk", "wizard", "generatehostname") or "1"
end


hostn = f:field(Value, "hostname", "Hostname")
hostn.rmempty=false
hostn.optional=true
hostn:depends("gen_hostname","0")
function hostn.cfgvalue(self, section)
	return sys.hostname()
end


lv = f:field(ListValue, "region", translate("pp_regional_assoc"))
uci:foreach("regions", "region", function(s)
	lv:value(s[".name"], "%s" % s.name)
end)

function lv.cfgvalue(self, section)
	return uci:get("freifunk", "contact", "region")
end

function lv.write(self, section, value)
	uci:set("freifunk", "contact", "region", value)
	uci:save("freifunk")
end

crew = f:field(Value, "crew", "Crew")
function crew.cfgvalue(self, section)
	return uci:get("freifunk", "contact", "crew")
end
function crew.write(self, section, value)
	uci:set("freifunk", "contact", "crew", value)
	uci:save("freifunk")
end

mail = f:field(Value, "mail", translate("ff_mail"))
function mail.cfgvalue(self, section)
	return uci:get("freifunk", "contact", "mail")
end
function mail.write(self, section, value)
	uci:set("freifunk", "contact", "mail", value)
	uci:save("freifunk")
end

hbm = f:field(ListValue, "heartbeat_mode", "Heartbeatmodus")
hbm.size=1
hbm.widget="radio"
uci:foreach("freifunk", "heartbeat_mode", function(s)
	hbm:value(s[".name"], "%s (%s)" %{s.name, s.description})
end)

function hbm.cfgvalue(self, section)
	return uci:get("freifunk", "heartbeat", "mode")
end

function hbm.write(self, section, value)
	uci:set("freifunk", "heartbeat", "mode", value)
	uci:save("freifunk")
end





-------------------- Control --------------------
function f.handle(self, state, data)
	if state == FORM_VALID then
		luci.http.redirect(luci.dispatcher.build_url("admin", "uci", "changes"))
		return false
	elseif state == FORM_INVALID then
		self.errmessage = "Ungültige Eingabe: Bitte die Formularfelder auf Fehler prüfen."
	end
	return true
end

local function _strip_internals(tbl)
	tbl = tbl or {}
	for k, v in pairs(tbl) do
		if k:sub(1, 1) == "." then
			tbl[k] = nil
		end
	end
	return tbl
end

-- Configure Freifunk checked
function main.write(self, section, value)
	uci:set("freifunk", "wizard", "setup_freifunk", value)
	uci:save("freifunk")

	if value == "0" then
		return
	end

	local device = dev:formvalue(section)
	local node_ip, external

	-- Collect IP-Address
	local community = net:formvalue(section)

	-- Invalidate fields
	if not community then
		net.tag_missing[section] = true
	else
		external = uci:get("freifunk", community, "external") or ""
		network = ip.IPv4(uci:get("freifunk", community, "mesh_network") or "104.0.0.0/8")
		node_ip = meship:formvalue(section) and ip.IPv4(meship:formvalue(section))

		if not node_ip or not network or not network:contains(node_ip) then
			meship.tag_missing[section] = true
			node_ip = nil
		end
	end

	if not node_ip then return end


	-- Cleanup
	tools.wifi_delete_ifaces(device)
	tools.network_remove_interface(device)
	tools.firewall_zone_remove_interface("freifunk", device)

	-- Tune community settings
	if community and uci:get("freifunk", community) then
		uci:tset("freifunk", "community", uci:get_all("freifunk", community))
	end

	-- Tune wifi device
	local devconfig = uci:get_all("freifunk", "wifi_device")
	util.update(devconfig, uci:get_all(external, "wifi_device") or {})
	uci:tset("wireless", device, devconfig)

	-- Create wifi iface
	local ifconfig = uci:get_all("freifunk", "wifi_iface")
	util.update(ifconfig, uci:get_all(external, "wifi_iface") or {})
	ifconfig.device = device
	ifconfig.network = device
	ifconfig.ssid = uci:get("freifunk", community, "ssid")
	uci:section("wireless", "wifi-iface", nil, ifconfig)

	-- Save wifi
	uci:save("wireless")

	-- Create firewall zone and add default rules (first time)
	local newzone = tools.firewall_create_zone("freifunk", "REJECT", "ACCEPT", "REJECT", true)
	if newzone then
		uci:foreach("freifunk", "fw_forwarding", function(section)
			uci:section("firewall", "forwarding", nil, section)
		end)
		uci:foreach(external, "fw_forwarding", function(section)
			uci:section("firewall", "forwarding", nil, section)
		end)

		uci:foreach("freifunk", "fw_rule", function(section)
			uci:section("firewall", "rule", nil, section)
		end)
		uci:foreach(external, "fw_rule", function(section)
			uci:section("firewall", "rule", nil, section)
		end)
	end

	-- Enforce firewall include
	local has_include = false
	uci:foreach("firewall", "include",
		function(section)
			if section.path == "/etc/firewall.freifunk" then
				has_include = true
			end
		end)

	if not has_include then
		uci:section("firewall", "include", nil,
			{ path = "/etc/firewall.freifunk" })
	end

	-- Allow state: invalid packets
	uci:foreach("firewall", "defaults",
		function(section)
			uci:set("firewall", section[".name"], "drop_invalid", "0")
		end)

	-- Prepare advanced config
	local has_advanced = false
	uci:foreach("firewall", "advanced",
		function(section) has_advanced = true end)

	if not has_advanced then
		uci:section("firewall", "advanced", nil,
			{ tcp_ecn = "0", ip_conntrack_max = "8192", tcp_westwood = "1" })
	end

	uci:save("firewall")


	-- Create network interface
	local netconfig = uci:get_all("freifunk", "interface")
	util.update(netconfig, uci:get_all(external, "interface") or {})
	netconfig.proto = "static"
	netconfig.ipaddr = node_ip:string()
	uci:section("network", "interface", device, netconfig)

	uci:save("network")

	tools.firewall_zone_add_interface("freifunk", device)
end


function olsr.write(self, section, value)
	--remember state in for wizard
	uci:set("freifunk", "wizard", "setup_olsr", value)
	uci:save("freifunk")
	if value == "0" then
		return
	end


	local device = dev:formvalue(section)

	local community = net:formvalue(section)
	local external  = community and uci:get("freifunk", community, "external") or ""

	local latval = tonumber(lat:formvalue(section))
	local lonval = tonumber(lon:formvalue(section))


	-- Delete old interface
	uci:delete_all("olsrd", "Interface", {interface=device})

	-- Write new interface
	local olsrbase = uci:get_all("freifunk", "olsr_interface")
	util.update(olsrbase, uci:get_all(external, "olsr_interface") or {})
	olsrbase.interface = device
	olsrbase.ignore    = "0"
	uci:section("olsrd", "Interface", nil, olsrbase)

	-- Delete old watchdog settings
	uci:delete_all("olsrd", "LoadPlugin", {library="olsrd_watchdog.so.0.1"})

	-- Write new watchdog settings
	uci:section("olsrd", "LoadPlugin", nil, {
		library  = "olsrd_watchdog.so.0.1",
		file     = "/var/run/olsrd.watchdog",
		interval = "30"
	})

	-- Delete old nameservice settings
	uci:delete_all("olsrd", "LoadPlugin", {library="olsrd_nameservice.so.0.3"})

	-- Write new nameservice settings
	uci:section("olsrd", "LoadPlugin", nil, {
		library     = "olsrd_nameservice.so.0.3",
		suffix      = ".olsr",
		hosts_file  = "/var/etc/hosts.olsr",
		latlon_file = "/var/run/latlon.js",
		lat         = latval and string.format("%.15f", latval) or "",
		lon         = lonval and string.format("%.15f", lonval) or ""
	})

	-- Save latlon to system too
	if latval and lonval then
		uci:foreach("system", "system", function(s)
			uci:set("system", s[".name"], "latlon",
				string.format("%.15f %.15f", latval, lonval))
		end)
	else
		uci:foreach("system", "system", function(s)
			uci:delete("system", s[".name"], "latlon")
		end)
	end

	-- Import hosts
	uci:foreach("dhcp", "dnsmasq", function(s)
		uci:set("dhcp", s[".name"], "addnhosts", "/var/etc/hosts.olsr")
	end)

	-- Make sure that OLSR is enabled
	sys.exec("/etc/init.d/olsrd enable")

	uci:save("olsrd")
	uci:save("dhcp")
end


function share.write(self, section, value)
	--remember state for wizard
	uci:set("freifunk", "wizard", "sharenet", value)
	uci:save("freifunk")

	uci:delete_all("firewall", "forwarding", {src="freifunk", dest="wan"})
	uci:delete_all("olsrd", "LoadPlugin", {library="olsrd_dyn_gw_plain.so.0.4"})
	uci:foreach("firewall", "zone",
		function(s)		
			if s.name == "wan" then
				uci:delete("firewall", s['.name'], "local_restrict")
				return false
			end
		end)

	if value == "1" then
		uci:section("firewall", "forwarding", nil, {src="freifunk", dest="wan"})
		uci:section("olsrd", "LoadPlugin", nil, {library="olsrd_dyn_gw_plain.so.0.4"})

		if wansec:formvalue(section) == "1" then
			uci:foreach("firewall", "zone",
				function(s)		
					if s.name == "wan" then
						uci:set("firewall", s['.name'], "local_restrict", "1")
						return false
					end
				end)
		end
	end

	uci:save("firewall")
	uci:save("olsrd")
	uci:save("system")
end


-- Set hostname
function hng.write(self, section, value)
	--remember state for wizard
	uci:set("freifunk", "wizard", "generatehostname", value)
	uci:save("freifunk")
	if hng:formvalue(section)=="1" then --generate hostname
		local node_ip = meship:formvalue(section) and ip.IPv4(meship:formvalue(section))
		local new_hostname = uci:get("freifunk", "wizard", "hostname_prefix") or "Freifunk"

		if node_ip then		
			new_hostname = new_hostname.."("..node_ip:string():gsub("%.", "-")..")"
		end

		uci:foreach("system", "system",
			function(s)
				-- Make crond silent
				uci:set("system", s['.name'], "cronloglevel", "10")

				-- Set hostname
				uci:set("system", s['.name'], "hostname", new_hostname)							
			end)
		sys.hostname(new_hostname)	
		uci:save("system")
	else --use custom hostname
		uci:foreach("system", "system",
			function(s)
				-- Make crond silent
				uci:set("system", s['.name'], "cronloglevel", "10")
	
				-- Set hostname
				uci:set("system", s['.name'], "hostname", value)
				sys.hostname(value)			
			end)
			uci:save("system")
	end
end

-- Manual hostname
function hostn.write (self, section, value)
end


function client.write(self, section, value)
	uci:set("freifunk", "wizard", "dhcp_splash", value)
	uci:save("freifunk")

	local device = dev:formvalue(section)

	-- Collect IP-Address
	local node_ip = meship:formvalue(section)

	if not node_ip then return end

	local community = net:formvalue(section)
	local external  = community and uci:get("freifunk", community, "external") or ""
	local splash_ip, splash_mask = mksubnet(community, node_ip)

	-- Delete old alias
	uci:delete("network", device .. "dhcp")

	-- Create alias
	local aliasbase = uci:get_all("freifunk", "alias")
	util.update(aliasbase, uci:get_all(external, "alias") or {})
	aliasbase.interface = device
	aliasbase.ipaddr = splash_ip
	aliasbase.netmask = splash_mask
	aliasbase.proto = "static"
	uci:section("network", "alias", device .. "dhcp", aliasbase)
	uci:save("network")


	-- Create dhcp
	local dhcpbase = uci:get_all("freifunk", "dhcp")
	util.update(dhcpbase, uci:get_all(external, "dhcp") or {})
	dhcpbase.interface = device .. "dhcp"
	dhcpbase.start = dhcpbeg
	dhcpbase.limit = limit
	dhcpbase.force = 1

	uci:section("dhcp", "dhcp", device .. "dhcp", dhcpbase)
	uci:save("dhcp")

	uci:delete_all("firewall", "rule", {
		src="freifunk",
		proto="udp",
		dest_port="53"
	})
	uci:section("firewall", "rule", nil, {
		src="freifunk",
		proto="udp",
		dest_port="53",
		target="ACCEPT"
	})
	uci:delete_all("firewall", "rule", {
		src="freifunk",
		proto="udp",
		src_port="68",
		dest_port="67"
	})
	uci:section("firewall", "rule", nil, {
		src="freifunk",
		proto="udp",
		src_port="68",
		dest_port="67",
		target="ACCEPT"
	})
	uci:delete_all("firewall", "rule", {
		src="freifunk",
		proto="tcp",
		dest_port="8082",
	})
	uci:section("firewall", "rule", nil, {
		src="freifunk",
		proto="tcp",
		dest_port="8082",
		target="ACCEPT"
	})

	uci:save("firewall")

	-- Delete old splash
	uci:delete_all("luci_splash", "iface", {network=device.."dhcp", zone="freifunk"})

	-- Register splash
	uci:section("luci_splash", "iface", nil, {network=device.."dhcp", zone="freifunk"})
	uci:save("luci_splash")
	
	-- Make sure that luci_splash is enabled
	sys.exec("/etc/init.d/luci_splash enable")

	-- Remember state
	uci:set("freifunk", "wizard", "dhcp_splash", "1")
	uci:save("freifunk")
end

return f
