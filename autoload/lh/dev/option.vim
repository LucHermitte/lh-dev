"=============================================================================
" File:         autoload/lh/dev/option.vim                        {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte/lh-dev>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-dev/tree/master/License.md>
" Version:      2.0.0
let s:k_version = 200
" Created:      05th Oct 2009
" Last Update:  18th Oct 2016
"------------------------------------------------------------------------
" Description:  «description»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
runtime autoload/lh/ft/option.vim

"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#dev#option#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#dev#option#verbose(...)
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

function! lh#dev#option#debug(expr) abort
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
function! lh#dev#option#get(name, ft,...) abort
  " This function has been deprecated
  return call('lh#ft#option#get', [a:name, a:ft] + a:000)
endfunction

" Function: lh#dev#option#get_postfixed(name, filetype, default [, scope])  {{{2
" @return which ever exists first among: b:{ft}_{name}, or g:{ft}_{name}, or
" b:{name}, or g:{name}. {default} is returned if none exists.
" @note filetype inheritance is supported.
" The order of the scopes for the variables checked can be specified through
" the optional argument {scope}
function! lh#dev#option#get_postfixed(name, ft,...) abort
  " This function has been deprecated
  return call('lh#ft#option#get_postfixed', [a:name, a:ft] + a:000)
endfunction

" Function: lh#dev#option#call(name, filetype, [, parameters])  {{{2
" @return lh#dev#{ft}#{name}({parameters}) if it exists, or
" lh#dev#{name}({parameters}) otherwise
" If {name} is a |List|, then the function name used is: {name}[0]#{ft}#{name}[1]
function! lh#dev#option#call(name, ft, ...) abort
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

  " call s:Verbose('Calling: '.fname.'('.join(map(copy(a:000), 'string(v:val)'), ', ').')')
  call s:Verbose('Calling: %1(%2)', fname, a:000)
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
    " TODO: here, check for timestamps in order to avoid reloading files that
    " haven't changed
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

" # Load

" # List of inherited properties between languages {{{2
" Function: lh#dev#option#inherited_filetypes(fts) {{{3
" - todo, this may required to be specific to each property considered
" For a very obscure reason, if this function is not duplicated here, tests are
" failling on travis! But neither on my Vim 7.4-2xxx nor on my Vim 7.3-429
" (yes, the same version than the one on travis!)
function! lh#dev#option#inherited_filetypes(fts) abort
  let res = []
  let lFts = split(a:fts, ',')
  let aux = map(copy(lFts), '[v:val] + lh#dev#option#inherited_filetypes(lh#option#get(v:val."_inherits", ""))')
  for a in aux
    let res += a
  endfor
  return res
  " return lh#ft#option#inherited_filetypes(a:fts)
endfunction

" }}}1
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
