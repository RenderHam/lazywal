--- lazywal — a wallpaper-driven colorscheme.
--- Palette comes from hellwal/pywall; roles decide which color goes where.
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
	vim.g.lazywal_roles = theme.roles
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

function M.preview()
	local p = state.palette or palette_mod.read(config.get())
	local lines = {}
	for i = 0, 15 do
		local slot = "color" .. i
		lines[i + 1] = string.format(" %-8s %s", slot, p[slot] or "#------")
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

function M.roles_preview()
	local roles = state.theme and state.theme.roles or {}
	local configured = config.get().roles or {}
	local names = vim.tbl_keys(roles)
	table.sort(names)

	local lines = {}
	for i, name in ipairs(names) do
		lines[i] = string.format(
			" %-14s %-12s %s",
			name,
			tostring(configured[name] or ""),
			roles[name] or "#------"
		)
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = 52,
		height = math.min(#lines, 36),
		row = 2,
		col = 2,
		border = "rounded",
		title = " lazywal roles ",
		title_pos = "center",
	})

	for i, name in ipairs(names) do
		vim.api.nvim_set_hl(
			0,
			"LazywalRolePreview" .. i,
			{ fg = roles[name] or "#ffffff", bold = true }
		)
		vim.api.nvim_buf_add_highlight(buf, -1, "LazywalRolePreview" .. i, i - 1, 29, -1)
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

		vim.api.nvim_create_user_command("LazywalRoles", function()
			M.roles_preview()
		end, { desc = "Show which color each lazywal role uses" })

		vim.api.nvim_create_user_command("LazywalPreview", function()
			M.preview()
		end, { desc = "Preview the current lazywal palette" })

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
