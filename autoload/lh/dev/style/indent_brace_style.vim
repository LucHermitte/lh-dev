"=============================================================================
" File:         autoload/lh/dev/style/indent_brace_style.vim      {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-dev>
" Version:      2.0.0
let s:k_version = '2.0.0'
" Created:      04th Aug 2017
" Last Update:  04th Aug 2017
"------------------------------------------------------------------------
" Description:
"       lh-dev style-plugin for EditorConfig non-official
"       "indent_brace_style" stylistic option.
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:
" - Merge everything w/ clang-format's BreakBeforeBrace style
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#dev#style#indent_brace_style#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#dev#style#indent_brace_style#verbose(...)
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

function! lh#dev#style#indent_brace_style#debug(expr) abort
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Styles             {{{1
" # Style definitions {{{2
" Function: lh#dev#style#indent_brace_style#_horstmann(local, ft, prio) {{{3
" TODO: adapt the indent when sw is changed, or read it in a:styles
" This also means that if Horstmann/Pico is global and &sw is not, it'll
" complicates &sw management...
function! lh#dev#style#indent_brace_style#_horstmann(local, ft, prio, ...) abort
  let style = lh#dev#style#breakbeforebraces#_new('horstmann', a:local, a:ft)
  call style.add('{' , '\n{'.repeat( ' ', &sw-1), a:prio)
  call style.add('};', '\n};\n'                 , a:prio)
  call style.add('}' , '\n}\n'                  , a:prio)
  return style
endfunction

" Function: lh#dev#style#indent_brace_style#_pico(local, ft, prio) {{{3
" TODO: adapt the indent when sw is changed, or read it in a:styles
" This also means that if Horstmann/Pico is global and &sw is not, it'll
" complicates &sw management...
function! lh#dev#style#indent_brace_style#_pico(local, ft, prio, ...) abort
  let style = lh#dev#style#breakbeforebraces#_new('pico', a:local, a:ft)
  call style.add('{' , '\n{'.repeat( ' ', &sw-1), a:prio)
  call style.add('};', '};\n'                   , a:prio)
  call style.add('}' , ' }\n'                   , a:prio)
  return style
endfunction

" Function: lh#dev#style#indent_brace_style#_lisp(local, ft, prio) {{{3
function! lh#dev#style#indent_brace_style#_lisp(local, ft, prio, ...) abort
  let style = lh#dev#style#breakbeforebraces#_new('lisp', a:local, a:ft)
  call style.add('{' , ' {\n', a:prio)
  call style.add('};', '};\n', a:prio)
  call style.add('}' , '}\n' , a:prio)
  return style
endfunction

" Function: lh#dev#style#indent_brace_style#_java(local, ft, prio) {{{3
function! lh#dev#style#indent_brace_style#_java(local, ft, prio, ...) abort
  let style = lh#dev#style#breakbeforebraces#_new('java', a:local, a:ft)
  call style.add('{', ' {\n', a:prio)
  call style.add('}', '\n}' , a:prio)
  return style
endfunction

" ## API      functions {{{1

" Function: lh#dev#style#indent_brace_style#use(styles, indent, ...) {{{3
function! lh#dev#style#indent_brace_style#use(styles, indent, ...) abort
  let input_options = get(a:, 1, {})
  let [options, local, prio, ft] = lh#dev#style#_prepare_options_for_add_style(input_options)
  if prio == 1
    let prio9 = 9
    let prio = 10
  endif
  if     a:indent =~? 'k_r\|1TBS\|OTBS\|linux_kernel\|bsd_knf\|Ratliff'
    " TODO: check what are the other differences
    let style = lh#dev#style#breakbeforebraces#_linux(local, ft, prio, prio9)
  elseif a:indent =~? 'Stroustrup'
    let style = lh#dev#style#breakbeforebraces#_stroustrup(local, ft, prio, prio9)
  elseif a:indent =~? 'Allman\|Whitesmiths'
    " TODO: check what are the other differences
    let style = lh#dev#style#breakbeforebraces#_allman(local, ft, prio, prio9)
  elseif a:indent =~? 'GNU'
    let style = lh#dev#style#breakbeforebraces#_gnu(local, ft, prio, prio9)
  elseif a:indent =~? 'Horstmann'
    let style = lh#dev#style#indent_brace_style#_horstmann(local, ft, prio, prio9)
  elseif a:indent =~? 'Pico'
    let style = lh#dev#style#indent_brace_style#_pico(local, ft, prio, prio9)
  elseif a:indent =~? 'Lisp'
    let style = lh#dev#style#indent_brace_style#_lisp(local, ft, prio, prio9)
  elseif a:indent =~? 'Java'
    let style = lh#dev#style#indent_brace_style#_java(local, ft, prio, prio9)
  else
    call s:Verbose("WARNING: Impossible to set `indent_brace_style` style to `%1`", a:indent)
    call lh#common#warning_msg("WARNING: Impossible to set `indent_brace_style` style to `".a:indent.'`')
    return 0
  endif
  call s:Verbose("`indent_brace_style` style set to `%1`", a:indent)
  return 1
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
