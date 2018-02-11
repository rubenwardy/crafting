package.path = '../../?.lua;' .. -- tests root
			   '../?.lua;' .. -- mod root
			   package.path


require("crafting/api")
require("crafting/recipes")

describe("Inv Crafttype", function()
	it("exists", function()
		assert.is_not_nil(crafting.recipes["inv"])
	end)

	it("has torch recipe", function()
		assert.equals("default:torch", crafting.recipes["inv"][1].output)
	end)
end)
