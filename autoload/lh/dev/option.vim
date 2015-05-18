"=============================================================================
" File:		autoload/lh/dev/option.vim                        {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte/lh-dev>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-dev/License.md>
" Version:	1.2.2
let s:k_version = 122
" Created:	05th Oct 2009
" Last Update:	24th Apr 2015
"------------------------------------------------------------------------
" Description:	«description»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------

" ## Misc Functions     {{{1
" # Version {{{2
function! lh#dev#option#version()
  return s:k_version
endfunction

" # Debug {{{2
if !exists('s:verbose')
  let s:verbose = 0
endif

function! lh#dev#option#verbose(level)
  let s:verbose = a:level
endfunction

function! s:Verbose(expr)
  if exists('s:verbose') && s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#dev#option#debug(expr)
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
" ## Exported functions {{{1

" Function: lh#dev#option#get(name, filetype[, default [, scope]])  {{{2
" @return which ever exists first among: b:{ft}_{name}, or g:{ft}_{name}, or
" b:{name}, or g:{name}. {default} is returned if none exists.
" @note filetype inheritance is supported.
" The order of the scopes for the variables checked can be specified through
" the optional argument {scope}
function! lh#dev#option#get(name, ft,...)
  let fts = lh#dev#option#inherited_filetypes(a:ft)
  call map(fts, 'v:val."_"')
  let fts += [ '']
  let scope = (a:0 == 2) ? a:2 : 'bg'
  let name = a:name
  for ft in fts
    let i = 0
    while i != strlen(scope)
      if exists(scope[i].':'.ft.name)
	return {scope[i]}:{ft}{name}
      endif
      let i += 1
    endwhile
  endfor
  return a:0 > 0 ? a:1 : lh#option#unset()
endfunction

" Function: lh#dev#option#get_postfixed(name, filetype, default [, scope])  {{{2
" @return which ever exists first among: b:{ft}_{name}, or g:{ft}_{name}, or
" b:{name}, or g:{name}. {default} is returned if none exists.
" @note filetype inheritance is supported.
" The order of the scopes for the variables checked can be specified through
" the optional argument {scope}
function! lh#dev#option#get_postfixed(name, ft,...)
  let fts = lh#dev#option#inherited_filetypes(a:ft)
  call map(fts, '"_".v:val')
  let fts += [ '']
  let scope = (a:0 == 2) ? a:2 : 'bg'
  let name = a:name
  for ft in fts
    let i = 0
    while i != strlen(scope)
      if exists(scope[i].':'.name.ft)
	return {scope[i]}:{name}{ft}
      endif
      let i += 1
    endwhile
  endfor
  return a:0 > 0 ? a:1 : lh#option#unset()
endfunction

" Function: lh#dev#option#call(name, filetype, [, parameters])  {{{2
" @return lh#dev#{ft}#{name}({parameters}) if it exists, or
" lh#dev#{name}({parameters}) otherwise
" If {name} is a |List|, then the function name used is: {name}[0]#{ft}#{name}[1]
function! lh#dev#option#call(name, ft, ...)
  if type(a:name) == type([])
    let prefix = a:name[0]
    let name   = a:name[1]
  elseif type(a:name) == type('string')
    let prefix = 'lh#dev'
    let name   = a:name
  else
    throw "Unexpected type (".type(a:name).") for name parameter"
  endif

  let fts = lh#dev#option#inherited_filetypes(a:ft)
  call map(fts, 'v:val."#"')
  let fts += ['']
  for ft in fts
    let fname = prefix.'#'.ft.name
    if !exists('*'.fname)
      let file = substitute(fname, '#', '/', 'g')
      let file = substitute(file, '.*\zs/.*', '.vim', '')
      exe 'runtime autoload/'.file
    endif
    if exists('*'.fname) | break | endif
  endfor

  call s:Verbose('Calling: '.fname.'('.join(map(copy(a:000), 'string(v:val)'), ', ').')')
  if s:verbose >= 2
    debug return call (function(fname), a:000)
  else
    return call (function(fname), a:000)
  endif
endfunction

" Function: lh#dev#option#pre_load_overrides(name, ft) {{{3
" @warning {name} hasn't the same syntax as #call() and #fast_call()
" @warning This function is expected to be executed from
" autoload/lh/dev/{name}.vim (or equivalent if the prefix is forced to
" something else)
function! lh#dev#option#pre_load_overrides(name, ft) abort
  if type(a:name) == type([])
    let prefix = a:name[0]
    let name   = a:name[1]
  elseif type(a:name) == type('string')
    let prefix = 'lh/dev'
    let name   = a:name
  else
    throw "Unexpected type (".type(a:name).") for name parameter"
  endif

  let fts = lh#dev#option#inherited_filetypes(a:ft)
  let files = map(copy(fts), 'prefix."/".v:val."/".name.".vim"')
  " let files += [prefix.'/'.name.'.vim'] " Don't load the default again!
  for file in files
    " TODO: here, check for timestamps in order to avoir reload files that
    " haven' changed
    exe 'runtime autoload/'.file
  endfor
endfunction

" Function: lh#dev#option#fast_call(name, ft, ...) {{{3
" @pre lh#option#dev#pre_load_overrides() must have been called before.
function! lh#dev#option#fast_call(name, ft, ...) abort
  if type(a:name) == type([])
    let prefix = a:name[0]
    let name   = a:name[1]
  elseif type(a:name) == type('string')
    let prefix = 'lh#dev'
    let name   = a:name
  else
    throw "Unexpected type (".type(a:name).") for name parameter"
  endif

  let fts = lh#dev#option#inherited_filetypes(a:ft)
  let fnames = map(copy(fts), 'prefix."#".v:val."#".name')
  let fnames += [prefix.'#'.name]

  let idx = lh#list#find_if(fnames, 'exists("*".v:val)')
  if idx < 0
    throw 'No override of '.prefix.'(#{ft})#'.name.' is known'
  endif
  let fname = fnames[idx]
  call s:Verbose('Calling: '.fname.'('.join(map(copy(a:000), 'string(v:val)'), ', ').')')
  if s:verbose >= 2
    debug return call (function(fname), a:000)
  else
    return call (function(fname), a:000)
  endif
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1

" # List of inherited properties between languages {{{2
" Function: lh#dev#option#inherited_filetypes(fts) {{{3
" - todo, this may required to be specific to each property considered
function! lh#dev#option#inherited_filetypes(fts)
  let res = []
  let lFts = split(a:fts, ',')
  for ft in lFts
    let parents = lh#option#get(ft.'_inherits', '')
    let res += [ft] + lh#dev#option#inherited_filetypes(parents)
  endfor
  return res
endfunction

LetIfUndef g:cpp_inherits 'c'


let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker: