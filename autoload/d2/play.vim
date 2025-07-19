" d2#play#Play opens the current buffer in D2 playground
function! d2#play#Play() abort
  " Save current buffer to a temporary file
  let l:tmpname = tempname() . '.d2'
  silent execute 'write! ' . fnameescape(l:tmpname)

  " Build d2 play command with options
  let l:cmd = get(g:, 'd2_play_command', 'd2 play')
  
  " Add theme option
  let l:theme = get(g:, 'd2_play_theme', 0)
  let l:cmd .= ' --theme=' . l:theme
  
  " Add sketch option if enabled
  let l:sketch = get(g:, 'd2_play_sketch', 0)
  if l:sketch
    let l:cmd .= ' --sketch'
  endif
  
  " Add the file
  let l:cmd .= ' ' . shellescape(l:tmpname)
  
  " Execute the command
  let l:output = system(l:cmd)
  let l:exit_code = v:shell_error
  
  " Clean up temp file
  call delete(l:tmpname)
  
  " Handle result
  if l:exit_code != 0
    echohl ErrorMsg
    echo 'd2 play failed: ' . substitute(l:output, '\n$', '', '')
    echohl None
  else
    " d2 play outputs "info: opening playground: <url>" on success
    if l:output =~ 'opening playground:'
      echo 'D2 file opened in playground'
    else
      echo 'D2 play executed successfully'
    endif
  endif
endfunction

