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
" # Common definitions {{{2
" Function: lh#dev#style#indent_brace_style#__k_r_end_bracket(style, a:prio) {{{3
" Many styles handle `}` in the same way: K&R, Java, 1TBS, 0TBS...
" NB:
" - finally belongs to java, C#...
" - catch belongs to C++, Java...
" TODO: Provide a way to inject other keywords.
function! lh#dev#style#indent_brace_style#__k_r_end_bracket(style, prio) abort
  call a:style.add('}\%(\s*\%(;\|else\|while\|catch\|finally\|$\|'.lh#marker#txt('.\{-}').'\|!mark!\)\)\@!' , '\n}\n' , a:prio)
  call a:style.add('}\ze\%(\s*\%(else\|while\|catch\|finally\)\)'                                           , '\n} '  , a:prio)
  call a:style.add('}\ze$'                                                                  , '\n}'   , a:prio)
  call a:style.add('}\ze\('.lh#marker#txt('.\{-}').'\|!mark!\)'                             , '\n}'   , a:prio)
  call a:style.add('};'                                                                     , '\n};\n', a:prio)
endfunction

" # Style definitions {{{2
" Function: lh#dev#style#indent_brace_style#_k_r(local, ft, prio, ...) {{{3
" clang-format BreakBeforeBrace=Linux is just about braces. This indent style
" also implies expandtab and ts8
" TODO:
" - Handle multiline statements
" - Update the definition when marker characters change
let s:k_k_r_context_no_break
      \ = '\%('
      \ .        '\<\%(if\|while\|switch\|for\)\>\s*(.*)'
      \ . '\|' . '\<do\|else\>'
      \ . '\)'
function! lh#dev#style#indent_brace_style#_k_r(local, ft, prio, ...) abort
  let style = lh#dev#style#breakbeforebraces#_new('K&R', a:local, a:ft)
  " Let's assume there is no function definition in a control statement, we'll
  " see about lambdas later
  call style.add(s:k_k_r_context_no_break.'\zs{'              , ' {\n', a:prio)
  " break if not behind one of the previous contexts, or at the beginning of
  " the line
  call style.add('\('.s:k_k_r_context_no_break.'\s*\|^\)\@<!{'                            , '\n{\n' , a:prio + 1)

  call lh#dev#style#indent_brace_style#__k_r_end_bracket(style, a:prio)
  return style
endfunction

" Function: lh#dev#style#indent_brace_style#_linux_kernel(local, ft, prio, ...) {{{3
" clang-format BreakBeforeBrace=Linux is just about braces. This indent style
" also implies expandtab and ts8
function! lh#dev#style#indent_brace_style#_linux_kernel(local, ft, prio, ...) abort
  let style = call('lh#dev#style#indent_brace_style#_k_r', [a:local, a:ft, a:prio] + a:000)
  " TODO: when used with global and ft!='*', register expandtab/ts to be set to
  " be set locally
  if a:local
    setlocal expandtab
    setlocal ts=8
  elseif a:ft == '*'
    set expandtab
    set ts=8
  else
    " TODO: when used with global and ft!='*', register expandtab/ts to be set to
    call lh#common#warning_msg("expandtab and tabstop won't be set properly with these parameters: all buffers and ft=".a:ft)
  endif
  return style
endfunction

" Function: lh#dev#style#indent_brace_style#_bsd_knf(local, ft, prio, ...) {{{3
" https://en.wikipedia.org/wiki/Indent_style#Variant:_BSD_KNF
" Also implies:
" - extra empty line at function start if there is no local variable: unimplemented
" - ts=8/expandtab // sw=4 for alignment (alignment: unimplemented)
" - space before parenthesis for ctrl statements, not functions
" TODO: handle multiline statements
let s:k_bsd_knf_context_no_break
      \ = '\%('
      \ .        '\<\%(if\|while\|switch\|for\)\>\s*(.*)'
      \ . '\|' . '\<do\|else\>'
      \ . '\)'
function! lh#dev#style#indent_brace_style#_bsd_knf(local, ft, prio, ...) abort
  let style = lh#dev#style#breakbeforebraces#_new('bsd_knf', a:local, a:ft)
  " Let's assume there is no function definition in a control statement, we'll
  " see about lambdas later
  call style.add(s:k_bsd_knf_context_no_break.'\zs{'              , ' {\n', a:prio)
  " break if not behind one of the previous contexts, or at the beginning of
  " the line
  call style.add('\('.s:k_bsd_knf_context_no_break.'\s*\|^\)\@<!{', '\n{\n', a:prio + 1)
  call style.add('};\@!'                                          , '\n}\n', a:prio)
  call style.add('};'                                             , '\n};\n', a:prio)

  " TODO: should it be registered as a paren_style?
  call style.add('\<\%(if\|while\|switch\|for\|catch\)\>\zs(', ' (', a:prio)

  " TODO: when used with global and ft!='*', register expandtab/ts to be set to
  " be set locally
  if a:local
    setlocal expandtab
    setlocal ts=8
    setlocal sw=4
  elseif a:ft == '*'
    set expandtab
    set ts=8
    set sw=4
  else
    " TODO: when used with global and ft!='*', register expandtab/ts to be set to
    call lh#common#warning_msg("expandtab and tabstop won't be set properly with these parameters: all buffers and ft=".a:ft)
  endif
  return style
endfunction

" Function: lh#dev#style#indent_brace_style#_ratliff(local, ft, prio, ...) {{{3
let s:k_ratliff_context_no_break
      \ = '\%('
      \ .        '\<\%(if\|while\|switch\|for\)\>\s*(.*)'
      \ . '\|' . '\<do\|else\>'
      \ . '\)'
function! lh#dev#style#indent_brace_style#_ratliff(local, ft, prio, ...) abort
  let style = lh#dev#style#breakbeforebraces#_new('ratliff', a:local, a:ft)
  " Let's assume there is no function definition in a control statement, we'll
  " see about lambdas later
  call style.add(s:k_ratliff_context_no_break.'\zs{'              , ' {\n', a:prio)
  " break if not behind one of the previous contexts, or at the beginning of
  " the line
  call style.add('\('.s:k_ratliff_context_no_break.'\s*\|^\)\@<!{', '\n{\n', a:prio + 1)
  call style.add('};\@!'                                        , '\n}\n', a:prio)
  call style.add('};'                                           , '\n};\n', a:prio)
  return style
endfunction

" Function: lh#dev#style#indent_brace_style#_horstmann(local, ft, prio) {{{3
" Horstmann 97 style, as the 2003 one is identical to Allman's.
" TODO: adapt the indent when sw is changed, or read it in a:styles
" This also means that if Horstmann/Pico is global and &sw is not, it'll
" complicates &sw management...
function! lh#dev#style#indent_brace_style#_horstmann(local, ft, prio, ...) abort
  let style = lh#dev#style#breakbeforebraces#_new('horstmann', a:local, a:ft)
  call style.add('^\@<!{', '\n{'.repeat( ' ', &sw-1), a:prio)
  call style.add('^{'    , '\n{'.repeat( ' ', &sw-1), a:prio)
  call style.add('};\@!' , '\n}\n'                  , a:prio)
  call style.add('};'    , '\n};\n'                 , a:prio)
  return style
endfunction

" Function: lh#dev#style#indent_brace_style#_pico(local, ft, prio) {{{3
" TODO: adapt the indent when sw is changed, or read it in a:styles
" This also means that if Horstmann/Pico is global and &sw is not, it'll
" complicates &sw management...
function! lh#dev#style#indent_brace_style#_pico(local, ft, prio, ...) abort
  let style = lh#dev#style#breakbeforebraces#_new('pico', a:local, a:ft)
  call style.add('^\@<!{', '\n{'.repeat( ' ', &sw-1), a:prio)
  call style.add('^{'    , '{'.repeat( ' ', &sw-1)  , a:prio)
  " TODO: Don't add a space in `{}` case.
  call style.add('};\@!' , ' }\n'                   , a:prio)
  call style.add('};'    , ' };\n'                  , a:prio)
  return style
endfunction

" Function: lh#dev#style#indent_brace_style#_lisp(local, ft, prio) {{{3
function! lh#dev#style#indent_brace_style#_lisp(local, ft, prio, ...) abort
  let style = lh#dev#style#breakbeforebraces#_new('lisp', a:local, a:ft)
  call style.add('^\@<!{' , ' {\n', a:prio)
  call style.add('^{'     , '{\n' , a:prio) " Not meant to exist
  call style.add('}\+;\=\zs'     , '\n', a:prio)
  return style
endfunction

" Function: lh#dev#style#indent_brace_style#_java(local, ft, prio) {{{3
function! lh#dev#style#indent_brace_style#_java(local, ft, prio, ...) abort
  let style = lh#dev#style#breakbeforebraces#_new('java', a:local, a:ft)
  call style.add('^{'    , ' {\n'    , a:prio) " Not meant to exist
  call style.add('^\@<!{', ' {\n'    , a:prio)
  call lh#dev#style#indent_brace_style#__k_r_end_bracket(style, a:prio)
  return style
endfunction

" ## API      functions {{{1
let s:k_function = {
      \ 'k_r'         : 'lh#dev#style#indent_brace_style#_k_r'
      \,'0tbs'        : 'lh#dev#style#indent_brace_style#_k_r'
      \,'1tbs'        : 'lh#dev#style#indent_brace_style#_k_r'
      \,'linux_kernel': 'lh#dev#style#indent_brace_style#_linux_kernel'
      \,'bsd_knf'     : 'lh#dev#style#indent_brace_style#_bsd_knf'
      \,'ratliff'     : 'lh#dev#style#indent_brace_style#_ratliff'
      \,'stroustrup'  : 'lh#dev#style#breakbeforebraces#_stroustrup'
      \,'allman'      : 'lh#dev#style#breakbeforebraces#_allman'
      \,'whitesmiths' : 'lh#dev#style#breakbeforebraces#_allman'
      \,'gnu'         : 'lh#dev#style#breakbeforebraces#_gnu'
      \,'horstmann'   : 'lh#dev#style#indent_brace_style#_horstmann'
      \,'pico'        : 'lh#dev#style#indent_brace_style#_pico'
      \,'lisp'        : 'lh#dev#style#indent_brace_style#_lisp'
      \,'java'        : 'lh#dev#style#indent_brace_style#_java'
      \ }

" Function: lh#dev#style#indent_brace_style#use(styles, indent, ...) {{{3
function! lh#dev#style#indent_brace_style#use(styles, indent, ...) abort
  let input_options = get(a:, 1, {})
  let [options, local, prio, ft] = lh#dev#style#_prepare_options_for_add_style(input_options)
  if prio == 1
    let prio9 = 9
    let prio = 10
  endif
  let indent = tolower(a:indent)
  if has_key(s:k_function, indent)
    let style = call(s:k_function[indent], [local, ft, prio, prio9])
    call s:Verbose("`indent_brace_style` style set to `%1`", a:indent)
    return 1
  else
    call s:Verbose("WARNING: Impossible to set `indent_brace_style` style to `%1`", a:indent)
    call lh#common#warning_msg("WARNING: Impossible to set `indent_brace_style` style to `".a:indent.'`')
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
