-- Simon Says: A memory game where you repeat an increasingly long sequence of colors.
-- Use arrow keys or h/j/k/l to navigate between buttons, then press press Enter to select.
-- Or press 1-4 to directly select a color.

local BufferLine = require("ascii-ui.buffer.bufferline")
local Segment = require("ascii-ui.buffer.segment")
local ui = require("ascii-ui")
local Button = ui.components.Button
local Paragraph = ui.components.Paragraph
local useEffect = ui.hooks.useEffect
local useReducer = ui.hooks.useReducer
local useTimeout = ui.hooks.useTimeout

local COLORS = {
	RED = "#FF6B6B",
	GREEN = "#4ECDC4",
	BLUE = "#4A90E2",
	YELLOW = "#FFE66D",
	DIM = "#6c757d",
	BORDER = "#495057",
	TEXT = "#f8f9fa",
	ACCENT = "#FFD700",
}

local COLOR_NAMES = { "RED", "GREEN", "BLUE", "YELLOW" }
local COLOR_VALUES = { COLORS.RED, COLORS.GREEN, COLORS.BLUE, COLORS.YELLOW }

--- @class ascii-ui.simon.GameState
--- @field sequence number[]
--- @field playerIndex number
--- @field score number
--- @field highScore number
--- @field gamePhase string
--- @field currentFlash number
--- @field flashVisible boolean
--- @field pendingNextRound boolean

--- @class ascii-ui.simon.GameAction
--- @field type string

--- @param state ascii-ui.simon.GameState
--- @param action ascii-ui.simon.GameAction
--- @return ascii-ui.simon.GameState
local function gameReducer(state, action)
	if action.type == "START_GAME" then
		return {
			sequence = { math.random(1, 4) },
			playerIndex = 0,
			score = 0,
			highScore = state.highScore,
			gamePhase = "showing",
			currentFlash = 0,
			flashVisible = false,
			pendingNextRound = false,
		}
	elseif action.type == "NEXT_ROUND" then
		local newSeq = vim.list_extend({}, state.sequence)
		table.insert(newSeq, math.random(1, 4))
		return vim.tbl_extend("force", state, {
			sequence = newSeq,
			playerIndex = 0,
			gamePhase = "showing",
			currentFlash = 0,
			flashVisible = false,
			pendingNextRound = false,
		})
	elseif action.type == "CORRECT_INPUT" then
		local newPlayerIndex = state.playerIndex + 1
		local roundComplete = newPlayerIndex >= #state.sequence
		local newScore = roundComplete and state.score + 1 or state.score
		local newHighScore = math.max(state.highScore, newScore)
		return vim.tbl_extend("force", state, {
			playerIndex = newPlayerIndex,
			score = newScore,
			highScore = newHighScore,
			pendingNextRound = roundComplete,
		})
	elseif action.type == "WRONG_INPUT" then
		return vim.tbl_extend("force", state, { gamePhase = "gameover" })
	elseif action.type == "SHOW_FLASH" then
		return vim.tbl_extend("force", state, { flashVisible = true })
	elseif action.type == "HIDE_FLASH" then
		return vim.tbl_extend("force", state, { flashVisible = false })
	elseif action.type == "ADVANCE_FLASH" then
		return vim.tbl_extend("force", state, {
			currentFlash = state.currentFlash + 1,
			flashVisible = true,
		})
	elseif action.type == "ENTER_INPUT_PHASE" then
		return vim.tbl_extend("force", state, { gamePhase = "input" })
	end
	return state
end

local INITIAL_STATE = {
	sequence = {},
	playerIndex = 0,
	score = 0,
	highScore = 0,
	gamePhase = "idle",
	currentFlash = 0,
	flashVisible = false,
	pendingNextRound = false,
}

-- Custom hook: encapsulates all Simon game state and logic
local function useSimonGame()
	local state, dispatch = useReducer(gameReducer, INITIAL_STATE)

	-- Start a new game
	local function startGame()
		dispatch({ type = "START_GAME" })
	end

	-- Handle player input
	local function handleInput(colorIndex)
		if state.gamePhase ~= "input" then
			return
		end

		if state.sequence[state.playerIndex + 1] == colorIndex then
			dispatch({ type = "CORRECT_INPUT" })
		else
			dispatch({ type = "WRONG_INPUT" })
		end
	end

	-- Start showing first flash when entering "showing" phase
	useEffect(function()
		if state.gamePhase == "showing" and state.currentFlash == 0 and not state.flashVisible then
			dispatch({ type = "SHOW_FLASH" })
		end
	end, { state.gamePhase })

	-- Hide flash after 600ms when visible
	useTimeout(function()
		dispatch({ type = "HIDE_FLASH" })
	end, state.flashVisible and state.gamePhase == "showing" and 600 or nil)

	-- Advance to next flash after 300ms when hidden
	useTimeout(
		function()
			dispatch({ type = "ADVANCE_FLASH" })
		end,
		not state.flashVisible and state.gamePhase == "showing" and state.currentFlash < #state.sequence and 300 or nil
	)

	-- Transition to input phase after 500ms when sequence complete
	useTimeout(
		function()
			dispatch({ type = "ENTER_INPUT_PHASE" })
		end,
		not state.flashVisible and state.gamePhase == "showing" and state.currentFlash >= #state.sequence and 500 or nil
	)

	-- Start next round after 1000ms when pending
	useTimeout(function()
		dispatch({ type = "NEXT_ROUND" })
	end, state.pendingNextRound and 1000 or nil)

	return {
		state = state,
		startGame = startGame,
		handleInput = handleInput,
	}
end

-- Custom components

local Title = ui.createComponent("Title", function()
	return {
		BufferLine.new(Segment:new({
			content = "╔══════════════════════════════════╗",
			color = COLORS.ACCENT,
		})),
		BufferLine.new(Segment:new({ content = "║       SIMON SAYS MEMORY GAME     ║", color = COLORS.ACCENT })),
		BufferLine.new(Segment:new({
			content = "╚══════════════════════════════════╝",
			color = COLORS.ACCENT,
		})),
	}
end)

local ScoreDisplay = ui.createComponent("ScoreDisplay", function(props)
	return {
		BufferLine.new(
			Segment:new({ content = "Score: ", color = COLORS.TEXT }),
			Segment:new({ content = tostring(props.score), color = COLORS.ACCENT }),
			Segment:new({ content = "  High Score: ", color = COLORS.TEXT }),
			Segment:new({ content = tostring(props.highScore), color = COLORS.ACCENT })
		),
	}
end, { score = "number", highScore = "number" })

local StatusMessage = ui.createComponent("StatusMessage", function(props)
	return {
		props.gamePhase == "idle" and Paragraph({ content = "Press any button to start!" }) or nil,
		props.gamePhase == "showing" and Paragraph({ content = "Watch the sequence..." }) or nil,
		props.gamePhase == "input" and BufferLine.new(
			Segment:new({ content = "Your turn! Repeat the sequence (" }),
			Segment:new({ content = tostring(props.playerIndex), color = COLORS.ACCENT }),
			Segment:new({ content = "/" }),
			Segment:new({ content = tostring(props.sequenceLength), color = COLORS.ACCENT }),
			Segment:new({ content = ")" })
		) or nil,
		props.gamePhase == "gameover" and BufferLine.new(Segment:new({
			content = "Game Over! Final Score: " .. props.score,
			color = COLORS.RED,
		})) or nil,
		props.gamePhase == "gameover" and Paragraph({ content = "Press any button to play again." }) or nil,
	}
end, { gamePhase = "string", playerIndex = "number", sequenceLength = "number", score = "number" })

local FlashIndicator = ui.createComponent("FlashIndicator", function(props)
	return {
		props.showing and props.visible and BufferLine.new(
			Segment:new({ content = ">>> ", color = COLORS.TEXT }),
			Segment:new({ content = props.colorName, color = props.colorValue }),
			Segment:new({ content = " <<<", color = COLORS.TEXT })
		) or nil,
		props.showing and not props.visible and Paragraph({ content = "..." }) or nil,
		props.showing and Paragraph({ content = "" }) or nil,
	}
end, { showing = "boolean", visible = "boolean", colorName = "string", colorValue = "string" })

local GameInstructions = ui.createComponent("GameInstructions", function()
	return {
		Paragraph({ content = "Controls:" }),
		BufferLine.new(
			Segment:new({ content = "• Navigate: ", color = COLORS.TEXT }),
			Segment:new({ content = "Arrow keys or h/j/k/l", color = COLORS.DIM })
		),
		BufferLine.new(
			Segment:new({ content = "• Select: ", color = COLORS.TEXT }),
			Segment:new({ content = "Enter", color = COLORS.DIM })
		),
		BufferLine.new(
			Segment:new({ content = "• Quit: ", color = COLORS.TEXT }),
			Segment:new({ content = "q", color = COLORS.DIM })
		),
	}
end)

-- App composes the custom components
local App = ui.createComponent("App", function()
	local game = useSimonGame()
	local state = game.state
	local showingFlash = state.gamePhase == "showing" and state.currentFlash < #state.sequence
	local flashColorIdx = state.sequence[state.currentFlash + 1]

	return {
		Title(),
		Paragraph({ content = "" }),
		ScoreDisplay({ score = state.score, highScore = state.highScore }),
		Paragraph({ content = "" }),
		StatusMessage({
			gamePhase = state.gamePhase,
			playerIndex = state.playerIndex,
			sequenceLength = #state.sequence,
			score = state.score,
		}),
		Paragraph({ content = "" }),
		FlashIndicator({
			showing = showingFlash,
			visible = state.flashVisible,
			colorName = COLOR_NAMES[flashColorIdx] or "",
			colorValue = COLOR_VALUES[flashColorIdx] or COLORS.TEXT,
		}),
		ui.map(COLOR_NAMES, function(colorName, i)
			return Button({
				label = "[" .. colorName:sub(1, 3) .. "]",
				on_press = function()
					if state.gamePhase == "idle" or state.gamePhase == "gameover" then
						game.startGame()
					elseif state.gamePhase == "input" then
						game.handleInput(i)
					end
				end,
			})
		end),
		Paragraph({ content = "" }),
		GameInstructions(),
	}
end)

ui.mount(App)
