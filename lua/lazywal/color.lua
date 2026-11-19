--- Color helpers for the `lazywal` colorscheme.
local M = {}

--- Normalize a hex color to `#rrggbb`.
---@param hex string|nil
---@return string|nil
function M.normalize(hex)
	if type(hex) ~= "string" then
		return nil
	end
	local s = hex:gsub("^%s+", ""):gsub("%s+$", ""):lower():gsub("^#", "")
	if not s:match("^%x%x%x%x%x%x$") then
		return nil
	end
	return "#" .. s
end

return M
