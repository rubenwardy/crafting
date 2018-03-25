-- Crafting Mod - semi-realistic crafting in minetest
-- Copyright (C) 2018 rubenwardy <rw@rubenwardy.com>
--
-- This library is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- This library is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA


crafting = {
	recipes = {},
	recipes_by_id = {},
}

function crafting.register_type(name)
	crafting.recipes[name] = {}
end

local recipe_counter = 0
function crafting.register_recipe(def)
	assert(def.output, "Output needed in recipe definition")
	assert(def.type,   "Type needed in recipe definition")
	assert(def.items,  "Items needed in recipe definition")

	def.level = def.level or 1

	local tab = crafting.recipes[def.type]
	assert(tab,        "Unknown craft type " .. def.type)

	recipe_counter = recipe_counter + 1
	def.id = recipe_counter
	crafting.recipes_by_id[recipe_counter] = def
	tab[#tab + 1] = def

	return def.id
end

function crafting.get_recipe(id)
	return crafting.recipes_by_id[id]
end

function crafting.get_all(type, level, item_hash, unlocked)
	assert(crafting.recipes[type], "No such craft type!")

	local results = {}

	for _, recipe in pairs(crafting.recipes[type]) do
		local craftable = true

		if recipe.level <= level and (recipe.always_known or unlocked[recipe.output]) then
			-- Check all ingredients are available
			local items = {}
			for _, item in pairs(recipe.items) do
				item = ItemStack(item)
				local needed_count = item:get_count()

				local available_count = item_hash[item:get_name()] or 0
				if available_count < needed_count then
					craftable = false
				end

				items[#items + 1] = {
					name = item:get_name(),
					have = available_count,
					need = needed_count,
				}
			end

			results[#results + 1] = {
				recipe    = recipe,
				items     = items,
				craftable = craftable,
			}
		end
	end

	return results
end

function crafting.set_item_hashes_from_list(inv, listname, item_hash)
	for _, stack in pairs(inv:get_list(listname)) do
		if not stack:is_empty() then
			local itemname = stack:get_name()
			item_hash[itemname] = (item_hash[itemname] or 0) + stack:get_count()

			local def = minetest.registered_items[itemname]
			if def.groups then
				for groupname, _ in pairs(def.groups) do
					local group = "group:" .. groupname
					item_hash[group] = (item_hash[group] or 0) + stack:get_count()
				end
			end
		end
	end
end

function crafting.get_all_for_player(player, type, level)
	-- TODO: unlocked crafts
	local unlocked = {}

	-- Get items hashed
	local item_hash = {}
	crafting.set_item_hashes_from_list(player:get_inventory(), "main", item_hash)

	return crafting.get_all(type, level, item_hash, unlocked)
end

function crafting.can_craft(name, type, level, recipe)
	-- TODO: unlocked crafts
	local unlocked = {}

	return recipe.type == type and recipe.level <= level and
		(recipe.always_known or unlocked[recipe.output])
end

local function give_all_to_player(inv, list)
	for _, item in pairs(list) do
		inv:add_item("main", item)
	end
end

function crafting.find_required_items(inv, listname, recipe)
	local items = {}
	for _, item in pairs(recipe.items) do
		item = ItemStack(item)

		local itemname = item:get_name()
		if item:get_name():sub(1, 6) == "group:" then
			local groupname = itemname:sub(7, #itemname)
			local required = item:get_count()

			-- Find stacks in group
			for i = 1, inv:get_size(listname) do
				local stack = inv:get_stack(listname, i)

				-- Is it in group?
				local def = minetest.registered_items[stack:get_name()]
				if def and def.groups and def.groups[groupname] then
					stack = ItemStack(stack)
					if stack:get_count() > required then
						stack:set_count(required)
					end
					items[#items + 1] = stack

					required = required - stack:get_count()

					if required == 0 then
						break
					end
				end
			end

			if required > 0 then
				return nil
			end
		else
			if inv:contains_item(listname, item) then
				items[#items + 1] = item
			else
				return nil
			end
		end
	end

	return items
end

function crafting.has_required_items(inv, listname, recipe)
	return crafting.find_required_items(inv, listname, recipe) ~= nil
end

function crafting.perform_craft(inv, listname, outlistname, recipe)
	local items = crafting.find_required_items(inv, listname, recipe)
	if not items then
		return false
	end

	-- Take items
	local taken = {}
	for _, item in pairs(items) do
		item = ItemStack(item)

		local took = inv:remove_item(listname, item)
		taken[#taken + 1] = took
		if took:get_count() ~= item:get_count() then
			minetest.log("error", "Unexpected lack of items in inventory")
			give_all_to_player(inv, taken)
			return false
		end
	end

	-- Add output
	inv:add_item(outlistname, recipe.output)

	return true
end

local function to_hex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

function crafting.calc_inventory_list_hash(inv, listname)
	local str = ""
	for _, stack in pairs(inv:get_list(listname)) do
		str = str .. stack:get_name() .. stack:get_count()
	end
	return minetest.sha1(to_hex(str))
end
