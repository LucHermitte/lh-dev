"=============================================================================
" File:         tests/lh/dev-comments.vim                         {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://github.com/LucHermitte/lh-dev/>
" Version:      2.0.0
" Created:      05th Nov 2010
" Last Update:  18th Oct 2016
"------------------------------------------------------------------------
" Description:
"       UT tests regardint comment manipulations
"
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/tests/lh
"       Requires Vim7+
"       «install details»
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

UTSuite [lh-dev] Testing lh#dev#purge_comments function

runtime autoload/lh/dev.vim
runtime autoload/lh/dev/option.vim

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
function! s:Setup()
  let s:cleanup = lh#on#exit()
        \.restore_option('ECcommentOpen')
        \.restore_option('ECcommentClose')
        \.restore('&commentstring')
        \.restore('&magic')
endfunction

function! s:Teardown()
  call s:cleanup.finalize()
endfunction

function! s:Test_mono_line_cpp()
  let b:ECcommentOpen  = '//'
  let b:ECcommentClose = ''
  let  &commentstring  = '/*%s*/'
  set magic

  AssertEqual(lh#dev#option#call('_open_comment', 'cpp'), '/*')
  AssertEqual(lh#dev#option#call('_close_comment', 'cpp'), '*/')
  AssertEqual(lh#dev#option#call('_line_comment', 'cpp'), '//')
  let line_comment0 = lh#dev#option#call('_line_comment', 'cpp')
  AssertEqual(line_comment0, '//')

  " Fails for no good reason on travis...
  let line_comment  = substitute(line_comment0, '[%<>+=*\[(){]', '\\&', 'g')
  AssertEqual(line_comment, '//')
  " Fails for no good reason on travis...
  let line_comment  = escape(line_comment0, '%<>+=*\[(){')
  AssertEqual(line_comment, '//')
  " Fails for no good reason on travis...
  AssertEqual(escape(line_comment0, '%<>+=*\[(){'), '//')

  AssertEqual(line_comment0, '//')
  AssertEqual('', substitute('// toto', '\v'.line_comment0.'.*', '', ''))
  AssertEqual('', substitute('// toto', '//.*', '', ''))
  " Fails for no good reason on travis...
  AssertEqual('', substitute('// toto', '\v'.line_comment.'.*', '', ''))

  " Fails for no good reason on travis...
  AssertEqual('', substitute('// toto', '\v//.*', '', ''))
  AssertEqual('', substitute('// toto', '//.*', '', ''))
  AssertEqual('', substitute('// toto', line_comment.'.*', '', ''))
  AssertEqual(['', 0], lh#dev#purge_comments('', 0, 'cpp'))
  AssertEqual(['', 1], lh#dev#purge_comments('', 1, 'cpp'))
  AssertEqual(['', 0], lh#dev#purge_comments('// toto', 0, 'cpp'))
  AssertEqual(['', 1], lh#dev#purge_comments('// toto', 1, 'cpp'))
  AssertEqual(['titi tutu ', 0], lh#dev#purge_comments('titi tutu // toto', 0, 'cpp'))
  AssertEqual(['', 1], lh#dev#purge_comments('titi tutu // toto', 1, 'cpp'))
endfunction

function! s:Test_region_cpp()
  let b:ECcommentOpen  = '//'
  let b:ECcommentClose = ''
  let  &commentstring  = '/*%s*/'

  AssertEqual(['', 0], lh#dev#purge_comments('/**/', 0, 'cpp'))
  AssertEqual(['', 1], lh#dev#purge_comments('/*', 1, 'cpp'))
  AssertEqual(['', 0], lh#dev#purge_comments('/* toto*/', 0, 'cpp'))
  AssertEqual(['', 0], lh#dev#purge_comments('/* toto*/', 1, 'cpp'))
  AssertEqual(['titi  foo ', 0], lh#dev#purge_comments('titi /*tutu*/ foo // toto', 0, 'cpp'))
  AssertEqual([' foo ', 0], lh#dev#purge_comments('titi /*tutu*/ foo // toto', 1, 'cpp'))
  AssertEqual([' foo ', 0], lh#dev#purge_comments('titi /*tutu*/ foo // toto /*', 1, 'cpp'))
  AssertEqual([' foo ', 1], lh#dev#purge_comments('titi /*tutu*/ foo /* toto /*', 1, 'cpp'))
endfunction

function! s:Test_mono_line_vim()
  let b:ECcommentOpen  = '"'
  let b:ECcommentClose = ''
  let  &commentstring  = '"%s'
  AssertEqual(['', 0], lh#dev#purge_comments('', 0, 'vim'))
  AssertEqual(['', 0], lh#dev#purge_comments('" toto', 0, 'vim'))
  AssertEqual(['toto ', 0], lh#dev#purge_comments('toto " toto', 0, 'vim'))

  " ouch! it also purge string ...
endfunction

let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
