"=============================================================================
" $Id$
" File:		autoload/lh/dev/cpp/types.vim                            {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.0.2
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
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------

" ## Functions {{{1
" # Debug {{{2
function! lh#dev#cpp#types#verbose(level)
  let s:verbose = a:level
endfunction

function! s:Verbose(expr)
  if exists('s:verbose') && s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#dev#cpp#types#debug(expr)
  return eval(a:expr)
endfunction

" const correction {{{2
" Function:	s:ExtractPattern(str, pat) : str	{{{3
" Note:		Internal, used by IsBaseType
function! s:ExtractPattern(expr, pattern)
  return substitute(a:expr, '^\s*\%('. a:pattern .'\)\s*', '', 'g')
endfunction

" Function:	lh#dev#cpp#types#IsBaseType(typeName) : bool	{{{3
" Note:		Do not test for aberrations like long float
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

" Various functions {{{2
" Function: lh#dev#cpp#types#IsPointer(type) : bool {{{3
function! lh#dev#cpp#types#IsPointer(type)
  return a:type =~ '\%([*]\|pointer\|_ptr\|Ptr\)\s*$'
endfunction

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
