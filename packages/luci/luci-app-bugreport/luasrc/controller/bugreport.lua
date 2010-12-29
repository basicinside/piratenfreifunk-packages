module "luci.controller.bugreport"

function index()
	entry({"admin", "freifunk", "bugreport"}, template("bugreport"), "Bugreport", 60)
	assign({"mini", "freifunk", "bugreport"}, {"admin", "freifunk", "bugreport"}, "Bugreport", 60)
end
