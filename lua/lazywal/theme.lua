--- Builds the final `lazywal` theme from a generated palette.
--- Option 1: each ANSI slot is blended toward the background by its percentage.
local color = require("lazywal.color")
local highlights = require("lazywal.highlights")

local M = {}

---@param palette table raw palette from palette.lua
---@param opts table config options
---@return table theme
function M.build(palette, opts)
	local bg = palette.background or palette.color0 or "#000000"
	local p = {}

	for i = 0, 15 do
		local key = "color" .. i
		local pct = (opts.percentages and opts.percentages[key]) or 100
		p[key] = color.mix(palette[key] or bg, bg, pct)
	end

	local c = {
		bg = opts.transparent and "NONE" or bg,
		fg = palette.foreground or p.color7,
		fg_dim = p.color7,
		grey = p.color8,

		red = p.color1,
		green = p.color2,
		yellow = p.color3,
		blue = p.color4,
		magenta = p.color5,
		cyan = p.color6,
		white = p.color7,

		bright_red = p.color9,
		bright_green = p.color10,
		bright_yellow = p.color11,
		bright_blue = p.color12,
		bright_magenta = p.color13,
		bright_cyan = p.color14,
		bright_white = p.color15,
	}

	c.bg_highlight = color.mix(p.color8, bg, 40)
	c.bg_add = color.mix(p.color2, bg, 15)
	c.bg_change = color.mix(p.color3, bg, 15)
	c.bg_delete = color.mix(p.color1, bg, 20)

	local groups = highlights.build(c, opts)
	if type(opts.overrides) == "function" then
		local extra = opts.overrides(c)
		if type(extra) == "table" then
			groups = vim.tbl_deep_extend("force", groups, extra)
		end
	end

	local terminal = {}
	for i = 0, 15 do
		terminal[i] = p["color" .. i]
	end

	return {
		palette = p,
		roles = c,
		highlights = groups,
		terminal = terminal,
		background = bg,
		foreground = c.fg,
	}
end

return M
