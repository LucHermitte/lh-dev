"=============================================================================
" $Id$
" File:         autoload/lh/dev.vim                               {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      0.0.1
" Created:      28th May 2010
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       «description»
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/autoload/lh
"       Requires Vim7+
"       «install details»
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
let s:k_version = 001
function! lh#dev#version()
  return s:k_version
endfunction

" # Debug {{{2
let s:verbose = 0
function! lh#dev#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#dev#debug(expr)
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
" ## Exported functions {{{1


" because C&C++ b:match_words have (:) before {:} =>
let c_function_start_pat = '{'
let cpp_function_start_pat = '{'

" Find the function that starts before {line}, and finish after.
" @todo: check monoline functions
function! lh#dev#find_function_boudaries(line)
  try 
    let lTags = lh#dev#start_tag_session()

    " 1- find the last occurrence of "function" before the line
    let lFunctions = filter(copy(lTags), 'v:val.kind=="f"')
    let crt_function = lh#list#Find_if(lFunctions, 'v:val.line > '.a:line)
    " Assert crt_function != -1
    let crt_function -= 1
    let first_line = lFunctions[crt_function].line

    " 2- find where the function ends
    " 2.1- get the hook that find the end of a function ; default hook is based
    " on matchit , we may also want to play with tags kinds
    let end_func_hook_name = lh#dev#option#get('end_func_hook_name', &ft, 'lh#dev#_end_func')
    let hook_str = end_func_hook_name.'('.first_line.')'
    " 2.2- execute the hook => last line
    let last_line = eval(hook_str)
    "
    let fun = {'lines': [first_line, last_line[1]], 'fn':lFunctions[crt_function]}
    return fun
  finally
    call lh#dev#end_tag_session()
  endtry
endfunction

" lh#dev#get_variables(function_boundaries [, split points ...])
let c_ctags_understands_local_variables_in_one_pass = 0
let cpp_ctags_understands_local_variables_in_one_pass = 0
function! lh#dev#get_variables(function_boundaries, ...)
  try 
    let lTags = lh#dev#start_tag_session()
    if ! lh#dev#option#get('ctags_understands_local_variables_in_one_pass', &ft, 1)
      let lTags = copy(s:BuildCrtBufferCtags(a:function_boundaries))
    endif

    let var_kind = lh#dev#option#get('variable_kind', &ft, '[vl]')

    let cond = 'v:val.kind =~ '.string(var_kind)
    if lh#dev#option#get('ctags_understands_local_variables_in_one_pass', &ft, 1)
      let cond .=
            \   ' && v:val.line>='. a:function_boundaries[0]
            \ . ' && v:val.line<='. a:function_boundaries[1]
    else
      call AddOffset(lTags, a:function_boundaries[0] - 1)
    endif
    call s:Verbose(cond)
    let lVariables = filter(copy(lTags), cond)

    " split at given split points
    let res = []
    let crt_list = []
    let split_point = 0
    for v in lVariables
      if split_point < a:0 && v.line >= a:000[split_point]
        call add(res, crt_list)
        let crt_list = []
        let split_point += 1
      endif
      call add(crt_list, v)
    endfor
    call add(res, crt_list)
    let res += repeat([[]], a:0 - split_point)

    return res
  finally
    call lh#dev#end_tag_session()
  endtry
endfunction

"- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
let s:tags = {
      \ 'tags': [],
      \ 'count': 0
      \ }
function! lh#dev#start_tag_session()
  if s:tags.count == 0
    let s:tags.tags = s:BuildCrtBufferCtags()
  endif
  let s:tags.count += 1
  return s:tags.tags
endfunction

function! lh#dev#end_tag_session()
  let s:tags.count -= 1
  if s:tags.count == 0
    let s:tags.tags = []
  endif
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1
function! AddOffset(lTags, function_start)
  for tt in a:lTags
    let tt.line += a:function_start
  endfor
endfunction

if !exists('s:temp_tags')
  let s:temp_tags = tempname()
  " let &tags .= ','.s:temp_tags
endif

function! s:BuildCrtBufferCtags(...)
  " let temp_tags = tempname()
  let ctags_dirname = fnamemodify(s:temp_tags, ':h')

  if &modified || a:0 > 0
    if a:0 > 0
      let s = a:1[0]
      let e = a:1[1]
    else
      let s = 1
      let e = '$'
    endif
    let source_name = tempname()
    call writefile(getline(s, e), source_name, 'b')
  else
    " todo: corriger le path car injecté par défaut...
    let source_name    = expand('%:p')
    " let source_name    = lh#path#relative_to(ctags_dirname, expand('%:p'))
  endif
  let ctags_pathname = s:temp_tags

  let cmd_line = lh#tags#cmd_line(ctags_pathname)
  let cmd_line = substitute(cmd_line, '--fields=\S\+', '&n', '') " inject line numbers in fields
  let cmd_line = substitute(cmd_line, '-kinds=\S\+\zsp', '', '') " remove prototypes, todo: ft-specific
  if a:0>0 || lh#dev#option#get('ctags_understands_local_variables_in_one_pass', &ft, 1)
    let cmd_line = substitute(cmd_line, '-kinds=\S\+', '&l', '') " inject local variable, todo: ft-specific
  endif
  let cmd_line .= ' ' . source_name
  call s:Verbose(cmd_line)
  if filereadable(s:temp_tags)
    call delete(s:temp_tags)
  endif
  call system(cmd_line)

  try 
    let tags_save = &tags
    let &tags = s:temp_tags
    let lTags = taglist('.')
  finally
    let &tags = tags_save
    if lh#dev#verbose() < 2
      call delete(s:temp_tags)
    else
      let b = bufwinnr('%')
      call lh#buffer#jump(s:temp_tags, "sp")
      exe b.'wincmd w'
    endif
  endtry
  call s:EvalLines(lTags)
  call sort(lTags, function('lh#dev#_sort_lines'))
  return lTags
endfunction

function! s:EvalLines(list)
  for t in a:list
    let t.line = eval(t.line)
    unlet t.filename
  endfor
endfunction

function! lh#dev#_sort_lines(t1, t2)
  let l1 = a:t1.line
  let l2 = a:t2.line
  return    l1 == l2 ? 0
	\ : l1 >  l2 ? 1
	\ :           -1
endfunction

" internal: matchit solution to find end of function
function! lh#dev#_end_func(line)
  try 
    let pos0 = getpos('.')
    :exe a:line
    let start_pat = lh#dev#option#get('function_start_pat', &ft, '')
    if empty(start_pat)
      let starts = split(b:match_words, ',')
      call map(starts, 'matchstr(v:val, "[^:]*")')
      let start_pat = join(starts, '\|')
    endif
    let l = search(start_pat, 'n')
    " this keepjumps seems useless
    keepjumps exe l
    " assert l < next func start
    " use matchit %
    keepjumps normal %
    return getpos('.')
  finally
    keepjumps call setpos('.', pos0)
  endtry
endfunction


"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
