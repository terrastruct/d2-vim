" d2#fmt#Format formats the current buffer using d2 fmt
function! d2#fmt#Format() abort
  " Don't format if buffer is not modifiable
  if !&modifiable
    return
  endif

  " Save current view
  let l:view = winsaveview()
  
  " Save current buffer to a temporary file
  let l:tmpname = tempname() . '.d2'
  silent execute 'keepalt write! ' . fnameescape(l:tmpname)

  " Run d2 fmt
  let l:cmd = get(g:, 'd2_fmt_command', 'd2 fmt') . ' ' . shellescape(l:tmpname)
  let l:output = system(l:cmd)
  let l:exit_code = v:shell_error

  " Handle errors
  if l:exit_code != 0
    call delete(l:tmpname)
    if !get(g:, 'd2_fmt_fail_silently', 0)
      echohl ErrorMsg
      echom 'd2 fmt failed: ' . substitute(l:output, '\n$', '', '')
      echohl None
    endif
    return
  endif

  " Get the current buffer content for comparison
  let l:current = getline(1, '$')
  
  " Read the formatted file
  let l:formatted = readfile(l:tmpname)
  
  " Clean up temp file
  call delete(l:tmpname)
  
  " Only update if content changed
  if l:formatted != l:current
    " Preserve undo history
    let l:undofile = &undofile
    let l:undodir = &undodir
    try
      set noundofile
      
      " Replace buffer content
      let l:modified_save = &modified
      silent! undojoin
      silent execute '1,$delete _'
      call setline(1, l:formatted)
      
      " Preserve modified state
      if !l:modified_save
        setlocal nomodified
      endif
    finally
      " Restore undo settings
      let &undofile = l:undofile
      let &undodir = l:undodir
    endtry
    
    " Force syntax sync
    syntax sync fromstart
  endif
  
  " Restore view
  call winrestview(l:view)
endfunction

" d2#fmt#ToggleAutoFormat toggles the auto format on save setting
function! d2#fmt#ToggleAutoFormat() abort
  let g:d2_fmt_autosave = !get(g:, 'd2_fmt_autosave', 1)
  if g:d2_fmt_autosave
    echo "D2 auto format on save: enabled"
  else
    echo "D2 auto format on save: disabled"
  endif
endfunction