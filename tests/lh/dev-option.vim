"=============================================================================
" $Id$
" File:		tests/lh/dev-option.vim                           {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim/>
" Version:	0.0.1
" Created:	05th Oct 2009
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	«description»
" 
"------------------------------------------------------------------------
" Installation:	«install details»
" History:	«history»
" TODO:		«missing features»
" }}}1
"=============================================================================

UTSuite [lh-dev-lib] Testing lh#dev#option functions

runtime autoload/lh/dev/option.vim
let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
function! s:Test_global()
  try 
    let g:foo = 42
    Assert lh#dev#option#get('foo', 'FT', 12) == 42
    Assert lh#dev#option#get('bar', 'FT', 12) == 12

    let b:foo = 43
    Assert lh#dev#option#get('foo', 'FT', 12) == 43

    let g:FT_foo = 44
    Assert lh#dev#option#get('foo', 'FT', 12) == 44

    let b:FT_foo = 45
    Assert lh#dev#option#get('foo', 'FT', 12) == 45
  finally
    unlet g:foo
    unlet b:foo
    unlet g:FT_foo
    unlet b:FT_foo
  endtry
endfunction

function! s:Test_local()
  try 
    let b:foo = 43
    Assert lh#dev#option#get('foo', 'FT', 12) == 43

    let g:FT_foo = 44
    Assert lh#dev#option#get('foo', 'FT', 12) == 44

    let b:FT_foo = 45
    Assert lh#dev#option#get('foo', 'FT', 12) == 45
  finally
    unlet b:foo
    unlet g:FT_foo
    unlet b:FT_foo
  endtry
endfunction

function! s:Test_FT_global()
  try 
    let g:FT_foo = 44
    Assert lh#dev#option#get('foo', 'FT', 12) == 44

    let b:FT_foo = 45
    Assert lh#dev#option#get('foo', 'FT', 12) == 45
  finally
    unlet g:FT_foo
    unlet b:FT_foo
  endtry
endfunction

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
