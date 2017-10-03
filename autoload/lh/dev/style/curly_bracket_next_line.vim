"=============================================================================
" File:         autoload/lh/dev/style/curly_bracket_next_line.vim {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-dev>
" Version:      2.0.0
let s:k_version = '2.0.0'
" Created:      04th Aug 2017
" Last Update:  03rd Oct 2017
"------------------------------------------------------------------------
" Description:
"       lh-dev style-plugin for EditorConfig non-official
"       "curly_bracket_next_line" stylistic option.
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
function! lh#dev#style#curly_bracket_next_line#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#dev#style#curly_bracket_next_line#verbose(...)
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

function! lh#dev#style#curly_bracket_next_line#debug(expr) abort
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Internal functions {{{1
" Function: lh#dev#style#curly_bracket_next_line#__new(name, local_global, ft) {{{2
function! lh#dev#style#curly_bracket_next_line#__new(name, local_global, ft) abort
  let style = lh#dev#style#define_group('curly-bracket-next-line', a:name, a:local_global, a:ft)
  let s:crt_style = style
  return style
endfunction

" ## API      functions {{{1
" Function: lh#dev#style#curly_bracket_next_line#none(local_global, ft) {{{2
" Permits to clear everything on this topic and to define things manually
" instead.
function! lh#dev#style#curly_bracket_next_line#none(local_global, ft) abort
  let style = lh#dev#style#curly_bracket_next_line#__new('none', a:local_global, a:ft)
  return style
endfunction

" Function: lh#dev#style#curly_bracket_next_line#use(styles, value, ...) {{{3
function! lh#dev#style#curly_bracket_next_line#use(styles, value, ...) abort
  let input_options = get(a:, 1, {})
  let [options, local_global, prio, ft] = lh#dev#style#_prepare_options_for_add_style(input_options)

  let style = lh#dev#style#curly_bracket_next_line#__new(a:value, local_global, ft)

  if a:value =~? '\v(true|yes|1)'
    call style.add('{', '\n{', prio)
  else
    call style.add('{', '{', prio)
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
