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

-- Game phases: "idle", "showing", "input", "gameover"
local function App()
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

	-- Flash indicator
	local showingFlash = gamePhase == "showing" and currentFlash < #sequence

	return {
		-- Title
		BufferLine.new(Segment:new({
			content = "╔══════════════════════════════════╗",
			color = COLORS.ACCENT,
		})),
		BufferLine.new(Segment:new({ content = "║       SIMON SAYS MEMORY GAME     ║", color = COLORS.ACCENT })),
		BufferLine.new(Segment:new({
			content = "╚══════════════════════════════════╝",
			color = COLORS.ACCENT,
		})),
		Paragraph({ content = "" }),

		-- Score display
		BufferLine.new(
			Segment:new({ content = "Score: ", color = COLORS.TEXT }),
			Segment:new({ content = tostring(score), color = COLORS.ACCENT }),
			Segment:new({ content = "  High Score: ", color = COLORS.TEXT }),
			Segment:new({ content = tostring(highScore), color = COLORS.ACCENT })
		),
		Paragraph({ content = "" }),

		-- Game status
		gamePhase == "idle" and Paragraph({ content = "Press any button to start!" }) or nil,
		gamePhase == "showing" and Paragraph({ content = "Watch the sequence..." }) or nil,
		gamePhase == "input" and BufferLine.new(
			Segment:new({ content = "Your turn! Repeat the sequence (" }),
			Segment:new({ content = tostring(playerIndex), color = COLORS.ACCENT }),
			Segment:new({ content = "/" }),
			Segment:new({ content = tostring(#sequence), color = COLORS.ACCENT }),
			Segment:new({ content = ")" })
		) or nil,
		gamePhase == "gameover" and BufferLine.new(Segment:new({
			content = "Game Over! Final Score: " .. score,
			color = COLORS.RED,
		})) or nil,
		gamePhase == "gameover" and Paragraph({ content = "Press any button to play again." }) or nil,

		Paragraph({ content = "" }),

		-- Flash indicator
		showingFlash and flashVisible and BufferLine.new(
			Segment:new({ content = ">>> ", color = COLORS.TEXT }),
			Segment:new({
				content = COLOR_NAMES[sequence[currentFlash + 1]],
				color = COLOR_VALUES[sequence[currentFlash + 1]],
			}),
			Segment:new({ content = " <<<", color = COLORS.TEXT })
		) or nil,
		showingFlash and not flashVisible and Paragraph({ content = "..." }) or nil,
		showingFlash and Paragraph({ content = "" }) or nil,

		-- Color buttons
		ui.map(COLOR_NAMES, function(colorName, i)
			local buttonLabel = string.format("[%s]", colorName:sub(1, 3))
			return Button({
				label = buttonLabel,
				on_press = function()
					if gamePhase == "idle" or gamePhase == "gameover" then
						startGame()
					elseif gamePhase == "input" then
						handleInput(i)
					end
				end,
			})
		end),

		Paragraph({ content = "" }),

		-- Instructions
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
end

ui.mount(ui.createComponent("App", App))
