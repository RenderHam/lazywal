--- Palette discovery for the `lazywal` colorscheme.
--- Reads generated palettes from hellwal or pywall without ever sourcing them.
local color = require("lazywal.color")

local M = {}

--- Used when no generated palette can be found.
M.fallback = {
	background = "#101014",
	foreground = "#d8d8d8",
	cursor = "#d8d8d8",
	color0 = "#101014",
	color1 = "#b84848",
	color2 = "#6fa860",
	color3 = "#c0a050",
	color4 = "#6080c0",
	color5 = "#a060a0",
	color6 = "#509090",
	color7 = "#d8d8d8",
	color8 = "#303038",
	color9 = "#e07070",
	color10 = "#98c888",
	color11 = "#e0c070",
	color12 = "#88a8e0",
	color13 = "#c888c8",
	color14 = "#78b8b8",
	color15 = "#ffffff",
	source = "fallback",
}

local function parse_vim(lines)
	local p = {}
	for _, line in ipairs(lines) do
		local key, value = line:match("let%s+([%w_]+)%s*=%s*[\"']([^\"']+)[\"']")
		if key and value then
			local hex = color.normalize(value)
			if hex then
				p[key] = hex
			end
		end
	end
	return p.color0 and p or nil
end

local function parse_sh(lines)
	local p = {}
	for _, line in ipairs(lines) do
		if not line:match("^%s*#") then
			local key, value = line:match("^%s*([%w_]+)%s*=%s*(%x+)%s*$")
			if key and value then
				p[key] = color.normalize("#" .. value)
			end
		end
	end
	return p.color0 and p or nil
end

local function parse_json(lines)
	local ok, data = pcall(vim.fn.json_decode, table.concat(lines, "\n"))
	if not ok or type(data) ~= "table" then
		return nil
	end
	local p = {}
	if type(data.colors) == "table" then
		for key, value in pairs(data.colors) do
			p[key] = color.normalize(value)
		end
	end
	if type(data.special) == "table" then
		for key, value in pairs(data.special) do
			p[key] = color.normalize(value)
		end
	end
	return p.color0 and p or nil
end

local function parse_list(lines)
	local p = {}
	for i = 0, 15 do
		p["color" .. i] = color.normalize(lines[i + 1])
	end
	return p.color0 and p or nil
end

local function parser_for(path)
	if path:match("%.vim$") then
		return parse_vim
	elseif path:match("%.json$") then
		return parse_json
	elseif path:match("%.sh$") then
		return parse_sh
	end
	return parse_list
end

local function candidates(opts)
	if opts.palette_path then
		return { vim.fn.expand(opts.palette_path) }
	end
	local base = vim.fn.expand("~")
	local hellwal = base .. "/.cache/hellwal/"
	local pywall = base .. "/.cache/wal/"
	if opts.generator == "hellwal" then
		return { hellwal .. "colors-wal.vim", hellwal .. "colors.sh" }
	elseif opts.generator == "pywall" then
		return { pywall .. "colors.json", pywall .. "colors" }
	end
	return {
		hellwal .. "colors-wal.vim",
		hellwal .. "colors.sh",
		pywall .. "colors.json",
		pywall .. "colors",
	}
end

---@param opts table
---@return table palette with color0..color15, background, foreground, cursor, source
function M.read(opts)
	for _, path in ipairs(candidates(opts)) do
		if vim.fn.filereadable(path) == 1 then
			local lines = vim.fn.readfile(path)
			local parsed = parser_for(path)(lines)
			if parsed then
				for key, value in pairs(M.fallback) do
					if key ~= "source" and not parsed[key] then
						parsed[key] = value
					end
				end
				parsed.source = path
				parsed.mtime = vim.fn.getftime(path)
				return parsed
			end
		end
	end
	return vim.deepcopy(M.fallback)
end

return M
