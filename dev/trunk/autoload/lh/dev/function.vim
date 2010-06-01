"=============================================================================
" $Id$
" File:         autoload/lh/dev/function.vim                      {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      0.0.1
" Created:      28th May 2010
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       Various helper functions that return ctags information on functions
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/autoload/lh/dev
"       Requires Vim7+, exhuberant ctags
" History:
" 	v0.0.1: code moved from lh-cpp
" TODO:         
" 	- option to use another code tool analysis that is not ft-dependant
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
let s:k_version = 001
function! lh#dev#function#version()
  return s:k_version
endfunction

" # Debug {{{2
let s:verbose = 0
function! lh#dev#function#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#dev#function#debug(expr)
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
" ## Exported functions {{{1

" lh#dev#function#get_(function_tag, key) {{{2
" This function returns cached function-data,
" If the data is not cached yet, the relevant hook is called to fill it
function! lh#dev#function#get_(fn_tag, key)
  if !has_key(a:fn_tag, a:key) 
    let a:fn_tag[a:key] = lh#dev#option#call('function#_'.a:key, &ft, a:fn_tag)
  endif
  return a:fn_tag[a:key]
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1
function! lh#dev#function#_prototype(fn_tag)
  return a:fn_tag.signature
endfunction

function! lh#dev#function#_signature(fn_tag)
  throw "ASSERT: This function is not expected to be called"
  " return a:fn_tag.signature
endfunction

function! lh#dev#function#_parameters(fn_tag)
  " ctags signature ensure a comments free signature => a comments free list of
  " parameters
  let signature = lh#dev#function#get_(a:fn_tag, 'signature')

  let params = lh#dev#option#call('function#_signature_to_parameters', &ft, signature)
  return params
endfunction

function! lh#dev#function#_signature_to_parameters(signature)
  " Most languages are free of pointer to function types, or even templates
  " Finding each parameter == spliting the string on commas
  " 1- find the list of formal parameters
  let sParameters = matchstr(a:signature, '(\zs.*\ze)')

  " 2- split it
  let lParameters = lh#dev#option#call('function#_split_list_of_parameters',&ft,sParameters)

  " 3- analyse the parameters ; 
  "    at least each shall have a name
  "    depending on the language, a type, a direction, etc may be provided
  let res = []
  for p in lParameters
    let ap = lh#dev#option#call('function#_analyse_parameter', &ft, p)
    let res += [ap]
  endfor
  return res
endfunction

function! lh#dev#function#_split_list_of_parameters(sParameters)
  let lParameters = split(a:sParameters, '\s*,\s*')
  return lParameters
endfunction

function! lh#dev#function#_analyse_parameter( param )
  " default case: implicitly typed languages like viml
  return { 'name': a:param }
endfunction

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
