"=============================================================================
" $Id$
" File:         autoload/lh/dev/tags.vim                          {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:	1.0.3
" Created:      09th Sep 2013
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       Various functions that parse ctags tags.
" 
"------------------------------------------------------------------------
" Requirements:
"       Requires Vim7+
" TODO: use the rigth scope resolution operator (depending on the langage)
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
let s:k_version = 103
function! lh#dev#tags#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = 0
function! lh#dev#tags#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#dev#tags#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1

" Function: lh#dev#tags#keep_full_names(tags_list) {{{3
function! lh#dev#tags#keep_full_names(tags_list)
  let result_as_dict = {}
  for tag in a:tags_list
    let full_name = []
    if has_key(tag, 'class') && stridx(tag.name, tag.class) < 0
      let full_name += [ tag.class ]
    endif
    let full_name += [ tag.name ]
    " TODO: use the right scope resolution operator
    let name = join(full_name, '::')

    if !has_key(result_as_dict, name)
      let tag.name = name
      let result_as_dict[name] = tag
    endif
  endfor
  " and then copy the dict to a list
  return values(result_as_dict)
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
