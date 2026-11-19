# lazywal

A Neovim colorscheme that takes its palette from your wallpaper generator
([hellwal](https://github.com/HiImFerris/hellwal) or
[pywall](https://github.com/pywal/pywal)) instead of hard-coding colors.

Each of the 16 ANSI colors has a **blend percentage toward the background**, so
you can tame aggressive wallpaper colors without changing their hue: `0` = fully
blended into the background, `100` = the raw palette color.

## Requirements

- Neovim 0.12+
- Optional: `hellwal` or `pywall`. If neither is installed, a built-in fallback
  palette is used, so the colorscheme still loads.

## Installation (lazy.nvim)

```lua
{
  "RenderHam/lazywal",
  lazy = false,
  priority = 1000,
  config = function()
    require("lazywal").setup({
      percentages = {
        color1 = 85, -- errors
        color2 = 75, -- strings
        color7 = 100, -- foreground
      },
    })
  end,
}
```

## Configuration

```lua
require("lazywal").setup({
  generator = "auto",          -- "auto" | "hellwal" | "pywall"
  palette_path = nil,          -- custom path to a generated palette file
  percentages = {
    color0 = 100, color1 = 85, color2 = 75, color3 = 85,
    color4 = 90, color5 = 80, color6 = 80, color7 = 100,
    color8 = 100, color9 = 85, color10 = 75, color11 = 85,
    color12 = 90, color13 = 80, color14 = 80, color15 = 100,
  },
  transparent = false,
  terminal_colors = true,
  styles = { comments = { italic = true } },
  overrides = function(colors)
    return { Comment = { fg = colors.grey, italic = true } }
  end,
})
```

Palette sources, in order:

1. `~/.cache/hellwal/colors-wal.vim`
2. `~/.cache/hellwal/colors.sh`
3. `~/.cache/wal/colors.json`
4. `~/.cache/wal/colors`

Generated files are parsed as text, never sourced.

## Commands

| Command | Action |
| --- | --- |
| `:LazywalPreview` | Show the 16 adjusted colors with their percentages |
| `:LazywalSet color1 80` | Change one percentage live and reapply |
| `:LazywalReload` | Re-read the generator output and reapply |

The adjusted palette is exported to `g:terminal_color_0..15` so Neovim's terminal
matches the editor. Highlights are cached in `~/.cache/nvim/lazywal_theme.json`
and invalidated when the palette file or your options change.

## License

MIT
