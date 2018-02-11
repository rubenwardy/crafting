unused_args = false
allow_defined_top = true

read_globals = {
	"minetest",
	string = {fields = {"split"}},
	table = {fields = {"copy", "getn"}},
	"vector", "default",
	"ItemStack",
	"crafting",

	-- Testing
	"describe",
	"it",
}
