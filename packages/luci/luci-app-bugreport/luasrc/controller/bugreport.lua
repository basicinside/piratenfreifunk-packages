module "luci.controller.bugreport"

function index()
	entry({"admin", "freifunk", "heartbeat"}, template("bugreport"), "Bugreport", 60)
end
