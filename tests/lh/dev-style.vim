"=============================================================================
" File:         tests/lh/dev-style.vim                            {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      1.3.1
" Created:      14th Feb 2014
" Last Update:  17th Aug 2015
"------------------------------------------------------------------------
" Description:
"       Unit tests for lh#dev#style
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim

UTSuite [lh-dev] Testing lh#dev#style

runtime autoload/lh/dev/style.vim

" ## Helper function
function! s:GetStyle(...)
  let style = call('lh#dev#style#get', a:000)
  let style = map(copy(style), 'v:val.replacement')
  return style
endfunction

" ## Tests {{{1
"------------------------------------------------------------------------
" # Setup/teardown {{{2
function! s:Setup()
  call lh#dev#style#clear()
endfunction

"------------------------------------------------------------------------
" # Simple tests first {{{2
" Function: s:Test_global_all() {{{3
function! s:Test_global_all()
  " Todo: play with scratch buffer
  " Yes there is a trailing whitespace
  AddStyle ; ;\ 
  Assert s:GetStyle(&ft) == {';': '; '}
  Assert s:GetStyle('fake') == {';': '; '}

  AssertEqual(lh#dev#style#apply('toto;titi'), 'toto; titi')
  " Shall the function be idempotent?
  " AssertEqual(lh#dev#style#apply('toto; titi'), 'toto; titi')
  " AssertEqual(lh#dev#style#apply('toto  ;   titi'), 'toto; titi')

  AddStyle | |\n
  Assert s:GetStyle(&ft) == {';': '; ', '|': "|\n"}
  Assert s:GetStyle('fake') == {';': '; ', '|': "|\n"}

  AssertEqual(lh#dev#style#apply("toto|titi"), "toto|\ntiti")
  " Shall the function be idempotent?
  " AssertEqual(lh#dev#style#apply("toto|\ntiti"), "toto|\ntiti")
  " AssertEqual(lh#dev#style#apply("toto  |\n   titi"), "toto|\ntiti")
endfunction

" Function: s:Test_local_all() {{{3
function! s:Test_local_all()
  " Todo: play with scratch buffer
  AddStyle ; ;\  -b
  Assert s:GetStyle(&ft) == {';': '; '}
  Assert s:GetStyle('fake') == {';': '; '}

  AddStyle | |\n -b
  Assert s:GetStyle(&ft) == {';': '; ', '|': "|\n"}
  Assert s:GetStyle('fake') == {';': '; ', '|': "|\n"}
endfunction

" Function: s:Test_global_this_ft() {{{3
function! s:Test_global_this_ft()
  AddStyle ; ;\  -ft
  Assert s:GetStyle(&ft) == {';': '; '}
  Assert s:GetStyle('fake') == {}

  AddStyle | |\n -ft
  Assert s:GetStyle(&ft) == {';': '; ', '|': "|\n"}
  Assert s:GetStyle('fake') == {}
endfunction

" Function: s:Test_global_SOME_ft() {{{3
function! s:Test_global_SOME_ft()
  AddStyle ; ;\  -ft=SOME
  Assert s:GetStyle('SOME') == {';': '; '}
  Assert s:GetStyle('fake') == {}
  Assert s:GetStyle(&ft) == {}

  AddStyle | |\n -ft=SOME
  Assert s:GetStyle('SOME') == {';': '; ', '|': "|\n"}
  Assert s:GetStyle('fake') == {}
  Assert s:GetStyle(&ft) == {}
endfunction

" Function: s:Test_local_this_ft() {{{3
function! s:Test_local_this_ft()
  AddStyle ; ;\  -ft -b
  Assert s:GetStyle(&ft) == {';': '; '}
  Assert s:GetStyle('fake') == {}

  AddStyle | |\n -ft -b
  Assert s:GetStyle(&ft) == {';': '; ', '|': "|\n"}
  Assert s:GetStyle('fake') == {}
endfunction

" Function: s:Test_local_SOME_ft() {{{3
function! s:Test_local_SOME_ft()
  AddStyle ; ;\  -ft=SOME -b
  Assert s:GetStyle('SOME') == {';': '; '}
  Assert s:GetStyle('fake') == {}
  Assert s:GetStyle(&ft) == {}

  AddStyle | |\n -ft=SOME -b
  Assert s:GetStyle('SOME') == {';': '; ', '|': "|\n"}
  Assert s:GetStyle('fake') == {}
  Assert s:GetStyle(&ft) == {}
endfunction

" }}}2
"------------------------------------------------------------------------
" # Tests with global/local overriding {{{2
" Function: s:Test_global_over_local() {{{3
function! s:Test_global_over_local()
  AddStyle ; ;\  -b
  Assert s:GetStyle('fake') == {';': '; '}
  Assert s:GetStyle(&ft)    == {';': '; '}

  AddStyle ; ;
  Assert s:GetStyle('fake') == {';': '; '}
  Assert s:GetStyle(&ft)    == {';': '; '}

  try
    new
    Assert s:GetStyle('fake') == {';': ';'}
    Assert s:GetStyle(&ft)    == {';': ';'}
  finally
    bw
  endtry
  Assert s:GetStyle('fake') == {';': '; '}
  Assert s:GetStyle(&ft)    == {';': '; '}
endfunction

" Function: s:Test_local_over_global() {{{3
function! s:Test_local_over_global()
  AddStyle ; ;\ 
  Assert s:GetStyle('fake') == {';': '; '}
  Assert s:GetStyle(&ft)    == {';': '; '}

  AddStyle ; ;  -b
  Assert s:GetStyle('fake') == {';': ';'}
  Assert s:GetStyle(&ft)    == {';': ';'}

  try
    new
    Assert s:GetStyle('fake') == {';': '; '}
    Assert s:GetStyle(&ft)    == {';': '; '}
  finally
    bw
  endtry
  Assert s:GetStyle('fake') == {';': ';'}
  Assert s:GetStyle(&ft)    == {';': ';'}
endfunction

" Function: s:Test_all_over_this_ft() {{{3
function! s:Test_all_over_this_ft()
  AddStyle ; ;\  -ft
  Assert s:GetStyle('fake') == {}
  Assert s:GetStyle(&ft)    == {';': '; '}

  AddStyle ; ;
  Assert s:GetStyle('fake') == {';': ';'}
  Assert s:GetStyle(&ft)    == {';': '; '}

  try
    new
    Assert s:GetStyle('fake') == {';': ';'}
    Assert s:GetStyle(&ft)    == {';': ';'}
  finally
    bw
  endtry
  Assert s:GetStyle('fake') == {';': ';'}
  Assert s:GetStyle(&ft)    == {';': '; '}
endfunction

" Function: s:Test_this_ft_over_all() {{{3
function! s:Test_this_ft_over_all()
  AddStyle ; ;\  -ft
  Assert s:GetStyle('fake') == {}
  Assert s:GetStyle(&ft)    == {';': '; '}

  AddStyle ; ;
  Assert s:GetStyle('fake') == {';': ';'}
  Assert s:GetStyle(&ft)    == {';': '; '}

  try
    new
    Assert s:GetStyle('fake') == {';': ';'}
    Assert s:GetStyle(&ft)    == {';': ';'}
  finally
    bw
  endtry
  Assert s:GetStyle('fake') == {';': ';'}
  Assert s:GetStyle(&ft)    == {';': '; '}
endfunction

" Function: s:Test_mix_everything() {{{3
function! s:Test_mix_everything()
  AddStyle T 1 -ft -b
  Assert s:GetStyle('fake') == {}
  Assert s:GetStyle(&ft)    == {'T': '1'}

  AddStyle T 2 -ft
  Assert s:GetStyle('fake') == {}
  Assert s:GetStyle(&ft)    == {'T': '1'}

  AddStyle T 3 -b
  Assert s:GetStyle('fake') == {'T': '3'}
  Assert s:GetStyle(&ft)    == {'T': '1'}

  AddStyle T 4
  Assert s:GetStyle('fake') == {'T': '3'}
  Assert s:GetStyle(&ft)    == {'T': '1'}

  " Check this is correctly filled
  let bufnr = bufnr('%')
  let style = lh#dev#style#debug('s:style')
  Assert len(style)   == 1
  Assert len(style.T) == 4
  Assert style.T[0].ft          == &ft
  Assert style.T[0].local       == bufnr
  Assert style.T[0].replacement == '1'

  Assert style.T[1].ft          == &ft
  Assert style.T[1].local       == -1
  Assert style.T[1].replacement == '2'

  Assert style.T[2].ft          == '*'
  Assert style.T[2].local       == bufnr
  Assert style.T[2].replacement == '3'

  Assert style.T[3].ft          == '*'
  Assert style.T[3].local       == -1
  Assert style.T[3].replacement == '4'

  " Check this is correctly restituted
  Assert s:GetStyle('fake') == {'T': '3'}
  Assert s:GetStyle(&ft)    == {'T': '1'}
  Assert &ft == 'vim'
  try
    new " other ft
    Assert s:GetStyle('fake') == {'T': '4'}
    Assert s:GetStyle('vim')    == {'T': '2'}
  finally
    bw
  endtry
  try
    new " same ft
    set ft=vim
    Assert s:GetStyle('fake') == {'T': '4'}
    Assert s:GetStyle('vim')    == {'T': '2'}
  finally
    bw
  endtry
endfunction

" }}}2
"------------------------------------------------------------------------
" # Override last definition {{{2
function! s:Test_override_global()
  " Yes there is a trailing whitespace
  AddStyle ; ;\ 
  Assert s:GetStyle(&ft) == {';': '; '}

  AddStyle ; zz
  Assert s:GetStyle(&ft) == {';': 'zz'}
endfunction

function! s:Test_override_local()
  " Yes there is a trailing whitespace
  AddStyle ; ;\  -b
  Assert s:GetStyle(&ft) == {';': '; '}

  AddStyle ; zz -b
  Assert s:GetStyle(&ft) == {';': 'zz'}
endfunction

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
