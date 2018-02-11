crafting.register_type("inv")

crafting.register_recipe({
	type   = "inv",
	output = "default:torch",
	items  = { "default:stick", "default:coal" },
	always_known = true,
})
