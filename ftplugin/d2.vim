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

" Commands
command! -buffer D2Fmt call d2#fmt#Format()
command! -buffer D2FmtToggle call d2#fmt#ToggleAutoFormat()
