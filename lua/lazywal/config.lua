local M = {}

---@class lazywal.Config
M.options = {
	generator = "auto", --- "auto" | "hellwal" | "pywall"
	palette_path = nil, --- custom path to a generated palette file

	--- Logical role -> palette slot (`color0`..`color15`, `background`,
	--- `foreground`, `cursor`) or a raw `#rrggbb` value.
	roles = {
		-- Base
		bg = "background",
		fg = "foreground",
		bg_alt = "color8",
		subtle = "color8",
		selection = "color8",

		-- Syntax
		comment = "color8",
		string = "color2",
		number = "color3",
		constant = "color6",
		variable = "foreground",
		parameter = "foreground",
		property = "foreground",
		func = "color4",
		method = "color4",
		keyword = "color5",
		operator = "color5",
		exception = "color9",
		type = "color6",
		tag = "color4",
		punctuation = "foreground",
		special = "color3",

		-- Diagnostics
		error = "color1",
		warn = "color3",
		info = "color4",
		hint = "color6",
		ok = "color2",

		-- UI
		search = "color3",
		linenr = "color8",
		border = "color8",
		heading = "color4",
		link = "color6",
		diff_add = "color2",
		diff_change = "color3",
		diff_delete = "color1",
		menu_sel_fg = "background",
		menu_sel_bg = "color4",
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
