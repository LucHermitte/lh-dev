"=============================================================================
" File:         autoload/lh/dev/python/attribute.vim              {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-dev>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-dev/blob/master/License.md>
" Version:      2.0.0.
let s:k_version = '200'
" Created:      02nd Sep 2025
" Last Update:  02nd Sep 2025
"------------------------------------------------------------------------
" Description:
"       «description»
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
function! lh#dev#python#attribute#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#dev#python#attribute#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Log(expr, ...) abort
  call call('lh#log#this',[a:expr]+a:000)
endfunction

function! s:Verbose(expr, ...) abort
  if s:verbose
    call call('s:Log',[a:expr]+a:000)
  endif
endfunction

function! lh#dev#python#attribute#debug(expr) abort
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1
" Function: lh#dev#python#attribute#_analyse(definition) {{{3
" Extract from
"  {internal variable name} {: optional type} {= optional value}
"
" Tests:
" >>> lh#dev#python#attribute#_analyse('self.toto')
" >>> lh#dev#python#attribute#_analyse('self.__toto')
" >>> lh#dev#python#attribute#_analyse('self.toto    : list[int]')
" >>> lh#dev#python#attribute#_analyse('self.__toto  : list[int]')
" >>> lh#dev#python#attribute#_analyse('self.toto                = [1, 2, 3]')
" >>> lh#dev#python#attribute#_analyse('self.__toto              = [1, 2, 3]')
" >>> lh#dev#python#attribute#_analyse('self.toto    : list[int] = [1, 2, 3]')
" >>> lh#dev#python#attribute#_analyse('self.__toto  : list[int] = [1, 2, 3]')
" let s:k_vardecl_re = '\v^(\.{-})\s*(:\s*([^=]{-})\s*)(\=\s*(.*))$'
let s:k_vardecl_re = '\v^(.{-})\s*(:\s*([^=]{-})\s*)?(\=\s*(.*))?$'
function! lh#dev#python#attribute#_analyse(definition)
  let clean_def = lh#string#trim(a:definition)
  let match_res = matchlist(clean_def, s:k_vardecl_re)
  if empty(match_res)
    return {}
  endif
  let [all, varname, colon_type, type, eq_value, value; _] = match_res

  let res = {
        \ 'name'    : matchstr(varname, '\v(self\.)?\zs.*'),
        \ 'type'    : type,
        \ 'default' : value,
        \ }
  return res
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
