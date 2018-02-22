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

crafting.register_recipe({
	type   = "inv",
	output = "default:torch",
	items  = { "default:stick", "default:coal_lump" },
	always_known = true,
	level  = 2,
})

crafting.register_recipe({
	type   = "inv",
	output = "default:wood",
	items  = { "group:stone" },
	always_known = true,
})

crafting.register_recipe({
	type   = "inv",
	output = "default:stone",
	items  = { "default:wood" },
	always_known = true,
})

crafting.register_recipe({
	type   = "inv",
	output = "default:cobble",
	items  = { "default:wood" },
	always_known = true,
})

crafting.register_recipe({
	type   = "inv",
	output = "default:stone",
	items  = { "default:gravel 3" },
	always_known = true,
})

crafting.register_recipe({
	type   = "inv",
	output = "default:sword_wood",
	items  = { "default:wood 2", "default:stick" },
	always_known = true,
})

crafting.register_recipe({
	type   = "inv",
	output = "default:pick_stone",
	items  = { "default:cobble 3", "default:stick 2" },
	always_known = true,
})

crafting.register_recipe({
	type   = "inv",
	output = "default:sword_stone",
	items  = { "default:cobble 2", "default:stick" },
	always_known = true,
})

crafting.register_recipe({
	type   = "inv",
	output = "default:pick_steel",
	items  = { "default:steel_ingot 3", "default:stick 2" },
	always_known = true,
})

crafting.register_recipe({
	type   = "inv",
	output = "default:stick",
	items  = { "default:wood" },
	always_known = true,
})

crafting.register_recipe({
	type   = "inv",
	output = "default:tree",
	items  = { "default:wood" },
	always_known = true,
})



crafting.register_type("furnace")

crafting.register_recipe({
	type   = "furnace",
	output = "default:steel_ingot",
	items  = { "default:iron_lump" },
	always_known = true,
})
