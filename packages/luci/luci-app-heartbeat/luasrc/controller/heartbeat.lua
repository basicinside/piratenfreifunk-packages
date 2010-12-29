module "luci.controller.heartbeat"

function index()
	entry({"admin", "freifunk", "heartbeat"}, cbi("heartbeat"), "Heartbeat", 60)
	assign({"mini", "freifunk", "heartbeat"}, {"admin", "freifunk", "heartbeat"}, "Heartbeat", 60)
end
