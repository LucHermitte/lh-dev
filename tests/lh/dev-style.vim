"=============================================================================
" $Id$
" File:         tests/lh/dev-style.vim                            {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      1.1.0
" Created:      14th Feb 2014
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       Unit tests for lh#dev#style
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim

UTSuite [lh-dev] Testing lh#dev#style

runtime autoload/lh/dev/style.vim

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
  AddStyle ; ;\ 
  Assert lh#dev#style#get(&ft) == {';': '; '}
  Assert lh#dev#style#get('fake') == {';': '; '}

  AddStyle | |\n
  Assert lh#dev#style#get(&ft) == {';': '; ', '|': "|\n"}
  Assert lh#dev#style#get('fake') == {';': '; ', '|': "|\n"}
endfunction

" Function: s:Test_local_all() {{{3
function! s:Test_local_all()
  " Todo: play with scratch buffer
  AddStyle ; ;\  -b 
  Assert lh#dev#style#get(&ft) == {';': '; '}
  Assert lh#dev#style#get('fake') == {';': '; '}

  AddStyle | |\n -b 
  Assert lh#dev#style#get(&ft) == {';': '; ', '|': "|\n"}
  Assert lh#dev#style#get('fake') == {';': '; ', '|': "|\n"}
endfunction

" Function: s:Test_global_this_ft() {{{3
function! s:Test_global_this_ft()
  AddStyle ; ;\  -ft
  Assert lh#dev#style#get(&ft) == {';': '; '}
  Assert lh#dev#style#get('fake') == {}

  AddStyle | |\n -ft
  Assert lh#dev#style#get(&ft) == {';': '; ', '|': "|\n"}
  Assert lh#dev#style#get('fake') == {}
endfunction

" Function: s:Test_global_SOME_ft() {{{3
function! s:Test_global_SOME_ft()
  AddStyle ; ;\  -ft=SOME
  Assert lh#dev#style#get('SOME') == {';': '; '}
  Assert lh#dev#style#get('fake') == {}
  Assert lh#dev#style#get(&ft) == {}

  AddStyle | |\n -ft=SOME
  Assert lh#dev#style#get('SOME') == {';': '; ', '|': "|\n"}
  Assert lh#dev#style#get('fake') == {}
  Assert lh#dev#style#get(&ft) == {}
endfunction

" Function: s:Test_local_this_ft() {{{3
function! s:Test_local_this_ft()
  AddStyle ; ;\  -ft -b
  Assert lh#dev#style#get(&ft) == {';': '; '}
  Assert lh#dev#style#get('fake') == {}

  AddStyle | |\n -ft -b
  Assert lh#dev#style#get(&ft) == {';': '; ', '|': "|\n"}
  Assert lh#dev#style#get('fake') == {}
endfunction

" Function: s:Test_local_SOME_ft() {{{3
function! s:Test_local_SOME_ft()
  AddStyle ; ;\  -ft=SOME -b
  Assert lh#dev#style#get('SOME') == {';': '; '}
  Assert lh#dev#style#get('fake') == {}
  Assert lh#dev#style#get(&ft) == {}

  AddStyle | |\n -ft=SOME -b
  Assert lh#dev#style#get('SOME') == {';': '; ', '|': "|\n"}
  Assert lh#dev#style#get('fake') == {}
  Assert lh#dev#style#get(&ft) == {}
endfunction

" }}}2
"------------------------------------------------------------------------
" # Tests with global/local overriding {{{2
" Function: s:Test_global_over_local() {{{3
function! s:Test_global_over_local()
  AddStyle ; ;\  -b
  Assert lh#dev#style#get('fake') == {';': '; '}
  Assert lh#dev#style#get(&ft)    == {';': '; '}

  AddStyle ; ; 
  Assert lh#dev#style#get('fake') == {';': '; '}
  Assert lh#dev#style#get(&ft)    == {';': '; '}

  try
    new
    Assert lh#dev#style#get('fake') == {';': ';'}
    Assert lh#dev#style#get(&ft)    == {';': ';'}
  finally
    bw
  endtry
  Assert lh#dev#style#get('fake') == {';': '; '}
  Assert lh#dev#style#get(&ft)    == {';': '; '}
endfunction

" Function: s:Test_local_over_global() {{{3
function! s:Test_local_over_global()
  AddStyle ; ;\ 
  Assert lh#dev#style#get('fake') == {';': '; '}
  Assert lh#dev#style#get(&ft)    == {';': '; '}

  AddStyle ; ;  -b
  Assert lh#dev#style#get('fake') == {';': ';'}
  Assert lh#dev#style#get(&ft)    == {';': ';'}

  try
    new
    Assert lh#dev#style#get('fake') == {';': '; '}
    Assert lh#dev#style#get(&ft)    == {';': '; '}
  finally
    bw
  endtry
  Assert lh#dev#style#get('fake') == {';': ';'}
  Assert lh#dev#style#get(&ft)    == {';': ';'}
endfunction

" Function: s:Test_all_over_this_ft() {{{3
function! s:Test_all_over_this_ft()
  AddStyle ; ;\  -ft
  Assert lh#dev#style#get('fake') == {}
  Assert lh#dev#style#get(&ft)    == {';': '; '}

  AddStyle ; ; 
  Assert lh#dev#style#get('fake') == {';': ';'}
  Assert lh#dev#style#get(&ft)    == {';': '; '}

  try
    new
    Assert lh#dev#style#get('fake') == {';': ';'}
    Assert lh#dev#style#get(&ft)    == {';': ';'}
  finally
    bw
  endtry
  Assert lh#dev#style#get('fake') == {';': ';'}
  Assert lh#dev#style#get(&ft)    == {';': '; '}
endfunction

" Function: s:Test_this_ft_over_all() {{{3
function! s:Test_this_ft_over_all()
  AddStyle ; ;\  -ft
  Assert lh#dev#style#get('fake') == {}
  Assert lh#dev#style#get(&ft)    == {';': '; '}

  AddStyle ; ; 
  Assert lh#dev#style#get('fake') == {';': ';'}
  Assert lh#dev#style#get(&ft)    == {';': '; '}

  try
    new
    Assert lh#dev#style#get('fake') == {';': ';'}
    Assert lh#dev#style#get(&ft)    == {';': ';'}
  finally
    bw
  endtry
  Assert lh#dev#style#get('fake') == {';': ';'}
  Assert lh#dev#style#get(&ft)    == {';': '; '}
endfunction

" Function: s:Test_mix_everything() {{{3
function! s:Test_mix_everything()
  AddStyle T 1 -ft -b
  Assert lh#dev#style#get('fake') == {}
  Assert lh#dev#style#get(&ft)    == {'T': '1'}

  AddStyle T 2 -ft
  Assert lh#dev#style#get('fake') == {}
  Assert lh#dev#style#get(&ft)    == {'T': '1'}

  AddStyle T 3 -b
  Assert lh#dev#style#get('fake') == {'T': '3'}
  Assert lh#dev#style#get(&ft)    == {'T': '1'}

  AddStyle T 4
  Assert lh#dev#style#get('fake') == {'T': '3'}
  Assert lh#dev#style#get(&ft)    == {'T': '1'}

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
  Assert lh#dev#style#get('fake') == {'T': '3'}
  Assert lh#dev#style#get(&ft)    == {'T': '1'}
  Assert &ft == 'vim'
  try
    new " other ft
    Assert lh#dev#style#get('fake') == {'T': '4'}
    Assert lh#dev#style#get('vim')    == {'T': '2'}
  finally
    bw
  endtry
  try
    new " same ft
    set ft=vim
    Assert lh#dev#style#get('fake') == {'T': '4'}
    Assert lh#dev#style#get('vim')    == {'T': '2'}
  finally
    bw
  endtry
endfunction

" }}}2
"------------------------------------------------------------------------
" # Override last definition {{{2
function! s:Test_override_global()
  AddStyle ; ;\ 
  Assert lh#dev#style#get(&ft) == {';': '; '}

  AddStyle ; zz
  Assert lh#dev#style#get(&ft) == {';': 'zz'}
endfunction

function! s:Test_override_local()
  AddStyle ; ;\  -b
  Assert lh#dev#style#get(&ft) == {';': '; '}

  AddStyle ; zz -b
  Assert lh#dev#style#get(&ft) == {';': 'zz'}
endfunction

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
