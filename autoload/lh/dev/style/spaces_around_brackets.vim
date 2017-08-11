"=============================================================================
" File:         autoload/lh/dev/style/spaces_around_brackets.vim  {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-dev>
" Version:      2.0.0.
let s:k_version = '200'
" Created:      11th Aug 2017
" Last Update:  11th Aug 2017
"------------------------------------------------------------------------
" Description:
"       lh-dev style-plugin for EditorConfig non-official
"       "spaces_around_brackets" stylistic option.
"
" Note:
" * As I understand this option:
"   - it makes no distinction between control statements and function calls and
"   definitions.
"   - it knows nothing about terminal characters like semicolon, nor trailing
"   whitespace
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
function! lh#dev#style#spaces_around_brackets#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#dev#style#spaces_around_brackets#verbose(...)
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

function! lh#dev#style#spaces_around_brackets#debug(expr) abort
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## API      functions {{{1

" Function: lh#dev#style#spaces_around_brackets#use(styles, value, ...) {{{3
function! lh#dev#style#spaces_around_brackets#use(styles, value, ...) abort
  let input_options = get(a:, 1, {})
  let [options, local, prio, ft] = lh#dev#style#_prepare_options_for_add_style(input_options)

  if     a:value =~? 'inside'
    call call('lh#dev#style#_add', options + ['(' , '( ' ])
    call call('lh#dev#style#_add', options + [')' , ' )' ])
  elseif a:value =~? 'outside'
    call call('lh#dev#style#_add', options + ['(' , ' (' ])
    call call('lh#dev#style#_add', options + [')' , ') ' ])
  elseif a:value =~? 'both'
    call call('lh#dev#style#_add', options + ['(' , ' ( ' ])
    call call('lh#dev#style#_add', options + [')' , ' ) ' ])
  else " "none"
    call call('lh#dev#style#_add', options + ['(' , '(' ])
    call call('lh#dev#style#_add', options + [')' , ')' ])
  endif
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
