"=============================================================================
" $Id$
" File:         autoload/lh/dev/c/function.vim                    {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      «0.0.3»
" Created:      31st May 2010
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       «description»
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/autoload/lh/dev/c
"       Requires Vim7+
"       «install details»
" History:      
"       «v 0.0.3» support for variadic parameters
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
let s:k_version = 002
function! lh#dev#c#function#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = 0
function! lh#dev#c#function#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#dev#c#function#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1

" # Prototype {{{2

" lh#dev#c#function#get_prototype(lineNo, onlyDeclaration) " {{{3
" Todo: 
" * Retrieve the type even when it is not on the same line as the function
"   identifier.
" * Retrieve the const modifier even when it is not on the same line as the
"   ')'.
function! lh#dev#c#function#get_prototype(lineNo, onlyDeclaration)
  let endPattern = a:onlyDeclaration ? ';' : '[;{]'
  exe a:lineNo
  " 0- Goto end of current line of prototype (stop at the first found)
  normal! 0
  call search( ')\|\n')
  " 1- Goto start of current prototype
  " let pos = searchpair('\<\i\+\>\%(\n\|\s\)*(', '', ')\%(\n\|[^;]\)*;.*$\ze', 'bW')
  " let pos = searchpair('\<\i\+\>\%(\n\|\s\)*(', '', ')', 'bW')
  let pos = searchpair('\<\i\+\>\_s*(', '', ')\_[^{};]*'.endPattern, 'bW')
  let l0 = line('.')
  " 2- Goto the "end" of the current prototype
  " let pos = searchpair('\<\i\+\>\%(\n\|\s\)*(', '', ')', 'W')
  " let pos = searchpair('\<\i\+\>\%(\n\|\s\)*(', '', ')\%(\n\|[^;]\)*;\zs','W')
  let pos = searchpair('\<\i\+\>\_s*(', '', ')\_[^{};]*'.endPattern.'\zs', 'W')
  let l1 = line('.')
  " Abort if nothing found
  if ((0==pos) || (l0>a:lineNo)) | return '' | endif
  " 3- Build the prototype string
  let proto = getline(l0)
  while l0 < l1
    let l0 += 1
    " Add the line, and trim any comments ending the line
    let proto .= "\n" .
	  \ substitute(getline(l0), '\s*//.*$\|\s*/\*.\{-}\*/\s*$', '', 'g')
	  " \ substitute(getline(l0), '//.*$', '', 'g')
	  " \ substitute(getline(l0), '//.*$\|/\*.\{-}\*/', '', 'g')
  endwhile
  " 4- and return it.
  exe a:lineNo
  return proto
endfunction



"------------------------------------------------------------------------
" ## Internal functions {{{1

" # Prototype {{{2
" lh#dev#c#function#_prototype(fn_tag) " {{{3
" overrides of lh#dev#function#_prototype() to search for the tag in
" the relevant file
function! lh#dev#c#function#_prototype(fn_tag)
  " or should we split-open ?
  call lh#tags#jump(a:fn_tag)
  try 
    return lh#dev#c#function#get_prototype(
	  \ line('.'),
	  \ a:fn_tag.kind == 'p' ? 1 : 0)
  finally
    pop
  endtry
endfunction


" # Parameters {{{2
" Split the list, then reaarange parameters together
function! lh#dev#c#function#_split_list_of_parameters(sParameters)
  " call the generic function,
  let raw_params = lh#dev#function#_split_list_of_parameters(a:sParameters)
  " then rearrange elements that should be together
  let lParameters = []

  let to_append = ''
  for param in raw_params
    " string to append to the result list
    let to_append .= (strlen(to_append)?',':'') . param
    " Reduce templates and function types ; take care of the recursive grammar
    " NB: {} are also used because of C++1x lambdas
    let tpl = substitute(to_append, '[^<>(){}]\+', '', 'g')
    while strlen(tpl)
      let tpl2 = substitute(tpl, '<>\|()', '', 'g')
      if tpl == tpl2 | break | endif
      let tpl = tpl2
    endwhile
    if !strlen(tpl) " a complete parameter has been read
      " => append it to the result list 
      let lParameters += [ to_append ]
      let to_append = ''
    endif
  endfor

  return lParameters
endfunction

" This function will treat C & C++ cases => must recognize
" [/] arrays
" [ ] array-references
" [ ] function-pointers
" [X] templates
" [/] type
" [X] const
" [ ] in/out
" [X] pointer/reference
" [X] multiple tokens types (e.g. "unsigned long long int")
" [X] default value
" [X] new line before (when analysing non ctags-signatures, but real text)
" [/] TU
" [X] variadic parameter "..."
function! lh#dev#c#function#_analyse_parameter( param )
  let res = {}

  " Strip spaces
  let param = substitute(a:param, '\_s\+', ' ', 'g')
  " variadic ?
  if param == '...'
    let res.type    = 'va_list'
    let res.default = ''
    let res.name    = '...'
    return res
  endif
  " Extract default value
  if stridx(param, '=') != -1
    let [all, param, res.default ; rest] = matchlist(param, '^\s*\([^=]\{-}\)\s*=\s*\(.\{-}\)\s*$')
  else
    let param = matchstr(param, '^\s*\zs.\{-}\ze\s*$')
    let res.default = ''
  endif
  " Type
  let res.type = matchstr(param, '^\s*\zs.*\%(\ze\s\+\|[&*]\ze\s*\)\S\+')
  " Special case for arrays
  let array = match(param, '\[.*\]$')
  if array != -1
    let res.type .= param[array : -1]
    let param = param[0 : array-1]
  endif
  " Parameter name
  let res.name = matchstr(param, '^.*\%(\s\|[&*]\)\s*\zs\S\+')
  " New line before the parameter
  let res.nl = match(a:param, "^\\s*[\n\r]") >= 0
  " Result
  return res
endfunction

function! lh#dev#c#function#_type(variable_tag)
  " or should we split-open ?
  call lh#tags#jump(a:variable_tag)
  try 
    let line = getline('.')
    let sVariables = matchstr(line, '^\s*\zs[^;=]*\ze[;=]\=.*$')
    echo "l=".line."\n->".sVariables
    " may be not the best way to split stuff
    let lVariables = lh#dev#option#call('function#_split_list_of_parameters', &ft, sVariables)
    let i = lh#list#match(lVariables, '\<'.a:variable_tag.name.'\>')
    if i == -1
      throw "lh-dev is unable to parse ``".sVariables."'' to extract ``".(a:variable_tag.name)."'' definition."
    endif
    return lh#dev#c#function#_analyse_parameter(lVariables[i]).type
  finally
    pop
  endtry
endfunction

" [ ] arrays
" [ ] array-references
" [ ] function-pointers
" [X] templates
" [/] type
" [X] const
" [ ] in/out
" [X] pointer/reference
" [X] multiple tokens types (e.g. "unsigned long long int")
" [ ] default value
" [X] new line before (when analysing non ctags-signatures, but real text)
" [ ] TU
function! lh#dev#function#_build_param_decl(param)
  return a:param.type . ' ' . (a:param.dir =='out' ? '*' : '') .a:param.formal
endfunction

function! lh#dev#function#_build_param_call(param)
  return (a:param.dir =='out' ? '&' : '') .a:param.name
endfunction

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
