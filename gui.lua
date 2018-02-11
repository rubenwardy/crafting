local function get_item_description(name)
	local def = minetest.registered_items[name] or {}
	return def.description or name
end

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
		for _, result in pairs(set) do
			local recipe = result.recipe

			local itemname = ItemStack(recipe.output):get_name()
			local item_description = get_item_description(itemname)

			formspec[#formspec + 1] = "button["
			formspec[#formspec + 1] = x
			formspec[#formspec + 1] = ","
			formspec[#formspec + 1] = y + 0.5
			formspec[#formspec + 1] = ";1,1;result_"
			formspec[#formspec + 1] = recipe.output
			formspec[#formspec + 1] = ";"
			formspec[#formspec + 1] = item_description
			formspec[#formspec + 1] = "]"

			formspec[#formspec + 1] = "tooltip[result_"
			formspec[#formspec + 1] = recipe.output
			formspec[#formspec + 1] = ";"
			formspec[#formspec + 1] = minetest.formspec_escape(item_description .. "\n")
			for j, item in pairs(result.items) do
				local color = item.have > item.need and "#6f6" or "#f66"
				local itemtab = {
					"\n",
					minetest.get_color_escape_sequence(color),
					get_item_description(item.name), ": ",
					item.have, "/", item.need
				}
				formspec[#formspec + 1] = minetest.formspec_escape(table.concat(itemtab, ""))
			end
			formspec[#formspec + 1] = minetest.get_color_escape_sequence("#ffffff")
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
