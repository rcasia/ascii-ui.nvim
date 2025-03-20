---@module "luassert"
local interaction_type = require("ascii-ui.interaction_type")

local eq = assert.are.same

local UserInteractions = require("ascii-ui.user_interactions")
local Buffer = require("ascii-ui.buffer.buffer")
local Bufferline = require("ascii-ui.buffer.bufferline")
local Element = require("ascii-ui.buffer.element")

describe("UserInteractions", function()
	it("can interact with element", function()
		local has_called = {
			on_select = false,
			on_hover = false,
		}
		local user_interactions = UserInteractions:new()
		local position = { line = 1, col = 1 }
		local buffer_id = 1

		local buffer = Buffer:new(Bufferline:new(Element:new("my text here", false, {
			on_select = function()
				has_called.on_select = true
			end,
			on_hover = function()
				has_called.on_hover = true
			end,
		})))

		user_interactions:attach_buffer(buffer)

		user_interactions:interact({
			buffer_id = buffer_id,
			position = position,
			interaction_type = interaction_type.select,
		})
		eq(true, has_called.on_select)

		user_interactions:interact({
			buffer_id = buffer_id,
			position = position,
			interaction_type = interaction_type.hover,
		})
		eq(true, has_called.on_hover)
	end)

	it("does nothing when element is not found in position", function()
		local user_interactions = UserInteractions:new()
		local position = { line = math.huge, col = math.huge }

		local buffer = Buffer:new(Bufferline:new(Element:new("my text here", false, {
			on_select = function()
				has_called.on_select = true
			end,
			on_hover = function()
				has_called.on_hover = true
			end,
		})))

		user_interactions:attach_buffer(buffer)
		user_interactions:interact({
			buffer_id = buffer.id,
			position = position,
			interaction_type = interaction_type.select,
		})
	end)
end)
