module "luci.controller.bugreport"

function index()
	entry({"admin", "freifunk", "heartbeat"}, form("bugreport"), "Bugreport", 60)
end
