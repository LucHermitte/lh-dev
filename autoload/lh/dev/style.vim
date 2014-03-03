"=============================================================================
" $Id$
" File:         autoload/lh/dev/style.vim                         {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      1.1.1
" Created:      12th Feb 2014
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       Functions related to help implement coding styles (e.g. Allman or K&R
"       way of placing brackets, must there be spaces after ';' in for control
"       statements, ...)
"
"       Defines:
"       - support function for :AddStyle
"       - lh#dev#style#get() that returns the style chosen for the given
"         filetype
"
" Tests:
"       See tests/lh/dev-style.vim
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim


"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
let s:k_version = 111
function! lh#dev#style#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = 0
function! lh#dev#style#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#dev#style#debug(expr)
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
" ## Exported functions {{{1

" Function: lh#dev#style#clear() {{{2
function! lh#dev#style#clear()
  let s:style = {} 
endfunction

" Function: lh#dev#style#get(ft) {{{3
" priority:
" 1- same ft && buffer local
" 2- same ft && global
" 3- inferior ft (C++ inherits C stuff) && buffer local
" 4- inferior ft (C++ inherits C stuff) && global
" ...
" n-1- for all ft && buffer local
" n- for all ft && global
function! lh#dev#style#get(ft)
  let res = {}

  let fts = lh#dev#option#inherited_filetypes(a:ft) + ['*']
  let bufnr = bufnr('%')

  for [pattern, hows] in items(s:style)
    let new_repl = {}
    let new_repl[pattern] = ''

    for how in hows
      if how.local != -1 && how.local != bufnr
        continue
      endif

      let ft = index(fts, how.ft)
      if ft < 0 | continue | endif

      if empty(new_repl[pattern])
        let new_repl[pattern] = how.replacement
        let new_repl.ft = ft
      else
        let old_ft = get(new_repl, 'ft', -1)
        if ft < old_ft
          let new_repl[pattern] = how.replacement
          let new_repl.ft = ft
        elseif ft == old_ft
          if how.local == bufnr " then we override global setting
            let new_repl[pattern] = how.replacement
          endif
        endif " compare fts
      endif " compare to previous definition
    endfor
    if !empty(new_repl[pattern])
      unlet new_repl.ft
      call extend(res, new_repl)
    endif
  endfor

  return res
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1
if !exists('s:style')
  call lh#dev#style#clear()
endif

" Function: lh#dev#style#_add(pattern, ...) {{{2
function! lh#dev#style#_add(pattern, ...)
  " Analyse params {{{3
  let local = -1
  let ft = '*'
  for o in a:000
    if     o =~ '-b\%[uffer]'
      let local = bufnr('%')
    elseif o =~ '-ft\|-filetype'
      let ft = matchstr(o, '.*=\zs.*')
      if empty(ft)
        let ft = &ft
      endif
    else
      let repl = o
    endif
  endfor
  if !exists('repl')
    throw "Replacement text unspecified in ".string(a:000)
  endif
  " Interpret some escape sequences
  let repl = lh#dev#reinterpret_escaped_char(repl)

  " Add the new style {{{3
  let previous = get(s:style, a:pattern, [])
  " but first check whether there is already something before adding anything
  for style in previous
    if style.local == local && style.ft == ft
      let style.replacement = repl
      return 
    endif
  endfor
  " This is new => add ;; note the "return" in the search loop
  let s:style[a:pattern] = previous + [ {'local': local, 'ft': ft, 'replacement': repl}]
endfunction

"------------------------------------------------------------------------
" ## Default definitions {{{1

AddStyle { -ft=java {\n
AddStyle } -ft=java \n}

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
