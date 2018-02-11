crafting = {
	recipes = {}
}

function crafting.register_type(name)
	crafting.recipes[name] = {}
end

function crafting.register_recipe(def)
	assert(def.output, "Output needed in recipe definition")
	assert(def.type,   "Type needed in recipe definition")
	assert(def.items,  "Items needed in recipe definition")

	local tab = crafting.recipes[def.type]
	assert(tab,        "Unknown craft type " .. def.type)

	tab[#tab + 1] = def
end

function crafting.get_all(type, item_hash, unlocked)
	assert(crafting.recipes[type], "No such craft type!")

	local ret_craftable   = {}
	local ret_uncraftable = {}

	for _, recipe in pairs(crafting.recipes[type]) do
		local craftable = true

		if recipe.always_known or unlocked[recipe.output] then
			-- Check all ingredients are available
			for _, item in pairs(recipe.items) do
				item = ItemStack(item)
				local available_count = item_hash[item:get_name()]
				if not available_count or available_count < item:get_count() then
					craftable = false
					break
				end
			end

			if craftable then
				ret_craftable[#ret_craftable + 1] = recipe
			else
				ret_uncraftable[#ret_uncraftable + 1] = recipe
			end
		end
	end

	return ret_craftable, ret_uncraftable
end

function crafting.get_all_for_player(player, type)
	local unlocked = {}   -- TODO

	-- Get items hashed
	local item_hash = {}
	local inv = player:get_inventory()
	for _, stack in pairs(inv:get_list("main")) do
		local itemname = stack:get_count()
		item_hash[itemname] = (item_hash[itemname] or 0) + 1

		local def = minetest.registered_items[itemname]
		if def.groups then
			for _, group in pairs(def.groups) do
				local groupname = "group:" .. group
				item_hash[groupname] = (item_hash[groupname] or 0) + 1
			end
		end
	end

	return crafting.get_all(type, item_hash, unlocked)
end
