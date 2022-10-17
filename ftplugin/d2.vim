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
