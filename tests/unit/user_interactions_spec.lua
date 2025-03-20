---@module "luassert"
local interaction_type = require("ascii-ui.interaction_type")

local eq = assert.are.same

local UserInteractions = require("ascii-ui.user_interactions")
local Buffer = require("ascii-ui.buffer.buffer")
local Bufferline = require("ascii-ui.buffer.bufferline")
local Element = require("ascii-ui.buffer.element")

describe("UserInteractions", function()
	it("can interact with element", function()
		local has_been_called = false
		local user_interactions = UserInteractions:new()
		local position = { line = 1, col = 1 }
		local buffer_id = 1
		local type = interaction_type.select

		local buffer = Buffer:new(Bufferline:new(Element:new("my text here", false, {
			on_select = function()
				has_been_called = true
			end,
		})))

		user_interactions:attach_buffer(buffer)

		user_interactions:interact({ buffer_id = buffer_id, position = position, interaction_type = type })

		eq(true, has_been_called)
	end)
end)
