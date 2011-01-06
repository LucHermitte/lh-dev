"=============================================================================
" $Id$
" File:		autoload/lh/dev/naming.vim                        {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	0.0.2
" Created:	05th Oct 2009
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	
" - Naming policies for programming styles
" 
"------------------------------------------------------------------------
" Installation:	«install details»
" History:
" 	v0.0.2: vim parameters specificities taken into account
" TODO:		
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------

" ## Misc Functions     {{{1
" # Version {{{2
let s:k_version = 001
function! lh#dev#naming#version()
  return s:k_version
endfunction

" # Debug {{{2
function! lh#dev#naming#verbose(level)
  let s:verbose = a:level
endfunction

function! s:Verbose(expr)
  if exists('s:verbose') && s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#dev#naming#debug(expr)
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1
function! s:Option(option, ft, default)
  return lh#dev#option#get('naming_'.a:option, a:ft, a:default)
endfunction

"------------------------------------------------------------------------
" ## Exported functions {{{1
" Tool functions {{{2
" Function:lh#dev#naming#to_upper_camel_case(identifier)   {{{3
function! lh#dev#naming#to_upper_camel_case(identifier)
  let identifier = substitute(a:identifier, '\%(^\|_\)\(\a\)', '\u\1', 'g')
  return identifier
endfunction

" Function:lh#dev#naming#to_lower_camel_case(identifier)   {{{3
function! lh#dev#naming#to_lower_camel_case(identifier)
  let identifier = substitute(a:identifier, '_\(\a\)', '\u\1', 'g')
  let identifier = substitute(identifier, '^\(\a\)', '\l\1', '')
  return identifier
endfunction

" Function:lh#dev#naming#to_underscore(identifier)         {{{3
function! lh#dev#naming#to_underscore(identifier)
  "todo: handle constant-like identifiers
  "test with lh#foo#FooBar ...
  let identifier = substitute(a:identifier, '\%(^\|[^A-Za-z0-9]\)\zs\(\u\)', '\l\1', '')
  let identifier = substitute(identifier, '\l\zs\(\u\)', '_\l\1', 'g')
  return identifier
endfunction

" Identifiers (var, getter, global, ...) {{{2
" Function: lh#dev#naming#variable(variable [, filetype] ) {{{3
function! lh#dev#naming#variable(name, ...)
  let ft = (a:0 == 1) ? a:1 : &ft
  let strip_re    = s:Option('strip_re', ft, '^\%(get\|set\|[mgsp]_\|_\+\)\=\(.\{-}\)\%(_\=\)$')
  let strip_subst = s:Option('strip_subst', ft, '\l\1')
  let res = substitute(a:name, strip_re, strip_subst, '')
  return res
endfunction

" Function: lh#dev#naming#getter(variable [, filetype] ) {{{3
function! lh#dev#naming#getter(variable, ...)
  let ft = (a:0 == 1) ? a:1 : &ft
  let get_re    = s:Option('get_re', ft, '.*')
  let get_subst = s:Option('get_subst', ft, 'get\u&')
  let res = substitute(a:variable, get_re, get_subst, '' )
  return res
endfunction

" Function: lh#dev#naming#setter(variable [, filetype] ) {{{3
function! lh#dev#naming#setter(variable, ...)
  let ft = (a:0 == 1) ? a:1 : &ft
  let set_re    = s:Option('set_re', ft, '.*')
  let set_subst = s:Option('set_subst', ft, 'set\u&')
  let res = substitute(a:variable, set_re, set_subst, '' )
  return res
endfunction

" Function: lh#dev#naming#global(variable [, filetype] ) {{{3
function! lh#dev#naming#global(variable, ...)
  let ft = (a:0 == 1) ? a:1 : &ft
  let global_re    = s:Option('global_re', ft, '.*')
  let global_subst = s:Option('global_subst', ft, 'g_&')
  let res = substitute(a:variable, global_re, global_subst, '' )
  return res
endfunction

" Function: lh#dev#naming#local(variable [, filetype] ) {{{3
function! lh#dev#naming#local(variable, ...)
  let ft = (a:0 == 1) ? a:1 : &ft
  let local_re    = s:Option('local_re', ft, '.*')
  let local_subst = s:Option('local_subst', ft, '&')
  let res = substitute(a:variable, local_re, local_subst, '' )
  return res
endfunction

" Function: lh#dev#naming#member(variable [, filetype] ) {{{3
function! lh#dev#naming#member(variable, ...)
  let ft = (a:0 == 1) ? a:1 : &ft
  let member_re    = s:Option('member_re', ft, '.*')
  let member_subst = s:Option('member_subst', ft, 'm_&')
  let res = substitute(a:variable, member_re, member_subst, '' )
  return res
endfunction

" Function: lh#dev#naming#static(variable [, filetype] ) {{{3
function! lh#dev#naming#static(variable, ...)
  let ft = (a:0 == 1) ? a:1 : &ft
  let static_re    = s:Option('static_re', ft, '.*')
  let static_subst = s:Option('static_subst', ft, 's_&')
  let res = substitute(a:variable, static_re, static_subst, '' )
  return res
endfunction

" Function: lh#dev#naming#constant(variable [, filetype] ) {{{3
function! lh#dev#naming#constant(variable, ...)
  let ft = (a:0 == 1) ? a:1 : &ft
  let constant_re    = s:Option('constant_re', ft, '.*')
  let constant_subst = s:Option('constant_subst', ft, '\U&\E')
  let res = substitute(a:variable, constant_re, constant_subst, '' )
  return res
endfunction

" Function: lh#dev#naming#param(variable [, filetype] ) {{{3
" Example to have parameters post-fixed with '_':
"   :let b:cpp_naming_param_re = '\(.\{-}\)_\=$'
"   :let b:cpp_naming_param_subst = '\1_'
function! lh#dev#naming#param(variable, ...)
  let ft = (a:0 == 1) ? a:1 : &ft
  let param_re    = s:Option('param_re', ft, '.*')
  let param_subst = s:Option('param_subst', ft, '&')
  let res = substitute(a:variable, param_re, param_subst, '' )
  return res
endfunction

"------------------------------------------------------------------------
" ## Predefined constants {{{1

" todo: differentiate vim arg use from arg names in function signature
LetIfUndef g:vim_naming_param_re     '\%([algsbwt]:\)\=\(.*\)'
LetIfUndef g:vim_naming_param_subst  'a:\1'
LetIfUndef g:vim_naming_static_re     '\%([algsbwt]:\)\=\(.*\)'
LetIfUndef g:vim_naming_static_subst 's:\1'
LetIfUndef g:vim_naming_global_re     '\%([algsbwt]:\)\=\(.*\)'
LetIfUndef g:vim_naming_global_subst 'g:\1'


"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
