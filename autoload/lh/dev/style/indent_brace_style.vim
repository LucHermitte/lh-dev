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
" TODO:         «missing features»
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
" ## API      functions {{{1

" Function: lh#dev#style#indent_brace_style#use(styles, indent, ...) {{{3
function! lh#dev#style#indent_brace_style#use(styles, indent, ...) abort
  let input_options = get(a:, 1, {})
  let [options, local, prio, ft] = lh#dev#style#_prepare_options_for_add_style(input_options)
  if prio == 1
    let options += ['-pr=10']
  endif
  if     a:indent =~? 'k_r\|1TBS\|OTBS\|linux_kernel\|bsd_knf\|Ratliff'
    call call('lh#dev#style#_add', options + ['{' , ' {\n'  ])
    call call('lh#dev#style#_add', options + ['};', '\n};\n'])
    call call('lh#dev#style#_add', options + ['}' , '\n}'   ])
  elseif a:indent =~? 'Stroustrup'
    call call('lh#dev#style#_add', options + ['{' , ' {\n'  ])
    call call('lh#dev#style#_add', options + ['};', '\n};\n'])
    call call('lh#dev#style#_add', options + ['}' , '\n}\n' ])
  elseif a:indent =~? 'Allman\|Whitesmiths\|GNU'
    call call('lh#dev#style#_add', options + ['{' , '\n{\n' ])
    call call('lh#dev#style#_add', options + ['};', '\n};\n'])
    call call('lh#dev#style#_add', options + ['}' , '\n}\n' ])
  elseif a:indent =~? 'Horstmann'
    " TODO: adapt the indent when sw is changed, or read it in a:styles
    " This also means that if Horstmann/Pico is global and &sw is not, it'll
    " complicates &sw management...
    call call('lh#dev#style#_add', options + ['{' , '\n{'.repeat( ' ', &sw-1) ])
    call call('lh#dev#style#_add', options + ['};', '\n};\n'])
    call call('lh#dev#style#_add', options + ['}' , '\n}\n' ])
  elseif a:indent =~? 'Pico'
    " TODO: adapt the indent when sw is changed, or read it in a:styles
    " This also means that if Horstmann/Pico is global and &sw is not, it'll
    " complicates &sw management...
    call call('lh#dev#style#_add', options + ['{' , '\n{'.repeat( ' ', &sw-1) ])
    call call('lh#dev#style#_add', options + ['};', '};\n'])
    call call('lh#dev#style#_add', options + ['}' , ' }\n' ])
  elseif a:indent =~? 'Lisp'
    call call('lh#dev#style#_add', options + ['{' , ' {\n'  ])
    call call('lh#dev#style#_add', options + ['};', '};\n'])
    call call('lh#dev#style#_add', options + ['}' , '}\n' ])
  elseif a:indent =~? 'Java'
    call call('lh#dev#style#_add', options + ['{', ' {\n'])
    call call('lh#dev#style#_add', options + ['}', '\n}' ])
  else
    return 0
  endif
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
