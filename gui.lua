

local function get_item_description(name)
	if name:sub(1, 6) == "group:" then
		local group = name:sub(7, #name):gsub("%_", " ")
		return "Any " .. group
	else
		local def = minetest.registered_items[name] or {}
		return def.description or name
	end
end

function crafting.make_result_selector(player, type, size, context)
	local page = context.crafting_page or 1
	local recipes = crafting.get_all_for_player(player, type)
	local num_per_page = size.x * size.y
	local max_pages = math.floor(0.999 + #recipes / num_per_page)
	if page > max_pages or page < 1 then
		page = ((page - 1) % max_pages) + 1
		context.crafting_page = page
	end

	local start_i  = (page - 1) * num_per_page + 1

	local formspec = {}

	formspec[#formspec + 1] = "container["
	formspec[#formspec + 1] = tostring(size.x)
	formspec[#formspec + 1] = ","
	formspec[#formspec + 1] = tostring(size.y)
	formspec[#formspec + 1] = "]"

	formspec[#formspec + 1] = "field[-4.75,0.81;3,0.8;query;;]"
	formspec[#formspec + 1] = "button[-2.2,0.5;0.8,0.8;search;?]"
	formspec[#formspec + 1] = "button[-1.4,0.5;0.8,0.8;prev;<]"
	formspec[#formspec + 1] = "button[-0.8,0.5;0.8,0.8;next;>]"

	formspec[#formspec + 1] = "container_end[]"


	formspec[#formspec + 1] = "label[0,-0.25;"
	formspec[#formspec + 1] = minetest.formspec_escape("Page: " ..
			page .. "/" .. max_pages ..
			" | Unlocked: " .. #recipes .. " / " .. #crafting.recipes[type])
	formspec[#formspec + 1] = "]"

	local x = 0
	local y = 0
	local y_offset = 0.2
	for i = start_i, math.min(#recipes, start_i * num_per_page)  do
		local result = recipes[i]
		local recipe = result.recipe

		local itemname = ItemStack(recipe.output):get_name()
		local item_description = get_item_description(itemname)

		formspec[#formspec + 1] = "item_image_button["
		formspec[#formspec + 1] = x
		formspec[#formspec + 1] = ","
		formspec[#formspec + 1] = y + y_offset
		formspec[#formspec + 1] = ";1,1;"
		formspec[#formspec + 1] = recipe.output
		formspec[#formspec + 1] = ";result_"
		formspec[#formspec + 1] = tostring(recipe.id)
		formspec[#formspec + 1] = ";]"

		formspec[#formspec + 1] = "tooltip[result_"
		formspec[#formspec + 1] = tostring(recipe.id)
		formspec[#formspec + 1] = ";"
		formspec[#formspec + 1] = minetest.formspec_escape(item_description .. "\n")
		for j, item in pairs(result.items) do
			local color = item.have >= item.need and "#6f6" or "#f66"
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

		formspec[#formspec + 1] = "image["
		formspec[#formspec + 1] = x
		formspec[#formspec + 1] = ","
		formspec[#formspec + 1] = y + y_offset
		if result.craftable then
			formspec[#formspec + 1] = ";1,1;crafting_slot_craftable.png]"
		else
			formspec[#formspec + 1] = ";1,1;crafting_slot_uncraftable.png]"
		end

		x = x + 1
		if x == size.x then
			x = 0
			y = y + 1
		end
		if y == size.y then
			break
		end
	end

	while y < size.y do
		while x < size.x do
			formspec[#formspec + 1] = "image["
			formspec[#formspec + 1] = tostring(x)
			formspec[#formspec + 1] = ","
			formspec[#formspec + 1] = tostring(y + y_offset)
			formspec[#formspec + 1] = ";1,1;crafting_slot_empty.png]"

			x = x + 1
		end
		x = 0
		y = y + 1
	end

	return table.concat(formspec, "")
end

function crafting.result_select_on_receive_results(player, type, context, fields)
	if fields.prev then
		context.crafting_page = (context.crafting_page or 1) - 1
		return true
	elseif fields.next then
		context.crafting_page = (context.crafting_page or 1) + 1
		return true
	end

	for key, value in pairs(fields) do
		if key:sub(1, 7) == "result_" then
			local num = string.match(key, "result_([0-9]+)")
			if num then
				local inv    = player:get_inventory()
				local recipe = crafting.get_recipe(tonumber(num))
				if not crafting.can_craft(player, type, recipe) then
					minetest.log("error", "[crafting] Player clicked a button they shouldn't have been able to")
					return true
				elseif crafting.perform_craft(inv, "main", recipe) then
					return true -- crafted
				else
					minetest.chat_send_player(player:get_player_name(), "Missing required items!")
					return false
				end
			end
		end
	end
end

sfinv.override_page("sfinv:crafting", {
	get = function(self, player, context)
		local formspec = crafting.make_result_selector(player, "inv", { x = 8, y = 3 }, context)
		formspec = formspec .. "list[detached:creative_trash;main;0,3.4;1,1;]" ..
				"image[0.05,3.5;0.8,0.8;creative_trash_icon.png]"
		return sfinv.make_formspec(player, context, formspec, true)
	end,
	on_player_receive_fields = function(self, player, context, fields)
		if crafting.result_select_on_receive_results(player, "inv", context, fields) then
			sfinv.set_player_inventory_formspec(player)
		end
		return true
	end
})
