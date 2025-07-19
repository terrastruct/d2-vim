" d2#validate#Validate validates the current buffer using d2 validate
function! d2#validate#Validate() abort
  " Save current buffer to a temporary file
  let l:tmpname = tempname() . '.d2'
  silent execute 'write! ' . fnameescape(l:tmpname)

  " Run d2 validate
  let l:cmd = get(g:, 'd2_validate_command', 'd2 validate') . ' ' . shellescape(l:tmpname)
  let l:output = system(l:cmd)
  let l:exit_code = v:shell_error

  " Clean up temp file
  call delete(l:tmpname)

  " Clear previous errors
  let l:list_type = get(g:, 'd2_list_type', 'quickfix')
  if l:list_type == 'locationlist'
    call setloclist(0, [], 'r')
  else
    call setqflist([], 'r')
  endif

  " If validation passed, notify and return
  if l:exit_code == 0
    echo "D2 validation passed"
    return
  endif

  " Parse errors from output
  let l:errors = []
  let l:filename = expand('%:p')
  
  " D2 error format: "err: [path:] line:col: message"
  for l:line in split(l:output, '\n')
    if l:line =~ '^err:'
      let l:parts = matchlist(l:line, '^err:\s*\%(.*:\s*\)\?\(\d\+\):\(\d\+\):\s*\(.*\)')
      if len(l:parts) > 3
        call add(l:errors, {
          \ 'filename': l:filename,
          \ 'lnum': str2nr(l:parts[1]),
          \ 'col': str2nr(l:parts[2]),
          \ 'text': l:parts[3],
          \ 'type': 'E'
          \ })
      endif
    endif
  endfor

  " Populate error list
  if !empty(l:errors)
    if l:list_type == 'locationlist'
      call setloclist(0, l:errors, 'r')
      if !get(g:, 'd2_validate_fail_silently', 0)
        lopen
      endif
    else
      call setqflist(l:errors, 'r')
      if !get(g:, 'd2_validate_fail_silently', 0)
        copen
      endif
    endif
  else
    " If we couldn't parse errors, show the raw output
    echohl ErrorMsg
    echo "D2 validation failed: " . substitute(l:output, '\n', ' ', 'g')
    echohl None
  endif
endfunction

" d2#validate#ToggleAutoValidate toggles the auto validate on save setting
function! d2#validate#ToggleAutoValidate() abort
  let g:d2_validate_autosave = !get(g:, 'd2_validate_autosave', 0)
  if g:d2_validate_autosave
    echo "D2 auto validate on save: enabled"
  else
    echo "D2 auto validate on save: disabled"
  endif
endfunction