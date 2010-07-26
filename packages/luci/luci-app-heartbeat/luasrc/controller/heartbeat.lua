module "luci.controller.heartbeat"

function index()
	entry({"admin", "freifunk", "heartbeat"}, cbi("heartbeat"), "Heartbeat", 60)
	entry({"admin", "freifunk", "heartbeat", "bugreport"}, template("bugreport"), "Fehlerbericht", 10)
end
