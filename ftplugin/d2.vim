if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

" d2 files indent with 2 spaces.
setlocal expandtab
setlocal tabstop=2
setlocal shiftwidth=0
setlocal softtabstop=0

" Disable autowrapping.
setlocal formatoptions-=t

setlocal comments=b:#
let &l:commentstring = '# %s'

" Format on save configuration
if !exists("g:d2_fmt_autosave")
  let g:d2_fmt_autosave = 1
endif

if !exists("g:d2_fmt_command")
  let g:d2_fmt_command = "d2 fmt"
endif

if !exists("g:d2_fmt_fail_silently")
  let g:d2_fmt_fail_silently = 0
endif

" Auto format on save
augroup d2_ftplugin
  autocmd!
  if get(g:, "d2_fmt_autosave", 1)
    autocmd BufWritePre *.d2 call d2#fmt#Format()
  endif
augroup END

" Validation configuration
if !exists("g:d2_validate_autosave")
  let g:d2_validate_autosave = 0
endif

if !exists("g:d2_validate_command")
  let g:d2_validate_command = "d2 validate"
endif

if !exists("g:d2_validate_fail_silently")
  let g:d2_validate_fail_silently = 0
endif

if !exists("g:d2_list_type")
  let g:d2_list_type = "quickfix"
endif

" Play configuration
if !exists("g:d2_play_command")
  let g:d2_play_command = "d2 play"
endif

if !exists("g:d2_play_theme")
  let g:d2_play_theme = 0
endif

if !exists("g:d2_play_sketch")
  let g:d2_play_sketch = 0
endif

" ASCII render configuration
if !exists("g:d2_ascii_command")
  let g:d2_ascii_command = "d2"
endif

if !exists("g:d2_ascii_preview_width")
  let g:d2_ascii_preview_width = &columns / 2
endif

if !exists("g:d2_ascii_autorender")
  let g:d2_ascii_autorender = 1
endif

if !exists("g:d2_ascii_mode")
  let g:d2_ascii_mode = "extended"
endif

" Auto validate on save (runs after formatting)
augroup d2_validate
  autocmd!
  if get(g:, "d2_validate_autosave", 0)
    autocmd BufWritePost *.d2 call d2#validate#Validate()
  endif
augroup END

" Auto ASCII render on save
augroup d2_ascii
  autocmd!
  if get(g:, "d2_ascii_autorender", 1)
    autocmd BufWritePost *.d2 call d2#ascii#PreviewUpdate()
  endif
augroup END

" Commands
command! -buffer D2Fmt call d2#fmt#Format()
command! -buffer D2FmtToggle call d2#fmt#ToggleAutoFormat()
command! -buffer D2Validate call d2#validate#Validate()
command! -buffer D2ValidateToggle call d2#validate#ToggleAutoValidate()
command! -buffer D2Play call d2#play#Play()
command! -buffer D2Preview call d2#ascii#Preview()
command! -buffer D2PreviewToggle call d2#ascii#PreviewToggle()
command! -buffer D2PreviewUpdate call d2#ascii#PreviewUpdate()
command! -buffer D2AsciiToggle call d2#ascii#ToggleAutoRender()

" Normal mode mapping for D2 files - preview entire buffer
nnoremap <buffer> <Leader>d2 :D2Preview<CR>
