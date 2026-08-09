-- Simon Says: A memory game where you repeat an increasingly long sequence of colors.
-- Use arrow keys or h/j/k/l to navigate between buttons, then press press Enter to select.
-- Or press 1-4 to directly select a color.

local BufferLine = require("ascii-ui.buffer.bufferline")
local Segment = require("ascii-ui.buffer.segment")
local ui = require("ascii-ui")
local Button = ui.components.Button
local Paragraph = ui.components.Paragraph
local useState = ui.hooks.useState
local useEffect = ui.hooks.useEffect
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

-- Custom hook: encapsulates all Simon game state and logic
local function useSimonGame()
	local sequence, setSequence = useState({})
	local playerIndex, setPlayerIndex = useState(0)
	local score, setScore = useState(0)
	local highScore, setHighScore = useState(0)
	local gamePhase, setGamePhase = useState("idle")
	local currentFlash, setCurrentFlash = useState(0)
	local flashVisible, setFlashVisible = useState(false)
	local pendingNextRound, setPendingNextRound = useState(false)

	-- Start a new game
	local function startGame()
		setSequence({ math.random(1, 4) })
		setPlayerIndex(0)
		setScore(0)
		setGamePhase("showing")
		setCurrentFlash(0)
		setFlashVisible(false)
		setPendingNextRound(false)
	end

	-- Add to sequence after successful round
	local function nextRound()
		local newSequence = vim.list_extend(sequence, { math.random(1, 4) })
		setSequence(newSequence)
		setPlayerIndex(0)
		setGamePhase("showing")
		setCurrentFlash(0)
		setFlashVisible(false)
	end

	-- Handle player input
	local function handleInput(colorIndex)
		if gamePhase ~= "input" then
			return
		end

		if sequence[playerIndex + 1] == colorIndex then
			-- Correct!
			setPlayerIndex(playerIndex + 1)
			if playerIndex + 1 >= #sequence then
				-- Round complete!
				setScore(score + 1)
				if score + 1 > highScore then
					setHighScore(score + 1)
				end
				-- Signal to start next round after delay
				setPendingNextRound(true)
			end
		else
			-- Wrong! Game over
			setGamePhase("gameover")
		end
	end

	-- Start showing first flash when entering "showing" phase
	useEffect(function()
		if gamePhase == "showing" and currentFlash == 0 and not flashVisible then
			setFlashVisible(true)
		end
	end, { gamePhase })

	-- Hide flash after 600ms when visible
	useTimeout(function()
		setFlashVisible(false)
	end, flashVisible and gamePhase == "showing" and 600 or nil)

	-- Advance to next flash after 300ms when hidden
	useTimeout(function()
		setCurrentFlash(currentFlash + 1)
		setFlashVisible(true)
	end, not flashVisible and gamePhase == "showing" and currentFlash < #sequence and 300 or nil)

	-- Transition to input phase after 500ms when sequence complete
	useTimeout(function()
		setGamePhase("input")
	end, not flashVisible and gamePhase == "showing" and currentFlash >= #sequence and 500 or nil)

	-- Start next round after 1000ms when pending
	useTimeout(function()
		setPendingNextRound(false)
		nextRound()
	end, pendingNextRound and 1000 or nil)

	return {
		sequence = sequence,
		playerIndex = playerIndex,
		score = score,
		highScore = highScore,
		gamePhase = gamePhase,
		currentFlash = currentFlash,
		flashVisible = flashVisible,
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
	local showingFlash = game.gamePhase == "showing" and game.currentFlash < #game.sequence
	local flashColorIdx = game.sequence[game.currentFlash + 1]

	return {
		Title(),
		Paragraph({ content = "" }),
		ScoreDisplay({ score = game.score, highScore = game.highScore }),
		Paragraph({ content = "" }),
		StatusMessage({
			gamePhase = game.gamePhase,
			playerIndex = game.playerIndex,
			sequenceLength = #game.sequence,
			score = game.score,
		}),
		Paragraph({ content = "" }),
		FlashIndicator({
			showing = showingFlash,
			visible = game.flashVisible,
			colorName = COLOR_NAMES[flashColorIdx] or "",
			colorValue = COLOR_VALUES[flashColorIdx] or COLORS.TEXT,
		}),
		ui.map(COLOR_NAMES, function(colorName, i)
			return Button({
				label = "[" .. colorName:sub(1, 3) .. "]",
				on_press = function()
					if game.gamePhase == "idle" or game.gamePhase == "gameover" then
						game.startGame()
					elseif game.gamePhase == "input" then
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
