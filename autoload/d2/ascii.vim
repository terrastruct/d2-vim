" d2#ascii#Preview renders the current buffer as ASCII in a preview window
function! d2#ascii#Preview() abort
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

" d2#ascii#PreviewSelection renders selected D2 code as ASCII
function! d2#ascii#PreviewSelection() range abort
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

