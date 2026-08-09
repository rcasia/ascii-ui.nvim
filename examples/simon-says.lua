-- Simon Says: A memory game where you repeat an increasingly long sequence of colors.
-- Classic Simon visual design with 4 colored quadrants that "light up".
-- Use arrow keys or h/j/k/l to navigate between quadrants, then press Enter to select.

local BufferLine = require("ascii-ui.buffer.bufferline")
local Segment = require("ascii-ui.buffer.segment")
local interaction_type = require("ascii-ui.interaction_type")
local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local useEffect = ui.hooks.useEffect
local useReducer = ui.hooks.useReducer
local useTimeout = ui.hooks.useTimeout

-- Quadrant dimensions
local QUAD_WIDTH = 12
local QUAD_HEIGHT = 4
local FILL = "█"

-- Color pairs: dark (inactive) and bright (lit/flash)
local COLORS = {
	GREEN = { dark = "#2d5a2d", bright = "#4ade80" },
	RED = { dark = "#5a2d2d", bright = "#f87171" },
	YELLOW = { dark = "#5a5a2d", bright = "#facc15" },
	BLUE = { dark = "#2d2d5a", bright = "#60a5fa" },
}

local BORDER_COLOR = "#586572"
local TEXT_COLOR = "#f8f9fa"
local ACCENT_COLOR = "#FFD700"
local DIM_COLOR = "#6c757d"

-- Canonical Simon positions:
-- Top-left: GREEN (1), Top-right: RED (2)
-- Bottom-left: YELLOW (3), Bottom-right: BLUE (4)
local QUADRANTS = {
	{ index = 1, color = COLORS.GREEN },
	{ index = 2, color = COLORS.RED },
	{ index = 3, color = COLORS.YELLOW },
	{ index = 4, color = COLORS.BLUE },
}

--- @class ascii-ui.simon.GameState
--- @field sequence number[]
--- @field playerIndex number
--- @field score number
--- @field highScore number
--- @field gamePhase string
--- @field currentFlash number
--- @field flashVisible boolean
--- @field pendingNextRound boolean
--- @field inputFlash number|nil

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
			inputFlash = nil,
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
			inputFlash = nil,
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
		return vim.tbl_extend("force", state, { gamePhase = "gameover", inputFlash = nil })
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
	elseif action.type == "INPUT_FLASH" then
		return vim.tbl_extend("force", state, { inputFlash = action.colorIndex })
	elseif action.type == "CLEAR_INPUT_FLASH" then
		return vim.tbl_extend("force", state, { inputFlash = nil })
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
	inputFlash = nil,
}

-- Custom hook: encapsulates all Simon game state and logic
local function useSimonGame()
	local state, dispatch = useReducer(gameReducer, INITIAL_STATE)

	-- Start a new game
	local function startGame()
		dispatch({ type = "START_GAME" })
	end

	-- Handle player input on a quadrant
	local function handleInput(colorIndex)
		if state.gamePhase ~= "input" then
			return
		end
		dispatch({ type = "INPUT_FLASH", colorIndex = colorIndex })
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

	-- Clear input flash after 300ms
	useTimeout(function()
		dispatch({ type = "CLEAR_INPUT_FLASH" })
	end, state.inputFlash ~= nil and 300 or nil)

	return {
		state = state,
		startGame = startGame,
		handleInput = handleInput,
	}
end

-- Helper: check if a quadrant should be lit
local function isQuadrantLit(quadrantIndex, state)
	if state.gamePhase == "showing" and state.flashVisible then
		return state.sequence[state.currentFlash + 1] == quadrantIndex
	end
	if state.gamePhase == "input" then
		return state.inputFlash == quadrantIndex
	end
	return false
end

-- Custom components

local Title = ui.createComponent("Title", function()
	return {
		BufferLine.new(Segment:new({
			content = "╔════════════════════════════════════╗",
			color = ACCENT_COLOR,
		})),
		BufferLine.new(Segment:new({ content = "║        SIMON SAYS MEMORY GAME      ║", color = ACCENT_COLOR })),
		BufferLine.new(Segment:new({
			content = "╚════════════════════════════════════╝",
			color = ACCENT_COLOR,
		})),
	}
end)

local ScoreDisplay = ui.createComponent("ScoreDisplay", function(props)
	return {
		BufferLine.new(
			Segment:new({ content = "  Score: ", color = TEXT_COLOR }),
			Segment:new({ content = tostring(props.score), color = ACCENT_COLOR }),
			Segment:new({ content = "    High Score: ", color = TEXT_COLOR }),
			Segment:new({ content = tostring(props.highScore), color = ACCENT_COLOR })
		),
	}
end, { score = "number", highScore = "number" })

local StatusMessage = ui.createComponent("StatusMessage", function(props)
	return {
		props.gamePhase == "idle" and Paragraph({ content = "  Press any quadrant to start!" }) or nil,
		props.gamePhase == "showing" and Paragraph({ content = "  Watch the sequence..." }) or nil,
		props.gamePhase == "input" and BufferLine.new(
			Segment:new({ content = "  Your turn! Repeat (", color = TEXT_COLOR }),
			Segment:new({ content = tostring(props.playerIndex), color = ACCENT_COLOR }),
			Segment:new({ content = "/" }),
			Segment:new({ content = tostring(props.sequenceLength), color = ACCENT_COLOR }),
			Segment:new({ content = ")" })
		) or nil,
		props.gamePhase == "gameover" and BufferLine.new(Segment:new({
			content = "  Game Over! Final Score: " .. props.score,
			color = COLORS.RED.bright,
		})) or nil,
		props.gamePhase == "gameover" and Paragraph({ content = "  Press any quadrant to play again." }) or nil,
	}
end, { gamePhase = "string", playerIndex = "number", sequenceLength = "number", score = "number" })

--- Renders the 2×2 Simon quadrant board with double-line borders.
--- Each quadrant is a multi-line filled block that lights up when active.
local SimonBoard = ui.createComponent("SimonBoard", function(props)
	local state = props.state
	local onInput = props.onInput

	local hLine = string.rep("═", QUAD_WIDTH)
	local fillStr = string.rep(FILL, QUAD_WIDTH)

	--- Create a colored quadrant segment
	local function makeQuadSeg(colorPair, lit, focusable, on_press)
		local color = lit and colorPair.bright or colorPair.dark
		return Segment:new({
			content = fillStr,
			color = { fg = color, bg = color },
			is_focusable = focusable,
			interactions = focusable and {
				[interaction_type.SELECT] = on_press,
			} or {},
		})
	end

	--- Create a border segment
	local function makeBorderSeg(content)
		return Segment:new({ content = content, color = BORDER_COLOR })
	end

	--- Create one row of two quadrants with borders
	local function makeQuadRow(leftIdx, rightIdx, isFirstLine)
		return BufferLine.new(
			makeBorderSeg("║"),
			makeQuadSeg(QUADRANTS[leftIdx].color, isQuadrantLit(leftIdx, state), isFirstLine, function()
				onInput(leftIdx)
			end),
			makeBorderSeg("║"),
			makeQuadSeg(QUADRANTS[rightIdx].color, isQuadrantLit(rightIdx, state), isFirstLine, function()
				onInput(rightIdx)
			end),
			makeBorderSeg("║")
		)
	end

	-- Build board lines: top border, top row, middle border, bottom row, bottom border
	local topBorder = { BufferLine.new(makeBorderSeg("╔" .. hLine .. "╦" .. hLine .. "╗")) }
	local topRows = ui.map(vim.fn.range(1, QUAD_HEIGHT), function(_, row)
		return makeQuadRow(1, 2, row == 1) -- GREEN (left), RED (right)
	end)
	local midBorder = { BufferLine.new(makeBorderSeg("╠" .. hLine .. "╬" .. hLine .. "╣")) }
	local bottomRows = ui.map(vim.fn.range(1, QUAD_HEIGHT), function(_, row)
		return makeQuadRow(3, 4, row == 1) -- YELLOW (left), BLUE (right)
	end)
	local bottomBorder = { BufferLine.new(makeBorderSeg("╚" .. hLine .. "╩" .. hLine .. "╝")) }

	local lines = {}
	vim.list_extend(lines, topBorder)
	vim.list_extend(lines, topRows)
	vim.list_extend(lines, midBorder)
	vim.list_extend(lines, bottomRows)
	vim.list_extend(lines, bottomBorder)
	return lines
end, { state = "table", onInput = "function" })

local GameInstructions = ui.createComponent("GameInstructions", function()
	return {
		Paragraph({ content = "" }),
		BufferLine.new(
			Segment:new({ content = "  Controls: ", color = TEXT_COLOR }),
			Segment:new({ content = "Navigate with arrow keys/hjkl, select with Enter", color = DIM_COLOR })
		),
	}
end)

-- App composes the custom components
local App = ui.createComponent("App", function()
	local game = useSimonGame()
	local state = game.state

	local function handleQuadrantPress(colorIndex)
		if state.gamePhase == "idle" or state.gamePhase == "gameover" then
			game.startGame()
		elseif state.gamePhase == "input" then
			game.handleInput(colorIndex)
		end
	end

	return {
		Title(),
		Paragraph({ content = "" }),
		ScoreDisplay({ score = state.score, highScore = state.highScore }),
		Paragraph({ content = "" }),
		SimonBoard({ state = state, onInput = handleQuadrantPress }),
		Paragraph({ content = "" }),
		StatusMessage({
			gamePhase = state.gamePhase,
			playerIndex = state.playerIndex,
			sequenceLength = #state.sequence,
			score = state.score,
		}),
		GameInstructions(),
	}
end)

ui.mount(App)
