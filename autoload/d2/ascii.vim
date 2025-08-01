" Check if d2 version supports ASCII output
function! s:check_d2_version() abort
  let l:cmd = get(g:, 'd2_ascii_command', 'd2') . ' version'
  let l:result = system(l:cmd)
  
  if v:shell_error != 0
    return {'valid': 0, 'version': 'unknown', 'error': 'd2 command not found or failed'}
  endif
  
  " Extract version number (format: "d2 version v0.7.1")
  let l:version_match = matchstr(l:result, 'v\?\zs\d\+\.\d\+\.\d\+')
  if l:version_match == ''
    return {'valid': 0, 'version': 'unknown', 'error': 'could not parse version'}
  endif
  
  " Parse version components
  let l:parts = split(l:version_match, '\.')
  if len(l:parts) != 3
    return {'valid': 0, 'version': l:version_match, 'error': 'invalid version format'}
  endif
  
  let l:major = str2nr(l:parts[0])
  let l:minor = str2nr(l:parts[1])
  let l:patch = str2nr(l:parts[2])
  
  " Check if version >= 0.7.1
  let l:valid = 0
  if l:major > 0
    let l:valid = 1
  elseif l:major == 0 && l:minor > 7
    let l:valid = 1
  elseif l:major == 0 && l:minor == 7 && l:patch >= 1
    let l:valid = 1
  endif
  
  return {'valid': l:valid, 'version': l:version_match, 'error': ''}
endfunction

" d2#ascii#Preview renders the current buffer as ASCII in a preview window
function! d2#ascii#Preview() abort
  let l:version_check = s:check_d2_version()
  if !l:version_check.valid
    echohl ErrorMsg
    if l:version_check.version != 'unknown'
      echo 'd2 ASCII preview requires version 0.7.1+. Current version: ' . l:version_check.version
    else
      echo 'd2 ASCII preview requires version 0.7.1+. ' . l:version_check.error
    endif
    echohl None
    return
  endif
  let l:tmpname = tempname() . '.d2'
  let l:output_file = tempname() . '.txt'
  
  silent execute 'write! ' . fnameescape(l:tmpname)
  
  let l:cmd = get(g:, 'd2_ascii_command', 'd2')
  
  " Add ascii-mode flag if not extended
  let l:ascii_mode = get(g:, 'd2_ascii_mode', 'extended')
  if l:ascii_mode == 'standard'
    let l:cmd .= ' --ascii-mode=standard'
  endif
  
  let l:cmd .= ' ' . shellescape(l:tmpname) . ' ' . shellescape(l:output_file)
  
  let l:result = system(l:cmd)
  let l:exit_code = v:shell_error
  
  call delete(l:tmpname)
  
  if l:exit_code != 0
    echohl ErrorMsg
    echo 'd2 ascii render failed: ' . substitute(l:result, '\n$', '', '')
    echohl None
    if filereadable(l:output_file)
      call delete(l:output_file)
    endif
    return
  endif
  
  if !filereadable(l:output_file)
    echohl ErrorMsg
    echo 'd2 ascii render failed: output file not created'
    echohl None
    return
  endif
  
  call s:show_ascii_preview(l:output_file)
  call delete(l:output_file)
endfunction

" d2#ascii#PreviewToggle toggles the ASCII preview window
function! d2#ascii#PreviewToggle() abort
  if s:preview_window_exists()
    call s:close_preview_window()
  else
    call d2#ascii#Preview()
  endif
endfunction

" d2#ascii#PreviewUpdate updates the existing ASCII preview
function! d2#ascii#PreviewUpdate() abort
  if s:preview_window_exists()
    let l:current_win = winnr()
    call d2#ascii#Preview()
    execute l:current_win . 'wincmd w'
  endif
endfunction

" Show ASCII content in a preview window
function! s:show_ascii_preview(output_file) abort
  let l:preview_width = get(g:, 'd2_ascii_preview_width', 80)
  
  " Close existing preview if it exists
  call s:close_preview_window()
  
  " Create new vertical preview window
  execute 'vertical botright ' . l:preview_width . 'split D2_ASCII_PREVIEW'
  
  " Configure the preview buffer
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  setlocal nowrap
  setlocal filetype=
  setlocal foldcolumn=0
  setlocal nofoldenable
  setlocal nonumber
  setlocal norelativenumber
  setlocal nospell
  
  " Read the ASCII content
  execute 'read ' . fnameescape(a:output_file)
  
  " Remove the empty first line
  1delete
  
  " Go back to original window
  wincmd p
endfunction

" Check if ASCII preview window exists
function! s:preview_window_exists() abort
  return bufwinnr('D2_ASCII_PREVIEW') != -1
endfunction

" Close ASCII preview window
function! s:close_preview_window() abort
  let l:preview_winnr = bufwinnr('D2_ASCII_PREVIEW')
  if l:preview_winnr != -1
    execute l:preview_winnr . 'wincmd w'
    close
    wincmd p
  endif
endfunction

" d2#ascii#ToggleAutoRender toggles automatic ASCII rendering on save
function! d2#ascii#ToggleAutoRender() abort
  let g:d2_ascii_autorender = !get(g:, 'd2_ascii_autorender', 1)
  if g:d2_ascii_autorender
    echo 'Auto ASCII render enabled'
  else
    echo 'Auto ASCII render disabled'
  endif
endfunction

" d2#ascii#CopyPreview copies the ASCII preview window content to clipboard
function! d2#ascii#CopyPreview() abort
  if !s:preview_window_exists()
    echohl ErrorMsg
    echo 'No ASCII preview window open'
    echohl None
    return
  endif
  
  let l:current_win = winnr()
  let l:preview_winnr = bufwinnr('D2_ASCII_PREVIEW')
  
  " Switch to preview window
  execute l:preview_winnr . 'wincmd w'
  
  " Get all lines from the preview buffer
  let l:lines = getline(1, '$')
  let l:content = join(l:lines, "\n")
  
  " Copy to clipboard and yank register
  let @+ = l:content
  let @* = l:content
  let @" = l:content
  
  " Switch back to original window
  execute l:current_win . 'wincmd w'
  
  echo 'ASCII preview copied to clipboard'
endfunction

" d2#ascii#PreviewSelection renders selected D2 code as ASCII
function! d2#ascii#PreviewSelection() range abort
  let l:version_check = s:check_d2_version()
  if !l:version_check.valid
    echohl ErrorMsg
    if l:version_check.version != 'unknown'
      echo 'd2 ASCII preview requires version 0.7.1+. Current version: ' . l:version_check.version
    else
      echo 'd2 ASCII preview requires version 0.7.1+. ' . l:version_check.error
    endif
    echohl None
    return
  endif
  let l:tmpname = tempname() . '.d2'
  let l:output_file = tempname() . '.txt'
  
  " Get selected text
  let l:lines = getline(a:firstline, a:lastline)
  
  " Write selected content to temp file
  call writefile(l:lines, l:tmpname)
  
  let l:cmd = get(g:, 'd2_ascii_command', 'd2')
  
  " Add ascii-mode flag if not extended
  let l:ascii_mode = get(g:, 'd2_ascii_mode', 'extended')
  if l:ascii_mode == 'standard'
    let l:cmd .= ' --ascii-mode=standard'
  endif
  
  let l:cmd .= ' ' . shellescape(l:tmpname) . ' ' . shellescape(l:output_file)
  
  let l:result = system(l:cmd)
  let l:exit_code = v:shell_error
  
  call delete(l:tmpname)
  
  if l:exit_code != 0
    echohl ErrorMsg
    echo 'd2 selection render failed: ' . substitute(l:result, '\n$', '', '')
    echohl None
    if filereadable(l:output_file)
      call delete(l:output_file)
    endif
    return
  endif
  
  if !filereadable(l:output_file)
    echohl ErrorMsg
    echo 'd2 selection render failed: output file not created'
    echohl None
    return
  endif
  
  call s:show_ascii_preview(l:output_file)
  call delete(l:output_file)
endfunction

