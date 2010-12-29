module "luci.controller.custom_splash"

function index()
	entry({"admin", "freifunk", "custom_splash"}, cbi("custom_splash"), "Custom Splash", 80)
	assign({"mini", "freifunk", "custom_splash"}, {"admin", "freifunk", "custom_splash"}, "Custom Splash", 50)
end
