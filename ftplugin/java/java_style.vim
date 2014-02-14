"=============================================================================
" $Id$
" File:         ftplugin/java/java_style.vim                      {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      001
" Created:      14th Feb 2014
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       «description»
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/ftplugin/java
"       Requires Vim7+
"       «install details»
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:k_version = 1
" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_java_style")
      \ && (b:loaded_ftplug_java_style >= s:k_version)
      \ && !exists('g:force_reload_ftplug_java_style'))
  finish
endif
let b:loaded_ftplug_java_style = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Style definition {{{2

AddStyle { -ft {\n
AddStyle } -ft \n}

"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded_ftplug_java_style")
      \ && (g:loaded_ftplug_java_style >= s:k_version)
      \ && !exists('g:force_reload_ftplug_java_style'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_java_style = s:k_version
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
" Note: most filetype-global functions are best placed into
" autoload/«your-initials»/java/«java_style».vim
" Keep here only the functions are are required when the ftplugin is
" loaded, like functions that help building a vim-menu for this
" ftplugin.
" Functions }}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
