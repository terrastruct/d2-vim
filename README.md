<div align="center">
  <h1 align="center">
    <img src="./logo.svg" alt="D2" />
  </h1>

The Vim plugin for [D2](https://d2lang.com) files.
<br />
<br />
</div>

## Table of Contents

- [Install](#install)
- [Features](#features)
  - [ASCII Preview](#ascii-preview)
  - [Auto-formatting](#auto-formatting)  
  - [Validation](#validation)
  - [Playground](#playground)
- [Documentation](#documentation)

## Install

### Using [vim-plug](https://github.com/junegunn/vim-plug)
```vim
Plug 'terrastruct/d2-vim'
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
  "terrastruct/d2-vim",
  ft = { "d2" },
}
```

## Features

### ASCII Preview
Render D2 diagrams as ASCII text for quick preview without leaving Vim. This feature provides a live preview of your diagrams in text format, perfect for:
- Quick previews without external tools
- Working in terminal environments
- Sharing diagrams in text-only contexts
- Understanding diagram structure while editing

The ASCII preview opens in a vertical split pane and automatically updates when you save your D2 file.

**Requirements:** D2 version 0.7.1 or higher is required for ASCII output features.

#### Configuration

```vim
" Enable/disable auto ASCII render on save (default: 1)
let g:d2_ascii_autorender = 1

" Customize the ASCII render command (default: "d2")
let g:d2_ascii_command = "d2"

" Set preview window width for vertical split (default: half screen)
let g:d2_ascii_preview_width = &columns / 2

" Set ASCII mode: "extended" (Unicode) or "standard" (basic ASCII)
let g:d2_ascii_mode = "extended"
```

#### ASCII Modes

**Extended Mode (default)**: Uses Unicode box-drawing characters for cleaner, more readable output:
```
┌─────────────┐     ┌──────────────┐
│    user     │────▶│   server     │
└─────────────┘     └──────────────┘
```

**Standard Mode**: Uses basic ASCII characters for maximum compatibility:
```
+-------------+     +--------------+
|    user     |---->|   server     |
+-------------+     +--------------+
```

#### Commands
- `:D2Preview` - Render current buffer as ASCII in preview window
- `:D2PreviewToggle` - Toggle ASCII preview window on/off
- `:D2PreviewUpdate` - Update existing preview window with current content
- `:D2AsciiToggle` - Toggle automatic ASCII rendering on save
- `:D2PreviewSelection` - Render selected text as ASCII (works in any file)

#### Keybindings
- `<Leader>d2` - Render selected text as ASCII (visual mode, any file)
- `<Leader>d2` - Render entire buffer as ASCII (normal mode, D2 files only)

### Auto-formatting
D2 files are automatically formatted on save using `d2 fmt`. This can be configured:

```vim
" Enable/disable auto format on save (default: 1)
let g:d2_fmt_autosave = 1

" Customize the format command (default: "d2 fmt")
let g:d2_fmt_command = "d2 fmt"

" Fail silently when formatting fails (default: 0)
let g:d2_fmt_fail_silently = 0
```

Commands:
- `:D2Fmt` - Format current buffer
- `:D2FmtToggle` - Toggle auto format on save

### Validation
D2 files can be validated using `d2 validate`. This can be configured:

```vim
" Enable/disable auto validate on save (default: 0)
let g:d2_validate_autosave = 0

" Customize the validate command (default: "d2 validate")
let g:d2_validate_command = "d2 validate"

" Use quickfix or locationlist for errors (default: "quickfix")
let g:d2_list_type = "quickfix"

" Fail silently when validation fails (default: 0)
let g:d2_validate_fail_silently = 0
```

Commands:
- `:D2Validate` - Validate current buffer
- `:D2ValidateToggle` - Toggle auto validate on save

### Playground
Open D2 files in the online playground at [play.d2lang.com](https://play.d2lang.com). This
is useful for an ad-hoc way of sharing your d2 diagram with someone.

```vim
" Customize the play command (default: "d2 play")
let g:d2_play_command = "d2 play"

" Set the theme ID (default: 0)
let g:d2_play_theme = 0

" Enable sketch mode (default: 0)
let g:d2_play_sketch = 0
```

Commands:
- `:D2Play` - Open current buffer in D2 playground

## Documentation

See `:help d2-vim` or [./doc/d2.txt](./doc/d2.txt) for options and additional documentation.
