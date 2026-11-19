--- Builds the final `lazywal` theme from a generated palette.
--- Colors are used exactly as generated; roles decide which color goes where.
local color = require("lazywal.color")
local highlights = require("lazywal.highlights")

local M = {}

local function resolve(value, palette)
	if type(value) ~= "string" then
		return nil
	end
	-- Raw hex escape hatch.
	local hex = color.normalize(value)
	if hex then
		return hex
	end
	-- Palette slot: color0..color15, background, foreground, cursor.
	return palette[value]
end

---@param palette table raw palette from palette.lua
---@param opts table config options
---@return table theme
function M.build(palette, opts)
	local c = {}

	for role, target in pairs(opts.roles) do
		local resolved = resolve(target, palette)
		if not resolved then
			vim.notify_once(
				"lazywal: invalid color for role '" .. role .. "': " .. tostring(target),
				vim.log.levels.WARN
			)
			resolved = palette.color0 or "#000000"
		end
		c[role] = resolved
	end

	if opts.transparent then
		c.bg = "NONE"
	end

	local groups = highlights.build(c, opts)
	if type(opts.overrides) == "function" then
		local extra = opts.overrides(c)
		if type(extra) == "table" then
			groups = vim.tbl_deep_extend("force", groups, extra)
		end
	end

	local terminal = {}
	for i = 0, 15 do
		terminal[i] = palette["color" .. i]
	end

	return {
		palette = palette,
		roles = c,
		highlights = groups,
		terminal = terminal,
		background = palette.background,
		foreground = c.fg,
	}
end

return M
