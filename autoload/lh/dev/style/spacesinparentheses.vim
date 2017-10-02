"=============================================================================
" File:         autoload/lh/dev/style/spacesinparentheses.vim     {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-dev>
" Version:      2.0.0.
let s:k_version = '200'
" Created:      02nd Oct 2017
" Last Update:  02nd Oct 2017
"------------------------------------------------------------------------
" Description:
"       lh-dev style-plugin for clang-format "SpacesInParentheses"
"       stylistic option.
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#dev#style#spacesinparentheses#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#dev#style#spacesinparentheses#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Log(expr, ...)
  call call('lh#log#this',[a:expr]+a:000)
endfunction

function! s:Verbose(expr, ...)
  if s:verbose
    call call('s:Log',[a:expr]+a:000)
  endif
endfunction

function! lh#dev#style#spacesinparentheses#debug(expr) abort
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1
" Function: lh#dev#style#spacesinparentheses#__new(name, local, ft) {{{2
function! lh#dev#style#spacesinparentheses#__new(name, local, ft) abort
  let style = lh#dev#style#define_group('spaces.brackets.cf.inside', a:name, !a:local, a:ft)
  let s:crt_style = style
  return style
endfunction

"------------------------------------------------------------------------
" ## API      functions {{{1
" Function: lh#dev#style#spacesinparentheses#use(styles, value, ...) {{{2
function! lh#dev#style#spacesinparentheses#use(styles, value, ...) abort
  let input_options = get(a:, 1, {})
  let [options, local, prio, ft] = lh#dev#style#_prepare_options_for_add_style(input_options)

  let style = lh#dev#style#spacesinparentheses#__new(a:value, local, ft)
  if     a:value =~? 'yes\|true\|1'
    call style.add('(\s*' , '( ' , prio)
    call style.add('\s*)' , ' )' , prio)
  else " no
    call style.add('(\s*' , '('  , prio)
    call style.add('\s*)' , ')'  , prio)
  endif
endfunction

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
