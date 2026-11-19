# lazywal

A Neovim colorscheme that takes its palette from your wallpaper generator
([hellwal](https://github.com/HiImFerris/hellwal) or
[pywall](https://github.com/pywal/pywal)) instead of hard-coding colors.

Colors are used **exactly as generated**. You freely choose which palette color
each logical role (comments, strings, functions, diagnostics, …) uses.

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
      -- your configuration
    })
  end,
}
```

## Configuration

`roles` maps a logical role to any of:

- a palette slot: `"color0"` … `"color15"`, `"background"`, `"foreground"`, `"cursor"`
- a raw hex value: `"#ff0000"`

No blending or percentage adjustment is applied — the selected color is used as-is.

```lua
require("lazywal").setup({
  generator = "auto", -- "auto" | "hellwal" | "pywall"
  palette_path = nil, -- custom path to a generated palette file

  roles = {
    comment = "color1",       -- comments use color1
    string = "color2",
    func = "color4",
    error = "color9",         -- bright variant
    warn = "#ffaa00",         -- raw color override
  },

  transparent = false,
  terminal_colors = true,
  styles = { comments = { italic = true } },

  overrides = function(colors)
    return { Comment = { fg = colors.comment, italic = true } }
  end,
})
```

`overrides` is the final escape hatch and wins over `roles` for individual
highlight groups.

### Available roles

| Category | Roles (default slot) |
| --- | --- |
| Base | `bg`=background, `fg`=foreground, `bg_alt`=color8, `subtle`=color8, `selection`=color8 |
| Syntax | `comment`=color8, `string`=color2, `number`=color3, `constant`=color6, `variable`=foreground, `parameter`=foreground, `property`=foreground, `func`=color4, `keyword`=color5, `operator`=color5, `exception`=color9, `type`=color6, `tag`=color4, `punctuation`=foreground, `special`=color3 |
| Diagnostics | `error`=color1, `warn`=color3, `info`=color4, `hint`=color6, `ok`=color2 |
| UI | `search`=color3, `linenr`=color8, `border`=color8, `heading`=color4, `link`=color6, `diff_add`=color2, `diff_change`=color3, `diff_delete`=color1, `menu_sel_fg`=background, `menu_sel_bg`=color4 |

Palette sources, in order:

1. `~/.cache/hellwal/colors-wal.vim`
2. `~/.cache/hellwal/colors.sh`
3. `~/.cache/wal/colors.json`
4. `~/.cache/wal/colors`

Generated files are parsed as text, never sourced.

## Commands

| Command | Action |
| --- | --- |
| `:LazywalRoles` | Show every role, its configured target, and the resolved color |
| `:LazywalPreview` | Show the 16 palette slots |
| `:LazywalReload` | Re-read the generator output and reapply |

The palette is exported to `g:lazywal_palette`, the resolved roles to
`g:lazywal_roles`, and terminal colors to `g:terminal_color_0..15`. Highlights are
cached in `~/.cache/nvim/lazywal_theme.json` and invalidated when the palette file
or your options change.

## License

MIT
