--- Small cache so startup only replays highlight groups, never recomputes them.
local M = {}

local cache_path = vim.fn.stdpath("cache") .. "/lazywal_theme.json"

---@param key string
---@return table|nil theme
function M.load(key)
	local f = io.open(cache_path, "r")
	if not f then
		return nil
	end
	local data = f:read("*a")
	f:close()
	local ok, decoded = pcall(vim.fn.json_decode, data)
	if not ok or type(decoded) ~= "table" or decoded.key ~= key then
		return nil
	end

	local cached = decoded.theme
	if type(cached) ~= "table" or type(cached.highlights) ~= "table" then
		return nil
	end

	-- JSON object keys are strings; restore integer indexes for the terminal colors.
	local terminal = {}
	for i = 0, 15 do
		terminal[i] = cached.terminal and cached.terminal[tostring(i)] or nil
	end

	return {
		highlights = cached.highlights,
		roles = cached.roles,
		background = cached.background,
		foreground = cached.foreground,
		terminal = terminal,
	}
end

---@param key string
---@param theme table
function M.save(key, theme)
	--- vim.fn.json_encode rejects tables with mixed key types, so keep this flat.
	local serializable = {
		highlights = theme.highlights,
		roles = theme.roles,
		background = theme.background,
		foreground = theme.roles and theme.roles.fg or theme.foreground,
		terminal = {},
	}
	for i = 0, 15 do
		serializable.terminal[tostring(i)] = theme.terminal[i]
	end

	local ok, data = pcall(vim.fn.json_encode, { key = key, theme = serializable })
	if not ok then
		return
	end
	local f = io.open(cache_path, "w")
	if not f then
		return
	end
	f:write(data)
	f:close()
end

function M.clear()
	vim.fn.delete(cache_path)
end

return M
