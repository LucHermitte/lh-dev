"=============================================================================
" File:		autoload/lh/dev/cpp/types.vim                            {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-dev/License.md>
" Version:	1.3.7
let s:k_version = '1.3.7'
" Created:	10th Feb 2009
" Last Update:	27th Oct 2015
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
" 	v1.3.2: New types added to is_pointer
" 	v1.3.7: lh#dev#cpp#types#IsPointer supports "_ptr<.*>"
" 	        lh#dev#cpp#types#ConstCorrectType supports smart-pointers and
" 	        pointers
" 	        + lh#dev#cpp#types#is_smart_ptr
" 	        + lh#dev#cpp#types#remove_ptr
" 	        + lh#dev#cpp#types#is_not_owning_ptr
" 	        + draft detection of some CppCoreGuideLines pointer types
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
" Note:         Badly named: it build types for parameters
function! lh#dev#cpp#types#ConstCorrectType(type)
  if lh#dev#cpp#types#IsBaseType(a:type,1) == 1
    return a:type
  endif
  if lh#dev#option#get('place_const_after_type', 'cpp', 1)
    let fmt = '%1 const%2'
  else
    let fmt = 'const %1 %2'
  endif
  if a:type =~ '\v\*\s*$'
    " raw pointers
    return lh#fmt#printf(fmt, matchstr(a:type, '\v.*\ze\*\s*$'), '*')
  elseif lh#dev#cpp#types#IsPointer(a:type)
    " Other pointer types: smart pointers are taken by copy
    " No need to add const?
    return a:type
  else
    return lh#fmt#printf(fmt, a:type, '&')
  endif
endfunction

" # Various functions {{{2
" Function: lh#dev#cpp#types#IsPointer(type) : bool {{{3
function! lh#dev#cpp#types#IsPointer(type)
  return a:type =~ '\v([*]|(pointer|_ptr|Ptr|<not_null>|<own(er)=>)(\<.*\>)=)\s*$'
endfunction

" Function: lh#dev#cpp#types#is_smart_ptr(type) : bool {{{3
" TODO: test owner<T*>, not_null<T*>, auto_ptr, unique_ptr & co
function! lh#dev#cpp#types#is_smart_ptr(type) abort
  let regex = lh#dev#option#get('smart_ptr_pattern', 'cpp')
  if lh#option#is_set(regex) && a:type =~ regex
    return 1
  endif
  return a:type =~ '\v(_ptr|not_null)(\<.*\>)=\s*$'
endfunction

" Function: lh#dev#cpp#types#is_not_owning_ptr(type) {{{3
function! lh#dev#cpp#types#is_not_owning_ptr(type) abort
  if     a:type =~ '\v\*\s*$'
    return lh#dev#options#get('is_following_CppCoreGuideline', cpp, 0)
    " Meaning, own<T*> is defined, and no own<> <=> no need to copy
  elseif a:type =~ '\v(auto|unique|scoped)_ptr'
    return 0
  elseif a:type =~ '\v<own(er)=>'
    return 0
  else
    return 1
  endif
endfunction

" Function: lh#dev#cpp#types#remove_ptr(type) :string {{{3
" @pre: type is a pointer type
function! lh#dev#cpp#types#remove_ptr(type) abort
  if     a:type =~ '\v\*\s*$'
    return substitute(a:type, '\v\*\s*$', '', '')
  elseif a:type =~ '\v<(own(er)=|not_null)\<.*\>\s*$' " <- CppCoreGuidelines
    return matchstr(a:type, '\v<(own(er)=|not_null)\<\zs.*\ze\s*\*\s*\>\s*$')
  elseif a:type =~ '\v\<.*\>\s*$'
    return matchstr(a:type, '\v\<\zs.{-}\ze\s*\>\s*$')
  endif
  " TODO: have an option to help get the right trait, or a substitte expression
  throw "lh#dev#cpp#remove_ptr: don't know how to remove pointer qualification from type"
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
