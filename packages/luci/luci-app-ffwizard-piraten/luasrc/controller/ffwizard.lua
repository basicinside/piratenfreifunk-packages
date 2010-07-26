module "luci.controller.ffwizard"

function index()
	entry({"admin", "freifunk", "ffwizard"}, form("ffwizard"), "Freifunkassistent", 50)
end
