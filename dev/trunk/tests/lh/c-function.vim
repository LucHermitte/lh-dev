"=============================================================================
" $Id$
" File:         tests/lh/c-function.vim                           {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      001
" Created:      24th Apr 2012
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       Unit tests for lh#dev#c#function#*()
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/tests/lh
"       Requires Vim7+, lh-dev, lh-UT
"       And run :UTRun tests/lh/c-function.vim
" History:      «history»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
UTSuite [lh-dev] Testing lh#dev#c#function functions

runtime autoload/lh/dev/c/function.vim
"------------------------------------------------------------------------
function! s:Test_analyse_param()
  Assert lh#dev#c#function#_analyse_parameter('unsigned long long int v') == {"nl":0, "default": "", "type": 'unsigned long long int', 'name': 'v'}
  Assert lh#dev#c#function#_analyse_parameter('unsigned const* v') == {"nl":0, "default": "", "type": 'unsigned const*', 'name': 'v'}
  Assert lh#dev#c#function#_analyse_parameter('unsigned const*& v') == {"nl":0, "default": "", "type": 'unsigned const*&', 'name': 'v'}
  Assert lh#dev#c#function#_analyse_parameter('unsigned const* const* v') == {"nl":0, "default": "", "type": 'unsigned const* const*', 'name': 'v'}
  Assert lh#dev#c#function#_analyse_parameter('unsigned') == {"nl":0, "default": "", "type": 'unsigned', 'name': ''}
  Assert lh#dev#c#function#_analyse_parameter('int t[42]') == {"nl":0, "default": "", "type": 'int[42]', 'name': 't'}
  Assert lh#dev#c#function#_analyse_parameter('v<T> :: type') == {"nl":0, "default": "", "type": 'v<T> :: type', 'name': ''}
  Assert lh#dev#c#function#_analyse_parameter('v<T> :: type v') == {"nl":0, "default": "", "type": 'v<T> :: type', 'name': 'v'}
endfunction

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
