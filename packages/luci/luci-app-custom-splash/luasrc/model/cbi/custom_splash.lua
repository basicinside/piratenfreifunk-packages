luci.i18n.loadc("freifunk")
local uci = require "luci.model.uci".cursor()
local fs = require "luci.fs"

m = Map("custom_splash", "Custom Splash")

d = m:section(NamedSection, "main", "settings", "Custom Splash")

----------------

active=d:option(ListValue, "mode", "Custom Splash benutzen?")
active.widget="radio"
active.size=2
active:value("enabled", "Ja")
active:value("disabled", "Nein")

disclaimer=d:option(ListValue, "disclaimer", "Standarddisclaimer benutzen?")
disclaimer.widget="radio"
disclaimer.size=2
disclaimer:value("enabled", "Ja")
disclaimer:value("disabled", "Nein")

msg=d:option(ListValue, "messages", "Nachrichten aktivieren?")
msg.widget="radio"
msg.size=2
msg:value("enabled", "Ja")
msg:value("disabled", "Nein")

----------------

header=d:option(TextValue, "header", "Custom Header")
header.rows="20"
function header.cfgvalue(self, section)
	cs=fs.readfile("/lib/uci/upload/custom_header.htm")
	if cs == nil then
		return ""
	else 
		return cs
	end
end

function header.write(self, section, value)
	fs.writefile("/lib/uci/upload/custom_header.htm",value)
end

----------------

footer=d:option(TextValue, "footer", "Custom Footer")
footer.rows="20"
function footer.cfgvalue(self, section)
	cs=fs.readfile("/lib/uci/upload/custom_footer.htm")
	if cs == nil then
		return ""
	else 
		return cs
	end
end

function footer.write(self, section, value)
	fs.writefile("/lib/uci/upload/custom_footer.htm",value)
end



return m
