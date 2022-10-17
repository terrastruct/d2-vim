if exists('b:did_indent')
  finish
endif
let b:did_indent = 1

setlocal indentexpr=D2Indent(v:lnum)
setlocal indentkeys=!^F,o,O,0},0],\|

function! D2Indent(ln) abort
  const l:pln = prevnonblank(a:ln-1)
  let l:indent = indent(l:pln)

  if getline(a:ln-2) !~ '\\$' && getline(a:ln-1) =~ '\\$'
    " Opening line continuation indents.
    let l:indent += shiftwidth()
  endif

  if getline(l:pln-1) =~ '\\$' && getline(l:pln) !~ '\\$'
    " Closing line continuation deindents.
    let l:indent -= shiftwidth()
  endif

  if getline(l:pln) =~ '|`\+[^|`[:space:]]*\s*$'
    " Opening |` indents.
    let l:indent += shiftwidth()
  endif

  if getline(a:ln) =~ '^\s*`\+|'
    " Closing `| deindents.
    let l:indent -= shiftwidth()
  endif

  if getline(l:pln) =~ '[{[]\s*' . '\%(#.*\)\?$'
    " Opening { or [ indents.
    let l:indent += shiftwidth()
  endif

  if getline(a:ln) =~ '^\s*[}\]]'
    " Closing } or ] deindents.
    let l:indent -= shiftwidth()
  endif

  if l:indent < 0
    return 0
  endif
  return l:indent
endfunction
