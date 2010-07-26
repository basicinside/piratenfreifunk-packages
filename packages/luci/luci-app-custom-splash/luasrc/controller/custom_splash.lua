module "luci.controller.custom_splash"

function index()
	entry({"admin", "freifunk", "custom_splash"}, cbi("custom_splash"), "Custom Splash", 80)
end
