" File:        tagbar.vim
" Description: Tagbar syntax settings
" Author:      Jan Larres <jan@majutsushi.net>
" Licence:     Vim licence
" Website:     https://preservim.github.io/tagbar
" Version:     2.7

scriptencoding utf-8

if exists('b:current_syntax')
    finish
endif

let s:ics = escape(join(g:tagbar_iconchars, ''), ']^\-')

let s:pattern = '\(^[' . s:ics . '] \)\@<=\[.\+\]$'
execute "syntax match TagbarKind '" . s:pattern . "'"

let s:pattern = '\(^ *[' . s:ics . ' ][-+# ]\)\@<=[a-z][a-z ]\+\( \w\+\(  \| = .\+\)\?$\)\@='
execute "syntax match TagbarScopeType '" . s:pattern . "'"

let s:pattern = '\(^ *[' . s:ics . ' ][-+# ][a-z][a-z ]\+ \)\@<=\w\+\(\( = .\+\)\?$\)\@='
execute "syntax match TagbarScope '" . s:pattern . "'"

let s:pattern = '\(^ *[' . s:ics . ' ][-+# ][a-z][a-z ]\+ \)\@<=\w\+\(  $\)\@='
execute "syntax match TagbarPseudoScope '" . s:pattern . "'"

let s:pattern = '^ *[' . s:ics . ']\([-+# ]\)\@='
execute "syntax match TagbarFoldIcon '" . s:pattern . "'"

let s:pattern = '\(^ *[' . s:ics . ' ]\)\@<=+\([^-+# ]\)\@='
execute "syntax match TagbarVisibilityPublic '" . s:pattern . "'"
let s:pattern = '\(^ *[' . s:ics . ' ]\)\@<=#\([^-+# ]\)\@='
execute "syntax match TagbarVisibilityProtected '" . s:pattern . "'"
let s:pattern = '\(^ *[' . s:ics . ' ]\)\@<=-\([^-+# ]\)\@='
execute "syntax match TagbarVisibilityPrivate '" . s:pattern . "'"

let s:pattern = '\(^[' . s:ics . ' ] \)\@<=main\((.*)\)\@='
execute "syntax match TagbarMain '" . s:pattern . "'"

unlet s:pattern

syntax match TagbarHelp      '^".*' contains=TagbarHelpKey,TagbarHelpTitle
syntax match TagbarHelpKey   '" \zs.*\ze:' contained
syntax match TagbarHelpTitle '" \zs-\+ \w\+ -\+' contained

syntax match TagbarNestedKind '^\s\+\[[^]]\+\]$'
syntax match TagbarSignature  '\(\<operator *( *) *\)\?\zs(.*)[^=]*\ze'
syntax match TagbarDelete     '\zs= delete\ze$'

highlight default link TagbarHelp       Comment
highlight default link TagbarHelpKey    Identifier
highlight default link TagbarHelpTitle  PreProc
highlight default link TagbarNestedKind TagbarKind
highlight default link TagbarScopeType  Type
highlight default link TagbarFoldIcon   Statement
highlight default link TagbarHighlight  Search

highlight default TagbarSignature       guifg=Cyan          ctermfg=DarkCyan
highlight default TagbarKind            guifg=Orange        ctermfg=DarkYellow
highlight default TagbarAccessPublic    guifg=#00CD00       ctermfg=Green
highlight default TagbarAccessProtected guifg=#669AFF       ctermfg=Blue
highlight default TagbarAccessPrivate   guifg=Red           ctermfg=Red
highlight default TagbarScope           gui=Bold            cterm=Bold
highlight default TagbarPseudoScope     guifg=LightMagenta  ctermfg=LightMagenta  gui=Bold  cterm=Bold
highlight default TagbarDelete          guifg=Red           ctermfg=Red
highlight default link TagbarVisibilityPublic    TagbarAccessPublic
highlight default link TagbarVisibilityProtected TagbarAccessProtected
highlight default link TagbarVisibilityPrivate   TagbarAccessPrivate
highlight default link TagbarMain                TagbarScope

let b:current_syntax = 'tagbar'

" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1
