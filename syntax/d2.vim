if exists('b:current_syntax')
  finish
endif

call d2#init_syn()

" This only marks errors where additional input after the error will not fix the error.
" Thus it's not constantly marking things as errors while you type but only errors you
" need to go back and deal with.
syn region d2Error start=/\S/ end=/\%(\s*\n\)\@=/

" ********************************************************************************
" XXX: Caution
" ********************************************************************************
" Very carefully written. Please keep changes in sync with d2-vscode. The regex
" structure should map one to one.
"
" Keep the following delimiters in mind when making changes:
"
" top: \n#,[]{}
" val: |`$'"\
" key: :.-<>*&()
"
" vals regex: [\n#,[\]{}|`$'"\\]
" keys regex: [\n#,[\]{}|`$'"\\:.\-<>*&()]
"
" The main differences between Oniguruma and VimL regexes:
" - Lookahead and lookbehind syntax
" - Grouping syntax
" - | + don't need to be escaped
" - [ needs to be escaped in a character class
" - parent group's have to use a lookahead if they want children to be able to match on
"   their start.

" ********************************************************************************
" @d2String
" ********************************************************************************

syn region d2StringUnquoted start=/\%([,[{:]\%(\s*\\\n\)\?\s*\|\\\@<!\n\s*\)\@<=\%([^[:space:]\n#,[\]{}|`$'"\\]\|\${\)/ end=/\%(\s*[\n#,[\]{}|`'"]\)\@=/ contains=d2Substitution,@d2Escape contained
syn region d2StringQuotedSingle matchgroup=d2Delimiter start=/\%([,[{:]\%(\s*\\\n\)\?\s*\|\\\@<!\n\s*\|'\)\@<='/ end=/'\|\n\@=/ contains=d2LineContinuation        contained
syn region d2StringQuotedDouble matchgroup=d2Delimiter start=/\%([,[{:]\%(\s*\\\n\)\?\s*\|\\\@<!\n\s*\)\@<="/    end=/"\|\n\@=/ contains=d2Substitution,@d2Escape contained

hi def link d2StringUnquoted     d2String
hi def link d2StringQuotedSingle d2String
hi def link d2StringQuotedDouble d2String

call d2#syn_block_string('', '[^|`[:space:]]*')
call d2#init_block_string_syntaxes()
hi def link d2BlockString          d2String
hi def link d2BlockStringDelimiter d2Delimiter

syn cluster d2String contains=d2StringUnquoted,d2StringQuotedSingle,d2StringQuotedDouble,@d2BlockString

" ********************************************************************************
" d2Key
" ********************************************************************************

syn region d2KeyUnquoted start=/\%([,{.\->*&(]\%(\s*\\\n\)\?\s*\|\\\@<!\n\s*\|\%^\s*\)\@<=[^[:space:]\n#,[\]{}|`$'"\\:.\-<>*&()]/ end=/\%(\s*[\n#,[\]{}|`$'":.\-<>*&()]\)\@=/ contains=@d2EscapeKey
syn region d2KeyQuotedSingle matchgroup=d2Delimiter start=/\%([,{.\->*&(]\%(\s*\\\n\)\?\s*\|\\\@<!\n\s*\|\%^\s*\|'\)\@<='/ end=/'\|\n\@=/  contains=d2LineContinuation
syn region d2KeyQuotedDouble matchgroup=d2Delimiter start=/\%([,{.\->*&(]\%(\s*\\\n\)\?\s*\|\\\@<!\n\s*\|\%^\s*\)\@<="/    end=/"\|\n\@=/  contains=@d2EscapeKey
syn region d2KeyGroup        matchgroup=d2Delimiter start=/\%([,{.\->*&(]\%(\s*\\\n\)\?\s*\|\\\@<!\n\s*\|\%^\s*\)\@<=(/    end=/)\|\n\@=/  contains=d2Error,d2LineContinuation,@d2Key
syn region d2KeyIndex        matchgroup=d2Delimiter start=/)\@<=\[/                                                end=/\]\|\n\@=/ contains=d2Error,d2LineContinuation,@d2Number
syn match  d2KeyReserved     /\%(type\|layer\|hidden\|class\|label\|tooltip\|style\|icon\|constraint\|near\|opacity\|stroke\|fill\|filled\|stroke\-width\|width\|height\|border\-radius\|source\-arrowhead\|target\-arrowhead\|link\|stroke\-dash\|font\-size\|font\-color\|shadow\|multiple\|3d\|animated\|shape\|imports\|vars\|scenarios\|on_click\|src\|dst\)\%(\s*[\n#,[\]{}|`$'"\\:.\-<>*&()]\)\@=/

hi def link d2KeyUnquoted     d2Identifier
hi def link d2KeyQuotedSingle d2Identifier
hi def link d2KeyQuotedDouble d2Identifier
hi def link d2KeyReserved     d2Keyword

syn cluster d2Key contains=d2KeyUnquoted,d2KeyQuotedSingle,d2KeyQuotedDouble,d2KeyGroup,d2KeyIndex,d2KeyReserved

syn region d2KeyEdge       start=/\%([^[:space:]\n#,[\]{}|`$:\-<>]\%(\s*[\-<>]*\\\n\)\?\s*\)\@<=[\-<>]\+/ end=/\%([^\-<>]\|\n\)\@=/
syn match  d2KeyPeriod     /\%([^[:space:]\n#,[\]{}|`$:.\-<>&]\%(\s*\\\n\)\?\s*\)\@<=\./
syn match  d2KeyGlob       /\*/
syn match  d2KeyDoubleGlob /\*\*/
syn match  d2KeyAmpersand  /\%([,{.]\%(\s*\\\n\)\?\s*\|\\\@<!\n\s*\|\%^\s*\)\@<=&/

hi def link d2KeyEdge       d2Operator
hi def link d2KeyPeriod     d2Delimiter
hi def link d2KeyGlob       d2Operator
hi def link d2KeyDoubleGlob d2Operator
hi def link d2KeyAmpersand  d2Operator

syn cluster d2Key add=d2KeyPeriod,d2KeyGlob,d2KeyDoubleGlob,d2KeyAmpersand,d2KeyEdge

" ********************************************************************************
" d2Substitution
" ********************************************************************************

syn region d2Substitution      matchgroup=d2Operator start=/\${/                                                           end=/}\|\n\@=/ contains=d2Error,@d2Key contained
syn region d2SubstitutionMerge matchgroup=d2Operator start=/\%([,{[]\%(\s*\\\n\)\?\s*\|\\\@<!\n\s*\|\%^\s*\)\@<=\.\.\.\${/ end=/}\|\n\@=/ contains=d2Error,@d2Key

" ********************************************************************************
" @d2Escape
" ********************************************************************************
" https://go.dev/ref/spec#String_literals
" $VIMRUNTIME/syntax/go.vim

syn match d2EscapeError      /\\./                contained
syn match d2EscapeSpecial    /\\[#,[\]{}|`$'"\\]/ contained
syn match d2EscapeSpecialKey /\\[:.\-<>*&()]/     contained
syn match d2EscapeC          /\\[abefnrtv]/       contained
syn match d2EscapeX          /\\x\x\{2}/          contained
syn match d2EscapeOctal      /\\[0-7]\{3}/        contained
syn match d2EscapeU          /\\u\x\{4}/          contained
syn match d2EscapeBigU       /\\U\x\{8}/          contained
syn match d2LineContinuation /\%(\S\s*\)\@<=\\\n/

hi def link d2EscapeError      d2Error
hi def link d2EscapeSpecial    d2Escape
hi def link d2EscapeSpecialKey d2Escape
hi def link d2EscapeC          d2Escape
hi def link d2EscapeX          d2Escape
hi def link d2EscapeOctal      d2Escape
hi def link d2EscapeU          d2Escape
hi def link d2EscapeBigU       dd2cape
hi def link d2LineContinuation d2Escape
hi def link d2Escape           d2SpecialChar

syn cluster d2Escape    contains=d2EscapeError,d2EscapeSpecial,d2EscapeC,d2EscapeX,d2EscapeOctal,d2EscapeU,d2EscapeBigU,d2LineContinuation
syn cluster d2EscapeKey contains=@d2Escape,d2EscapeSpecialKey

" ********************************************************************************
" d2Null
" ********************************************************************************

syn match d2Null /null\%(\s*[\n#,[\]{}|`$'"\\]\)\@=/ contained
hi def link d2Null d2Constant

" ********************************************************************************
" d2Boolean
" ********************************************************************************

syn match d2Boolean /\%(true\|false\)\%(\s*[\n#,[\]{}|`$'"\\]\)\@=/ contained

" ********************************************************************************
" @d2Number
" ********************************************************************************
" https://go.dev/ref/spec#Integer_literals
" https://go.dev/ref/spec#Floating-point_literals
" $VIMRUNTIME/syntax/go.vim

syn match d2NumberDecimal /[+-]\?[0-9_]*\.\?[0-9_]\+\%([eEpP][+-]\?[0-9_]*\)\?\%(\s*[\n#,[\]{}|`$'"\\]\)\@=/ contained
syn match d2NumberDecimal /[+-]\?[0-9_]\+\.\?[0-9_]*\%([eEpP][+-]\?[0-9_]*\)\?\%(\s*[\n#,[\]{}|`$'"\\]\)\@=/ contained

syn match d2NumberOctal  /[+-]\?0[oO]\?[0-7_]*\%([eEpP][+-]\?[0-9_]*\)\?\%(\s*[\n#,[\]{}|`$'"\\]\)\@=/                        contained
syn match d2NumberHex    /[+-]\?0[xX][[:xdigit:]_]*\.\?[[:xdigit:]_]*\%([eEpP][+-]\?[0-9_]*\)\?\%(\s*[\n#,[\]{}|`$'"\\]\)\@=/ contained
syn match d2NumberBinary /[+-]\?0[bB][01_]*\.\?[01_]*\%([eEpP][+-]\?[0-9_]*\)\?\%(\s*[\n#,[\]{}|`$'"\\]\)\@=/                 contained

syn cluster d2Number contains=d2NumberDecimal,d2NumberOctal,d2NumberHex,d2NumberBinary

hi def link d2NumberDecimal d2Number
hi def link d2NumberOctal   d2Number
hi def link d2NumberHex     d2Number
hi def link d2NumberBinary  d2Number

" ********************************************************************************
" d2Array
" ********************************************************************************

syn region d2Array matchgroup=d2Delimiter start=/\%([,:]\%(\s*\\\n\)\?\s*\|\\\@<!\n\s*\)\@<=\[/ end=/]/ contains=d2Error,d2Comment,d2Comma,d2SubstitutionMerge,@d2Value contained

" ********************************************************************************
" d2Map
" ********************************************************************************

syn region d2Map matchgroup=d2Delimiter start=/\%(\%([,:]\|[^[:space:]\]}]\)\%(\s*\\\n\)\?\s*\|\\\@<!\n\s*\)\@<={/ end=/}/ contains=TOP contained

" ********************************************************************************
" Top
" ********************************************************************************

syn region d2KeyValue matchgroup=d2Delimiter start=/:/ end=/\%(\s*[\n#,}]\)\@=/ contains=d2Error,d2LineContinuation,@d2Value

syn cluster d2Value contains=d2Null,d2Boolean,@d2Number,@d2String,d2Array,d2Map

syn match   d2Comma /,/
hi def link d2Comma d2Delimiter

syn match   d2Comment /#.*/ contains=d2Todo
syn keyword d2Todo TODO FIXME XXX BUG contained

" ********************************************************************************
" Links to base Vim groups
" ********************************************************************************
" See :help group-name

hi def link d2Error Error

hi def link d2Comment Comment

hi def link d2Constant Constant
hi def link d2String   String
hi def link d2Number   Number
hi def link d2Boolean  Boolean

hi def link d2Identifier Identifier

" Statement
hi def link d2Operator Operator
hi def link d2Keyword  Keyword

" Special
hi def link d2SpecialChar SpecialChar
hi def link d2Delimiter   Delimiter

hi def link d2Todo Todo

let b:current_syntax = 'd2'
