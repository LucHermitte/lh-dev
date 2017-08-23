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
let s:style = lh#on#exit()
function! lh#dev#style#breakbeforebraces#use(styles, indent, ...) abort
  let input_options = get(a:, 1, {})
  let [options, local, prio, ft] = lh#dev#style#_prepare_options_for_add_style(input_options)
  if prio == 1
    let prio9 = 9
    let prio = 10
  endif
  if     a:indent ==? 'attach'
    let style = lh#dev#style#define_group('breakbeforebraces', !local, ft)
    " Always attach braces to surrounding context
    call call(style.add, ['{' , ' {\n'  , prio], style)
    call call(style.add, ['};', '\n};\n', prio], style)
    call call(style.add, ['}' , '\n}'   , prio], style)
    let s:style = style
  elseif a:indent ==? 'linux'
    " Like Attach, but break before braces on function, namespace and class
    " definitions.
    let style = lh#dev#style#define_group('breakbeforebraces', !local, ft)
    " TODO: handle multiline statements
    call call(style.add,
          \ ['\<\(if\|while\|switch\|for\)\>\s*(.*\)\zs)\s*{' , ') {\n'  , prio], style)
    call call(style.add, ['\<do\>\s*{' , 'do {\n'  , prio], style)
    call call(style.add, ['{' , '\n{\n' , prio9], style)
    call call(style.add, ['};', '\n};\n', prio], style)
    call call(style.add, ['}' , '\n}'   , prio], style)
  elseif a:indent ==? 'stroustrup'
    " Like Attach, but break before function definitions.
    let style = lh#dev#style#define_group('breakbeforebraces', !local, ft)
    " TODO: handle multiline statements
    call call(style.add,
          \ + ['\<\(if\|while\|switch\|for\)\>\s*(.*\)\zs)\s*{' , ') {\n'  , prio], style)
    call call(style.add,
          \ + ['\<do\>\s*{' , 'do {\n'  , prio], style)
    call call(style.add,
          \ + ['\<\(namespace\|class\>.\{-}\zs\s*{' , ' {\n'  , prio], style)
    call call(style.add, ['{' , ' {\n'  , prio9], style)
    call call(style.add, ['};', '\n};\n', prio], style)
    call call(style.add, ['}' , '\n}'   , prio], style)
  elseif a:indent ==? 'Allman'
    " Always break before braces.
    let style = lh#dev#style#define_group('breakbeforebraces', !local, ft)
    call call(style.add, ['{' , '\n{\n' , prio], style)
    call call(style.add, ['};', '\n};\n', prio], style)
    call call(style.add, ['}' , '\n}\n' , prio], style)
  elseif a:indent ==? 'GNU'
    " Always break before braces and add an extra level of indentation to
    " braces of control statements, not to those of class, function or other
    " definitions.
    let style = lh#dev#style#define_group('breakbeforebraces', !local, ft)
    call call(style.add, ['{' , '\n{\n' , prio], style)
    call call(style.add, ['};', '\n};\n', prio], style)
    call call(style.add, ['}' , '\n}\n' , prio], style)
    " TODO: adjust cindent
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
