"=============================================================================
" File:         autoload/lh/dev/style/breakbeforebraces.vim       {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-dev>
" Version:      2.0.0.
let s:k_version = '200'
" Created:      12th Aug 2017
" Last Update:  23rd Aug 2017
"------------------------------------------------------------------------
" Description:
"       lh-dev style-plugin for clang-format "BreakBeforeBraces" stylistic
"       option.
"       https://clangformat.com/#BreakBeforeBraces
"       https://zed0.co.uk/clang-format-configurator/
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:
" - BS styles:
"   - Mozilla
"   - Webkit
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#dev#style#breakbeforebraces#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#dev#style#breakbeforebraces#verbose(...)
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

function! lh#dev#style#breakbeforebraces#debug(expr) abort
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
" ## API      functions {{{1

" Function: lh#dev#style#breakbeforebraces#use(styles, indent, ...) {{{3
" "factory" function
let s:style = lh#on#exit()
let s:k_function = {
      \ 'none'      : 'lh#dev#style#__braces#none'
      \,'attach'    : 'lh#dev#style#__braces#attach'
      \,'linux'     : 'lh#dev#style#__braces#linux'
      \,'stroustrup': 'lh#dev#style#__braces#stroustrup'
      \,'allman'    : 'lh#dev#style#__braces#allman'
      \,'gnu'       : 'lh#dev#style#__braces#gnu'
      \ }

function! lh#dev#style#breakbeforebraces#use(styles, indent, ...) abort
  let input_options = get(a:, 1, {})
  let [options, local, prio, ft] = lh#dev#style#_prepare_options_for_add_style(input_options)
  if prio == 1
    let prio9 = 9
    let prio = 10
  endif
  let indent = tolower(a:indent)
  if has_key(s:k_function, indent)
    let style = call(s:k_function[indent], [local, ft, prio, prio9])
    call s:Verbose("`breakbeforebraces` style set to `%1`", a:indent)
    return 1
  else
    call s:Verbose("WARNING: Impossible to set `breakbeforebraces` style to `%1`", a:indent)
    call lh#common#warning_msg("WARNING: Impossible to set `breakbeforebraces` style to `".a:indent.'`')
    return 0
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
