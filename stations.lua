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

crafting.register_type("inv")
crafting.register_type("furnace")

if minetest.global_exists("sfinv") then
	sfinv.override_page("sfinv:crafting", {
		get = function(self, player, context)
			local formspec = crafting.make_result_selector(player, "inv", 1, { x = 8, y = 3 }, context)
			formspec = formspec .. "list[detached:creative_trash;main;0,3.4;1,1;]" ..
					"image[0.05,3.5;0.8,0.8;creative_trash_icon.png]"
			return sfinv.make_formspec(player, context, formspec, true)
		end,
		on_player_receive_fields = function(self, player, context, fields)
			if crafting.result_select_on_receive_results(player, "inv", 1, context, fields) then
				sfinv.set_player_inventory_formspec(player)
			end
			return true
		end
	})
end

minetest.register_node("crafting:work_bench", {
	description = "Work Bench",
	groups = { snappy = 1 },
	on_rightclick = crafting.make_on_rightclick("inv", 2, { x = 8, y = 3 }),
})

crafting.create_async_station("crafting:furnace", "furnace", 1, {
	description = "Furnace",
	tiles = {
		"crafting_furnace_top.png", "crafting_furnace_bottom.png",
		"crafting_furnace_side.png", "crafting_furnace_side.png",
		"crafting_furnace_side.png", "crafting_furnace_front.png"
	},
	paramtype2 = "facedir",
	groups = {cracky=2},
	legacy_facedir_simple = true,
	is_ground_content = false,
}, {
	description = "Furnace (active)",
	tiles = {
		"crafting_furnace_top.png", "crafting_furnace_bottom.png",
		"crafting_furnace_side.png", "crafting_furnace_side.png",
		"crafting_furnace_side.png",
		{
			image = "crafting_furnace_front_active.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.5
			},
		}
	},
	paramtype2 = "facedir",
	light_source = 8,
	drop = "crafting:furnace",
	groups = {cracky=2, not_in_creative_inventory=1},
	legacy_facedir_simple = true,
	is_ground_content = false,
})
