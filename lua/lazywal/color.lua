--- Color helpers for the `lazywal` colorscheme.
--- Only sRGB hex colors are used; everything is kept simple and predictable.
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

---@param hex string
---@return { r: number, g: number, b: number }
function M.to_rgb(hex)
	local s = M.normalize(hex) or "#000000"
	return {
		r = tonumber(s:sub(2, 3), 16),
		g = tonumber(s:sub(4, 5), 16),
		b = tonumber(s:sub(6, 7), 16),
	}
end

---@param rgb { r: number, g: number, b: number }
---@return string
function M.to_hex(rgb)
	local function byte(v)
		v = math.max(0, math.min(255, math.floor(v + 0.5)))
		return string.format("%02x", v)
	end
	return "#" .. byte(rgb.r) .. byte(rgb.g) .. byte(rgb.b)
end

--- Blend `fg` toward `bg` by `pct` percent (0 = bg, 100 = fg).
---@param fg string
---@param bg string
---@param pct number
---@return string
function M.mix(fg, bg, pct)
	local a, b = M.to_rgb(fg), M.to_rgb(bg)
	local p = math.max(0, math.min(100, pct)) / 100
	return M.to_hex({
		r = a.r * p + b.r * (1 - p),
		g = a.g * p + b.g * (1 - p),
		b = a.b * p + b.b * (1 - p),
	})
end

return M
