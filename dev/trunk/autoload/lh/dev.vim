"=============================================================================
" $Id$
" File:         autoload/lh/dev.vim                               {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      0.0.2
" Created:      28th May 2010
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       �description�
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/autoload/lh
"       Requires Vim7+
"       �install details�
" History:      
" 	v0.0.2: + lh#dev#*_comments()
"		+ ways to extract local variables
"		- lh#dev#_end_func fixed cursor movements
" TODO:         �missing features�
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
let s:k_version = 002
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

" # Find the function that starts before {line}, and finish after. {{{2
" @todo: check monoline functions
function! lh#dev#find_function_boundaries(line)
  try 
    let lTags = lh#dev#start_tag_session()
    if empty(lTags)
      throw "No tags found, cannot find function boundaries around line ".a:line
    endif

    " 1- find the last occurrence of "function" before the line
    let lFunctions = filter(copy(lTags), 'v:val.kind=="f"')
    let crt_function = lh#list#Find_if(lFunctions, 'v:val.line > '.a:line)
    if crt_function == -1
      throw "No known function around line ".a:line." in ctags base"
    endif
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

" # lh#dev#get_variables(function_boundaries [, split points ...]) {{{2
let c_ctags_understands_local_variables_in_one_pass = 0
let cpp_ctags_understands_local_variables_in_one_pass = 0
function! lh#dev#get_variables(function_boundaries, ...)
  let lVariables = lh#dev#option#call('function#_local_variables', &ft, a:function_boundaries)

  " split at given split-points
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
endfunction

"- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
" # Tags sessions {{{2
let s:tags = {
      \ 'tags': [],
      \ 'count': 0
      \ }
function! lh#dev#start_tag_session()
  if s:tags.count < 0
    let s:tags.count = 0
  endif
  let s:tags.count += 1
  if s:tags.count == 1
    let s:tags.tags = lh#dev#__BuildCrtBufferCtags()
  endif
  return s:tags.tags
endfunction

function! lh#dev#end_tag_session()
  let s:tags.count -= 1
  if s:tags.count == 0
    let s:tags.tags = []
  endif
endfunction

" # lh#dev#purge_comments(line, is_continuing_comment [, ft]) {{{2
" @return [fixed_line, is_continuing_comment]
function! lh#dev#purge_comments(line, is_continuing_comment, ...)
  let ft = (a:0 > 0) ? (a:1) : &ft
  let line = a:line
  let open_comment  = escape(lh#dev#option#call('_open_comment', ft), '*\[')
  let close_comment = escape(lh#dev#option#call('_close_comment', ft), '*\[')
  let line_comment  = escape(lh#dev#option#call('_line_comment', ft), '*\[')
  " purge remaining comment from a previous line
  if a:is_continuing_comment
    " assert(!empty(close_comment))
    if empty(close_comment) || -1 == match(line, close_comment)
      return ["", 1]
    else
      " todo: use p
      let line = substitute(line, '.\{-}'.close_comment, '', '')
    endif
  endif
  " purge line comment (// in C++, # in perl, ...)
  if !empty(line_comment)
    let line = substitute(line, line_comment.'.*', '', '')
  endif
  " purge "zone" comment (/**/ in C, ...)
  let is_continuing_comment = 0
  if !empty(open_comment)
    let line = substitute(line, open_comment.'.\{-}'.close_comment, '', 'g')
    let p = match(line, open_comment)
    if -1 != p
      let line = line[0:p-1]
      let is_continuing_comment = 1
    endif
  endif
  return [line, is_continuing_comment]
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1
if !exists('s:temp_tags')
  let s:temp_tags = tempname()
  " let &tags .= ','.s:temp_tags
endif

" # lh#dev#__BuildCrtBufferCtags(...) {{{2
function! lh#dev#__BuildCrtBufferCtags(...)
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
    " todo: corriger le path car inject� par d�faut...
    let source_name    = expand('%:p')
    " let source_name    = lh#path#relative_to(ctags_dirname, expand('%:p'))
  endif
  let ctags_pathname = s:temp_tags

  let cmd_line = lh#tags#cmd_line(ctags_pathname)
  let cmd_line = substitute(cmd_line, '--fields=\S\+', '&n', '') " inject line numbers in fields
  let cmd_line = substitute(cmd_line, '-kinds=\S\+\zsp', '', '') " remove prototypes, todo: ft-specific
  if a:0>0 || lh#dev#option#get('ctags_understands_local_variables_in_one_pass', &ft, 1)
    if stridx(cmd_line, '-kinds=') != -1
    let cmd_line = substitute(cmd_line, '-kinds=\S\+', '&l', '') " inject local variable, todo: ft-specific
    else
      let cmd_line .= ' ' . &ft . '-kinds=lv'
    endif
  endif
  let cmd_line .= ' ' . shellescape(source_name)
  if filereadable(s:temp_tags)
    call delete(s:temp_tags)
  endif
  call s:Verbose(cmd_line)
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

" # s:EvalLines(list) {{{2
function! s:EvalLines(list)
  for t in a:list
    if !has_key(t, 'line') " sometimes, VimL declarations are badly understood
      let fields = split(t.cmd)
      for field in fields
	if field =~ '^\k\+:'
	  let [all, key, value; rest ] = matchlist(field, '^\(\k\+\):\(.*\)')
	  let t[key] = value
	elseif field =~ '^.$'
	  let t.kind = field
	elseif field =~ '/.*/";'
	  let t.cmd = field
	endif
      endfor
      let t.file = fields[0]
    endif
    " and do evaluate the line eventually
    let t.line = eval(t.line)
    unlet t.filename
  endfor
endfunction

" # lh#dev#_sort_lines(t1, t2) {{{2
function! lh#dev#_sort_lines(t1, t2)
  let l1 = a:t1.line
  let l2 = a:t2.line
  return    l1 == l2 ? 0
	\ : l1 >  l2 ? 1
	\ :           -1
endfunction

" # internal: matchit solution to find end of function {{{2
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
    let l = search(start_pat, 'nW')
    let line = getline(l)
    let c = match(line, start_pat) " todo: check in utf-8
    " this keepjumps seems useless
    keepjumps exe l.'normal! 0'.c.'l'
    " assert l < next func start
    " use matchit g%, to cycle backward => jump to the end of the function from
    " the beginning, avoiding any return instruction on the way
    keepjumps normal g%
    return getpos('.')
  finally
    keepjumps call setpos('.', pos0)
  endtry
endfunction

" # Comments related functions {{{2
" @move to lh/dev/comments/
" # lh#dev#_open_comment() {{{3
" @todo cache the results until :source that clear the table
function! lh#dev#_open_comment()
  " default asks to
  " - EnhancedCommentify
  if exists('b:ECcommentOpen') && exists('b:ECcommentClose') && !empty(b:ECcommentClose)
    return b:ECcommentOpen
  endif
  " - tComment
  " - NERDCommenter
  " - &commentstring
  if !empty(&commentstring) && &commentstring =~ '.\+%s.\+'
    return matchstr(&commentstring, '.*\ze%s')
  endif
  return ""
endfunction

" # lh#dev#_close_comment() {{{3
" @todo cache the results until :source that clear the table
function! lh#dev#_close_comment()
  " default asks to
  " - EnhancedCommentify
  if exists('b:ECcommentClose') && !empty(b:ECcommentClose)
    return b:ECcommentClose
  endif
  " - tComment
  " - NERDCommenter
  " - &commentstring
  if !empty(&commentstring) && &commentstring =~ '.\+%s.\+'
    return matchstr(&commentstring, '.*%s\zs.*')
  endif
  return ""
endfunction

" # lh#dev#_line_comment() {{{3
" @todo cache the results until :source that clear the table
function! lh#dev#_line_comment()
  " default asks to
  " - EnhancedCommentify
  if exists('b:ECcommentOpen') && (!exists('b:ECcommentClose') || empty(b:ECcommentClose))
    return b:ECcommentOpen
  endif
  " - tComment
  " - NERDCommenter
  " - &commentstring
  if !empty(&commentstring) && &commentstring =~ '.\+%s$'
    return matchstr(&commentstring, '.*%s\zs.*')
  endif
  return ""
endfunction

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
