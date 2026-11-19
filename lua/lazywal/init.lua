--- lazywal — a wallpaper-driven colorscheme.
--- Palette comes from hellwal/pywall; each ANSI slot has a blend percentage.
local config = require("lazywal.config")
local palette_mod = require("lazywal.palette")
local theme_mod = require("lazywal.theme")
local cache = require("lazywal.cache")

local M = {}

local state = {
	commands = false,
	palette = nil,
	theme = nil,
}

local function apply(theme)
	vim.g.colors_name = "lazywal"

	for group, spec in pairs(theme.highlights) do
		local clean = {}
		for key, value in pairs(spec) do
			clean[key] = value == "NONE" and nil or value
		end
		vim.api.nvim_set_hl(0, group, clean)
	end

	if config.get().terminal_colors then
		for i = 0, 15 do
			vim.g["terminal_color_" .. i] = theme.terminal[i]
		end
		vim.g.terminal_color_background = theme.background
		vim.g.terminal_color_foreground = theme.foreground
	end
end

function M.load()
	local palette = palette_mod.read(config.get())
	local key = (palette.source or "")
		.. "|"
		.. tostring(palette.mtime or "")
		.. "|"
		.. config.signature()

	local theme = cache.load(key)
	if not theme then
		theme = theme_mod.build(palette, config.get())
		cache.save(key, theme)
	end

	state.palette = palette
	state.theme = theme
	vim.g.lazywal_palette = palette
	apply(theme)
	return theme
end

function M.reload()
	cache.clear()
	return M.load()
end

function M.get_palette()
	return state.palette
end

function M.get_theme()
	return state.theme
end

---@param slot string color0..color15
---@param pct number 0..100
function M.set_percentage(slot, pct)
	if not config.get().percentages[slot] then
		vim.notify("lazywal: unknown slot " .. slot, vim.log.levels.WARN)
		return
	end
	config.get().percentages[slot] = math.max(0, math.min(100, tonumber(pct) or 100))
	M.load()
end

function M.preview()
	local p = state.palette or palette_mod.read(config.get())
	local lines = {}
	for i = 0, 15 do
		local slot = "color" .. i
		local pct = config.get().percentages[slot] or 100
		lines[i + 1] = string.format(" %-8s %s  %3d%%", slot, p[slot] or "#------", pct)
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = 32,
		height = 16,
		row = 2,
		col = 2,
		border = "rounded",
		title = " lazywal palette ",
		title_pos = "center",
	})

	for i = 0, 15 do
		vim.api.nvim_set_hl(
			0,
			"LazywalPreview" .. i,
			{ fg = p["color" .. i] or "#ffffff", bold = true }
		)
		vim.api.nvim_buf_add_highlight(buf, -1, "LazywalPreview" .. i, i, 1, 9)
	end
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = buf, silent = true })
end

local function maybe_reload()
	local palette = palette_mod.read(config.get())
	local previous = state.palette
	if previous and palette.source == previous.source and palette.mtime == previous.mtime then
		return
	end
	M.load()
end

---@param opts? lazywal.Config
function M.setup(opts)
	config.setup(opts)

	if not state.commands then
		state.commands = true

		vim.api.nvim_create_user_command("LazywalReload", function()
			M.reload()
			vim.notify("lazywal: palette reloaded", vim.log.levels.INFO)
		end, { desc = "Reload the lazywal palette and reapply highlights" })

		vim.api.nvim_create_user_command("LazywalSet", function(args)
			local slot, pct = args.args:match("^(%w+)%s+(%d+)$")
			if not slot then
				vim.notify("lazywal: usage :LazywalSet color1 80", vim.log.levels.WARN)
				return
			end
			M.set_percentage(slot, pct)
		end, { nargs = "+", desc = "Set the blend percentage of an ANSI color slot" })

		vim.api.nvim_create_user_command("LazywalPreview", function()
			M.preview()
		end, { desc = "Preview the current lazywal palette" })

		-- Short aliases for existing muscle memory.
		vim.api.nvim_create_user_command("WalReload", function()
			vim.cmd.LazywalReload()
		end, { desc = "Alias for :LazywalReload" })
		vim.api.nvim_create_user_command("WalSet", function(args)
			vim.cmd.LazywalSet(args.args)
		end, { nargs = "+", desc = "Alias for :LazywalSet" })
		vim.api.nvim_create_user_command("WalPreview", function()
			vim.cmd.LazywalPreview()
		end, { desc = "Alias for :LazywalPreview" })

		-- Reapply after lazy plugins have defined their own highlights.
		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy",
			once = true,
			callback = function()
				M.load()
			end,
		})

		-- React when hellwal/pywall regenerates its palette.
		vim.api.nvim_create_autocmd("FocusGained", {
			callback = maybe_reload,
		})
	end

	vim.cmd.colorscheme("lazywal")
end

return M
