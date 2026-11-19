local M = {}

---@class lazywal.Config
M.options = {
	generator = "auto", --- "auto" | "hellwal" | "pywall"
	palette_path = nil, --- custom path to a generated palette file

	--- Blend percentage for each ANSI slot: 0 = background, 100 = pure palette color.
	percentages = {
		color0 = 100,
		color1 = 85,
		color2 = 75,
		color3 = 85,
		color4 = 90,
		color5 = 80,
		color6 = 80,
		color7 = 100,
		color8 = 100,
		color9 = 85,
		color10 = 75,
		color11 = 85,
		color12 = 90,
		color13 = 80,
		color14 = 80,
		color15 = 100,
	},

	transparent = false,
	terminal_colors = true,
	styles = {
		comments = { italic = true },
	},
	overrides = nil, --- fun(colors): table<string, table> — extra highlight groups
}

local function sanitize(value)
	if type(value) ~= "table" then
		return value
	end
	local out = {}
	for key, item in pairs(value) do
		if type(item) ~= "function" then
			out[key] = sanitize(item)
		end
	end
	return out
end

---@param opts? lazywal.Config
function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", M.options, opts or {})
	for slot, pct in pairs(M.options.percentages) do
		local n = tonumber(pct)
		M.options.percentages[slot] = math.max(0, math.min(100, n or 100))
	end
end

--- A stable string describing everything that affects the generated theme.
function M.signature()
	local copy = vim.deepcopy(M.options)
	copy.palette_path = copy.palette_path and vim.fn.expand(copy.palette_path) or nil
	return vim.inspect(sanitize(copy)) .. "|" .. (copy.palette_path or "")
end

function M.get()
	return M.options
end

return M
