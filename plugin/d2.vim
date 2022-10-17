if exists('g:loaded_d2')
  finish
endif
let g:loaded_d2 = 1

call d2#add_default_block_string_syntaxes()
call d2#sync_markdown_fenced_languages()

augroup d2_syntax_post
  autocmd!
  autocmd Syntax d2 call d2#syntax_post()
augroup END
