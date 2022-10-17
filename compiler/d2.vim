if exists('current_compiler')
  finish
endif
let current_compiler = 'd2c'

if exists(':CompilerSet') != 2
  command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet makeprg=d2c
