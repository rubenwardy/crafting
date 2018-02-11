function crafting.make_result_selector(player, type, page, size)
	local craftable, uncraftable = crafting.get_all_for_player(player, type)

	local formspec = {}
	formspec[#formspec + 1] = "label[0,0;Unlocked: "
	formspec[#formspec + 1] = minetest.formspec_escape("8 / 8")
	formspec[#formspec + 1] = "]"

	local x = 0
	local y = 0
	local i = 1
	for set_id, set in pairs({ craftable, uncraftable }) do
		for _, recipe in pairs(set) do
			local itemname = ItemStack(recipe.output):get_name()
			local def = minetest.registered_items[itemname] or {}
			formspec[#formspec + 1] = "button["
			formspec[#formspec + 1] = x
			formspec[#formspec + 1] = ","
			formspec[#formspec + 1] = y + 0.5
			formspec[#formspec + 1] = ";1,1;result_"
			formspec[#formspec + 1] = recipe.output
			formspec[#formspec + 1] = ";"
			formspec[#formspec + 1] = def.description or recipe.output
			formspec[#formspec + 1] = "]"

			x = x + 1
			i = i + 1
			if x == size.x then
				x = 0
				y = y + 1
			end
			if y == size.y then
				break
			end
		end
		if y == size.y then
			break
		end
	end

	return table.concat(formspec, "")
end

sfinv.override_page("sfinv:crafting", {
	get = function(self, player, context)
		local page = context.crafting_page or 1
		local formspec = crafting.make_result_selector(player, "inv", page, { x = 8, y = 3 })
		return sfinv.make_formspec(player, context, formspec, true)
	end,
})
