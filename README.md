<div align="center">
  <h1 align="center">
    <img src="./logo.svg" alt="D2" />
  </h1>

The Vim plugin for [D2](https://d2lang.com) files.
<br />
<br />
</div>

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
