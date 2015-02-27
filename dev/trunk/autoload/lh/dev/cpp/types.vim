"=============================================================================
" $Id$
" File:		autoload/lh/dev/cpp/types.vim                            {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.3
let s:k_version = '1.1.3'
" Created:	10th Feb 2009
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:
" 	Analysis functions for C++ types.
"
"------------------------------------------------------------------------
" History:
" 	v0.0.0: Creation in lh-cpp
" 	v0.2.2: Moved to lh-dev v0.0.3
" 	v1.0.2: New function lh#dev#cpp#types#IsPointer(type) for lh-cpp
" 	        doxygenation.
" 	v1.1.3: New function specialization: lh#dev#types#deduce()
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------

" ## Misc Functions     {{{1
" # Version {{{2
function! lh#dev#cpp#types#version()
  return s:k_version
endfunction

" # Debug   {{{2
if !exists('s:verbose')
  let s:verbose = 0
endif
function! lh#dev#cpp#types#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#dev#cpp#types#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1

" # const correction {{{2
" Function:	s:ExtractPattern(str, pat) : str	{{{3
" Note:		Internal, used by IsBaseType
function! s:ExtractPattern(expr, pattern)
  return substitute(a:expr, '^\s*\%('. a:pattern .'\)\s*', '', 'g')
endfunction

" Function:	lh#dev#cpp#types#IsBaseType(typeName) : bool	{{{3
" Note:		Do not test for aberrations like long float
" @todo Check for enumerates in ctags (or other) databases
function! lh#dev#cpp#types#IsBaseType(type, pointerAsWell)
  echomsg "Check lh#dev#cpp#types#IsBaseType(".a:type.")"
  let sign  = '\<unsigned\>\|\<signed\>'
  let size  = '\<short\>\|\<long\>\|\<long\s\+long\>\|\<\>'
  let types = '\<void\>\|\<char\>\|\<wchar_t\>\|\<int\>\|\<float\>\|\<double\>\|\<size_t\>\|\<ptrdiff_t\>'
  let scope = '\(\<\I\i*\s*::\s*\)\+'
  " C++11 types
  let types.= '\|\<u\=int\%(_least\|_fast\)\=\%(8\|16\|32\|64\)_t\>'
  let types.= '\|\<u\=int\%(max\|ptr\)_t\>'
  let types.= '\|\<bool\>'

  let expr = s:ExtractPattern( a:type, scope )
  let expr = s:ExtractPattern( expr, sign )
  let expr = s:ExtractPattern( expr,   size )
  let expr = s:ExtractPattern( expr,   types )
  if a:pointerAsWell==1
    if match( substitute(expr,'\s*','','g'), '\(\*\|&\)\+$' ) != -1
      return 1
    endif
  endif
  " return strlen(expr) == 0
  return expr == ''
endfunction

" Function:	lh#dev#cpp#types#ConstCorrectType(type) : string	{{{3
" Purpose:	Returns the correct expression of the type regarding the
" 		const-correctness issue ; cf Herb Sutter's
" 		_Exceptional_C++_ - Item 43.
" Option:       (b|g):{cpp_}place_const_after_type : boolean, default: true
function! lh#dev#cpp#types#ConstCorrectType(type)
  if lh#dev#cpp#types#IsBaseType(a:type,1) == 1
    return a:type
  elseif lh#dev#option#get('place_const_after_type', 'cpp', 1)
    return a:type . ' const&'
  else
    return 'const ' . a:type . '&'
  endif
endfunction

" # Various functions {{{2
" Function: lh#dev#cpp#types#IsPointer(type) : bool {{{3
function! lh#dev#cpp#types#IsPointer(type)
  return a:type =~ '\%([*]\|pointer\|_ptr\|Ptr\)\s*$'
endfunction

" ## Overridden functions {{{1

" Function: lh#dev#cpp#types#_deduce(expr) {{{3
function! lh#dev#cpp#types#_deduce(expr)
  " 1- C++ 11 or more ?
  runtime autoload/lh/cpp.vim
  if exists('*lh#cpp#use_cpp11') && lh#cpp#use_cpp11()
    return 'auto'
  endif
  " 2- fallback to C/type
  return lh#dev#c#types#_deduce(a:expr)
endfunction

" ## Internal functions {{{1

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
