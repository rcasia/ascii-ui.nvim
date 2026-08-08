--- @class ascii-ui.LayoutEngine
local LayoutEngine = {}

--- Measures a fiber node's dimensions based on its content.
--- For leaf nodes, measures the BufferLine dimensions.
--- For layout nodes, recursively measures children first.
--- @param fiber ascii-ui.FiberNode
--- @return integer width
--- @return integer height
function LayoutEngine.measure(fiber)
	if not fiber then
		return 0, 0
	end

	-- If already measured, return cached frame
	if fiber.frame then
		return fiber.frame.width, fiber.frame.height
	end

	-- Leaf node: measure the line
	if fiber:is_leaf() then
		local line = fiber:get_line()
		return line:len(), 1
	end

	-- Layout node: measure children first
	if fiber.layout and fiber.child then
		local max_width = 0
		local total_height = 0
		local total_width = 0
		local gap = fiber.props and fiber.props.gap
		if gap == nil then
			gap = 1 -- default gap
		end

		local child = fiber.child
		local child_index = 0
		while child do
			child_index = child_index + 1
			local child_width, child_height = LayoutEngine.measure(child)

			if fiber.layout.direction == "row" then
				-- Horizontal layout: stack widths, max height
				total_width = total_width + child_width
				if child_index > 1 then
					total_width = total_width + gap
				end
				max_width = math.max(max_width, child_width)
				total_height = math.max(total_height, child_height)
			else
				-- Vertical layout (column): max width, stack heights
				max_width = math.max(max_width, child_width)
				total_height = total_height + child_height
				if child_index > 1 then
					total_height = total_height + gap
				end
			end

			child = child.sibling
		end

		if fiber.layout.direction == "row" then
			return total_width, total_height
		else
			return max_width, total_height
		end
	end

	-- Regular parent node: aggregate children
	local max_width = 0
	local total_height = 0

	local child = fiber.child
	while child do
		local child_width, child_height = LayoutEngine.measure(child)
		max_width = math.max(max_width, child_width)
		total_height = total_height + child_height
		child = child.sibling
	end

	return max_width, total_height
end

--- Arranges fiber nodes within a given rectangle.
--- Sets the frame (x, y, width, height) for each fiber.
--- @param fiber ascii-ui.FiberNode
--- @param x integer
--- @param y integer
--- @param width integer
--- @param height integer
function LayoutEngine.arrange(fiber, x, y, width, height)
	if not fiber then
		return
	end

	-- Set frame for this fiber
	fiber.frame = {
		x = x,
		y = y,
		width = width,
		height = height,
	}

	-- Leaf node: no children to arrange
	if fiber:is_leaf() then
		return
	end

	-- Layout node: arrange children based on direction
	if fiber.layout and fiber.child then
		local gap = fiber.props and fiber.props.gap
		if gap == nil then
			gap = 1 -- default gap
		end
		local current_x = x
		local current_y = y

		local child = fiber.child
		while child do
			local child_width, child_height = LayoutEngine.measure(child)

			if fiber.layout.direction == "row" then
				-- Horizontal: children side by side
				LayoutEngine.arrange(child, current_x, y, child_width, height)
				current_x = current_x + child_width + gap
			else
				-- Vertical (column): children stacked
				LayoutEngine.arrange(child, x, current_y, width, child_height)
				current_y = current_y + child_height + gap
			end

			child = child.sibling
		end

		return
	end

	-- Regular parent (component): arrange children vertically
	-- Propagate parent's x offset to children, and adjust y for each line
	local current_y = y
	local child = fiber.child
	while child do
		local child_width, child_height = LayoutEngine.measure(child)
		-- Pass parent's x coordinate to children
		LayoutEngine.arrange(child, x, current_y, child_width, child_height)
		current_y = current_y + child_height
		child = child.sibling
	end
end

--- Performs a complete layout pass on the fiber tree.
--- Measures all nodes and arranges them starting from (0, 0).
--- @param root ascii-ui.FiberNode
function LayoutEngine.layout(root)
	-- First pass: measure all nodes
	local root_width, root_height = LayoutEngine.measure(root)

	-- Second pass: arrange all nodes
	LayoutEngine.arrange(root, 0, 0, root_width, root_height)
end

return LayoutEngine
