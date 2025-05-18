pcall(require, "luacov")
---@module "luassert"
local INTERACTION_TYPE = require("ascii-ui.interaction_type")

local eq = assert.are.same

local Buffer = require("ascii-ui.buffer")
local Bufferline = require("ascii-ui.buffer.bufferline")
local Element = require("ascii-ui.buffer.element")
local UserInteractions = require("ascii-ui.user_interactions")

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
			SELECT = function()
				has_called.on_select = true
			end,
			on_hover = function()
				has_called.on_hover = true
			end,
		})))

		user_interactions:attach_buffer(buffer, buffer_id)

		user_interactions:interact({
			buffer_id = buffer_id,
			position = position,
			interaction_type = INTERACTION_TYPE.SELECT,
		})
		eq(true, has_called.on_select)

		user_interactions:interact({
			buffer_id = buffer_id,
			position = position,
			interaction_type = INTERACTION_TYPE.HOVER,
		})
		eq(true, has_called.on_hover)
	end)

	it("does nothing when element is not found in position", function()
		local buffer_id = 1
		local user_interactions = UserInteractions:new()
		local is_called = false
		local position = { line = math.huge, col = math.huge }
		local type = INTERACTION_TYPE.SELECT

		local buffer = Buffer:new(Bufferline:new(Element:new("my text here", false, {
			on_select = function()
				is_called = true
			end,
		})))

		user_interactions:attach_buffer(buffer, buffer_id)
		user_interactions:interact({
			buffer_id = buffer_id,
			position = position,
			interaction_type = type,
		})

		eq(false, is_called)
	end)

	it("does nothing when buffer is not found", function()
		local buffer_id = 1
		local user_interactions = UserInteractions:new()
		local position = { line = 1, col = 1 }
		local type = INTERACTION_TYPE.SELECT

		-- interact without attach a buffer first
		local ok = pcall(
			--
			user_interactions.interact,
			user_interactions,
			{
				buffer_id = buffer_id,
				position = position,
				interaction_type = type,
			}
		)

		eq(true, ok)
	end)
end)
