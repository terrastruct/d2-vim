if exists('s:loaded_d2')
  finish
endif
let s:loaded_d2 = 1

function! d2#add_default_block_string_syntaxes() abort
  let g:d2_block_string_syntaxes = get(g:, 'd2_block_string_syntaxes', {})
  if type(g:d2_block_string_syntaxes) != v:t_dict && empty(g:d2_block_string_syntaxes)
    return
  endif

  let g:d2_block_string_syntaxes = extend(g:d2_block_string_syntaxes, {
        \ 'd2': extend(['d2'], get(g:d2_block_string_syntaxes, 'd2', [])),
        \ 'markdown': extend(['md', 'markdown'], get(g:d2_block_string_syntaxes, 'markdown', [])),
        \ 'javascript': extend(['javascript', 'js'], get(g:d2_block_string_syntaxes, 'javascript', [])),
        \ 'html': extend(['html'], get(g:d2_block_string_syntaxes, 'html', [])),
        \ 'json': extend(['json'], get(g:d2_block_string_syntaxes, 'json', [])),
        \ 'c': extend(['c'], get(g:d2_block_string_syntaxes, 'c', [])),
        \ 'go': extend(['go'], get(g:d2_block_string_syntaxes, 'go', [])),
        \ 'sh': extend(['sh', 'ksh', 'bash'], get(g:d2_block_string_syntaxes, 'sh', [])),
        \ 'css': extend(['css'], get(g:d2_block_string_syntaxes, 'css', [])),
        \ 'vim': extend(['vim'], get(g:d2_block_string_syntaxes, 'vim', [])),
        \ })
endfunction

function! d2#init_syn() abort
  syn case match
  syn sync fromstart
endfunction

function! d2#init_block_string_syntaxes() abort
  let b:included_syntaxes = get(b:, 'included_syntaxes', [])
  if exists('g:d2_block_string_syntaxes') == 0 || type(g:d2_block_string_syntaxes) != v:t_dict || empty(g:d2_block_string_syntaxes) == 1
    return
  endif

  for [l:syntax, l:tags] in items(g:d2_block_string_syntaxes)
    for l:tag in l:tags
      call d2#syn_block_string(l:syntax, l:tag)
    endfor
  endfor
endfunction

function! d2#syn_block_string(syntax, tag) abort
  let l:contains = ''
  let l:contained_group = 'd2BlockString'
  if a:syntax != ''
    let l:contained_group = 'd2BlockString'.substitute(a:syntax, '.', '\u\0', '')
    let l:contains = 'contains=@'.l:contained_group

    if a:syntax == 'markdown' &&
          \ index(b:included_syntaxes, a:syntax) == -1 &&
          \ get(g:, 'main_syntax', '') == 'markdown'
      " See comment on include_toplevel_markdown.
      call s:include_toplevel_markdown(l:contained_group)
    elseif a:syntax == 'd2'
      let l:contains = 'contains=TOP'
    else
      call s:include_syn(a:syntax, l:contained_group)
    endif
  endif

  " See nested-markdown-block-string-test for extend and keepend. We don't want parents or
  " children matching on our end pattern unless they too have extend and keepend set. i.e
  " recursive block strings.
  exe 'syn region '.l:contained_group.' matchgroup=d2BlockStringDelimiter start=/|\z(`\+\)'.a:tag.'[\n[:space:]]/ end=/`\@<!\z1|/ contained '.l:contains.' extend keepend'
  exe 'syn cluster d2BlockString add='.l:contained_group
endfunction

function! s:include_syn(syntax, contained_group) abort
  if index(b:included_syntaxes, a:syntax) != -1
    return
  endif
  if a:syntax == 'markdown'
    call d2#sync_markdown_fenced_languages()
  endif

  let b:included_syntaxes = add(b:included_syntaxes, a:syntax)

  exe 'syn include @'.a:contained_group.' syntax/'.a:syntax.'.vim'
  unlet b:current_syntax
  syn sync clear
  syn iskeyword clear
  call d2#init_syn()
endfunction

function! d2#sync_markdown_fenced_languages() abort
  if type(g:d2_block_string_syntaxes) != v:t_dict && empty(g:d2_block_string_syntaxes)
    return
  endif

  let g:markdown_fenced_languages = get(g:, 'markdown_fenced_languages', [])

  " Sync from g:d2_block_string_syntaxes to g:markdown_fenced_languages
  for [l:syntax, l:tags] in items(g:d2_block_string_syntaxes)
    for l:tag in l:tags
      if l:syntax == 'markdown'
        " markdown.vim isn't smart enough to not include itself.
        continue
      elseif l:syntax == 'vim'
        " markdown.vim is unable to embed the vim syntax.
        continue
      endif
      let l:line = l:tag
      if l:tag != l:syntax
        let l:line .= '='.l:syntax
      endif
      if index(g:markdown_fenced_languages, l:line) == -1
        let g:markdown_fenced_languages = add(g:markdown_fenced_languages, l:line)
      endif
    endfor
  endfor

  " Sync from g:markdown_fenced_languages to g:d2_block_string_syntaxes
  for l:syntax in g:markdown_fenced_languages
    let l:md_tag = matchstr(l:syntax, '^[^=]\+')
    let l:syntax = matchstr(l:syntax, '[^=]\+$')
    if l:syntax == ''
      let l:syntax = l:md_tag
    endif
    let l:bs_tags = get(g:d2_block_string_syntaxes, l:syntax, [])
    if index(l:bs_tags, l:md_tag) == -1
      let g:d2_block_string_syntaxes = extend(g:d2_block_string_syntaxes, {
            \ l:syntax: extend(l:bs_tags, [l:md_tag]),
            \ })
    endif
  endfor
endfunction

function! d2#syntax_post() abort
  let b:included_syntaxes = get(b:, 'included_syntaxes', [])
  if index(b:included_syntaxes, 'markdown') != -1
    if hlexists('markdownCodeBlock')
      syn clear markdownCodeBlock
    endif

    syn cluster d2BlockStringMarkdown add=@markdownBlock
  endif
endfunction

" include_toplevel_markdown is called when markdown is the top level syntax and is
" embedding us. We cannot directly include it as markdown.vim errors on being recursively
" included but we can explicitly include its TOP groups except markdownCodeBlock.
" See $VIMRUNTIME/syntax/markdown.vim
function! s:include_toplevel_markdown(contained_group) abort
  syn cluster d2MarkdownBlock contains=markdownH1,markdownH2,markdownH3,markdownH4,markdownH5,markdownH6,markdownBlockquote,markdownListMarker,markdownOrderedListMarker,markdownRule
  syn match d2MarkdownLineStart "^[<@]\@!" nextgroup=@d2MarkdownBlock,htmlSpecialChar
  " Run :syn list @d2BlockStringMarkdown in a d2 file to see the TOP markdown groups.
  let l:contains = 'contains=markdownItalic,htmlError,htmlSpecialChar,htmlEndTag,htmlCssDefinition,htmlTag,htmlComment,htmlPreProc,htmlLink,javaScript,htmlStrike,htmlBold,htmlUnderline,htmlItalic,htmlH1,htmlH2,htmlH3,htmlH4,htmlH5,htmlH6,htmlTitle,cssStyle,htmlHead,markdownValid,d2MarkdownLineStart,markdownLineBreak,markdownLinkText,markdownBold,markdownCode,markdownEscape,markdownError,markdownAutomaticLink,markdownIdDeclaration,markdownBoldItalic,markdownFootnote,markdownFootnoteDefinition,@d2MarkdownBlock,@markdownInline'

  let g:markdown_fenced_languages = get(g:, 'markdown_fenced_languages', [])
  for l:syntax in g:markdown_fenced_languages
    let l:syntax = matchstr(l:syntax, '^[^=]\+')
    let l:contains .= ',markdownHighlight'.substitute(l:syntax, '\.', '', 'g')
  endfor

  exe 'syn cluster '.a:contained_group.' '.l:contains
endfunction
