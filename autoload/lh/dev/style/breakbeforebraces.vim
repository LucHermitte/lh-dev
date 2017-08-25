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
" ## Styles             {{{1
" # Root "class" {{{2

" Function: lh#dev#style#breakbeforebraces#_new(name, local, ft) {{{3
function! lh#dev#style#breakbeforebraces#_new(name, local, ft) abort
  let style = lh#dev#style#define_group('breakbeforebraces', a:name, !a:local, a:ft)
  let s:crt_style = style
  return style
endfunction

" # Style definitions {{{2
" Function: lh#dev#style#breakbeforebraces#_attach(local, ft, prio) {{{3
" Always attach braces to surrounding context
function! lh#dev#style#breakbeforebraces#_attach(local, ft, prio, ...) abort
  let style = lh#dev#style#breakbeforebraces#_new('attach', a:local, a:ft)
  " except at the start of the line
  call style.add('^\@<!{', ' {\n'  , a:prio)
  call style.add('}' , '\n}'   , a:prio)
  " extra \n after the semi-colon
  call style.add('};', '};\n', a:prio)
  return style
endfunction

" Function: lh#dev#style#breakbeforebraces#_linux(local, ft, prio) {{{3
" Like Attach, but break before braces on function, namespace and class
" definitions.
" TODO: handle multiline statements
let s:k_linux_context_no_break
      \ = '\%('
      \ .        '\<\%(if\|while\|switch\|for\)\>\s*(.*)'
      \ . '\|' . '\<do\>'
      \ . '\)'
function! lh#dev#style#breakbeforebraces#_linux(local, ft, prio, prio9) abort
  let style = lh#dev#style#breakbeforebraces#_new('linux', a:local, a:ft)
  " Let's assume there is no function definition in a control statement, we'll
  " see about lambdas later
  call style.add(s:k_linux_context_no_break.'\zs{'              , ' {\n', a:prio)
  " break if not behind one of the previous contexts, or at the beginning of
  " the line
  call style.add('\('.s:k_linux_context_no_break.'\s*\|^\)\@<!{', '\n{\n', a:prio + 1)
  call style.add('}'                                            , '\n}' , a:prio)
  " extra \n if followed by a semi-colon
  call style.add('};'                                           , '};\n', a:prio)
  return style
endfunction

" Function: lh#dev#style#breakbeforebraces#_stroustrup(local, ft, prio) {{{3
" Like Attach, but break before function definitions.
" TODO: handle multiline statements
let s:k_stroutrup_context_no_break
      \ = '\%('
      \ .        '\<\%(if\|while\|switch\|for\)\>\s*(.*)'
      \ . '\|' . '\<do\>'
      \ . '\|' . '\<\%(namespace\|class\|struct\|union\|enum\).\{-}\S\>'
      \ . '\)'
function! lh#dev#style#breakbeforebraces#_stroustrup(local, ft, prio, prio9) abort
  let style = lh#dev#style#breakbeforebraces#_new('stroustrup', a:local, a:ft)

  " Let's assume there is no function definition in a control statement, we'll
  " see about lambdas later
  call style.add(s:k_stroutrup_context_no_break.'\zs{'              , ' {\n' , a:prio)
  " break if not behind one of the previous contexts, or at the beginning of
  " the line
  call style.add('\('.s:k_stroutrup_context_no_break.'\s*\|^\)\@<!{', '\n{\n', a:prio + 1)
  call style.add('}'                                                , '\n}'  , a:prio)
  " extra \n if followed by a semi-colon
  call style.add('};'                                               , '};\n' , a:prio)
  return style
endfunction

" Function: lh#dev#style#breakbeforebraces#_allman(local, ft, prio) {{{3
" Always break before braces.
function! lh#dev#style#breakbeforebraces#_allman(local, ft, prio, ...) abort
  let style = lh#dev#style#breakbeforebraces#_new('allman', a:local, a:ft)

  call style.add('^\@<!{' , '\n{\n' , a:prio)
  call style.add('};\@!'  , '\n}\n' , a:prio)
  call style.add('};'     , '\n};\n', a:prio)
  return style
endfunction

" Function: lh#dev#style#breakbeforebraces#_gnu(local, ft, prio) {{{3
" Always break before braces and add an extra level of indentation to braces of
" control statements, not to those of class, function or other definitions.
" TODO: adjust cindent
function! lh#dev#style#breakbeforebraces#_gnu(local, ft, prio, ...) abort
  let style = lh#dev#style#breakbeforebraces#_new('gnu', a:local, a:ft)

  call style.add('^\@<!{' , '\n{\n' , a:prio)
  call style.add('};\@!'  , '\n}\n' , a:prio)
  call style.add('};'     , '\n};\n', a:prio)
  return style
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
    let style = lh#dev#style#breakbeforebraces#_attach(local, ft, prio)
  elseif a:indent ==? 'linux'
    let style = lh#dev#style#breakbeforebraces#_linux(local, ft, prio, prio9)
  elseif a:indent ==? 'stroustrup'
    let style = lh#dev#style#breakbeforebraces#_stroustrup(local, ft, prio, prio9)
  elseif a:indent ==? 'Allman'
    let style = lh#dev#style#breakbeforebraces#_allman(local, ft, prio)
  elseif a:indent ==? 'GNU'
    let style = lh#dev#style#breakbeforebraces#_gnu(local, ft, prio)
  else
    call s:Verbose("WARNING: Impossible to set `breakbeforebraces` style to `%1`", a:indent)
    call lh#common#warning_msg("WARNING: Impossible to set `breakbeforebraces` style to `".a:indent.'`')
    return 0
  endif
  call s:Verbose("`breakbeforebraces` style set to `%1`", a:indent)
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
